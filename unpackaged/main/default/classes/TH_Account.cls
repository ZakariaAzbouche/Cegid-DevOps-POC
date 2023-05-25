/**
 * @File Name          : TH_Account
 * @Description        : Update Account Values with territory  
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    30/10/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
 * 1.5    16/09/2021         BCR              add checkAccPermissionUpdate method
 * ---    -----------       -------           ------------------------ 
**/

public without sharing class TH_Account extends TriggerHandler {

    /***BCR W-001709 ***/
    public override void beforeInsert() {
        System.debug('TH_Account beforeInsert');
        checkAdminCompliance(Trigger.new);
        emailEbilingManage(Trigger.new);
        System.debug('End TH_Account beforeInsert');
    }
    /***FIN BCR W-001709 ***/ 
    
    /**
* @author
* @date
* @description Handler Method for before Update Event
* @return void
*/
    public override void beforeUpdate() {
        system.debug('TH_Account beforeUpdate');
        Map<Id, Account> accsToBeProcess = (Map<Id, Account>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.BEFORE_UPDATE);
        
        if(accsToBeProcess.isEmpty()) {//Control recursiv call from trigger
            System.debug('No Acc to be processed');
        } else {
            //All trigger logic should be here
            set<Id> setAccId = new set<Id>();
            List<Account> listAcc = new List<Account>();
            Map<Id,Id> mapAccountIdOwnerId = new Map<Id,Id>();
            
            for(Account acc: accsToBeProcess.values()){
                Account oldAcc = (Account)Trigger.oldMap.get(acc.Id);
                system.debug('accID before Update' + acc.Id);
                system.debug('acc.OwnerId'+acc.OwnerId);
                if(oldAcc.OwnerId != acc.OwnerId || (oldAcc.TECHFollowedByCodeToBeCalculated__c!= acc.TECHFollowedByCodeToBeCalculated__c && acc.TECHFollowedByCodeToBeCalculated__c)){
                    system.debug('Trigger Account');
                    listAcc.add(acc);
                    mapAccountIdOwnerId.put(acc.Id, acc.OwnerId);
                    acc.TECHFollowedByCodeToBeCalculated__c = false; // reset flag
                }
            } 
            system.debug('mapAccountIdOwnerId'+mapAccountIdOwnerId);
            if(listAcc.size()>0){
                //SM001_Account.setAccountTerritoryCode(listAcc);
                SM001_Account.setAccountTerritoryCode(listAcc, mapAccountIdOwnerId);
            }
            checkAccPermissionUpdate(accsToBeProcess.values());
            checkAdminCompliance(accsToBeProcess.values());
            emailEbilingManage(accsToBeProcess.values());
            setIndustryCode(accsToBeProcess.values(), (Map<Id, Account>)Trigger.oldMap);
        }
        
        system.debug('TH_Account End beforeUpdate');
    }

    

	// US 2273
    // Insert Defautl IndustryCode - Lead Qualification
    private void setIndustryCode(List<Account> accs, Map<Id, Account> oldMap) {

        Map<String, List<Id>> mapIndustryToAccounts = new Map<String, List<Id>>();

        List<Account> accsUpdate = new List<Account>();

        System.debug(accs);

        for(Account acc: accs) {
            Account oldAcc = oldMap.get(acc.Id);

            if(acc.Industry != null && acc.Industry != oldAcc.Industry) {
                if(mapIndustryToAccounts.containsKey(acc.Industry)) {
                    List<Id> lstTmp = mapIndustryToAccounts.get(acc.Industry);
                    lstTmp.add(acc.Id);
                    mapIndustryToAccounts.put(acc.Industry, lstTmp);
                } else {
                    mapIndustryToAccounts.put(acc.Industry, new List<Id>{acc.Id});
                }
				accsUpdate.add(acc);
            }
        }

        System.debug(mapIndustryToAccounts);

        Map<String, Id> mapIndsNameToId = new Map<String, Id>();
        List<Industry__c> inds = [SELECT Id, Industry__c FROM Industry__c WHERE Default_NAF__c = true AND Industry__c IN :mapIndustryToAccounts.keySet()];
        
        System.debug(inds);

        for(Industry__c ind: inds) {
            mapIndsNameToId.put(ind.Industry__c, ind.Id);
        }

        System.debug(mapIndsNameToId);

        for(Account acc: accsUpdate) {
			System.debug(mapIndsNameToId.get(acc.Industry));
			acc.Industry_Code__c = mapIndsNameToId.get(acc.Industry);

			System.debug(acc);
        }

    }
    
    /**
     * 
     *
    public static Boolean check_Email_privilege_edition(List<Account> listNewValuesAccout, List<Account> listOldValuesAccout) {

        Id Curentuser =   UserInfo.getUserId();
       
        List<User> users = [ SELECT id, Profile.name  FROM user where id = UserInfo.getUserId() ];
        for (User user : users) {
            if ((user.Profile.Name =='System Administrator' ) || (user.Profile.Name =='Cegid Business Suppor' ))
            return true ;
        }

        for (Account newAccount : listNewValuesAccout) {
            if (newAccount.ReferentCode__c ==null || newAccount.SedentaryCode__c ==null) {
                return false ;
            }
           for (Account oldAccount : listOldValuesAccout) {
              if (newAccount.id != oldAccount.id )  continue ;
              if ((oldAccount.Email_e_Billing__c != null ) && ( oldAccount.Email_e_Billing__c <> newAccount.Email_e_Billing__c)) {
                  return false ;
              }
               
           }             
        }
        return true ;  
    }*/

    public override void beforeDelete() {
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        if(u.Profile.Name == 'CEGID Sales' || u.Profile.Name =='Cegid Sales Assistant' || u.Profile.Name == 'Cegid Telemarketing') {
            for(Account acc : (List<Account>) Trigger.old) {
                acc.addError('You don\'t have permission to delete Account');
            }
        }
    }

    public override void afterInsert() {
        system.debug('TH_Account afterInsert');        
        /** AZI W-001713**/
        if(System.IsBatch() == false && System.isFuture() == false) {        
            //IsAccountOwnerInRightTerritory(Trigger.newMap.keySet()); //B-1403 provisoire
        }
         /**BCR B-1570 start */
        Set<Id> accIds = new Set<Id>();
        List<Account> accs = new List<Account>();
        Map<Id,Id> mapAccountIdOwnerId = new Map<Id,Id>();
            
        for(Account acc: (List<Account>)Trigger.new){
            accIds.add(acc.Id);
            mapAccountIdOwnerId.put(acc.Id, acc.OwnerId);
        }
            
        accs = [SELECT Id, OwnerId, CodeFollowedBy__c, ReferentCode__c, SedentaryCode__c, TECHFollowedByCodeToBeCalculated__c FROM Account WHERE Id IN: accIds];
            
        system.debug('mapAccountIdOwnerId'+mapAccountIdOwnerId);
        if(accs.size() > 0) {
            SM001_Account.setAccountTerritoryCode(accs, mapAccountIdOwnerId);
            update accs;
        }
        
        /**BCR B-1570 end */
        system.debug('End TH_Account afterInsert');      
        /** End AZI W-001713**/
    }

    
    public override void afterUpdate() {
            
        
        System.debug('TH_Account afterUpdate');   
        Map<Id, Account> accsToBeProcess = (Map<Id, Account>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.AFTER_UPDATE);     
        /** AZI W-001713**/
        if(accsToBeProcess.isEmpty()) {//Control recursiv call from trigger
            System.debug('No Acc to be processed');
        } else {
            //All trigger logic should be here
            if(System.IsBatch() == false && System.isFuture() == false) {
            	//IsAccountOwnerInRightTerritory(accsToBeProcess.keySet()); //B-1403 provisoire
        	}

            if(isBypassed('TH_AccountbeforeUpdate')){
                return;
        	}

            set<Id> setAccountIds = new set<Id>();

            for(Account acc : accsToBeProcess.values()){
                Account oldAcc = (Account)Trigger.oldMap.get(acc.Id);

                if(acc.Amount_of_delay_0_1_month__c != oldAcc.Amount_of_delay_0_1_month__c || 
                acc.Amount_of_delay_1_month__c != oldAcc.Amount_of_delay_1_month__c ||
                acc.Amount_of_delay_3_months__c != oldAcc.Amount_of_delay_3_months__c ||
                acc.Amount_of_delay_6_months__c != oldAcc.Amount_of_delay_6_months__c ||
                acc.Amount_of_delay_12_months__c != oldAcc.Amount_of_delay_12_months__c || 
                acc.Amount_of_delay_over_24_months__c != oldAcc.Amount_of_delay_over_24_months__c ||
                acc.Total_Amount_of_delay__c != oldAcc.Total_Amount_of_delay__c || acc.Risk_Level__c != oldAcc.Risk_Level__c || acc.Nature__c != oldAcc.Nature__c            
                ) {
                    setAccountIds.add(acc.Id);
                }
            }

            if(setAccountIds.size()>0){
                SM004_QuoteService.rccApprovalCalculationFromAccount(setAccountIds);
            }

            bypass('TH_AccountbeforeUpdate');
        }
        
        /** End AZI W-001713**/
        System.debug('End TH_Account afterUpdate');        
    }

    /***BCR  W-001705 B-1344 ***/
    @TestVisible
    private void checkAccPermissionUpdate(List<Account> accs) {
        System.debug('checkAccPermission');
        User connectedUser = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
        
                                                           
       if((connectedUser.Profile.Name == 'CEGID Sales' || connectedUser.Profile.Name == 'CEGID Sales Assistant')) {
        List<PermissionSetAssignment> permissions = [SELECT Id,
                                                            PermissionSet.Name,
                                                            PermissionSet.ProfileId,
                                                            PermissionSet.Profile.Name,
                                                            AssigneeId, Assignee.Name 
                                                            FROM PermissionSetAssignment 
                                                            WHERE PermissionSet.Name = 'Sales_Ops'
                                                            AND AssigneeId =: connectedUser.Id];

           Set<Id> accIds = new Set<Id>();
           Set<Id> terrUserIds = new Set<Id>();
           Set<Id> accIdNoRestriction = new Set<Id>();

           for(Account acc: accs) {
               accIds.add(acc.Id); 
           }

           List<UserTerritory2Association> userTerritory2Associations = [SELECT Territory2Id FROM UserTerritory2Association WHERE UserId =: connectedUser.Id];
           
           if(!userTerritory2Associations.isEmpty()) {
                for(UserTerritory2Association usrTerrAsso : userTerritory2Associations) {
                    terrUserIds.add(usrTerrAsso.Territory2Id);
                }
                
                Map<Id, Set<Id>> accWithTerritoriesHieriarchy = extractSObjectTerritoryHierarchy(accIds);
    
                for(Id accId : accWithTerritoriesHieriarchy.keySet()) {
                    System.debug(accWithTerritoriesHieriarchy.get(accId));
                    System.debug(terrUserIds);
                    if(accWithTerritoriesHieriarchy.get(accId).removeAll(terrUserIds)) {
                        accIdNoRestriction.add(accId);  
                    }
                }
           }
           
           Integer nbFieldNotPassed;
           Map<String, Schema.SObjectField> fieldApiName = Schema.SObjectType.Account.fields.getMap();
           for(Account acc : accs) {
               nbFieldNotPassed = 0;
               if(acc.TECH_oppy_byPass_US1705__c) {

                acc.TECH_oppy_byPass_US1705__c = false;

               } else if(!accIdNoRestriction.contains(acc.Id) && Trigger.oldMap.get(acc.Id).get('OwnerId') != connectedUser.Id && acc.TECH_Lead_conversion__c == null) { //BCR US-1776
                    for(String field : fieldApiName.keySet())
                    { 
						if(!fieldApiName.get(field).getDescribe().isCalculated()) {
                            if(field !='Decision_center__c' &&
                               field !='ParentId' &&
                               field !='Parent_Account_Nature__c' &&
                               field !='DGE_Group__c' &&
                               field !='No_of_establishments__c' &&
                               field !='No_of_Subsidiaries__c' &&
                               field !='No_of_companies__c' &&
                               field !='Payslips_per_month__c' &&
                               field !='Phone' &&
                               field !='Website' &&
                               field !='Fiscal_Year_End_Month__c' &&
                               field !='Retail_Sector__c' &&
                               field !='No_of_Stores__c' &&
                               field !='Retail_Segmentation__c' &&
                               field !='RegisteredwiththeOrderofCharteredA__c' &&
                               field !='Yearofregistration__c' &&
                               field !='No_of_Folders__c' &&
                               field !='CPA_Sector__c' &&
                               field !='Maturity_Level__c' &&
                               field !='CPA_Number_of_users__c' &&
                               field !='Academy__c' &&
                               field !='School_Type__c' &&
                               field !='School_Level__c' &&
                               field !='To_Be_Deleted__c' &&
                               field !='National_ID__c' &&
                               field !='Email_e_Billing__c' &&
                               field !='AccountSource' &&
                               field !='Country_Scope__c' &&
                               field !='No_of_POS__c' &&
                               field !='Public_Administration__c' &&
                               field !='Customer_External_ID__c' &&
                               field !='Risk_of_Churn_Comment__c' &&
                               field !='Risk_of_Churn__c' &&
                               
                               //Technical Fields
                               field !='Infolegale_conn__Override_Account_Synchronisation_Rule__c' &&
                               field !='Infolegale_conn__Account_Synchronisation__c' &&
                               field !='TECH_NumberOfOpenOpties__c' &&
                               field !='Tech_Contact_Direct__c' &&
                               field !='Tech_Nb_Contact__c' &&
                               field !='CodeFollowedBy__c' &&
                               field !='ReferentCode__c' &&
                               acc.get(field) != Trigger.oldMap.get(acc.Id).get(field)) {
                                   if(!permissions.isEmpty()) {
                                       if(field != 'OwnerId' &&
                                          field != 'Mkto_account_owner_Role__c' &&
                                          field != 'Mkto_account_owner_job_title__c' &&
                                          field != 'Mkto_account_owner_Profile__c' &&
                                          field != 'Mkto_account_owner_Phone__c' &&
                                          field != 'sedentarycode__c' &&
                                          field !='Manual_Sync_TS__c') {
                                              nbFieldNotPassed++;
                                              system.debug('Field not passed '+field);
                                              system.debug('Old value '+Trigger.oldMap);
                                              system.debug('Old value '+Trigger.oldMap.get(acc.Id));
                                              system.debug('Old value '+Trigger.oldMap.get(acc.Id).get(field));
                                              system.debug('New value '+acc.get(field));
                                        }
                                    } else {
                                        nbFieldNotPassed++;
                                        system.debug('Field not passed '+field);
                                        system.debug('Old value '+Trigger.oldMap);
                                        system.debug('Old value '+Trigger.oldMap.get(acc.Id));
                                        system.debug('Old value '+Trigger.oldMap.get(acc.Id).get(field));
                                        system.debug('New value '+acc.get(field));
                                    }
                                }
                        }
                    }
						
					 
                    if(nbFieldNotPassed > 0) {
                        acc.addError(System.Label.VR_accountFieldsLocked);
                    }
               } else if (acc.TECH_Lead_conversion__c == 'true') { //BCR US-1776
                   System.debug('Lead conversion');
                   acc.TECH_Lead_conversion__c = null;
               }
           }
       }
    }

    public Map<Id, Set<Id>> extractSObjectTerritoryHierarchy(Set<Id> sobjIds) {
        //Extract all Territories
        Map<Id, Territory2> allOrgTerritories = new Map<Id, Territory2>([SELECT Id, ParentTerritory2Id, Name FROM Territory2 LIMIT 9800]);

        //Extract all account Territories associations
        List<ObjectTerritory2Association> sObjTerrAssos = [SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId IN: sobjIds];
        
         //Build result Map
        Map<Id, Set<Id>> mapSObjectTerritories = new Map<Id, Set<Id>>();
        //Extract all account Territories Id
        for(ObjectTerritory2Association sObjTerrAsso : sObjTerrAssos) {
            if(!mapSObjectTerritories.containsKey(sObjTerrAsso.ObjectId)) {
                mapSObjectTerritories.put(sObjTerrAsso.ObjectId, new Set<Id>());
            }
            mapSObjectTerritories.get(sObjTerrAsso.ObjectId).add(sObjTerrAsso.Territory2Id);
        }
       
        Territory2 tmp;
        for(Id SObjectId : mapSObjectTerritories.keySet()) {
            
            for(Id territoryId : mapSObjectTerritories.get(SObjectId)) {
                tmp = allOrgTerritories.get(territoryId);
                System.debug(tmp.Name);
                while (tmp.ParentTerritory2Id != null) {
                    tmp = allOrgTerritories.get(tmp.ParentTerritory2Id);
                    mapSObjectTerritories.get(SObjectId).add(tmp.Id);
                    System.debug(tmp.Name);
                }
            }
        }
        return mapSObjectTerritories;  
    }


    /***FIN BCR W-001705 B-1344 ***/ 

    /***BCR W-001709 ***/
    @TestVisible
    private void checkAdminCompliance(List<Account> accs) {
        for(Account acc : accs) {
            if(String.isBlank(acc.ERP_Number__c) || 
               String.isBlank(acc.Phone) ||
               String.isBlank(acc.BillingStreet) ||
               String.isBlank(acc.BillingPostalCode) ||
               String.isBlank(acc.BillingCity) ||
               !(acc.Status__c == 'Validated') ||
               !acc.Tech_Contact_Direct__c) {

                acc.TECH_Administrative_Compliance__c = false;
                
            } else if((acc.BillingCountryCode == 'FR') && 
                      (String.isBlank(acc.National_ID__c) ||
                       String.isBlank(acc.IntercommunityVATnumber__c))) {

                        acc.TECH_Administrative_Compliance__c = false;
        
            } else if(acc.BillingCountryCode == 'MC' &&
                      String.isBlank(acc.National_ID__c) &&
                      String.isBlank(acc.IntercommunityVATnumber__c) ) {
                          
                        acc.TECH_Administrative_Compliance__c = false;

            } else if ((acc.BillingCountryCode == 'BE' ||
                        acc.BillingCountryCode == 'ES' ||
                        acc.BillingCountryCode == 'PT' ||
                        acc.BillingCountryCode == 'IT' ||
                        acc.BillingCountryCode == 'DE' ||
                        acc.BillingCountryCode == 'GB' ||
                        acc.BillingCountryCode == 'AT' ||
                        acc.BillingCountryCode == 'BG' ||
                        acc.BillingCountryCode == 'CY' ||
                        acc.BillingCountryCode == 'HR' ||
                        acc.BillingCountryCode == 'DK' ||
                        acc.BillingCountryCode == 'EE' ||
                        acc.BillingCountryCode == 'FI' ||
                        acc.BillingCountryCode == 'GR' ||
                        acc.BillingCountryCode == 'HU' ||
                        acc.BillingCountryCode == 'IE' ||
                        acc.BillingCountryCode == 'LV' ||
                        acc.BillingCountryCode == 'LT' ||
                        acc.BillingCountryCode == 'LU' ||
                        acc.BillingCountryCode == 'MT' ||
                        acc.BillingCountryCode == 'NL' ||
                        acc.BillingCountryCode == 'PL' ||
                        acc.BillingCountryCode == 'CZ' ||
                        acc.BillingCountryCode == 'RO' ||
                        acc.BillingCountryCode == 'SK' ||
                        acc.BillingCountryCode == 'SI' ||
                        acc.BillingCountryCode == 'SE' ) &&
                        String.isBlank(acc.IntercommunityVATnumber__c )) {

                    acc.TECH_Administrative_Compliance__c = false;

            } else if(!(acc.BillingCountryCode == 'FR' ||
                        acc.BillingCountryCode == 'MC' ||
                        acc.BillingCountryCode == 'BE' ||
                        acc.BillingCountryCode == 'ES' ||
                        acc.BillingCountryCode == 'PT' ||
                        acc.BillingCountryCode == 'IT' ||
                        acc.BillingCountryCode == 'DE' ||
                        acc.BillingCountryCode == 'GB' ||
                        acc.BillingCountryCode == 'AT' ||
                        acc.BillingCountryCode == 'BG' ||
                        acc.BillingCountryCode == 'CY' ||
                        acc.BillingCountryCode == 'HR' ||
                        acc.BillingCountryCode == 'DK' ||
                        acc.BillingCountryCode == 'EE' ||
                        acc.BillingCountryCode == 'FI' ||
                        acc.BillingCountryCode == 'GR' ||
                        acc.BillingCountryCode == 'HU' ||
                        acc.BillingCountryCode == 'IE' ||
                        acc.BillingCountryCode == 'LV' ||
                        acc.BillingCountryCode == 'LT' ||
                        acc.BillingCountryCode == 'LU' ||
                        acc.BillingCountryCode == 'MT' ||
                        acc.BillingCountryCode == 'NL' ||
                        acc.BillingCountryCode == 'PL' ||
                        acc.BillingCountryCode == 'CZ' ||
                        acc.BillingCountryCode == 'RO' ||
                        acc.BillingCountryCode == 'SK' ||
                        acc.BillingCountryCode == 'SI' ||
                        acc.BillingCountryCode == 'SE' ) &&
                        String.isBlank(acc.National_ID__c)) {
                    
                        acc.TECH_Administrative_Compliance__c = false;
            } else {
                acc.TECH_Administrative_Compliance__c = true;
            }
                  
        }
        
    }
    /***FIN BCR W-001709 ***/

    @future //BCR B-1403
    public static void IsAccountOwnerInRightTerritory(Set<Id> accsId){ 
        system.debug('IsAccountOwnerInRightTerritory');   
        List<Account> accounts = [SELECT Id, Name, IsOwnerInRightTerritory__c, OwnerId FROM Account WHERE Id IN :accsId];
        
        List<Id> ownersId =  new List<Id>();
        List<Account> accsUpdated = new List<Account>();

        for (Account acc: accounts) {
            ownersId.add(acc.OwnerId);
            //break;
        }
               System.debug('IsAccountOwnerInRightTerritory ownersId ' + ownersId.size());   

               List<ObjectTerritory2Association> objectTerritory2AssociationList = 
                      [SELECT Territory2Id, ObjectId FROM  ObjectTerritory2Association  WHERE IsDeleted = false AND ObjectId in :accsId];

               System.debug('IsAccountOwnerInRightTerritory :: objectTerritory2AssociationList.size ' +objectTerritory2AssociationList.size() );

                List<UserTerritory2Association> usersTerr = 
                                   [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE isActive = true AND UserId in :ownersId];

                System.debug('IsAccountOwnerInRightTerritory :: usersTerr.size ' +usersTerr.size() );


                for (Account acc: accounts) {
                    boolean userFound  = false;
                    acc.IsOwnerInRightTerritory__c = true;
                    
                    for(ObjectTerritory2Association objectTerritory2Association: objectTerritory2AssociationList){
                        if(objectTerritory2Association.ObjectId.equals(acc.Id)){
                            for(UserTerritory2Association userTerr : usersTerr){                                    
                                if (userTerr.Territory2Id.equals(objectTerritory2Association.Territory2Id) && userTerr.UserId.equals(acc.OwnerId)){
                                    userFound = true;  
                                    break; 
                                }                                                                                                                 
                            } 
                        }                                                                         
                    }       
    
            System.debug('IsAccountOwnerInRightTerritory userFound  : ' + userFound+' For Account  : ' + acc.Name);   
                if(!userFound){
                   acc.IsOwnerInRightTerritory__c = false;                   
                }
                accsUpdated.add(acc);
            } 
            
            if(accsUpdated.size()>0){
                update accsUpdated;
            }                
            System.debug('IsAccountOwnerInRightTerritory');   
    }

    private void emailEbilingManage(List<Account> accs) {
        for(Account acc : accs) {
            if(acc.Invoice_Sending_Mode__c != 'Email') {
                acc.Email_e_Billing__c = null;
            }
        }
    }        
}