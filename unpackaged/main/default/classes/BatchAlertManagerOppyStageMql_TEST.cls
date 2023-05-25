@IsTest
public with sharing class BatchAlertManagerOppyStageMql_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  
    
    @testSetup
    static void setup() {
      insert adminUser;
      System.runAs(adminUser){
        
        User adminUserManager = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  
         adminUserManager.email = 'testManager@test.fr';
        insert adminUserManager;


       adminUser.ManagerId = adminUserManager.Id;
       update adminUser;
      
        adminUser.Manager = adminUserManager;
        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        insert acc;
    
        List<Territory2Model> Territory2Models = [SELECT Id FROM Territory2Model WHERE state = 'active' LIMIT 1];
        List<Territory2Type> TerritoryTypes = [SELECT Id FROM Territory2Type LIMIT 1];
        Territory2 terr = new Territory2(Name='testTerritoryAlliance', DeveloperName='testTerritoryDevName', Territory2ModelId=Territory2Models[0].Id, Territory2TypeId=TerritoryTypes[0].Id);
        insert terr;

        List<Opportunity> opps = new List<Opportunity>();
        Integer nbOpp = 10;
        for(Integer i = 0; i < nbOpp; i++) {
          Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, true);
          opp.StageName = 'G - MQL';
          opp.Last_Alerte_For_Managers_MQL__c = Datetime.now().addDays(-8);
          opp.OwnerId = adminUser.Id;
          opp.CreatedById = adminUser.Id;
          opp.Owner = adminUser;
          opp.Territory2 = terr;
          opps.add(opp);
        }
          
        insert opps;
          for(Opportunity opp : opps) {
              System.debug(opp);
              System.debug(opp.Owner.Manager.email);
              System.debug(opp.Territory2);
              System.debug(opp.Territory2.Name);
              System.debug(opp.OwnerId);
              System.debug(opp.Territory2.Name != null && opp.Territory2.Name.contains('Alliance') && opp.OwnerId == opp.CreatedById);
              
          }
      } 
        
    }

    @isTest static void testBatch() {

        Test.startTest();        
        BatchAlertManagerOppyStageMql batch = new BatchAlertManagerOppyStageMql();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

     }
}