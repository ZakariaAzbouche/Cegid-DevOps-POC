@isTest
public class SM001_Opportunity_TEST {
    /**
* @author Keshav - Comforth
* @date 2020-02-04
* @group UTIL
* @description Classe SM001_Opportunity_TEST
*/
    /**
* @File Name          : TH_Opportunity
* @Description        : Update owner field based on territory when an opportunity is created from a contact
* @Author             : SRA   
* @Group              : Comforth-Karoo
* @Last Modified By   : SRA
* @Last Modified On   : 31/07/2020
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* ---    -----------       -------           ------------------------ 
* 1.0    31/07/2020         SRA              Initial Version
* ---    -----------       -------           ------------------------ 
**/
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        System.runAs(adminUser){       
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
                
            Test.startTest();
            List<Account> listAcc = new List<Account>();
            List<Contact> listCon = new List<Contact>();
            List<Opportunity> listOppConverted = new List<Opportunity>();
            List<Opportunity> listOppAutoCreate = new List<Opportunity>();
            List<ObjectTerritory2Association> listOTA = new List<ObjectTerritory2Association>();
            List<Territory2> listTerritory = [Select Id , Expertise__c from Territory2 where  Expertise__c='200' AND Territory2Model.State = 'Active']; 
            
            listAcc.add(new UTIL_TestFactory.AccountFactory().createAccount());
            listAcc[0].National_ID_Exception__c ='Empty on loading';
            listAcc[0].BillingPostalCode ='75008';
            listAcc[0].BillingCountry ='France';
            listAcc[0].BillingCity ='Paris';
            listAcc[0].No_of_Employees_Group__c =12;
            listAcc[0].No_of_Stores__c =2;
            listAcc[0].NumberOfEmployees =12;
            insert listAcc;
            
            Account_Expertise__c accShare = new Account_Expertise__c();
            accShare.Account__c=listAcc[0].Id;
            accShare.Expertise__c='200';
            accShare.Cegid_solution__c=true;
            insert accShare;
            
            listCon.add(new UTIL_TestFactory.ContactFactory().createContact(listAcc[0].id));   
            listCon[0].Salutation ='MR';
            listCon[0].Expertise__c='200';
            listCon[0].Active__c=True;
            listCon[0].Email='test@test.com';
            listCon[0].LeadOrigin__c='Sales';
            insert listCon;
            
            listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[0].Id,listTerritory[0].Id));
            Insert listOTA;
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPackage() {
        
        List<Account> listAcc = [SELECT id from Account];
        
        List<Opportunity> listOppAutoCreate = new List<Opportunity>();
        listOppAutoCreate.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[0].Id,false,true));
            listOppAutoCreate[0].Expertise__c='200';
            listOppAutoCreate[0].Oppy_AutoCreated__c = true;
        
        System.runAs(adminUser) {
            Test.startTest();
            Insert listOppAutoCreate;
            Test.stopTest();
        }
    }
    
    static testMethod void testConvertedLead() {
        
        List<Account> listAcc = [SELECT id from Account];
        
        List<Opportunity> listOppConverted = new List<Opportunity>();
        listOppConverted.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[0].Id,True,false));
            listOppConverted[0].Expertise__c='200';
            listOppConverted[0].TECHOwnerCalculated__c = False;
            listOppConverted[0].Oppy_converted_from_Lead__c=True;
        
        System.runAs(adminUser) {
            Test.startTest();
            Insert listOppConverted;
            Test.stopTest();
        }
    }
    
    static testMethod void testCalculateOpportunitySubSalesPurpose() {
        
        List<Account> listAcc = [SELECT id from Account];
        Account_Expertise__c ae = new Account_Expertise__c(Account__c = listAcc[0].Id, Expertise__c = '200');
        insert ae;
        AccountCoreBusiness__c acb1 = new AccountCoreBusiness__c(AccountExpertise__c = ae.Id, ProductLine__c='046');
        insert acb1;
        AccountCoreBusiness__c acb2 = new AccountCoreBusiness__c(AccountExpertise__c = ae.Id, ProductLine__c='046');
        insert acb2;
        Product_Line__c pl = new Product_Line__c(API_Code__c = '046', Name = 'Test');
        insert pl;
        
        List<Opportunity> listOppConverted = new List<Opportunity>();
        listOppConverted.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[0].Id,True,false));
            listOppConverted[0].Expertise__c='200';
        	listOppConverted[0].Product_Line__c='046';
            listOppConverted[0].Sales_Purpose__c = '411';
        
        System.runAs(adminUser) {
            Test.startTest();
            Insert listOppConverted;
            Test.stopTest();
        }
    }
}