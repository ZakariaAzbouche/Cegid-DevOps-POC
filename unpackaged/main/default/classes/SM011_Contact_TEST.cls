@isTest
public class SM011_Contact_TEST {
/**
 * @File Name          : SM011_Contact_TEST
 * @Description        : Convert Lead if contact has same email 
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    03/12/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User adminUser2 = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static List<Account> listAcc = new List<Account>();
    static Contact con = new Contact();
    
    @testSetup static void setup(){
        System.runAs(adminUser){       
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
                
            Test.startTest();
            
            listAcc.add(new UTIL_TestFactory.AccountFactory().createAccount());
            listAcc[0].National_ID_Exception__c ='Empty on loading';
            listAcc[0].BillingPostalCode ='75008';
            listAcc[0].BillingCountry ='France';
            listAcc[0].BillingCity ='Paris';
            listAcc[0].No_of_Employees_Group__c =12;
            listAcc[0].No_of_Stores__c =2;
            listAcc[0].NumberOfEmployees =12;
            insert listAcc;
            
            Lead l = new Lead();
            l.FirstName='Test1111';
            l.LastName='Test1111';
            l.Service__c='HR';
            l.Function__c='Personnel Dir.';
            l.Status='Assigned';
            l.Company='test';
            l.Email='TestContact1111@test.com';
            //l.OwnerId='00G1w000002aZGb';
            
            insert l;
            
            Lead lead2 = new Lead();
            lead2.FirstName='Test11';
            lead2.LastName='Test11';
            lead2.Service__c='HR';
            lead2.Function__c='Personnel Dir.';
            lead2.Status='New';
            lead2.Company='testing';
            lead2.Email='TestContact11@test.com';
            //lead2.OwnerId='00G1w000002aZGb';
            
            insert lead2;
            
            
            Test.stopTest();
        }
    }
    
    static testMethod void testErrorMessage() {

        System.runAs(adminUser) {
            Test.startTest();

            List<Account> listAcc = [SELECT id,TECHFollowedByCodeToBeCalculated__c,OwnerId,ReferentCode__c,SedentaryCode__c,CodeFollowedBy__c from Account where Name LIKE '%Test%'];

            con.FirstName='TestContact';
            con.LastName='Trigger';
            con.Email='TestContact1111@test.com';
            con.AccountId=listAcc[0].Id;
            con.CurrencyIsoCode='EUR';
            con.Function__c='General Services Mgr.';
            con.Service__c='Purchasing';
            
            try {
                insert con;
            } catch(DmlException e) {
                System.debug('The contact you\'re trying to create had already a lead being currently processed by the telemarketing team, please contact them.' + e.getMessage());
            }
            
            Test.stopTest();
        }
    }
    
        static testMethod void testConversionLead() {

        System.runAs(adminUser) {
            Test.startTest();

            List<Account> listAcc = [SELECT id,TECHFollowedByCodeToBeCalculated__c,OwnerId,ReferentCode__c,SedentaryCode__c,CodeFollowedBy__c from Account where Name LIKE '%Test%'];

            con.FirstName='TestContact';
            con.LastName='Trigger';
            con.Email='TestContact11@test.com';
            con.AccountId=listAcc[0].Id;
            con.CurrencyIsoCode='EUR';
            con.Function__c='General Services Mgr.';
            con.Service__c='Purchasing';
            
            insert con;
            
            Test.stopTest();
        }
    }
}