@isTest
public class LWC_LeadController_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    @isTest static void getLeadByEmailTestEmailFounded() {

        List<Lead> lds = new List<Lead>();
       
        for(Integer i = 0 ; i < 20 ; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('test'+i));
        }
        System.runAs(adminUser) {
            insert lds;
       
            Test.startTest();
                List<Lead> ldsResult = LWC_LeadController.getLeadByEmail('test15@test15.com');
            Test.stopTest();

            System.assertEquals(1, ldsResult.size(), 'list size should be 1');
        }
    }

    @isTest static void getLeadByEmailTestNoEmailFounded() {

        List<Lead> lds = new List<Lead>();
       
        for(Integer i = 0 ; i < 20 ; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('test'+i));
        }
        System.runAs(adminUser) {
            insert lds;
       
            Test.startTest();
                List<Lead> ldsResult = LWC_LeadController.getLeadByEmail('test64@test64.com');
            Test.stopTest();

            System.assertEquals(0, ldsResult.size(), 'list size should be 0');
        }
    }
    
}