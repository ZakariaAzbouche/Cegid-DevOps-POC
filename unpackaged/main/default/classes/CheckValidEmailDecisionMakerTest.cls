@isTest(SeeAllData=true)
public with sharing class CheckValidEmailDecisionMakerTest {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    
         static testMethod void CheckValidEmailDecisionMaker(){
      	 System.debug('Start ');    
        Test.startTest();
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
         insert opp;
        insert oppyRoleList ;
        update ContactListToUpdate ;
             try {
        		update oppListToUpdate ;         
             } catch (DmlException e) {
                 String message = e.getMessage();
       			 System.assert(e.getMessage().contains(System.Label.VR_checkEmailValidDecisionMaker), 'message=' + e.getMessage());
             }   
        
        }
        Test.stopTest();
        
    }
}