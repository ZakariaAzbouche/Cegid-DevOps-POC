@isTest
public class CampaignMemberTrigger_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User salesUser = new UTIL_TestFactory.UserFactory().createUserCegidSales();

    @TestSetup static void makeData(){
        Campaign c = new Campaign(Name='TestCamp');
        List<Lead> lds = new List<Lead>();
        List<CampaignMember> cms = new List<CampaignMember>();

        for(Integer i = 0; i < 50 ; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('TestLd'+i));
        }

        insert c;
        insert lds;
        insert adminUser;

        for(Integer j = 0; j < 50 ; j++) {
            cms.add(new CampaignMember(CampaignId = c.Id, LeadId = lds[j].Id));
        }
        
        insert cms;
    }
    @isTest static void beforeDeleteValidateTest() {
        Integer nbSucess = 0;
        Integer nbError = 0;
        List<CampaignMember> cms = [SELECT Id FROM CampaignMember];
        System.runAs(adminUser) {
            Test.startTest();
            
            List<Database.DeleteResult> drList = Database.delete(cms, false);

            Test.stopTest();

            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    nbSucess++;
                } else {
                    nbError++;
                }
            }
            System.assertEquals(50, nbSucess);
            System.assertEquals(0, nbError);
        }
        
    }

    @isTest static void beforeDeleteUnValidateTest() {
        Integer nbSucess = 0;
        Integer nbError = 0;
        List<CampaignMember> cms = [SELECT Id FROM CampaignMember];

        System.runAs(salesUser) {
            Test.startTest();
            
            List<Database.DeleteResult> drList = Database.delete(cms, false);

            Test.stopTest();

            for(Database.DeleteResult dr : drList) {
                if (dr.isSuccess()) {
                    nbSucess++;
                } else {
                    nbError++;
                }
            }
            System.assertEquals(0, nbSucess);
            System.assertEquals(50, nbError);
        }
        
    }
    
    
}