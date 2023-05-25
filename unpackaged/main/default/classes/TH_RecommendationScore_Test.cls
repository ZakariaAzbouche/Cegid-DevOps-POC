@isTest
public class TH_RecommendationScore_Test {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();        
    static User salesUser = new UTIL_TestFactory.UserFactory().createUserCegidSales();
    static User salesUser2 = new UTIL_TestFactory.UserFactory().createUserCegidSales();
    static User salesUser3 = new UTIL_TestFactory.UserFactory().createUserCegidSales();

    @isTest static void generateTaskTest() {
        
        Id TERR_TYPE = [SELECT Id FROM Territory2Type Limit 1].Id;
        Id TERR_MODEL = [SELECT Id FROM Territory2Model][1].Id;
        
        //BU Finance test
        Account acc1_Finance = new Account();
        acc1_Finance.Name= 'Test Account 1 CSM CAP'+System.now().millisecond();
        acc1_Finance.National_ID_Exception__c ='Empty on loading';
        acc1_Finance.BillingPostalCode ='75009';
        acc1_Finance.BillingCountry ='France';
        acc1_Finance.BillingCity ='Paris';
        acc1_Finance.No_of_Employees_Group__c = 15;
        acc1_Finance.No_of_Stores__c = 7;
        acc1_Finance.NumberOfEmployees = 14;
                        
        insert acc1_Finance;

		Contact c1_Finance = new Contact(LastName = 'LName'+System.now().millisecond(),
                                         FirstName = 'FName'+System.now().millisecond(),
                                         Salutation='Mr.',
                                         email = 'lname'+System.now().millisecond()+'@email.com',
                                         AccountId = acc1_Finance.Id,
                                         Service__c = 'IT',
                                         Function__c = 'IT Dir.');

        insert c1_Finance;
        //
        
        //BU Other test
        Account acc2 = new Account();
        acc2.Name= 'Test Account 2 CSM CAP'+System.now().millisecond();
        acc2.National_ID_Exception__c ='Empty on loading';
        acc2.BillingPostalCode ='69100';
        acc2.BillingCountry ='France';
        acc2.BillingCity ='Lyon';
        acc2.No_of_Employees_Group__c = 24;
        acc2.No_of_Stores__c = 6;
        acc2.NumberOfEmployees = 44;
                        
        insert acc2;

		Contact c2 = new Contact(LastName = 'LName'+System.now().millisecond(),
                                 FirstName = 'FName'+System.now().millisecond(),
                                 Salutation='Mr.',
                                 email = 'lname'+System.now().millisecond()+'@email.com',
                                 AccountId = acc2.Id,
                                 Service__c = 'IT',
                                 Function__c = 'IT Dir.');

        insert c2;
        //
        
        //Create Terrs and Account Expertise
        List<Account_Expertise__c> accExper = new List<Account_Expertise__c>();
        
        accExper.add(new Account_Expertise__c(Account__c=acc1_Finance.Id, MRR__c = 2000, Expertise__c='350'));
        accExper.add(new Account_Expertise__c(Account__c=acc1_Finance.Id, MRR__c = 3400, Expertise__c='360'));
        accExper.add(new Account_Expertise__c(Account__c=acc2.Id, MRR__c = 3434, Expertise__c='380'));
        
        insert accExper;
        
        System.runAs(adminUser) {
            
            insert salesUser;
            insert salesUser2;
            insert salesUser3;
        
            List<Territory2> accTerrs = new List<Territory2>();
            
            accTerrs.add(new Territory2(DeveloperName='CSM1_TEST', BU__c = '316', Expertise__c = '360', Name='CSM1_TEST', Territory2ModelId=TERR_MODEL, Territory2TypeId=TERR_Type));
            accTerrs.add(new Territory2(DeveloperName='CSM2_TEST', BU__c = '319', Expertise__c = '380', Name='CSM2_TEST', Territory2ModelId=TERR_MODEL, Territory2TypeId=TERR_Type));
            accTerrs.add(new Territory2(DeveloperName='CSM3_TEST', BU__c = '316', Expertise__c = '350', Name='CSM3_TEST', Territory2ModelId=TERR_MODEL, Territory2TypeId=TERR_Type));
            
            insert accTerrs;
        
            List<ObjectTerritory2Association> objTerrAssos = new List<ObjectTerritory2Association>();
            
            objTerrAssos.add(new ObjectTerritory2Association(Territory2Id = accTerrs[0].Id, ObjectId = acc1_Finance.Id, AssociationCause='Territory2Manual'));
            objTerrAssos.add(new ObjectTerritory2Association(Territory2Id = accTerrs[2].Id, ObjectId = acc1_Finance.Id, AssociationCause='Territory2Manual'));
            objTerrAssos.add(new ObjectTerritory2Association(Territory2Id = accTerrs[1].Id, ObjectId = acc2.Id, AssociationCause='Territory2Manual'));
            
            insert objTerrAssos;
            
            List<UserTerritory2Association> userForAccMRR = new List<UserTerritory2Association>();
            
            userForAccMRR.add(new UserTerritory2Association(Territory2Id = accTerrs[0].Id, UserId = salesUser.Id, RoleInTerritory2='CSM'));
            userForAccMRR.add(new UserTerritory2Association(Territory2Id = accTerrs[0].Id, UserId = salesUser3.Id, RoleInTerritory2='CSM'));
            userForAccMRR.add(new UserTerritory2Association(Territory2Id = accTerrs[1].Id, UserId = salesUser2.Id, RoleInTerritory2='CSM'));
            
            insert userForAccMRR;
            
        }
        //

        List<Recommendation_score__c> rcScores = new List<Recommendation_score__c>();

        rcScores.add(new Recommendation_score__c(Contact__c = c1_Finance.Id,
                                                 Asked_to_be_contacted_back__c = true,
                                                 Recommendation_score__c = 8,
                                                 Team_in_charge_of_contacting_back__c = 'CSM'));
        
        rcScores.add(new Recommendation_score__c(Contact__c = c2.Id,
                                                 Asked_to_be_contacted_back__c = true,
                                                 Recommendation_score__c = 8,
                                                 Team_in_charge_of_contacting_back__c = 'CSM'));
        
        insert rcScores;
        
        List<Recommendation_score__c> rcScores2Update = new List<Recommendation_score__c>();
        rcScores = [SELECT Contact__c, 
                    Asked_to_be_contacted_back__c,
                    Recommendation_score__c,
                    Team_in_charge_of_contacting_back__c 
                    FROM Recommendation_score__c];         
        
        for(Recommendation_score__c rcScore : rcScores) {
            rcScore.Recommendation_score__c = 2; 
            rcScores2Update.add(rcScore);
        }

        Test.startTest();
        	List<Database.SaveResult> results = Database.update(rcScores2Update, false);
        Test.stopTest();

    }

}