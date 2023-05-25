@isTest
private class LCC001_SyncWithZuora_Test {
     @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator2());

        String res = LCC001_SyncWithZuora.makeCallout('randomId');

        System.assertNotEquals(null ,res);
    }
}