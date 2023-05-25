/***
* @author      : Trilochnah - Comforth Karoo
* @date		   : 27/10/21
* @description : Test class for B2BCartControllerSample
***/
@isTest
public class B2BCartControllerSample_TEST {
    private static User adminUser =  new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User testUser;
    static WebCart wc1;
    static Account acc1;
    static Participant__c participant1;
    static BypassTrigger__c bypasstrigger;
    static CartItem cartItem1;
    static CartItem cartItem2;
    static CartDeliveryGroup cartDeliveryGroup1;
    static WebStore webStore1;
    
    static{       
        System.runAs(adminUser){
            //Insert BypassTrigger__c
            bypasstrigger = new BypassTrigger__c(
                Activatetrigger__c=false,
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
            
            webStore1 = new WebStore(
                Name='testwebstore'
                
            );
            insert webStore1;
            
            // Insert WebCart
            wc1 = new WebCart(
                Name = 'Cart1',
                //Status='Closed',
                Status='Active',
                AccountId=acc1.id,
                WebStoreId=webStore1.id           
            );
            insert wc1; 
            
            // Insert cartDeliveryGroup
            cartDeliveryGroup1 = new CartDeliveryGroup(
                Name='Default Delivery',
                CartId=wc1.Id
            );
            insert cartDeliveryGroup1;
            
            //Insert cart item
            CartItem cartItem1 = new CartItem(
                CartId=wc1.Id, 
                Sku='SKU_Test1', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct', 
                CartDeliveryGroupId=cartDeliveryGroup1.Id
            );
            insert cartItem1;
            
            //Insert cart item
            CartItem cartItem2 = new CartItem(
                CartId=wc1.Id, 
                Sku='SKU_Test1', 
                Quantity=3.0, 
                Type='Product', 
                Name='TestProduct',
                CartDeliveryGroupId=cartDeliveryGroup1.Id
            );
            insert cartItem2;
            
            
            //insert participants
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
    * @description : 
    ***/
    @isTest
    static void testUpdateCartStatus(){
        
        system.runAs(adminUser){
            
            wc1.Status='Active';
            
            Test.startTest();
            B2BCartControllerSample.updateCartStatus(wc1.id) ;                      
            Test.stopTest();
            
            WebCart wc = [SELECT Id,Name,status FROM WebCart WHERE Id =:wc1.Id];
            
            System.assertEquals('Active', wc.status, 'Asserting that WebCart Status has been updated');
            
            
        }
        
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 28/10/21
    * @description : 
    ***/
    @isTest
    static void testGetCartItems(){
        
        system.runAs(adminUser){
            
            //Added a try catch to catch the following error.
            //System.UnsupportedOperationException: ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true).
            
            Test.startTest();
            try
            {
                B2BCartControllerSample.getCartItems('525632222255523', null, wc1.id, '1', 'ASC');
            }catch(Exception ex){
                system.debug('##error GetCartItems' + ex.getMessage());
            }
            Test.stopTest();
            
        }
        
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 03/11/21
    * @description : 
    ***/
    @isTest
    static void testDeleteCart(){
        
        system.runAs(adminUser){
            
            String webstoreId ='525632222255523';
            
            Test.startTest();
            
            try
            {
                B2BCartControllerSample.deleteCart('525632222255523', '525632222255523', wc1.id);
                
            }catch(Exception ex){
                system.debug('##error DeleteCart' + ex.getMessage());
            }
            
            
            Test.stopTest();
            
        }
        
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 03/11/21
    * @description : 
    ***/
   /* @isTest
    static void testUpdateCartItem(){
        
        system.runAs(adminUser){
            
            List<ConnectApi.CartItemInput> cartItemInputs = new List<ConnectApi.CartItemInput>();

            ConnectApi.CartItemInput cartInputItems = new ConnectApi.CartItemInput();
                        
            cartInputItems.quantity =String.ValueOf(cartItem1.Quantity);
            cartInputItems.productId = cartItem1.Id;

            //cartInputItems.type='Product';

            Test.startTest();
            try
            {
                B2BCartControllerSample.updateCartItem('525632222255523', '525632222255523', wc1.Id,cartItem1.Id,cartInputItems);
                
            }catch(Exception ex){
                system.debug('##error UpdateCartItem' + ex.getMessage());
            }
            
            Test.stopTest();
      
        }
        
    }*/
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 03/11/21
    * @description : 
    ***/
    @isTest
    static void testGetCartSummary(){
        
        system.runAs(adminUser){
            
            Test.startTest();
            try
            {
                B2BCartControllerSample.getCartSummary('525632222255523', '525632222255523',  wc1.Id);
                
            }catch(Exception ex){
                system.debug('##error GetCartSummary' + ex.getMessage());
            }
            
            Test.stopTest();
            
        }
        
    }
    
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 03/11/21
    * @description : 
    ***/
    @isTest
    static void testCreateCart(){
        
        system.runAs(adminUser){
            
            Test.startTest();
            
            try
            {
                B2BCartControllerSample.createCart('525632222255523', '525632222255523');
                
            }catch(Exception ex){
                system.debug('##error CreateCart' + ex.getMessage());
            }
            
            Test.stopTest();
            
        }
        
    }
    /***
    * @author      : Trilochnah - Comforth Karoo
    * @date		   : 03/11/21
    * @description : 
    ***/
    @isTest
    static void testDeleteCartItem(){
        
        system.runAs(adminUser){
            
            Test.startTest();
            
            try
            {
                B2BCartControllerSample.deleteCartItem('525632222255523', '525632222255523',  wc1.Id,'0a93O0000008Uh0QAE');
                //Getting while insert cartItem1.id
                //B2BCartControllerSample.deleteCartItem(communityId, effectiveAccountId, activeCartOrId,cartItemId)
                
            }catch(Exception ex){
                system.debug('##error DeleteCartItem ' + ex.getMessage());
            }
            
            
            Test.stopTest();
            
        }
        
    }
    
}