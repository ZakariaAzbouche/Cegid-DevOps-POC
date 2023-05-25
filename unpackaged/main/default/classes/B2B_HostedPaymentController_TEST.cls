/**
 * @description       : Test class for B2B_HostedPaymentController
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-29
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
@IsTest
private class B2B_HostedPaymentController_TEST {
    private static final B2B_Settings__c SETTINGS = B2B_Settings__c.getOrgDefaults();

    @isTest(SeeAllData=true) static void testLexOrigin() {
        B2B_HostedPaymentController controller = new B2B_HostedPaymentController();
        System.assertEquals(SETTINGS.StoreDomain__c, controller.lexOrigin, 'Domain not correct');
    }

    @isTest(SeeAllData=true) static void testGetVisualforceURL() {
        System.assertEquals(SETTINGS.StoreDomain__c, B2B_HostedPaymentController.getVisualforceURL(), 'Domain not correct');
    }

    @isTest(SeeAllData=true) static void testStripeId() {
        B2B_HostedPaymentController controller = new B2B_HostedPaymentController();
        System.assertEquals(SETTINGS.StripePublishableKey__c, controller.stripeId, 'Key not correct');
    }
}