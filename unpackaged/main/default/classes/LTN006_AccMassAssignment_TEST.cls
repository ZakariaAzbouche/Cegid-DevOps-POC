/**
* @author Jeetesh- Comforth
* @date 30/06/20
* @description Test class for LTN006_AccMassAssignment
*/
@isTest
private class LTN006_AccMassAssignment_TEST {
    
    static User adminUser;
    static list<Account> lstAcc;
    static list<Account_Expertise__c> lstAccExp;
    static list<Account_Competitor__c> lstAccCom;
    static list<AccountCoreBusiness__c> lstAccCoreBus;
    static Targeting_Plan__c tarPlan;
    
    static{
        adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
        
        System.runAs(adminUser){
            
            Integer nbBulkDataAcc=10, nbBulkDataAccExp=10, nbBulkDataAccCom=10;
            
            //1. Insert Account
            lstAcc = new list<Account>();
            for(Integer i=0;i< nbBulkDataAcc; i++){
                Account acc = new Account();
                acc.Name = 'Test Acc' + i;
                acc.ERP_Number__c = '9867196' + i;
                acc.Nature__c = 'PRO';
                acc.BillingStreet = 'Rue de la Victoire';
                acc.BillingCity = 'Paris';
                acc.BillingCountry ='France';
                acc.BillingPostalCode = '78000';
                lstAcc.add(acc);
            }
            insert lstAcc;
            system.debug('##lstAcc: '+ lstAcc);
            
            //2. Insert Account Expertise
            lstAccExp = new list<Account_Expertise__c>();
            for(Integer i=0;i< nbBulkDataAccExp; i++){
                Account_Expertise__c accExp = new Account_Expertise__c();
                accExp.Account__c = lstAcc[0].Id;
                accExp.Expertise__c = '110';
                lstAccExp.add(accExp);
            }
            insert lstAccExp;
            system.debug('##lstAccExp: '+ lstAccExp);
            
            //3. Insert Account Competitor
            lstAccCom = new list<Account_Competitor__c>();
            for(Integer i=0;i< nbBulkDataAccCom; i++){
                Account_Competitor__c accCom = new Account_Competitor__c();
                accCom.Account__c = lstAcc[0].Id;
                accCom.Core_Business__c = '110';
                lstAccCom.add(accCom);
            }
            insert lstAccCom;
            system.debug('##lstAccCom: '+ lstAccCom);
            
            //3. Insert Account Core Business
            lstAccCoreBus = new list<AccountCoreBusiness__c>();
            for(Integer i=0;i< nbBulkDataAccCom; i++){
                AccountCoreBusiness__c accCoreBus = new AccountCoreBusiness__c();
                accCoreBus.AccountExpertise__c = lstAccExp[0].Id;
                accCoreBus.CoreBusiness__c = '110';
                lstAccCoreBus.add(accCoreBus);
            }
            insert lstAccCoreBus;
            system.debug('##lstAccCoreBus: '+ lstAccCoreBus);
            
            //4. Insert Targeting Plan
            tarPlan = new Targeting_Plan__c();
            tarPlan.Name = 'Test TarPlan';
            tarPlan.Expertise__c = '110';
            tarPlan.Sales_Purpose__c = '613';
            tarPlan.Start_Date__c = system.today();
            tarPlan.End_Date__c = system.today() + 30;
            
            insert tarPlan;
            system.debug('##tarPlan: '+ tarPlan);
        }
    }
    
    /**
    * @author Jeetesh- Comforth
    * @date 30/06/20
    * @description Get filtered accounts
    */
    @isTest
    static void filteredAccs(){
        system.runAs(adminUser){
            
            list<Account> lstAccFiltered = new list<Account>();
            
            string strFilter = ' Nature__c IN ( \'PRO\' )';
            string strFilterAccExp = ' Expertise__c IN ( \'110\' )';
            string strFilterAccCom = ' Core_Business__c IN ( \'110\' )';
            string strFilterAccCoreBus = ' CoreBusiness__c IN ( \'110\' )';
            
            test.startTest();
            lstAccFiltered = LTN006_AccMassAssignment.getFilteredAccs(strFilter, strFilterAccExp, strFilterAccCom, strFilterAccCoreBus); 
            test.stopTest();
            
            system.assertEquals(1, lstAccFiltered.size(), 'Asserting that size of lstAccFiltered is 1');
        }
    }
    
