/**
 * @description       : Test class for B2B_StripeAdapter
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : B2B
 * @last modified on  : 2021-11-29
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
@IsTest
private class B2B_StripeAdapter_TEST {
    @isTest static void testCreateAuthResponse() {
        Test.setMock(HttpCalloutMock.class, new B2B_StripeAdapter_MOCK());

        B2B_StripeAdapter adapter = new B2B_StripeAdapter();
        commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest(100);
        authRequest.currencyIsoCode = 'EUR';
        authRequest.additionalData = new Map <String, String>{
            'token' => 'testToken'
        };
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(authRequest, commercepayments.RequestType.Authorize);

        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
    }

    @isTest static void testCreateTokenizeResponse() {
        Test.setMock(HttpCalloutMock.class, new B2B_StripeAdapter_MOCK());

        Test.startTest();
        B2B_StripeAdapter adapter = new B2B_StripeAdapter();
        commercepayments.PaymentMethodTokenizationRequest paymentRequest = new commercepayments.PaymentMethodTokenizationRequest('paymentGatewayId');
        commercepayments.CardPaymentMethodRequest cardPaymentMethodRequest = new commercepayments.CardPaymentMethodRequest(commercepayments.CardCategory.CreditCard);
        paymentRequest.address = new commercepayments.AddressRequest('street', 'city', 'state', 'country', 'postalCode');
        paymentRequest.cardPaymentMethod = cardPaymentMethodRequest;
        paymentRequest.cardPaymentMethod.cardHolderName = 'TEST CARDHOLDER NAME';
        commercepayments.paymentGatewayContext gatewayContext = new commercepayments.paymentGatewayContext(paymentRequest, commercepayments.RequestType.Tokenize);

        commercepayments.GatewayResponse response = adapter.processRequest(gatewayContext);
        Test.stopTest();
    }

    // coverage for B2B_StripeValidationException
    @isTest static void testToStripeCurrencyUnitsException() {
        try{
            B2B_StripeAdapter.toStripeCurrencyUnits('test', 100);
        }catch(Exception e){

        }
    }
}