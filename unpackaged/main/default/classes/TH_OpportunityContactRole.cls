public without sharing class TH_OpportunityContactRole  extends TriggerHandler {
    

    public override void afterInsert() {
		
        Set<Id> OpportunityContactRoleIds = (new Map<Id,OpportunityContactRole>((List<OpportunityContactRole>)Trigger.New)).keySet();
        updateContactRole (OpportunityContactRoleIds) ;
    }
    
    /**
     * */
    @future 
    public static void updateContactRole(Set<Id> oppyCtsRoleIds )    {
     List<OpportunityContactRole> listOppRoleContacts =  [ SELECT Id, role, ContactId, OpportunityId  FROM OpportunityContactRole where Id IN :oppyCtsRoleIds ]; 
     List<OpportunityContactRole> listOppRole = getRoleOfContactFromConvertedLead (listOppRoleContacts)  ;  
     update  (listOppRole) ;  
        
    }
    
/**
 * 
 */
    public static List<OpportunityContactRole> getRoleOfContactFromConvertedLead (List<OpportunityContactRole> listOpp) {
        
        List<OpportunityContactRole> listOppRole = new List<OpportunityContactRole>() ;
        List<Id> contactIds = new List<Id>();
        
        System.debug('listOpp = '+listOpp);
        
        for (OpportunityContactRole o: listOpp) {
            
            contactIds.add(o.ContactId);
        }
        List<Lead> leads = [ SELECT Id, name,Role_in_decision_1__c, ConvertedContactId  FROM Lead where ConvertedContactId  IN :contactIds ];
        
        System.debug('leads = '+leads.size());
        
        for (Lead lead : leads) {
            for (OpportunityContactRole opportunityContactRole : listOpp) {
                
                if (lead.ConvertedContactId == opportunityContactRole.ContactId)  {
					 System.debug('leads = '+lead.Role_in_decision_1__c);
                    if (isNotEmpty(lead.Role_in_decision_1__c)) {
                        opportunityContactRole.Role = lead.Role_in_decision_1__c ;
                        listOppRole.add(opportunityContactRole) ;
                    }
                }
            }

        }

        return listOppRole;
    }

    
/**
 * 
 */
    Public static Boolean isEmpty(String str) {

        return (str ==null||str.trim().length() == 0 ) ;
    }
/**
 * 
 */
    Public static Boolean isNotEmpty(String str) {

       return !(isEmpty (str));
    }

}