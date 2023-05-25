@isTest
public class LeadVRSDRPRMTelemark_TEST {
    @isTest static void enabledByPassVRTest() {
        LeadVRSDRPRMTelemark.enabledByPassVR();

        System.assertEquals(true, LeadVRSDRPRMTelemark.byPassVR, 'byPass must be activated');
    }

    @isTest static void disableByPassVRTest() {
        LeadVRSDRPRMTelemark.disableByPassVR();

        System.assertEquals(false, LeadVRSDRPRMTelemark.byPassVR, 'byPass must be desactivated');
    }
}