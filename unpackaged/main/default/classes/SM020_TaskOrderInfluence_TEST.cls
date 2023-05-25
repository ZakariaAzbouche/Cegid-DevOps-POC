/**
* @author Keshav M - Comforth
* @date 2021-07-05
* @description SM020_TaskOrderInfluence_TEST          
*/
@isTest
public class SM020_TaskOrderInfluence_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();
    @testSetup static void setup(){
        System.runAs(adminUser){ 

            bt.Activatetrigger__c = false;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;

            List<Territory2> listTerritory = [Select Id , Expertise__c from Territory2 where  Expertise__c='200'];
            //Insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
            Test.startTest();
            
            //create account
            List<Account> listAcc = new List<Account>();
            for(Integer i=0; i<2;i++ ){
                listAcc.add( new UTIL_TestFactory.AccountFactory().createAccountWithNature(i));
            }

            for(account acc:listAcc){
                acc.OwnerId=adminUser.Id;
            }
            insert listAcc;
            
            //create ProductLine
            List<Product_Line__c> proLine = new List<Product_Line__c>();
            for(Integer i=0; i<2;i++){
                proLine.add(new UTIL_TestFactory.ProductLineFactory().createProductLinePrice('Test Product Line ', '13'+i));
            }
            insert proLine;
            
            List<ObjectTerritory2Association> listOTA = new List<ObjectTerritory2Association>();
            for(Integer i=0; i<2;i++){
                listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[i].Id,listTerritory[0].Id));
            }
            
            System.debug('listOTA : ' + listOTA);
            insert listOTA;
             
            
            //create ProductLine
            List<Order_Influence__c> orderInfluence = new List<Order_Influence__c>();
            for(Integer i=0; i<2;i++){
                orderInfluence.add(new UTIL_TestFactory.OrderInfluenceFactory().createOrderInfluence(listAcc[i].Id, proLine[i].Id));
            }
            insert orderInfluence;
            
            Test.stopTest();
        }
    }
    
    static testMethod void testTaskInsert(){
        System.runAs(adminUser) {
            BypassTrigger__c bypass = [SELECT Id, SetupOwnerId FROM BypassTrigger__c Limit 1];
            bypass.Activatetrigger__c = true;
            update bypass;
    
            Test.startTest();
                Product_Line__c proLine = [Select Id from Product_Line__c limit 1];
                Account acc = [Select Id from Account limit 1];
                Task tsk = new UTIL_TestFactory.TaskFactory().createTask(acc.Id,proLine.Id,adminUser.Id);
                try{
                    insert tsk;
                }catch(Exception e){
                    //System.assert(e.getMessage().contains('Your Order Influence can\'t be registered because you are not assigned in at least one of the Account\'s Territories.'));
                }
            Test.stopTest();
            
        }
    }
    
    static testMethod void testOrderInfluenceInsert(){
        System.runAs(adminUser) {
            BypassTrigger__c bypass = [SELECT Id, SetupOwnerId FROM BypassTrigger__c  Limit 1];
            bypass.Activatetrigger__c = true;
            update bypass;
    
            Test.startTest();
                Product_Line__c proLine = [Select Id from Product_Line__c limit 1];
                Account acc = [Select Id from Account limit 1];
                Order_Influence__c oi = new UTIL_TestFactory.OrderInfluenceFactory().createOrderInfluence(acc.Id, proLine.Id);
                try{
                    insert oi;
                }catch(Exception e){
                    //System.assert(e.getMessage().contains('Your Order Influence can\'t be registered because you are not assigned in at least one of the Account\'s Territories.'));
                }
            Test.stopTest();
            
        }
       
    }

    static testMethod void testOrderInfluenceUpdate(){
        System.runAs(adminUser) {
            BypassTrigger__c bypass = [SELECT Id, SetupOwnerId FROM BypassTrigger__c  Limit 1];
            bypass.Activatetrigger__c = true;
            update bypass;
    
            Test.startTest();
                Product_Line__c proLine = [Select Id from Product_Line__c limit 1];
                Account acc = [Select Id from Account limit 1];
                Order_Influence__c oi = [SELECT id FROM Order_Influence__c LIMIT 1];
                try{
                    update oi;
                }catch(Exception e){
                    //System.assert(e.getMessage().contains('Your Order Influence can\'t be registered because you are not assigned in at least one of the Account\'s Territories.'));
                }
            Test.stopTest();
            
        }
       
    }
}