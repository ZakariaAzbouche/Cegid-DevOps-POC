@isTest
public class TH_Account_TEST {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    static User salesUser = new UTIL_TestFactory.UserFactory().createUserCegidSales(); 
    /***BCR W-001709 ***/
    @isTest static void checkAdminComplianceTest() {

        List<Schema.PicklistEntry> accountBilCountCodeFieldValue = Schema.SObjectType.Account.fields.BillingCountryCode.getPicklistValues();

        List<Account> accs = new List<Account>();

        Account acc; 
        for(Schema.PicklistEntry pe : accountBilCountCodeFieldValue) {
            acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.BillingCountryCode = pe.getValue();
            acc.ERP_Number__c = 'TESTERP';
            acc.Phone = '0143434543';
            acc.BillingStreet = 'Rue du Test';
            acc.BillingPostalCode = '69007';
            acc.BillingCity = 'LYON';
            acc.Status__c = 'Validated';
            acc.National_Id__c = '32345545656767';
            acc.IntercommunityVATnumber__c = 'Test';
            acc.Tech_Contact_Direct__c = true;
            
            if(acc.BillingCountryCode == 'FR') {

                acc.National_Id__c = '';

            } else if (acc.BillingCountryCode == 'GP') {

                acc.IntercommunityVATnumber__c = '';

            } else if(acc.BillingCountryCode == 'MC') {
                //accs.add(acc.clone(false, false, false, false));

                acc.National_Id__c = '';
                acc.IntercommunityVATnumber__c = '';

            } else if(acc.BillingCountryCode == 'SE') {

                acc.IntercommunityVATnumber__c = '';

            } else if(acc.BillingCountryCode == 'DK') {
                acc.Tech_Contact_Direct__c = false;
            }
 
           
            accs.add(acc);
        }

        
		System.debug('ACCS SIZE :'+ accs.size());

        Test.startTest();
            TH_Account thAcc = new TH_Account();

            thAcc.checkAdminCompliance(accs);
        Test.stopTest();
        
        Integer success = 0;
        for(Account acc1 : accs) {
            if(acc1.TECH_Administrative_Compliance__c == true) {
                success++;
            }
        }

        System.assertEquals(accs.size() - 4, success, 'incorrect number of sucess');
    }
    /***FIN BCR W-001709 ***/     
    
    /***BCR W-001705 ***/
    
