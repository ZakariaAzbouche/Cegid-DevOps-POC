/***
* @author      : Trilochnah - Comforth Karoo
* @date		   : 25/10/21
* @description : Test class for B2B_AddParticipants
***/

@isTest
public class B2B_AddParticipants_TEST {
    //private static User adminUser =  new TestDataFactory.UserFactory().createRunningUserAdministrator();
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User testUser;
    static WebCart webcart1;
    static Account acc1;
    static Participant__c participant1;
    static CartItem cartItem1;
    static CartDeliveryGroup cartDeliveryGroup1;
    static BypassTrigger__c bypasstrigger;
    static WebStore webStore1;
    
    static{       
        System.runAs(adminUser){
            //Insert BypassTrigger__c
            bypasstrigger = new BypassTrigger__c(
                Activatetrigger__c=true,
                SetupOwnerId=Userinfo.getOrganizationId()
            );
            insert bypasstrigger;
            
            system.debug('##bypasstrigger ' + bypasstrigger);
            
            // Insert Account
            acc1 = new Account(
                Name = 'Acc1',
                Type__c='001',
                BillingStreet = 'Test',
                BillingCity = 'Test',
                BillingCountry = 'Italy',
                BillingPostalCode = '12345',
                National_ID_Exception__c='Creation In progress'
                
            );
            insert acc1;
            
            //Insert webstore
            webStore1 = new WebStore(
                Name='testwebstore'
                
            );
            insert webStore1;
            
            // Insert WebCart
            webcart1 = new WebCart(
                Name = 'Cart1',
                Status='Closed',
                AccountId=acc1.id,
                WebStoreId= webStore1.Id         
            );
            insert webcart1;  
            
            // Insert cartDeliveryGroup
            cartDeliveryGroup1 = new CartDeliveryGroup(
                Name='Default Delivery',
                CartId=webcart1.Id
            );
            insert cartDeliveryGroup1;
            
            //Insert cart item
            CartItem cartItem1 = new CartItem(
                CartId=webcart1.Id, 
                Sku='SKU_Test1', 
                Quantity=3.0,
                SalesPrice=400,
                Type='Product', 
                Name='TestProduct', 
                CartDeliveryGroupId=cartDeliveryGroup1.Id
            );
            insert cartItem1;
            
            //Insert participants
            participant1 = new Participant__c(
                Name='testP1',
                Civilite__c ='Mr',
                Prenom__c = 'Test',
                EmailAddress__c='test1@test.test', 
                CartItemId__c=cartItem1.Id          
            );
            insert participant1;
            
            
        }
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 25/10/21
    * @description : Updating Status to 'Active'
    ***/
    static testMethod void testResetCartStatus() {
        
        System.runAs(adminUser){
            
            webcart1.Status='Active';
            
            Test.startTest();
            B2B_AddParticipants.resetCartStatus(webcart1.id);                        
            Test.stopTest();
            
            WebCart wc = [SELECT Id,Name,Status FROM WebCart WHERE Id =:webcart1.Id];
            
            System.assertEquals('Active', wc.Status, 'Asserting that WebCart Status is not active');
            
        }
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 28/10/21
    * @description : Updating Status to 'Active'
    ***/
    static testMethod void testGetParticipantRow() {
        
        System.runAs(adminUser){
            
            webcart1.Status='Active';
            
            Test.startTest();
            B2B_AddParticipants.getParticipantRow(webcart1.Id);                       
            Test.stopTest();
            
            WebCart wc = [SELECT Id,Name,Status FROM WebCart WHERE Id =:webcart1.Id];
            
            System.assertEquals('Active', wc.Status, 'Asserting that WebCart Status is not active');
            
        }
    }
    
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 28/10/21
    * @description :
    ***/
    static testMethod void testDeleteAllParticipant() {
        
        System.runAs(adminUser){
            
            List<Id> listCartIds = new List<Id>();
            
            CartItem ct = [SELECT Id FROM CartItem];
            
            listCartIds.add(ct.Id);
            
            
            Test.startTest();
            Boolean b = B2B_AddParticipants.deleteAllParticipant(listCartIds);
            Test.stopTest();
            
            System.assertEquals(true,b, 'Asserting that list of participant is less than zero');
            
        }
    }
    
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 28/10/21
    * @description :
    ***/
    static testMethod void testDeleteParticipantByIds() {
        
        System.runAs(adminUser){
            
            List<string> listParticipantIds = new List<string>();
            
            Participant__c pt = [SELECT Id FROM Participant__c LIMIT 1];
            
            CartItem ct=[SELECT Id FROM CartItem LIMIT 1 ];
            
            listParticipantIds.add(ct.Id + '-' + pt.Id);
            
            system.debug('##listP  ' + listParticipantIds );
            
            Test.startTest();
            B2B_AddParticipants.deleteParticipantByIds(listParticipantIds,'525632222255523', '525632222255523', webcart1.id);
            Test.stopTest();
            
           // System.assertEquals();
            
        }
    }
}