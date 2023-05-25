@isTest
public class TH_Contact_Test {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @testSetup
    static void makeData() {

         adminUser.BypassVR__c = true;
         adminUser.Bypass_Contact_Duplicate_Rule__c = true;

         Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
         acc.IntercommunityVATnumber__c = 'TestVAT';
         acc.National_ID__c = '12345690745678';
         List<Contact> cts = new List<Contact>();
        
         System.runAs(adminUser) {
             insert acc;
             for(Integer i = 0 ; i < 10 ; i++) {
                Contact ct = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
                ct.Active__c = true;
                ct.Salutation = 'Mr.';
                ct.Phone = '0123456789';
                cts.add(ct);
             }
             insert cts;
             System.debug('cts '+cts);
         }
        
         System.debug('BypassTrigger__c '+BypassTrigger__c.getOrgDefaults());

        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
        insert bypass;
    }
    
    
    @isTest static void computeAccountTechContactDirectTest() {

    }

    @isTest static void beforeInsertTest() {
        List<Database.SaveResult> results;
        System.runAs(adminUser) {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<Contact> cts = new List<Contact>();
        Contact c;
        for(Integer i = 0 ; i < 10 ; i++) {
            c = new Contact();
            c.LastName = 'LName'+System.now().millisecond()+i;
            c.FirstName = 'FName'+System.now().millisecond()+i;
            c.email = 'lname'+System.now().millisecond()+i+'@email.com';
            c.AccountId = acc.Id;
            c.Service__c = 'IT';
            c.Function__c = 'IT Dir.';
            cts.add(c);
        }

        
        Test.startTest();
        
            results = Database.insert(cts, false);    
        }  
        Test.stopTest();
        for(Database.SaveResult result : results) {
            System.assertEquals(result.isSuccess(), true, 'Result have to be a sucess');
        }
        
    }
    
    @isTest static void afterInsertTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Contact c;
        List<Contact> cts = new List<Contact>();
        for(Integer i = 0 ; i < 10 ; i++) {
            c = new Contact();
            c.LastName = 'LName'+System.now().millisecond()+i;
            c.FirstName = 'FName'+System.now().millisecond()+i;
            c.email = 'lname'+System.now().millisecond()+i+'@email.com';
            c.AccountId = acc.Id;
            c.Service__c = 'IT';
            c.Function__c = 'IT Dir.';
            cts.add(c);
        }

        List<Database.SaveResult> results;
        Test.startTest();
        System.runAs(adminUser) {
            results = Database.insert(cts, false);    
        }  
        Test.stopTest();
        for(Database.SaveResult result : results) {
            System.assertEquals(result.isSuccess(), true, 'Result have to be a sucess');
        }
    }

    @isTest static void afterUpdateTest() {
        List<Contact> cts = [SELECT Id, FirstName FROM Contact];
        Integer i = 0;
        for(Contact ct : cts) {
            ct.FirstName = ct.FirstName+'change'+i;
            i++;
        }

        List<Database.SaveResult> results;

        Test.startTest();
        System.runAs(adminUser) {
            results = Database.update(cts, false);   
        }  
        Test.stopTest();
        
        for(Database.SaveResult result : results) {
            System.debug('Error : '+ result.getErrors());
            //System.assertEquals(true, result.isSuccess(), 'Result have to be a sucess');
        }
    }

    @isTest static void afterDeleteTest() {
        List<Contact> cts = [SELECT Id, LastName FROM Contact];

        List<Database.DeleteResult> results;

        Test.startTest();
        System.runAs(adminUser) {
            results = Database.delete(cts, false);   
        }  
        Test.stopTest();
        
        for(Database.DeleteResult result : results) {
            System.assertEquals(true, result.isSuccess(), 'Result have to be a sucess');
        }
    }

    @isTest static void AsyncUpdateAndRedirectMergedContactTest() {

        List<Contact> cts = [SELECT Id, CreatedById FROM Contact];
        List<Contact> ctsToMerged = new List<Contact>();
        List<merge_contact_done__e> ctsMerge = new List<merge_contact_done__e>();
        List<Contact> ctsToDelete = new List<Contact>();

        for(Integer i; i < cts.size(); i++) {
            if(i < 5) {
                ctsToDelete.add(cts[i]);
            } else {
                ctsToMerged.add(cts[i]);
            }
        }

        for(Integer i; i < cts.size(); i++) {   
            ctsMerge.add(new merge_contact_done__e(Merged_Contact_Id__c = ctsToMerged[i].Id,
                                                   Contact_To_be_deleted__c = ctsToDelete[i].Id,
                                                   Created_By_Id__c = ctsToDelete[i].CreatedById));
        }

        TH_Contact.AsyncUpdateAndRedirectMergedContact asyncTest = new TH_Contact.AsyncUpdateAndRedirectMergedContact(ctsToMerged, ctsMerge, ctsToDelete);

       Test.startTest();
       ID jobID = System.enqueueJob(asyncTest);
       Test.StopTest();
       
    }
}