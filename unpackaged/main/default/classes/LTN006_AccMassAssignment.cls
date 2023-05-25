/**
* @author Jeetesh- Comforth
* @date 18/06/20
* @description Controller for LWC accMassAssignmentAccountList and accMassAssignmentFilters
*/
public with sharing class LTN006_AccMassAssignment {

    /**
    * @author Jeetesh- Comforth
    * @date 22/06/20
    * @description Retrieves list of filtered accounts
    * @param string strFilter, string strFilterAccExp, string strFilterAccCom, string strFilterAccCoreBus
    * @return list lstAcc
    */
    @AuraEnabled(cacheable=true)
    public static List<Account> getFilteredAccs(string strFilter, string strFilterAccExp, string strFilterAccCom, string strFilterAccCoreBus) {

        list<Account> lstAcc = new list<Account>();
        list<Account_Expertise__c> lstAccExp = new list<Account_Expertise__c>();
        list<Account_Competitor__c> lstAccCom = new list<Account_Competitor__c>();
        list<AccountCoreBusiness__c> lstAccCoreBus = new list<AccountCoreBusiness__c>();

        set<Id> setAccExpId = new set<Id>();
        set<Id> setAccComId = new set<Id>();
        set<Id> setAccCoreBusId = new set<Id>();

        string sQueryAccExp;
        string sQueryAccCom;
        string sQueryAccCoreBus;

        string queryLineAcc = '';
        string queryLineAccExp = '';
        string queryLineAccCom = '';
        string queryLineAccCoreBus = '';

        system.debug('##strFilter: ' + strFilter);
        system.debug('##strFilterAccExp: ' + strFilterAccExp);
        system.debug('##strFilterAccCom: ' + strFilterAccCom);
        system.debug('##strFilterAccCoreBus: ' + strFilterAccCoreBus);

        // Check Account query
        if(strFilter != ''){
            queryLineAcc = ' WHERE ' + strFilter;
        }
        
        system.debug('##queryLineAcc: ' + queryLineAcc);

        // Check Account Core Business query
        if(strFilterAccCoreBus != ''){
            sQueryAccCoreBus = 'SELECT AccountExpertise__c'
                            + ' FROM AccountCoreBusiness__c'
                            + ' WHERE '
                            + strFilterAccCoreBus;

            lstAccCoreBus = (List <AccountCoreBusiness__c>) Database.query(sQueryAccCoreBus);

            for(AccountCoreBusiness__c accCoreBus : lstAccCoreBus){
                setAccCoreBusId.add(accCoreBus.AccountExpertise__c);
            }
            
        	system.debug('##setAccCoreBusIdSize: ' + setAccCoreBusId.size());
            queryLineAccCoreBus = 'Id IN :setAccCoreBusId';
        }

        // Check Account Expertise query
        if(strFilterAccExp != '' || strFilterAccCoreBus != ''){

            if(strFilterAccExp != ''){
                sQueryAccExp = 'SELECT Account__c'
                                + ' FROM Account_Expertise__c'
                                + ' WHERE '
                                + strFilterAccExp;
    
                if(queryLineAccCoreBus != ''){
                    sQueryAccExp = sQueryAccExp
                                    + ' AND '
                                    + queryLineAccCoreBus;
                }
            }

            else if(strFilterAccExp == '' && queryLineAccCoreBus != ''){
                sQueryAccExp = 'SELECT Account__c'
                                + ' FROM Account_Expertise__c'
                                + ' WHERE '
                                + queryLineAccCoreBus;
            }
            
            system.debug('##sQueryAccExp: ' + sQueryAccExp);

            lstAccExp = (List <Account_Expertise__c>) Database.query(sQueryAccExp);

            for(Account_Expertise__c accExp : lstAccExp){
                setAccExpId.add(accExp.Account__c);
            }

            if(queryLineAcc == ''){
                queryLineAccExp = ' WHERE Id IN :setAccExpId';
            }

            else{
                queryLineAccExp = ' AND Id IN :setAccExpId';
            }

        }

        // Check Account Competitor query
        if(strFilterAccCom != ''){
            sQueryAccCom = 'SELECT Account__c'
                        + ' FROM Account_Competitor__c'
                        + ' WHERE '
                        + strFilterAccCom;

            lstAccCom = (List <Account_Competitor__c>) Database.query(sQueryAccCom);

            for(Account_Competitor__c accCom : lstAccCom){
                setAccComId.add(accCom.Account__c);
            }

            if(queryLineAcc == '' && queryLineAccExp == ''){
                queryLineAccCom = ' WHERE Id IN :setAccComId';
            }
            else{
                queryLineAccCom = ' AND Id IN :setAccComId';
            }
        }
        
        String sQuery = 'SELECT Id,'
                        + ' Name,'
                        + ' ERP_Number__c,'
                        + ' toLabel(Nature__c),'
                        + ' BillingPostalCode,'
                        + ' AnnualRevenue,'
                        + ' Risk_Level__c,'
                        + ' NumberOfEmployees,'
                        + ' No_of_Stores__c,'
                        + ' Retail_Segmentation__c,'
                        + ' Collaborative_Portal__c,'
                        + ' ( SELECT toLabel(Expertise__c) FROM Account_Expertises__r )'
                        + ' FROM Account'
                        + queryLineAcc
                        + queryLineAccExp
                        + queryLineAccCom
                        + ' ORDER BY Name ASC';

        lstAcc = (List <Account>) Database.query(sQuery);
        system.debug('##sQuery' + sQuery);

        return lstAcc;
    }

    /**
    * @author Jeetesh- Comforth
    * @date 30/06/20
    * @description Create PAC Accounts
    * @param List<String> accIds, String targetingPlan, String pacAccOwner
    * @return void
    */
    @AuraEnabled
    public static void createPacAccs(List<String> accIds, String targetingPlan, String pacAccOwner) {

        string splitStr;
        string msg;
        string tarAccErrId;
        set<Id> setAccIds = new set<Id>();
        list<Target_Accounts__c> listTargetAcc = new list<Target_Accounts__c>();
        Target_Accounts__c tarAccErr;
        
        system.debug('##accIds: ' + accIds);
		system.debug('##targetingPlan: ' + targetingPlan);
        
        // Remove / from list
        for(string s : accIds){
            string accId = s.remove('/');

            Target_Accounts__c targetAcc = new Target_Accounts__c(
                Account__c = accId,
                Targeting_Plan__c = targetingPlan,
                OwnerId = pacAccOwner
            );
            listTargetAcc.add(targetAcc);
        }

        if(listTargetAcc.size() > 0){
            try{
                insert listTargetAcc;
            }

            catch (DMLException e) {
                msg = string.valueOf(e.getDmlMessage(0));
                //system.debug('##msgId: ' + msg);

                if(msg.contains(Label.LBL_ErrorMsgDuplicateValueFound)){
                    tarAccErrId = msg.right(15);
                    system.debug('##tarAccErrId: ' + tarAccErrId);

                    tarAccErr = [SELECT Account__r.Name FROM Target_Accounts__c WHERE Id = :tarAccErrId];

                    throw new AuraHandledException(Label.LBL_ErrorMsgDuplicate + ' ' + tarAccErr.Account__r.Name);
                }
                else{
                    throw new AuraHandledException(Label.LBL_ErrorMsgOther + ' ' + e.getMessage());
                }
            }
        
            catch (Exception e) {
                throw new AuraHandledException(Label.LBL_ErrorMsgOther + ' ' + e.getMessage());
            }
        }
    }
}