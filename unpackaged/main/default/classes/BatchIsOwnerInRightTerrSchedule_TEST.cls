@isTest
private class BatchIsOwnerInRightTerrSchedule_TEST {

    public static String CRON_EXP = '0 0 0 3 9 ? 2042';

    @testSetup
    static void setup() {
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

        //BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
    
        //insert salesUser;

        List<Territory2> allOrgTerritories = [SELECT Id, ParentTerritory2Id, Name FROM Territory2 WHERE Territory2Model.State = 'Active' LIMIT 5];
        //UserTerritory2Association usrTerrAsso = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=allOrgTerritories[2].Id);
        insert accs;
            //insert usrTerrAsso;
        
        
    }
    @isTest static void testScheduleBatch() {

        Test.startTest();
        String jobId = System.schedule('BatchIsOwnerInRightTerritorySchedule',
        CRON_EXP, 
         new BatchIsOwnerInRightTerritorySchedule());
        Test.stopTest();
        // after the testing stops, assert records were updated properly
    }
}