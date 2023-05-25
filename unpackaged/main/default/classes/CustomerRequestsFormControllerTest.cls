/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * created on  : 20/07/2022
**/


@IsTest 
private class CustomerRequestsFormControllerTest {
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @TestSetup static void setup(){

        List<Customer_Requests_API_Properties__c> customerRequestsAPIProperties = new List<Customer_Requests_API_Properties__c>();
        Customer_Requests_API_Properties__c customerRequestsAPIPropertie1 = new Customer_Requests_API_Properties__c();
		customerRequestsAPIPropertie1.Name ='Access_Token_Endpoint';
        customerRequestsAPIPropertie1.Value__c ='https://uat-cegid-oauth-provider.de-c1.eu1.cloudhub.io/v2/access-token';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie1);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie2 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie2.Name ='Client_Secret';
        customerRequestsAPIPropertie2.Value__c ='abc123456789';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie2);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie3 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie3.Name ='Client_Id';
        customerRequestsAPIPropertie3.Value__c ='efg123456789';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie3);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie4 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie4.Name ='InvoiceLines_Endpoint';
        customerRequestsAPIPropertie4.Value__c ='https://egid/api/exp-cegid-salesforce-api-acceptance/v1/invoiceLines';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie4);

        Customer_Requests_API_Properties__c customerRequestsAPIPropertie5 = new Customer_Requests_API_Properties__c();
        customerRequestsAPIPropertie5.Name ='Subscriptions_Endpoint';
        customerRequestsAPIPropertie5.Value__c ='https://egid/api/exp-cegid-salesforce-api-acceptance/v1/subscriptions';
        customerRequestsAPIProperties.add(customerRequestsAPIPropertie5);
        
		insert customerRequestsAPIProperties ;
        
        Account acc = new Account();
        acc.Name='Test';
        acc.ERP_Number__c='98671965';
        acc.National_ID__c='12345677789999';
        acc.BillingCountry='France';
        acc.BillingPostalCode='12354';
        acc.BillingCity='Paris';
        acc.NumberOfEmployees=12;
        acc.AnnualRevenue=1234;
        insert acc;

        Business_Unit__c bu1 = new Business_Unit__c();
        bu1.Name = 'CPA';
        bu1.BU__c = '110';
        bu1.API_Code__c = '110';
        insert bu1;

        Business_Unit__c bu2 = new Business_Unit__c();
        bu2.Name = 'SB';
        bu2.BU__c = '100';
        bu2.API_Code__c = '100';
        insert bu2;

        CustomerRequest__c customerRequest1 = new CustomerRequest__c();
        customerRequest1.Account__c=acc.Id;
        customerRequest1.Type__c='Credit Note';
        insert customerRequest1;

        CustomerRequest__c customerRequest2 = new CustomerRequest__c();
        customerRequest2.Account__c=acc.Id;
        customerRequest2.Type__c='Cancellation';
        insert customerRequest2;

    }
    
    @IsTest
    public static void testGetInvoiceLinesData() {
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new CustomerRequestsFormControllerMock('InvoiceLines'));
            Test.startTest();
            List<CustomerRequestsFormController.lineWrapper> data = CustomerRequestsFormController.getInvoiceLinesData('1111111', 'Saas', 'ZUORA', '100', 'EUR', 'AS001-BM66666Z66', 'F002-00222222', '20', '40', '2021-02-01', '2021-11-01', 'MPI AUTO', '25');
            Test.stopTest();
            System.assertNotEquals(null, data, 'Asserting that data is not null');
        }
    } 
    
    @IsTest
    public static void testGetSubscriptionLinesData() {
        System.runAs(adminUser){
            Test.setMock(HttpCalloutMock.class, new CustomerRequestsFormControllerMock('SubscriptionLines'));
            Test.startTest();
            List<CustomerRequestsFormController.lineWrapper> data = CustomerRequestsFormController.getSubscriptionLinesData('1111111', 'ZUORA', 'EUR', '100', '25');
            Test.stopTest();
            System.assertNotEquals(null, data, 'Asserting that data is not null');
        }
    } 

    @IsTest
    public static void testCRUDInvoiceLines() {

        CustomerRequest__c customerRequest = [SELECT Id FROM CustomerRequest__c WHERE Type__c = 'Credit Note'];

        System.runAs(adminUser){
            Test.startTest();
            CustomerRequestsFormController.saveLines(customerRequest.Id, '[{"amount":"27.00","buOffer":"130","calculatedBu":"SB","startDate":"2021-09-01","endDate":"2021-09-30","loadName":"chargeNameTest","contractNumber":"AS001-BM66666Z66","domain":"Saas","lineDate":"2021-05-11","lineName":"FA002-002222221","lineNumber":"FA002-00222222","name":"1","origin":"ZUORA","sectorAgency3Part":"831","tierslivre":"MPI AUTO"},{"amount":"20.0000","buOffer":"130","calculatedBu":"SB","startDate":"2021-09-01","endDate":"2021-09-30","loadName":"chargeNameTest","contractNumber":"AS001-BM66666Z66","domain":"Saas","lineDate":"2021-05-11","lineName":"FA002-002222222","lineNumber":"FA002-00222222","name":"2","origin":"ZUORA","sectorAgency3Part":"831","tierslivre":"MPI AUTO"}]', 'InvoiceLine', '130');
            List<CustomerRequestsFormController.InvoiceLineWrapper> invoiceLines = CustomerRequestsFormController.getInvoiceLinesByCustomerRequestId(customerRequest.Id);
            System.assertNotEquals(null, invoiceLines, 'Asserting that invoiceLines is not null');
            System.assertEquals(27.00, invoiceLines[0].CreditNoteAmount);
            InvoiceLine__c invoiceLine = [SELECT CreditNoteAmount__c From InvoiceLine__c WHERE CreditNoteAmount__c = 27.00];
            String isUpdated =  CustomerRequestsFormController.updateInvoiceLines('[{"CreditNoteAmount":"25.00","InvoiceLineId":"' + invoiceLine.Id + '"}]');
            System.assertEquals('Success', isUpdated);
            InvoiceLine__c invoiceLineUpdated = [SELECT CreditNoteAmount__c From InvoiceLine__c WHERE CreditNoteAmount__c = 25.00];
            System.assertEquals(25.00, invoiceLineUpdated.CreditNoteAmount__c);
            String isDeleted =  CustomerRequestsFormController.deleteInvoiceLine(invoiceLineUpdated.Id);
            System.assertEquals('Success', isDeleted);
            Test.stopTest();
        }
    }
     
    @IsTest
    public static void testCRUDSubscriptionLines() {

        CustomerRequest__c customerRequest = [SELECT Id FROM CustomerRequest__c WHERE Type__c = 'Cancellation'];

        System.runAs(adminUser){
            Test.startTest();
            CustomerRequestsFormController.saveLines(customerRequest.Id, '[{"amount":"27.0000","buOffer":"130","calculatedBu":"SB","loadName":"NameTest","loadType":"chargeTypeTest","contractNumber":"AS001-BM66666Z66","lineDate":"2024-04-15","lineName":"AS001-BM66666Z661","lineNumber":"AS001-BM66666Z66","name":"888888","nextDateRenewal":"2023-01-01","quantity":"1.0000","startDate":"2022-01-01","unitPrice":"27","tierslivre":"MPI AUTO"},{"amount":"22.0000","buOffer":"130","calculatedBu":"SB","loadName":"NameTest2","loadType":"chargeTypeTest","contractNumber":"AS001-BM66666Z66","lineDate":"2024-04-15","lineName":"AS001-BM66666Z662","lineNumber":"AS001-BM66666Z66","name":"999999","nextDateRenewal":"2023-01-01","quantity":"1.0000","startDate":"2022-01-01","unitPrice":"27","tierslivre":"MPI AUTO"}]', 'SubscriptionLines', '');
            List<CustomerRequestsFormController.SubscriptionLineWrapper> subscriptionLines = CustomerRequestsFormController.getSubscriptionLinesByCustomerRequestId(customerRequest.Id);
            System.assertNotEquals(null, subscriptionLines, 'Asserting that subscriptionLines is not null');
            SubscriptionLine__c subscriptionLine = [SELECT CancellationDate__c, QuantityCancelled__c From SubscriptionLine__c WHERE Name = 'NameTest'];
            String isUpdated =  CustomerRequestsFormController.updateSubscriptionLines('[{"CancellationDate":"2024-01-01","QuantityCancelled":"1","SubscriptionLineId":"' + subscriptionLine.Id + '"}]');
            System.assertEquals('Success', isUpdated);
            SubscriptionLine__c subscriptionLineUpdated = [SELECT QuantityCancelled__c From SubscriptionLine__c WHERE Name = 'NameTest'];
            System.assertEquals(1, subscriptionLineUpdated.QuantityCancelled__c);
            String isDeleted =  CustomerRequestsFormController.deleteSubscriptionLine(subscriptionLineUpdated.Id);
            System.assertEquals('Success', isDeleted);
            Test.stopTest();
        }
    } 

    @IsTest
    public static void testGetDomainPicklist() {
        System.runAs(adminUser){

            Test.startTest();
            Map<String,String> domainsMap = CustomerRequestsFormController.getDomainPicklist();
            Test.stopTest();
            System.assertNotEquals(null, domainsMap, 'Asserting that domainsMap is not null');
        }
    } 

    @IsTest
    public static void testSearchLookUp() {
        System.runAs(adminUser){

            Test.startTest();
            List<CustomerRequestsFormController.ErpnumberWrapper> results = CustomerRequestsFormController.searchLookUp('986');
            Test.stopTest();
            System.assertNotEquals(null, results, 'Asserting that results is not null');
        }
    } 

    @IsTest
    public static void testGetBUExternalId() {
        System.runAs(adminUser){

            Business_Unit__c bu = [SELECT Id FROM Business_Unit__c Limit 1];

            Test.startTest();
            Business_Unit__c buExternalId = CustomerRequestsFormController.getBUExternalId(bu.Id);
            Test.stopTest();
            System.assertNotEquals(null, buExternalId, 'Asserting that buExternalId is not null');
        }
    }

    @IsTest
    public static void testGetBUIdByExternalId() {
        System.runAs(adminUser){
            Test.startTest();
            Map<Id, Business_Unit__c> buMap = CustomerRequestsFormController.getBUIdByExternalId(new List<String>{'100', '110'});
            Test.stopTest();
            System.assertNotEquals(null, buMap, 'Asserting that buMap is not null');
        }
    }
}