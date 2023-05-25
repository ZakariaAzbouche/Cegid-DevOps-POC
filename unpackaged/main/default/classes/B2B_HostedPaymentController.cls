/**
 * @description       : Controller for the Hosted iFrame solution to return the LE Domain and Stripe Publishable Key
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-30
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
public with sharing class B2B_HostedPaymentController {
    private static final B2B_Settings__c SETTINGS = B2B_Settings__c.getOrgDefaults();

    public String lexOrigin {
        get {
            //Populate with the value of the domain of the LE Community
            return SETTINGS.StoreDomain__c;
        }
        set;
    }
    
    public String stripeId {
        get {
            //Populate with the value of the publishable key in the Stripe Dashboard 
            return SETTINGS.StripePublishableKey__c;
        }
        set;
    }

	//Returns the Visualforce URL to leverage in the LWC
    @AuraEnabled(cacheable=true)
    public static String getVisualforceURL() {
        //return URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] + '--c.visualforce.com';
        return SETTINGS.StoreDomain__c;
    }
}