@isTest
public class TH_Opportunity_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();        
    static User salesUser = new UTIL_TestFactory.UserFactory().createUserCegidSales();
    static User salesUser2 = new UTIL_TestFactory.UserFactory().createUserCegidSales();
    static User salesUser3 = new UTIL_TestFactory.UserFactory().createUserCegidSales();
    
    @testSetup static void setup() {
        System.runAs(adminUser) {       
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
            
            
            
            Test.startTest();
            List<Account> accs = new List<Account>();
            for(Integer i = 0 ; i < 5 ; i++) {
                Account acc = new Account();
                acc.Name= 'Test Account AZA2 '+i;
                acc.National_ID_Exception__c ='Empty on loading';
                acc.BillingPostalCode ='75009';
                acc.BillingCountry ='France';
                acc.BillingCity ='Paris';
                acc.No_of_Employees_Group__c = 15;
                acc.No_of_Stores__c = 7;
                acc.NumberOfEmployees = 14;

                accs.add(acc);
            }
                        

            insert accs;
                  
            Opportunity oppToInsert = New Opportunity();
            oppToInsert.Name='test azas2';
            oppToInsert.AccountId=accs[0].Id;
            oppToInsert.StageName='G - MQL';
            oppToInsert.Sales_Purpose__c='121';
            oppToInsert.CurrencyIsoCode='EUR';
            oppToInsert.Forecast_Category_EDIT__c='Omitted';
            oppToInsert.CloseDate=date.today();
            oppToInsert.LeadSource='Sales Prospecting';
            oppToInsert.Competitors__c = 'ADP';  
            
            insert oppToInsert;

            List<User> users = new List<User>();
        
            for(Integer i = 0 ; i < 5 ; i++) {
                User u = new UTIL_TestFactory.UserFactory().createUserCegidSales();
                u.IsActive = true;
                users.add(u);
            }

            insert users;
            List<Territory2> terr2s = [SELECT Id, DeveloperName 
            FROM Territory2
            WHERE Territory2Model.state = 'Active'
            LIMIT 5];
            List<ObjectTerritory2Association> objTerrAssos = new List<ObjectTerritory2Association>();
        for(Integer i = 0 ; i < 5 ; i++) {
            objTerrAssos.add(new ObjectTerritory2Association(Territory2Id = terr2s[i].Id, ObjectId = accs[i].Id, AssociationCause='Territory2Manual'));
        }

        insert objTerrAssos;
               
            Test.stopTest();
        }
    }
    
   /*     static testMethod void testCheckValidEmailDecisionMaker(){      	
            System.runAs(adminUser){      
        List<Opportunity> oppList = [select Id,Name,StageName From Opportunity  Where stageName != 'Closed Won' Limit 1] ;
        List<Contact> contactList = [select id,name,Mkto_email_invalid__c from contact Limit 1];
        
        System.debug('contact = '+contactList); 
        List<OpportunityContactRole> oppyRoleList = new List<OpportunityContactRole>();
        List<Opportunity> oppListToUpdate  = new List<Opportunity>();
        List<Contact> ContactListToUpdate  = new List<Contact>();
        for (Opportunity opp : oppList) {
           opp.StageName ='D - Draw up the solution';
           for (Contact contact : contactList) {
            oppyRoleList.add(new OpportunityContactRole(OpportunityId = opp.Id ,ContactId = contact.Id,Role ='Decision Maker'));
            contact.Mkto_email_invalid__c = true ;
            ContactListToUpdate.add(contact) ; 
          //  continue ;   
           } 
           oppListToUpdate.add(opp);

        }
            List<Account> listAcc = [Select Id, Name From Account Limit 1];
            Opportunity opp = New Opportunity();
            opp.Name='test';
            opp.AccountId=listAcc[0].Id;
            opp.StageName='G - MQL';
            opp.Sales_Purpose__c='121';
            opp.CurrencyIsoCode='EUR';
            opp.Forecast_Category_EDIT__c='Omitted';
            opp.CloseDate=date.today();
            opp.LeadSource='Sales Prospecting';
            //
            Test.startTest();
            insert opp;
            insert oppyRoleList ;
            update ContactListToUpdate ;
             try {
        		update oppListToUpdate ;         
             } catch (DmlException e) {
                 String message = e.getMessage();
       			// System.assert(e.getMessage().contains(System.Label.VR_checkEmailValidDecisionMaker), 'message=' + e.getMessage());
             }
             Test.stopTest();   
            }
    }*/

        @isTest static void testUpdateWinningCompetitor() {
        System.runAs(adminUser){  
            Opportunity opp = [SELECT id, Name FROM Opportunity WHERE Name LIKE 'test azas2'];        
            System.debug('Update Opp ');
            opp.StageName = 'Closed Lost';
            opp.Loss_Reason__c = 'Competition choosen';            
            opp.Competitors__c = 'ADP;APTOS';
              
            
            // Perform test
            Test.startTest();
            
            Database.SaveResult result = Database.update(opp, false);
            Test.stopTest();
            //System.assert(result.isSuccess());
        }               
    }

    //AZI - W-001685
    
     static testMethod void testCheckContactBeforValidateTheSolutionStage() {
        System.runAs(adminUser){ 
     		//Add  Territory2
            List<Territory2> terrList = [Select Id From Territory2  where Territory2Model.State <> 'Archived'];
            terrList[0].Business__c = 'Value';

            update terrList[0];

            Opportunity opp = [select StageName, Territory2Id, Sales_Purpose__c from Opportunity where Name LIKE 'test azas2'];        
            System.debug('Update Opp ');
            opp.StageName = 'C - Validate the solution';
            opp.Territory2Id = terrList[0].Id;
            opp.Sales_Purpose__c = 'Renew';
            
            // Perform test
            Test.startTest();
            
            Database.SaveResult result = Database.update(opp, false);
            Test.stopTest();
            //System.assert(result.isSuccess());
        }               
    }
    //END AZI - W-001685    

    private static void affectLeadSourceFromUserTypeData() {
        
        insert salesUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Ecosystem_Relationships_Management'];
        insert new PermissionSetAssignment(AssigneeId = salesUser.id, PermissionSetId = ps.Id);    
        
        List<Territory2Model> terrModels = [SELECT Id FROM Territory2Model WHERE DeactivatedDate = null];
        List<Territory2Type> terrTypes = [SELECT Id FROM Territory2Type];
        Territory2 terrTest = new Territory2(Name = 'Test', DeveloperName = 'Test', Expertise__c='110', territory2ModelId=terrModels[0].Id, Territory2TypeId=terrTypes[0].Id);

        insert terrTest;
        
        UserTerritory2Association usrTerr = new UserTerritory2Association(UserId = salesUser.Id, Territory2Id=terrTest.Id);

        insert usrTerr;
        
    }

    

    @isTest static void affectLeadSourceFromUserTypeSDRTest() {
        affectLeadSourceFromUserTypeData();

        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 100 ; i++) {
            opps.add(new Opportunity(Name = 'Test opp '+i, AccountId = acc.Id, StageName = 'G - Sales Ready'));
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        salesUser.Sale_Type__c = 'SDR';

        System.debug(salesUser);
        Test.startTest();
        System.runAs(salesUser) {
            thOpp.affectLeadSourceFromUserType(opps);
        }
        Test.stopTest();
    }

    @isTest static void affectLeadSourceFromUserTypeNoSDRTest() {
        affectLeadSourceFromUserTypeData();

        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 100 ; i++) {
            opps.add(new Opportunity(Name = 'Test opp '+i, AccountId = acc.Id, StageName = 'G - Sales Ready'));
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
        System.runAs(salesUser) {
            thOpp.affectLeadSourceFromUserType(opps);
        }
        Test.stopTest();

        Integer nbOppLSourcePartner = 0;

        for(Opportunity opp : opps) {
            if(opp.LeadSource == 'Partner') {
                nbOppLSourcePartner++;
            }
        }

        System.assertEquals(100, nbOppLSourcePartner, 'There are 100 opp with Lead source = partner');
    }

    @isTest static void affectLeadSourceFromUserTypeNoSDRNoPartnerTest() {
        affectLeadSourceFromUserTypeData();

        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 100 ; i++) {
            opps.add(new Opportunity(Name = 'Test opp '+i, AccountId = acc.Id, StageName = 'G - Sales Ready'));
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
        System.runAs(salesUser2) {
            thOpp.affectLeadSourceFromUserType(opps);
        }
        Test.stopTest();

        
    }

    @isTest static void affectLeadSourceFromUserTypeExpertiseMatchOppTest() {

        Account acc = new Account();
        acc.Name= 'TestAccount 6';
        acc.BillingPostalCode ='69006';
        acc.BillingCountryCode ='AD';
        acc.National_ID__c = '012563412563799';
        acc.BillingCity ='Lyon';
        acc.No_of_Employees_Group__c =60;
        acc.No_of_Stores__c =1;
        acc.NumberOfEmployees =90;            

        System.runAs(adminUser) {
            insert acc;
        }

        Account_Expertise__c accExp = new Account_Expertise__c(Account__c = acc.Id, expertise__c = '110');
        insert accExp;
        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 100 ; i++) {
            opps.add(new Opportunity(Name = 'Test opp '+i, AccountId = acc.Id, StageName = 'G - Sales Ready', expertise__c = '110'));
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
        System.runAs(salesUser2) {
            thOpp.affectLeadSourceFromUserType(opps);
        }
        Test.stopTest();

        Integer nbOppLSourceNull = 0;

        for(Opportunity opp : opps) {
            if(opp.LeadSource == null && opp.Sales_purpose__c == null) {
                nbOppLSourceNull++;
            }
        }

        System.assertEquals(100, nbOppLSourceNull, 'There are 100 opp with Lead source = null and Sales prupose = null');
    }

    @isTest static void affectLeadSourceFromUserTypeExpertiseNoMatchOppTest() {

        Account acc = new Account();
        acc.Name= 'TestAccount 3';
        acc.BillingPostalCode ='69006';
        acc.BillingCountryCode ='AD';
        acc.National_ID__c = '012563412563299';
        acc.BillingCity ='Lyon';
        acc.No_of_Employees_Group__c =60;
        acc.No_of_Stores__c =1;
        acc.NumberOfEmployees =90;            

        System.runAs(adminUser) {
            insert acc;
        }

        Account_Expertise__c accExp = new Account_Expertise__c(Account__c = acc.Id, expertise__c = '110');
        insert accExp;
        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 100 ; i++) {
            opps.add(new Opportunity(Name = 'Test opp '+i, AccountId = acc.Id, StageName = 'G - Sales Ready'));
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
        System.runAs(salesUser2) {
            thOpp.affectLeadSourceFromUserType(opps);
        }
        Test.stopTest();
        Integer nbOppCrossSell = 0;

        for(Opportunity opp : opps) {
            if(opp.LeadSource == 'Sales Cross Sell' && opp.Sales_purpose__c == '121') {
                nbOppCrossSell++;
            }
        }

        //System.assertEquals(100, nbOppCrossSell, 'There are 100 opp with Cross-sell and Sales prupose = 121');
    }

    @isTest static void affectLeadSourceFromUserTypeNothingTest() {

        Account acc = new Account();
        acc.Name= 'TestAccount 2';
        acc.BillingPostalCode ='69006';
        acc.BillingCountryCode ='AD';
        acc.National_ID__c = '012563412563298';
        acc.BillingCity ='Lyon';
        acc.No_of_Employees_Group__c =60;
        acc.No_of_Stores__c =1;
        acc.NumberOfEmployees =90;            

        System.runAs(adminUser) {
            insert acc;
        }
        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 100 ; i++) {
            opps.add(new Opportunity(Name = 'Test opp '+i, AccountId = acc.Id, StageName = 'G - Sales Ready'));
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
        System.runAs(salesUser2) {
            thOpp.affectLeadSourceFromUserType(opps);
        }
        Test.stopTest();

        Integer nbOppCrossSell = 0;

        for(Opportunity opp : opps) {
            if(opp.LeadSource == 'Sales Cross Sell' && opp.Sales_purpose__c == '121') {
                nbOppCrossSell++;
            }
        }

        //System.assertEquals(100, nbOppCrossSell, 'There are 100 opp with Cross-sell and Sales prupose = 121');
    }

    @isTest static void updateOppyAttributesTest() {
        Territory2 terr = [SELECT Id,
                                  BU__c, 
                                  CommercialOrganization__c,
                                  Sales_Region__c, 
                                  Job__c, 
                                  TerritoryCode__c,
                                  Channel__c,
                                  Agency__c 
                           FROM Territory2
                           LIMIT 1];
        Opportunity opp1 = new Opportunity();
        Opportunity opp2 = new Opportunity();
        User usr1 = new User(Sale_Type__c = 'Inside Sales', Agency__c = '552');
        User usr2 = new User(Sale_Type__c = 'SDR', Agency__c = '217');

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
            thOpp.updateOppyAttributes(opp1, terr, usr1);
            thOpp.updateOppyAttributes(opp2, terr, usr2);
        Test.stopTest();

        system.assertEquals(terr.Id, opp1.territory2Id, 'Opp1 Terr ID missmatch');
        system.assertEquals(terr.BU__c, opp1.BU__c, 'Opp1 BU__c missmatch');
        system.assertEquals(terr.CommercialOrganization__c, opp1.CommercialOrganization__c, 'Opp1 CommercialOrganization__c missmatch');
        system.assertEquals(terr.Sales_Region__c, opp1.Sales_Region__c, 'Opp1 Sales_Region__c missmatch');
        system.assertEquals(terr.Job__c, opp1.Job__c, 'Opp1 Job__c missmatch');
        system.assertEquals(terr.TerritoryCode__c, opp1.TerritoryCode__c, 'Opp1 TerritoryCode__c missmatch');
        system.assertEquals('003', opp1.Channel__c, 'Opp1 Channel__c missmatch');
        system.assertEquals(usr1.Agency__c, opp1.Agency__c, 'Opp1 Agency__c missmatch');

        system.assertEquals(terr.Id, opp2.territory2Id, 'Opp2 Terr ID missmatch');
        system.assertEquals(terr.BU__c, opp2.BU__c, 'Opp2 BU__c missmatch');
        system.assertEquals(terr.CommercialOrganization__c, opp2.CommercialOrganization__c, 'Opp2 CommercialOrganization__c missmatch');
        system.assertEquals(terr.Sales_Region__c, opp2.Sales_Region__c, 'Opp2 Sales_Region__c missmatch');
        system.assertEquals(terr.Job__c, opp2.Job__c, 'Opp2 Job__c missmatch');
        system.assertEquals(terr.TerritoryCode__c, opp2.TerritoryCode__c, 'Opp2 TerritoryCode__c missmatch');
        system.assertEquals(terr.Channel__c, opp2.Channel__c, 'Opp2 Channel__c missmatch');
        system.assertEquals(terr.Agency__c, opp2.Agency__c, 'Opp2 Agency__c missmatch');
    }

    @isTest static void oppyTerritoryCalculationOnInsertTest() {
        
        insert salesUser3;
        insert adminUser;
        
        List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 10];

        System.debug(users);
        List<Territory2> terr2s = [SELECT Id, DeveloperName 
                                   FROM Territory2
                                   WHERE Territory2Model.state = 'Active'
                                   LIMIT 5];
        
        List<UserTerritory2Association> userTerrAssos = new List<UserTerritory2Association>();
        for(Integer i = 0 ; i < 5 ; i++) {
            userTerrAssos.add(new UserTerritory2Association(Territory2Id = terr2s[i].Id, UserId = salesUser3.Id, RoleInTerritory2='Opportunity Owner'));
        }

        
        insert userTerrAssos;
        
        
       /* List<Account> accs = new List<Account>();
        for(Integer i = 0; i < 5 ; i++) {
            accs.add(new Account(Name='Acc name '+i, National_ID_Exception__c='	Creation In progress', BillingPostalCode ='69006', 
            BillingCountryCode ='AD',
            BillingCity = 'Lyon'));
        }

        insert accs;*/
        List<Account> accs = [SELECT Id FROM Account LIMIT 5];

        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 150 ; i++) {
            if(i < 30) {
                opps.add(new Opportunity(AccountId = accs[0].Id, OwnerId = adminUser.Id));
            } else if(i >= 30 && i < 60) {
                opps.add(new Opportunity(AccountId = accs[1].Id, OwnerId = salesUser3.Id));
            } else if(i >= 60 && i < 90) {
                opps.add(new Opportunity(AccountId = accs[2].Id, OwnerId = adminUser.Id));
            } else if(i >= 90 && i < 120) {
                opps.add(new Opportunity(AccountId = accs[3].Id, OwnerId = adminUser.Id));
            } else if(i >= 120 && i < 150) {
                opps.add(new Opportunity(AccountId = accs[4].Id, OwnerId = adminUser.Id));
            }
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
            thOpp.oppyTerritoryCalculation(opps, true);
        Test.stopTest();

    }

    @isTest static void oppyTerritoryCalculationOnUpdateTest() {
        
        insert salesUser3;
        insert adminUser;
        
        List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 10];

        System.debug(users);
        List<Territory2> terr2s = [SELECT Id, DeveloperName 
                                   FROM Territory2
                                   WHERE Territory2Model.state = 'Active'
                                   LIMIT 5];
        
        List<UserTerritory2Association> userTerrAssos = new List<UserTerritory2Association>();
        for(Integer i = 0 ; i < 5 ; i++) {
            userTerrAssos.add(new UserTerritory2Association(Territory2Id = terr2s[i].Id, UserId = salesUser3.Id, RoleInTerritory2='Opportunity Owner'));
        }

        
        insert userTerrAssos;
        
        
       /* List<Account> accs = new List<Account>();
        for(Integer i = 0; i < 5 ; i++) {
            accs.add(new Account(Name='Acc name '+i, National_ID_Exception__c='	Creation In progress', BillingPostalCode ='69006', 
            BillingCountryCode ='AD',
            BillingCity = 'Lyon'));
        }

        insert accs;*/
        List<Account> accs = [SELECT Id FROM Account LIMIT 5];

        
        List<Opportunity> opps = new List<Opportunity>();

        for(Integer i = 0 ; i < 150 ; i++) {
            if(i < 30) {
                opps.add(new Opportunity(AccountId = accs[0].Id, OwnerId = adminUser.Id));
            } else if(i >= 30 && i < 60) {
                opps.add(new Opportunity(AccountId = accs[1].Id, OwnerId = salesUser3.Id));
            } else if(i >= 60 && i < 90) {
                opps.add(new Opportunity(AccountId = accs[2].Id, OwnerId = adminUser.Id));
            } else if(i >= 90 && i < 120) {
                opps.add(new Opportunity(AccountId = accs[3].Id, OwnerId = adminUser.Id));
            } else if(i >= 120 && i < 150) {
                opps.add(new Opportunity(AccountId = accs[4].Id, OwnerId = adminUser.Id));
            }
        }

        TH_Opportunity thOpp = new TH_Opportunity();

        Test.startTest();
            thOpp.oppyTerritoryCalculation(opps, false);
        Test.stopTest();

    }
}