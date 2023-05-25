/**
* @author Keshav - Comforth Karoo
* @date 2021-08-26
* @description Trigger handler class for Participant__c
*/
public  with sharing class TH_Participant extends TriggerHandler{
    
    public override void beforeInsert(){
        Boolean createParticipant = false;
        for(participant__c par:(List<participant__c>)Trigger.new){
            if(par.CartItemId__c != null && par.EmailAddress__c != null){
                createParticipant = true;
            }
        }
        
        if(createParticipant){
            SM022_CheckDuplicateParticipant.DuplicateVerification(Trigger.New);
        }
    }
    
    public override void beforeUpdate() {
        Boolean createParticipant = false;
        for(participant__c par:(List<participant__c>)Trigger.new){
            participant__c oldpar = (participant__c)trigger.oldMap.get(par.Id);
            if(par.CartItemId__c != null && par.EmailAddress__c != null && par.EmailAddress__c != oldpar.EmailAddress__c){
                createParticipant = true;
            }
        }
        
        if(createParticipant){
            SM022_CheckDuplicateParticipant.DuplicateVerification(Trigger.New);
        }
    }
    
}