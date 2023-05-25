@isTest
public class SM010_Case_TEST {
/**
 * @File Name          : SM010_Case_TEST
 * @Description        : Update Opportunity Team Member if a user is the owner of the case.
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    01/12/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User adminUser2 = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    
    @testSetup static void setup(){
        System.runAs(adminUser){       
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
                
            Test.startTest();
            List<Account> listAcc = new List<Account>();
            List<Contact> listCon = new List<Contact>();
            List<Opportunity> listOppConverted = new List<Opportunity>();
            List<Opportunity> listOppAutoCreate = new List<Opportunity>();
            List<ObjectTerritory2Association> listOTA = new List<ObjectTerritory2Association>();
            List<Territory2> listTerritory = [Select Id , Expertise__c from Territory2 where  Expertise__c='200']; 
            
            listAcc.add(new UTIL_TestFactory.AccountFactory().createAccount());
            listAcc[0].National_ID_Exception__c ='Empty on loading';
            listAcc[0].BillingPostalCode ='75008';
            listAcc[0].BillingCountry ='France';
            listAcc[0].BillingCity ='Paris';
            listAcc[0].No_of_Employees_Group__c =12;
            listAcc[0].No_of_Stores__c =2;
            listAcc[0].NumberOfEmployees =12;
            insert listAcc;
            
            Opportunity opp = New Opportunity();
            opp.Name='test';
            opp.AccountId=listAcc[0].Id;
            opp.StageName='G - MQL';
            opp.Sales_Purpose__c='121';
            opp.CurrencyIsoCode='EUR';
            opp.Forecast_Category_EDIT__c='Omitted';
            opp.CloseDate=date.today();
            opp.LeadSource='Sales Prospecting';
            
            insert opp;
            
            Case case1 = new Case();
            case1.Subject='Test';
            case1.Description='test';
            case1.Type= 'Demonstration';
            case1.ClosedDate=date.TODAY();
            case1.Scheduled_Date__c=date.TODAY();
            //case1.Expertise__c='ERP High';
            //case1.Product_Line__c='021';
            case1.Sales_Purpose__c='121';
            case1.Opportunity__c=opp.Id;
            
            insert case1;
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPackage() {
        
        insert adminUser2;
        
        List<Case> listCase = [SELECT id,OwnerId from Case];
        system.debug('listCase[0].OwnerId'+listCase[0].OwnerId);
        system.debug('adminUser2.Id'+adminUser2.Id);
        listCase[0].OwnerId=adminUser2.Id;
        
        System.runAs(adminUser) {
            Test.startTest();
            Update listCase;
            Test.stopTest();
        }
    }
}