    /**
    * @author Jeetesh- Comforth
    * @date 30/06/20
    * @description Get filtered accounts - string strFilter blank
    */
    @isTest
    static void accFilterBlank(){
        system.runAs(adminUser){
            
            list<Account> lstAccFiltered = new list<Account>();
            
            string strFilter = '';
            string strFilterAccExp = ' Expertise__c IN ( \'110\' )';
            string strFilterAccCom = ' Core_Business__c IN ( \'110\' )';
            string strFilterAccCoreBus = ' CoreBusiness__c IN ( \'110\' )';
            
            test.startTest();
            lstAccFiltered = LTN006_AccMassAssignment.getFilteredAccs(strFilter, strFilterAccExp, strFilterAccCom, strFilterAccCoreBus); 
            test.stopTest();
            
            system.assertEquals(1, lstAccFiltered.size(), 'Asserting that size of lstAccFiltered is 1');
        }
    }
    
    /**
    * @author Jeetesh- Comforth
    * @date 30/06/20
    * @description Get filtered accounts - strings strFilter and strFilterAccExp blank
    */
    @isTest
    static void accFilterAccExpBlank(){
        system.runAs(adminUser){
            
            list<Account> lstAccFiltered = new list<Account>();
            
            string strFilter = '';
            string strFilterAccExp = '';
            string strFilterAccCom = ' Core_Business__c IN ( \'110\' )';
            string strFilterAccCoreBus = ' CoreBusiness__c IN ( \'110\' )';
            
            test.startTest();
            lstAccFiltered = LTN006_AccMassAssignment.getFilteredAccs(strFilter, strFilterAccExp, strFilterAccCom, strFilterAccCoreBus); 
            test.stopTest();
            
            system.assertEquals(1, lstAccFiltered.size(), 'Asserting that size of lstAccFiltered is 1');
        }
    }
    
    /**
    * @author Jeetesh- Comforth
    * @date 30/06/20
    * @description Create PAC/Accounts
    */
    @isTest
    static void createPacAccs(){
        system.runAs(adminUser){
            
            list<String> accIds = new List<String>();
            string accId;
            
            for(Account acc : lstAcc){
                accId = acc.Id;
                accIds.add(accId);
            }
            
            test.startTest();
            LTN006_AccMassAssignment.createPacAccs(accIds, tarPlan.Id, adminUser.Id);
            test.stopTest();
            
            list<Target_Accounts__c> listTargetAcc = [Select Id From Target_Accounts__c];
                
            system.assertEquals(10, listTargetAcc.size(), 'Asserting that size of listTargetAcc is 10');
        }
    }
    
    /**
    * @author Jeetesh- Comforth
    * @date 03/07/20
    * @description Get DML Exception PAC/Accounts
    */
    @isTest
    static void errorPacAccs(){
        system.runAs(adminUser){
            
            list<String> accIds = new List<String>();
            string accId;
            
            for(Account acc : lstAcc){
                accId = acc.Id;
                accIds.add(accId);
            }
            
            LTN006_AccMassAssignment.createPacAccs(accIds, tarPlan.Id, adminUser.Id);
            
            test.startTest();
            
            try{
                 LTN006_AccMassAssignment.createPacAccs(accIds, tarPlan.Id, adminUser.Id);     
            }
            
            catch(Exception e){
                system.debug('##e: ' + e.getMessage());
            }
            
            test.stopTest();
            
            list<Target_Accounts__c> listTargetAcc = [Select Id From Target_Accounts__c];
                
            system.assertEquals(10, listTargetAcc.size(), 'Asserting that size of listTargetAcc is 10, thus no more Target Accounts have been created');
        }
    }
}