@isTest
private class OpportunityContactRoleTrigger_Test {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    
    
   
     @isTest(SeeAllData=true)  static void createOppContactRole() {
	 
        Test.startTest();
        List<Opportunity> oppy = [select Id,Name, StageName from Opportunity where NOT( StageName like 'Closed%') Limit 10];
        List<Lead> leads = [select Id, ConvertedContact.id from lead where ConvertedContactId != null  and Role_in_decision_1__c != null  limit 3 ];
        List<Lead> leads2 = [select Id, ConvertedContact.id from lead where ConvertedContactId != null  and Role_in_decision_1__c = null  limit 2 ];
        leads.addAll(leads2);
        
        List<Id> convertContactIds = new List<Id>();
        For (Lead lead:leads) {

            convertContactIds.add(lead.ConvertedContactId);
        }
        if (oppy.size() > 0 ) {
        
        List<Contact> contact = [Select Id , Name from Contact where Id IN :convertContactIds  Limit 10];
		List<OpportunityContactRole> opportunityContactRole = new List<OpportunityContactRole>();
            //OpportunityContactRole oppyRole ;
        for (Integer i = 0; i < 4; i++) {
            OpportunityContactRole oppyRole = new OpportunityContactRole() ;
            oppyRole.OpportunityId = oppy[i].Id  ;
            oppyRole.contactId =  contact[i].Id ;
            opportunityContactRole.add(oppyRole);
        } 
        
         insert opportunityContactRole ;
        }
		 Test.stopTest();
       
    	}
    
}