    @isTest static void checkAccPermissionUpdate() {
        List<Account> accs = new List<Account>();
        Account acc; 
        for(Integer i = 0; i < 5; i++) {
            acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.National_Id__c = '3234554565676'+i;
            acc.BillingCountryCode = 'FR';
            acc.ERP_Number__c = 'TESTER'+i;
            acc.Phone = '0143434543';
            acc.BillingStreet = 'Rue du Test'+i;
            acc.BillingPostalCode = '69007';
            acc.BillingCity = 'LYON'+i;
            acc.IntercommunityVATnumber__c = 'TESTVAT';
            acc.Siren_Siret__c = '';
            accs.add(acc);
        }

        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
    
        insert salesUser;

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5];
        UserTerritory2Association usrTerrAsso = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=allOrgTerritories[2].Id);

        System.runAs(adminUser) {
            insert bypass;
            insert accs;
            insert usrTerrAsso;
        }

        List<Account> existingAccs = [SELECT Id, Name, BillingStreet FROM Account];
        System.debug('Existing' + existingAccs);
        existingAccs[0].BillingStreet = 'TestModify';
        existingAccs[1].BillingStreet = 'TestModify';
        existingAccs[1].OwnerId = salesUser.Id;
        List<Database.SaveResult> results;
        CheckRecursivCall.alreadySeenRecords.clear();
        Test.startTest();
        System.runAs(salesUser) {
            results = Database.update(existingAccs, false);   
        }  
        Test.stopTest();
        System.debug(results);
    }
    /*** FIN BCR W-001705 */

    /**Coverage existing class BCR */
    @isTest static void afterInsertTest() {
        List<Account> accs = new List<Account>();
        Account acc; 
        for(Integer i = 5; i < 10; i++) {
            acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.National_Id__c = '3234554565676'+i;
            acc.BillingCountryCode = 'FR';
            acc.ERP_Number__c = 'TESTER'+i;
            acc.Phone = '0143434543';
            acc.BillingStreet = 'Rue du Test'+i;
            acc.BillingPostalCode = '69007';
            acc.BillingCity = 'LYON'+i;
            acc.IntercommunityVATnumber__c = 'TESTVAT';
            acc.Siren_Siret__c = '';
            accs.add(acc);
        }

        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
        System.runAs(adminUser) {
            insert bypass;
        }
        List<Database.SaveResult> results;
        Test.startTest();
        System.runAs(adminUser) {
            results = Database.insert(accs, false);    
        }  
        Test.stopTest();
        System.debug(results);
    }

    /**FIN Coverage existing class BCR */
    @isTest static void extractSObjectTerritoryHierarchyTest() {
        List<Account> accs = new List<Account>();
        Account acc; 
        for(Integer i = 50; i < 100; i++) {
            acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.National_Id__c = '3234554565676'+i;
            acc.BillingCountryCode = 'FR';
            acc.ERP_Number__c = 'TESTER'+i;
            acc.Phone = '0143434543';
            acc.BillingStreet = 'Rue du Test'+i;
            acc.BillingPostalCode = '69007';
            acc.BillingCity = 'LYON'+i;
            acc.IntercommunityVATnumber__c = 'TESTVAT';
            acc.Siren_Siret__c = '';
            accs.add(acc);
        }

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5 ];
        List<ObjectTerritory2Association> sObjsTerrAssos = new List<ObjectTerritory2Association>();

        
        System.runAs(adminUser) {
            
            insert accs;
        }

        for(Integer i = 0; i < 20; i++) {
            sObjsTerrAssos.add(new ObjectTerritory2Association(ObjectId = accs[i].Id, Territory2Id=allOrgTerritories[0].Id, AssociationCause='Territory2Manual'));
            sObjsTerrAssos.add(new ObjectTerritory2Association(ObjectId = accs[i].Id, Territory2Id=allOrgTerritories[1].Id, AssociationCause='Territory2Manual'));
        }
        for(Integer i = 20; i < 30; i++) {
            sObjsTerrAssos.add(new ObjectTerritory2Association(ObjectId = accs[i].Id, Territory2Id=allOrgTerritories[2].Id, AssociationCause='Territory2Manual'));
            sObjsTerrAssos.add(new ObjectTerritory2Association(ObjectId = accs[i].Id, Territory2Id=allOrgTerritories[3].Id, AssociationCause='Territory2Manual'));
        }
        for(Integer i = 30; i < 40; i++) {
            sObjsTerrAssos.add(new ObjectTerritory2Association(ObjectId = accs[i].Id, Territory2Id=allOrgTerritories[4].Id, AssociationCause='Territory2Manual'));
            
        }

        System.runAs(adminUser) {
            insert sObjsTerrAssos;
        }

        Test.startTest();
            Map<Id, Account> accsMap = new Map<Id, Account>([SELECT Id FROM Account]);
            Map<Id, Set<Id>> results =  new TH_Account().extractSObjectTerritoryHierarchy(accsMap.keySet());
            System.debug(results);
        Test.stopTest();

        System.assertEquals(40, results.size(), 'Map Size should be 40');

    }

    @isTest static void testIsAccountOwnerInRightTerritory() {
        List<Account> accs = new List<Account>();
        Account acc; 
        for(Integer i = 0; i < 5; i++) {
            acc = new UTIL_TestFactory.AccountFactory().createAccount();
            acc.National_Id__c = '3234554565676'+i;
            acc.BillingCountryCode = 'FR';
            acc.ERP_Number__c = 'TESTER'+i;
            acc.Phone = '0143434543';
            acc.BillingStreet = 'Rue du Test'+i;
            acc.BillingPostalCode = '69007';
            acc.BillingCity = 'LYON'+i;
            acc.IntercommunityVATnumber__c = 'TESTVAT';
            acc.Siren_Siret__c = '';
            accs.add(acc);
        }

        System.runAs(adminUser) {
            
            insert accs;
        }

        System.runAs(adminUser){  
              
            Map<Id, Account> accMap = new Map<Id, Account>([select id,Name from Account]);  
            
            // Perform test
            Test.startTest();  
            TH_Account.IsAccountOwnerInRightTerritory(accMap.keySet());             
            Test.stopTest();
            //System.assert(result.isSuccess());
        }
    }              
}