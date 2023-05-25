@isTest
public with sharing class TH_UserTerritory2Association_TEST {    

    private static String SYSTEM_ADMINISTRATOR_PROFILE_NAME = 'System Administrator';
    private static String SYSTEM_ADMINISTRATOR_PROFILE_NAME_FR = 'Administrateur système';   
    private static String CEGID_TELEMARKETING_PROFILE_NAME = 'Cegid Telemarketing';
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  

    @testSetup
    static void setup() {
    
        List<Account> accounts = new List<Account>();
        List<User> users = new List<User>();        
        
        // insert 100 users
        for (Integer i=0;i<10;i++) {
            users.add(new User(
                alias = 'Test',
                email = i+'test.magellan-admin@example.com',
                emailencodingkey = 'UTF-8',
                BypassPB__c = true,
                BypassVR__c = true,
                BypassWF__c = true,
                lastname = 'testAdmin'+i,
                languagelocalekey = 'fr',
                localesidkey = 'fr_FR',
                profileid = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :CEGID_TELEMARKETING_PROFILE_NAME
                    LIMIT 1
                ][0].Id,
                timezonesidkey = 'Europe/Paris',
                username = 'test.magellan-admin1' + System.now().millisecond()
                + UserInfo.getOrganizationId() + '@example.com'
            ));
        }
        insert users;   
        
        // insert 100 accounts
        for (Integer i=0;i<10;i++) {
            accounts.add(new Account(	
            Name= 'Test Account AZA2'+i,
            National_ID_Exception__c ='Empty on loading',
            BillingPostalCode ='75009',
            BillingCountry ='France',
            BillingCity ='Paris',
            No_of_Employees_Group__c =15,
            No_of_Stores__c =7,
            NumberOfEmployees =14,
            //National_ID__c='1012151415124'+i,
            OwnerId = users.get(i).Id
                                   ));
            
            
        }
        insert accounts;          
    }

    @isTest static void testInsert() {
        System.runAs(adminUser){ 
        String CEGID_TELEMARKETING_PROFILE_NAME = 'Cegid Telemarketing';
        List<ObjectTerritory2Association> objectTerritory2Associations = new List<ObjectTerritory2Association>();
        List<UserTerritory2Association> userTerritory2Associations = new List<UserTerritory2Association>();
        List<Territory2> territories = new List<Territory2>();
        
        Territory2Model territoryModel = [select Id,Name From Territory2Model  Where State <> 'Archived' limit 1];

        Territory2Type territoryType = [select Id,MasterLabel From Territory2Type where MasterLabel='Hierarchy Territory' limit 1]; 
        // insert 10 Territories
        for (Integer i=0;i<10;i++) {
            Integer j = 1;
            if(i<9){
            j = i + 1;    
            }

            territories.add(new Territory2(Name = 'Cegid Test'+i,
            TerritoryCode__c ='344'+i,
            DeveloperName= 'Cegid_Test'+i,
            Territory2ModelId=territoryModel.Id,
            BU__c='105',                                      
            Channel__c='00'+j,
            Territory2TypeId=territoryType.Id));
        }        
        insert territories;
        
        // find the account just inserted. add objectTerritory2Association for each
       List<id> usersId = new List<id>();
        Integer j = 0;
        for (Account account : [select Id, Name, OwnerId from account]) {
            System.debug('TEST objectTerritory2Associations : account OwnerId :'+account.OwnerId);
            System.debug('TEST objectTerritory2Associations : territories Id :'+territories.get(j).Id);
            
            objectTerritory2Associations.add(new ObjectTerritory2Association(Territory2Id=territories.get(j).Id,
                                             ObjectId=account.Id,
                                             AssociationCause = 'Territory2Manual'));
            usersId.add(account.OwnerId);
            j++;
        }
        insert objectTerritory2Associations;
       
       
       for (Integer i=0;i<10;i++) {
           System.debug('TEST userTerritory2Associations : territories Id :'+territories.get(i).Id);
                userTerritory2Associations.add(new UserTerritory2Association(
                Territory2Id =territories.get(i).Id,
                UserId = usersId.get(i)
            ));
        }        

        Test.startTest();

        List<Database.SaveResult> result = Database.insert(userTerritory2Associations);
        Test.stopTest();
        
       }
     }

    @isTest static void testDelete() {
        System.runAs(adminUser){ 
        String CEGID_TELEMARKETING_PROFILE_NAME = 'Cegid Telemarketing';
        List<ObjectTerritory2Association> objectTerritory2Associations = new List<ObjectTerritory2Association>();
        List<UserTerritory2Association> userTerritory2Associations = new List<UserTerritory2Association>();
        List<Territory2> territories = new List<Territory2>();
        
        Territory2Model territoryModel = [select Id,Name From Territory2Model Where State <> 'Archived' limit 1];

        Territory2Type territoryType = [select Id,MasterLabel From Territory2Type where MasterLabel='Hierarchy Territory' limit 1]; 
        Profile  profile  = [SELECT Id FROM Profile WHERE Name = :CEGID_TELEMARKETING_PROFILE_NAME LIMIT 1 ];
        List<User> users = [Select Id From User where profileid = :profile.Id];
        // insert 10 Territories
        for (Integer i=0;i<10;i++) {
            Integer j = 1;
            if(i<9){
            j = i + 1;    
            }

            territories.add(new Territory2(Name = 'Cegid Test'+i,
            TerritoryCode__c ='344'+i,
            DeveloperName= 'Cegid_Test'+i,
            Territory2ModelId=territoryModel.Id,
            BU__c='105',                                      
            Channel__c='00'+j,
            Territory2TypeId=territoryType.Id));
        }
        System.debug('TEST territories :: '+territories.size());        
        insert territories;
        
        // find the account just inserted. add objectTerritory2Association for each
        Integer j = 0;
        for (Account account : [select Id, Name, OwnerId from account]) {
            objectTerritory2Associations.add(new ObjectTerritory2Association(Territory2Id=territories.get(j).Id,
                                             ObjectId=account.Id,
                                             AssociationCause = 'Territory2Manual'));
            j++;
        }
        System.debug('TEST objectTerritory2Associations :: '+objectTerritory2Associations.size());    
        insert objectTerritory2Associations;
        
        for (Integer i=0;i<10;i++) {
                userTerritory2Associations.add(new UserTerritory2Association(
                Territory2Id =territories.get(i).Id,
                UserId = users.get(i).Id
            ));
        }
		insert userTerritory2Associations;            
        System.debug('userTerritory2Associations Size :: '+userTerritory2Associations.size());    
            
                      
        Test.startTest();

            
        List<UserTerritory2Association> listUserTerr = [select Id from UserTerritory2Association where Territory2.Territory2Model.State <> 'Archived' and User.ProfileId <> :profile.Id];
                              
		System.debug('listUserTerr size :: '+listUserTerr.get(0).Id);
        Database.DeleteResult result = Database.delete(listUserTerr.get(0));
        Test.stopTest();

       }
     }
}