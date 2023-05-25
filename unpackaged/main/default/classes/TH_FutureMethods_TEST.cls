@isTest
public class TH_FutureMethods_TEST {
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    private static String CEGID_TELEMARKETING_PROFILE_NAME = 'Cegid Telemarketing';

    @testSetup static void setup(){
        System.runAs(adminUser){       
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
                
   
            Account acc = new Account();
            acc.Name= 'Test Account AZA2';
            acc.National_ID_Exception__c ='Empty on loading';
            acc.BillingPostalCode ='75009';
            acc.BillingCountry ='France';
            acc.BillingCity ='Paris';
            acc.No_of_Employees_Group__c =15;
            acc.No_of_Stores__c =7;
            acc.NumberOfEmployees =14;            

            insert acc;
                  
            Opportunity oppToInsert = New Opportunity();
            oppToInsert.Name='test azas2';
            oppToInsert.AccountId=acc.Id;
            oppToInsert.StageName='G - MQL';
            oppToInsert.Sales_Purpose__c='121';
            oppToInsert.CurrencyIsoCode='EUR';
            oppToInsert.Forecast_Category_EDIT__c='Omitted';
            oppToInsert.CloseDate=date.today();
            oppToInsert.LeadSource='Sales Prospecting';
            oppToInsert.Competitors__c = 'ADP';  
            
            insert oppToInsert;
               
            ////// 
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
                Name= 'Account userTerritory2Associations AZA'+i,
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
    }

    static testMethod void testUpdateOppyAndAccount() {
        System.runAs(adminUser){  
            Opportunity opp = [select id,Name from Opportunity where Name LIKE 'test azas2'];        
            System.debug('Update Opp ');
            opp.StageName = 'Closed Lost';
            opp.Loss_Reason__c = 'Competition choosen';            
            opp.Competitors__c = 'ADP;APTOS';
              
            Account acc = [select id,Name from Account where Name LIKE 'Test Account AZA2'];  
            acc.Name = 'Test Account AZA2 Update'; 
            
            // Perform test
            Test.startTest();            
            Database.SaveResult result = Database.update(opp, false);
            Database.SaveResult resultAcc = Database.update(acc, false);
            Test.stopTest();
            System.assert(result.isSuccess());
        }               
    }


     static testMethod void testCreateLeadWithTelemarketingProfile() {
        System.runAs(createUserTelemarketing()){  
            
            List<Account> accInserted = [Select Id From Account Where Name Like 'Test Account AZA2'];

            Account acc = new Account();
            if(accInserted == null || accInserted.size() == 0){

                acc.Name= 'Test Account AZA2';
                acc.National_ID_Exception__c ='Empty on loading';
                acc.BillingPostalCode ='75009';
                acc.BillingCountry ='France';
                acc.BillingCity ='Paris';
                acc.No_of_Employees_Group__c =15;
                acc.No_of_Stores__c =7;
                acc.NumberOfEmployees =14;            
                acc.Type ='Partner';    

                insert acc;
            }else{
                acc = accInserted[0];
            }

            RecordType recordTypeLeadTelemarketing = [Select Id From RecordType Where Name = 'Lead Telemarketing'];                          
            List<Lead> existedLead = [Select Status, Email From Lead Where Status <> 'Assigned' AND Status <> 'In Progress' AND Status <> 'Qualified'];
            
            Lead l = new Lead();
            if(existedLead == null || existedLead.size() == 0){                           
                l.FirstName='Test1111';
                l.LastName='Test1111';
                l.Service__c='HR';
                l.Function__c='Personnel Dir.';
                l.Status='Assigned';
                l.Company='test';
                l.Email='email@hello.com';
                l.RecordTypeId = recordTypeLeadTelemarketing.Id;
                l.Lead_s_Chosen_Solution__c = 'CPA';
                l.ImpartnerPRM__IsDealRegistration__c = false;
                l.ImpartnerPRM__PartnerAccount__c = acc.Id;
                
                Insert l;    
                
                Lead leadToUpdate = [Select Status From Lead Where Id=:l.Id];
                leadToUpdate.Status = 'New';
                update leadToUpdate;
            }

            Lead lead = new Lead();
            lead.FirstName='Test1112';
            lead.LastName='Test1112';
            lead.Service__c='HR';
            lead.Function__c='Personnel Dir.';
            lead.Status='Assigned';
            lead.Company='test 2';
            if(existedLead == null || existedLead.size() == 0){ 
            lead.Email='email@hello.com';
            }
            else{
            lead.Email=existedLead[0].Email;    
            }            
            lead.RecordTypeId = recordTypeLeadTelemarketing.Id;
            lead.Lead_s_Chosen_Solution__c = 'CPA';
            lead.ImpartnerPRM__IsDealRegistration__c = false;
            lead.ImpartnerPRM__PartnerAccount__c = acc.Id;            
            
            // Perform test
            Test.startTest();
            
            Database.SaveResult result = Database.insert(lead, false);
            Test.stopTest();
              for(Database.Error err : result.getErrors()) {
            		System.debug('The following error has occurred.');                    
            		System.debug(err.getStatusCode() + ': ' + err.getMessage());
            		System.debug('Lead fields that affected this error: ' + err.getFields());
        	}
            //System.assert(result.isSuccess());
        }               
    }

    public static User createUserTelemarketing() {
        /**
        * @description Crée un utilisateur de IM Partner
        */            
        User userImPartner = new User(
            alias = 'TestTele',
            email = 'testTele.sales@example.com',
            emailencodingkey = 'UTF-8',
            BypassPB__c = true,
            BypassVR__c = true,
            BypassWF__c = true,
            lastname = 'testsales',
            languagelocalekey = 'fr',
            localesidkey = 'fr_FR',
            profileid = [
                SELECT Id
                FROM Profile
                WHERE Name = :CEGID_TELEMARKETING_PROFILE_NAME
                LIMIT 1
            ][0].Id,
            timezonesidkey = 'Europe/Paris',
            username = 'test.impartner' + System.now().millisecond()
            + UserInfo.getOrganizationId() + '@example.com'
        );
        return userImPartner;
    }
    
     static testMethod void testIsOppyOwnerIsActifMemberOfTerritory() {
        System.runAs(adminUser){  
              
            List<Opportunity> oppyList = [select id,Name from Opportunity];  
            
            // Perform test
            Test.startTest();    
            Set<Id> oppiesId = new Set<Id>();
			for(Opportunity oppy : oppyList){                    
                    oppiesId.add(oppy.Id);
                }
            TH_FutureMethods.isOppyOwnerIsActifMemberOfTerritory(oppiesId);             
            Test.stopTest();
            //System.assert(result.isSuccess());
        }               
    }

}