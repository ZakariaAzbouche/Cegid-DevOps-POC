@isTest
public  class Customer_ReferenceTrigger_Test {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    static User salesUser = new UTIL_TestFactory.UserFactory().createUserCegidSales(); 

    @isTest static void beforeInsertTest() {

        List<Schema.PicklistEntry> accountBilCountCodeFieldValue = Schema.SObjectType.Account.fields.BillingCountryCode.getPicklistValues();
        Account acc;
        acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = 'TESTERP';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.Status__c = 'Validated';
        acc.National_Id__c = '32345545656767';
        acc.IntercommunityVATnumber__c = 'Test';
        acc.Tech_Contact_Direct__c = true;

        insert salesUser;

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5];
        UserTerritory2Association usrTerrAsso = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=allOrgTerritories[2].Id);
        

        System.runAs(adminUser) {
            insert acc;
            insert usrTerrAsso;
        }

        ObjectTerritory2Association objTerrAsso = new ObjectTerritory2Association(AssociationCause = 'Territory2Manual', ObjectId = acc.Id, Territory2Id=allOrgTerritories[2].Id);

        System.runAs(adminUser) {
            insert objTerrAsso;
        }

        List<Customer_Reference__c> crs = new List<Customer_Reference__c>();

        

        for(Integer i = 0; i < 30; i++) {
            crs.add(new Customer_Reference__c(Account__c = acc.Id));
        }

        List<Database.SaveResult> results;
        Test.startTest();
        System.runAs(salesUser) {
            results = Database.insert(crs, false);
        }
               
        Test.stopTest();
    }

    @isTest static void beforeUpdateTest() {
        List<Schema.PicklistEntry> accountBilCountCodeFieldValue = Schema.SObjectType.Account.fields.BillingCountryCode.getPicklistValues();
        Account acc;
        acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = 'TESTUERP';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.Status__c = 'Validated';
        acc.National_Id__c = '32345545656767';
        acc.IntercommunityVATnumber__c = 'Test';
        acc.Tech_Contact_Direct__c = true;

        insert salesUser;

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5];
        UserTerritory2Association usrTerrAsso = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=allOrgTerritories[3].Id);
        

        System.runAs(adminUser) {
            insert acc;
            insert usrTerrAsso;
        }

        Contact ct = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
        
        insert ct;
           

        ObjectTerritory2Association objTerrAsso = new ObjectTerritory2Association(AssociationCause = 'Territory2Manual', ObjectId = acc.Id, Territory2Id=allOrgTerritories[3].Id);

        System.runAs(adminUser) {
            insert objTerrAsso;
        }

        List<Customer_Reference__c> crs = new List<Customer_Reference__c>();

        /*Product2 prd = new UTIL_TestFactory.ProductFactory().createProduct('Product', null);

        insert prd;*/

        for(Integer i = 0; i < 30; i++) {
            crs.add(new Customer_Reference__c(Account__c = acc.Id, Product_Line__c='297',
                                              Core_Business__c='140', Type_of_reference__c='NPS', Contact_of_reference__c=ct.Id));
        }

        insert crs;

        List<Customer_Reference__c> crsUpdate = [SELECT Id FROM Customer_Reference__c];

        List<Database.SaveResult> results;
        Test.startTest();
        System.runAs(salesUser) {
            results = Database.update(crsUpdate, false);
        }
               
        Test.stopTest();
    }

    @isTest static void beforeDeleteTest() {
        List<Schema.PicklistEntry> accountBilCountCodeFieldValue = Schema.SObjectType.Account.fields.BillingCountryCode.getPicklistValues();
        Account acc;
        acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = 'TESTUERP';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.Status__c = 'Validated';
        acc.National_Id__c = '32345545656767';
        acc.IntercommunityVATnumber__c = 'Test';
        acc.Tech_Contact_Direct__c = true;

        insert salesUser;

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5];
        UserTerritory2Association usrTerrAsso = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=allOrgTerritories[3].Id);
        

        System.runAs(adminUser) {
            insert acc;
            insert usrTerrAsso;
        }

        Contact ct = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
        
        insert ct;
           

        ObjectTerritory2Association objTerrAsso = new ObjectTerritory2Association(AssociationCause = 'Territory2Manual', ObjectId = acc.Id, Territory2Id=allOrgTerritories[3].Id);

        System.runAs(adminUser) {
            insert objTerrAsso;
        }

        List<Customer_Reference__c> crs = new List<Customer_Reference__c>();

        /*Product2 prd = new UTIL_TestFactory.ProductFactory().createProduct('Product', null);

        insert prd;*/

        for(Integer i = 0; i < 30; i++) {
            crs.add(new Customer_Reference__c(Account__c = acc.Id, Product_Line__c='297',
                                              Core_Business__c='140', Type_of_reference__c='NPS', Contact_of_reference__c=ct.Id));
        }

        insert crs;

        List<Customer_Reference__c> crsDelete = [SELECT Id FROM Customer_Reference__c];

        List<Database.DeleteResult> results;
        Test.startTest();
        System.runAs(salesUser) {
            results = Database.delete(crsDelete, false);
        }
               
        Test.stopTest();
    }

    @isTest static void AfterDeleteTest() {
        List<Schema.PicklistEntry> accountBilCountCodeFieldValue = Schema.SObjectType.Account.fields.BillingCountryCode.getPicklistValues();
        Account acc;
        acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = 'TESTUERP';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.Status__c = 'Validated';
        acc.National_Id__c = '32345545656767';
        acc.IntercommunityVATnumber__c = 'Test';
        acc.Tech_Contact_Direct__c = true;

        insert salesUser;

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5];
        UserTerritory2Association usrTerrAsso = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=allOrgTerritories[3].Id);
        

        System.runAs(adminUser) {
            insert acc;
            insert usrTerrAsso;
        }

        Contact ct = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
        
        insert ct;
           

        ObjectTerritory2Association objTerrAsso = new ObjectTerritory2Association(AssociationCause = 'Territory2Manual', ObjectId = acc.Id, Territory2Id=allOrgTerritories[3].Id);

        System.runAs(adminUser) {
            insert objTerrAsso;
        }

        List<Customer_Reference__c> crs = new List<Customer_Reference__c>();

        /*Product2 prd = new UTIL_TestFactory.ProductFactory().createProduct('Product', null);

        insert prd;*/

        for(Integer i = 0; i < 30; i++) {
            crs.add(new Customer_Reference__c(Account__c = acc.Id, Product_Line__c='297',
                                              Core_Business__c='140', Type_of_reference__c='NPS', Contact_of_reference__c=ct.Id));
        }

        insert crs;

        List<Customer_Reference__c> crsDelete = [SELECT Id FROM Customer_Reference__c];

        List<Database.DeleteResult> results;
        Test.startTest();
        System.runAs(salesUser) {
            results = Database.delete(crsDelete, false);
        }
               
        Test.stopTest();
    }

    /*public override void mainEntry(TriggerParameters tp) {
        System.debug('BEFORE INSERT HANDLER START');
        process((List<Customer_Reference__c>)tp.newList);
        System.debug('BEFORE INSERT HANDLER END');
    }
    
    private void process(List<Customer_Reference__c> newList) {
    
        this.bulkbeforeProcessing(newList);
    
        for(Customer_Reference__c cRef : newList) {
            Customer_ReferenceHelper.checkAccPermissionInsertUpdate(cRef, this.connectedWithProfile, this.terrUserIds, this.accWithTerritoriesHieriarchy);
        }
    }
    
    
    private void bulkbeforeProcessing(List<Customer_Reference__c> newList) {
        this.connectedWithProfile = Customer_ReferenceHelper.getUserWithProfile(UserInfo.getUserId());
        this.terrUserIds = Customer_ReferenceHelper.getTerritoryUserIds(UserInfo.getUserId());
        Set<Id> accIds = new Set<Id>();
    
        for(Customer_Reference__c cRef : newList) {
            accIds.add(cRef.Account__c);
        }
    
        this.accWithTerritoriesHieriarchy = Customer_ReferenceHelper.extractSObjectTerritoryHierarchy(accIds);
        /*@isTest static void checkAccPermissionUpdate() {
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
}*/
}