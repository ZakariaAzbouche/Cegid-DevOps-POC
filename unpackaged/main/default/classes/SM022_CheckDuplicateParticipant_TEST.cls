/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-29-2021
 * @last modified by  : keshav Matabadul
**/
@isTest
public with sharing class SM022_CheckDuplicateParticipant_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @testSetup static void setup(){
        System.runAs(adminUser){ 
            // Account and Contact are related
            Account account = new Account(Name='TestAccount');
            insert account;

            Contact contact = new Contact(LastName='TestContact', AccountId=account.Id);
            insert contact;

            WebStore webStore = new WebStore(Name='TestWebStore');
            insert webStore;

            WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id);
            insert cart;

            CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery');
            insert cartDeliveryGroup;

            CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product', 
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
            );
            insert cartItem;

            List<Participant__c> listParticipant = new List<Participant__c>{
                new UTIL_TestFactory.ParticipantFactory().createParticipant(cartItem.Id)
            };
            insert listParticipant;

            List<Participant__c> listParticipantNew = new List<Participant__c>{
                new UTIL_TestFactory.ParticipantFactory().createParticipant(cartItem.Id)
            };
            listParticipantNew[0].EmailAddress__c = 'test@test.com';
            insert listParticipantNew;

            BypassTrigger__c bt= new BypassTrigger__c(
                Activatetrigger__c = true,
                SetupOwnerId = UserInfo.getOrganizationId()
            );

            insert bt;
            
        }
    }

    static testMethod void testInsertData(){
        
        System.runAs(adminUser){
             
            Id cartI = [SELECT Id FROM CartItem].Id;
            Test.startTest();
            try {
                Participant__c part= new UTIL_TestFactory.ParticipantFactory().createParticipant(cartI);
                insert part;
            } catch (Exception e) {
               
                // assert
                Boolean expectedExceptionThrown =  (e.getMessage().contains('Merci de bien vouloir saisir un e-mail distinct pour chaque participant à une session de formation.')) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
            } 
            
            Test.stopTest();
   
        }
            
    }

    static testMethod void testUpdateData(){
        
        System.runAs(adminUser){
             
            Id cartI = [SELECT Id FROM CartItem].Id;
            Test.startTest();
            try {
                Participant__c part= [SELECT Id FROM Participant__c WHERE EmailAddress__c ='test@test.com' limit 1];
                part.EmailAddress__c = 'test1@test.test';
                Update part;
            } catch (Exception e) {
               
                // assert
                Boolean expectedExceptionThrown =  (e.getMessage().contains('Merci de bien vouloir saisir un e-mail distinct pour chaque participant à une session de formation.')) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
            } 
            
            Test.stopTest();
   
        }
            
    }
}