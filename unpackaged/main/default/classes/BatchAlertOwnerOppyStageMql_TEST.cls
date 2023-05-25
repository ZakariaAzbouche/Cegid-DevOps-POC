@isTest
public with sharing class BatchAlertOwnerOppyStageMql_TEST {
    
  static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  
    
  @testSetup
  static void setup() {
    insert adminUser;
    System.runAs(adminUser){
      
      User adminUserManager = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  
       adminUserManager.email = 'testOwner@test.fr';
      insert adminUserManager;


     adminUser.ManagerId = adminUserManager.Id;
     update adminUser;
    
      adminUser.Manager = adminUserManager;
      Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
      acc.Name = 'Account Test Owner';
      insert acc;
      
      List<Opportunity> opps = new List<Opportunity>();
      Integer nbOpp = 10;
      for(Integer i = 0; i < nbOpp; i++) {
        Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, true);
        opp.StageName = 'G - MQL';
        opp.Last_Alerte_For_Sales_MQL__c = Datetime.now().addDays(-5);
        opp.OwnerId = adminUser.Id;
        opp.CreatedById = adminUser.Id;
        opp.Owner = adminUser;
        //opp.Territory2 = terr;
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
      System.runAs(adminUser){
          System.debug(adminUser);
      Test.startTest();        
      BatchAlertOwnerOppyStageMql batch = new BatchAlertOwnerOppyStageMql();
      Id batchId = Database.executeBatch(batch);
      Test.stopTest();
     }
   }
}