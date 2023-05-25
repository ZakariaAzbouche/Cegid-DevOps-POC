/**
 * @author Varun Molla - Comforth Karoo
 * @date Creation 2021-11-11
 * @description Test class for apex class B2B_GetConnectedUserEmail
 *              
*/
@isTest
private class B2B_GetConnectedUserEmail_TEST {
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @isTest static void getProducts_Test(){ 
        System.runAs(adminUser){ 
            Test.startTest();
                B2B_GetConnectedUserEmail.B2B_GetConnectedUserEmail();
            Test.stopTest();
        } 
    }
}