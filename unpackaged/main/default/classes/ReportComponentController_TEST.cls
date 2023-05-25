@isTest
private class ReportComponentController_TEST {
    static Id RecordTypeIdProductPackage = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Package').getRecordTypeId();
    
    @isTest(SeeAllData=true) static void getReportMetadata_validID(){
        Report aReport = [ SELECT Id, Name, DeveloperName FROM Report where name LIKE 'Parent Products %' limit 1];
        system.System.debug('aReport' + aReport) ;
        Product2 pro = new Product2(Name = 'testpro', recordtypeid = RecordTypeIdProductPackage, Buying_Metric__c = '100', Possible_Billing_Modes__c='Consumption', Marketing_Status__c = 'Marketable', SBQQ__ChargeType__c = 'One-Time' , IsActive = true);
        insert pro;
        //Product2 pro = new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List');
        //insert pro;
        Test.startTest();
        String reportJSON = ReportComponentController.getReportMetadata(aReport.Id, pro.Id);
        Test.stopTest();
        
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(reportJSON);
        Map<String, Object> reportMetadata = (Map<String, Object>)m.get('reportMetadata');
        System.assertEquals( aReport.Name, reportMetadata.get('name'), 'The correct report should be returned' );
    }
    
    @isTest static void getReportMetadata_invalidID(){
        Id bogusId = '00Q000000000000';
        Product2 pro = new Product2(Name = 'testpro', recordtypeid = RecordTypeIdProductPackage, Buying_Metric__c = '100', Possible_Billing_Modes__c='Consumption', Marketing_Status__c = 'Marketable', SBQQ__ChargeType__c = 'One-Time' , IsActive = true);
        insert pro;
        //Product2 pro = new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List');
        //insert pro;
        NoDataFoundException expectedEx;
        String reportJSON;
        try{
            Test.startTest();
            reportJSON = ReportComponentController.getReportMetadata(bogusId,pro.Id);
            Test.stopTest();
        } catch( NoDataFoundException ex ){
            expectedEx = ex;
        }
        
        System.assertEquals( null, reportJSON, 'No report json should be returned' );
        System.assertNotEquals( null, expectedEx, 'An exception should been thronw to be handled by the front-end' );
    }
}