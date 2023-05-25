/**
 * @author Easyfront Consulting - MLE
 * @date 28/07/2022
 * @description Trigger handler class for OpportunityLineItem
*/
public with sharing class TH_OpportunityLineItem extends TriggerHandler{
    /**
     * @author Easyfront Consulting - MLE
     * @date 28/07/2022
     * @description afterInsert logic          
    */
    public override void afterInsert() {
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.new){    
            //US W-000834                         
            if(canTriggerByFeature('CalculateOppyEstProjectWorkload__c') && oli.TECH_IsOppyPrimaryQuote__c){
                oppIds.add(oli.OpportunityId);              
            }
        }
        
        if(!oppIds.isEmpty()){
            SM009_CalcEstProjectWorkload.calcOLIProjectWorkload(oppIds);
        }
        
    }
    
    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-11-11
     * @description beforeUpdate logic          
    */
    public override void beforeUpdate() {
        Map<Id, OpportunityLineItem> oppyLinesToBeProcess = (Map<Id, OpportunityLineItem>) CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.BEFORE_UPDATE);
        computeSaasAmount(oppyLinesToBeProcess.values());
    }

    /**
     * @author Easyfront Consulting - MLE
     * @date 28/07/2022
     * @description afterUpdate logic          
    */
    public override void afterUpdate() {
        system.debug('AFTER UPDATE HERE !!');
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.new){ 
            OpportunityLineItem oldOppLine = (OpportunityLineItem)trigger.oldMap.get(oli.Id);
            //US W-000834                         
            if(canTriggerByFeature('CalculateOppyEstProjectWorkload__c') && oli.TECH_IsOppyPrimaryQuote__c && oli.TECH_IsOppyPrimaryQuote__c != oldOppLine.TECH_IsOppyPrimaryQuote__c){
                oppIds.add(oli.OpportunityId);    
                system.debug('oli.OpportunityId '+oli.OpportunityId);
            }
        }
        
        if(!oppIds.isEmpty()){
            SM009_CalcEstProjectWorkload.calcOLIProjectWorkload(oppIds);
        }
    }
    
    /**
     * @author Easyfront Consulting - MLE
     * @date 28/07/2022
     * @description afterDelete logic          
    */
    public override void afterDelete() {
        Set<Id> oppIds = new Set<Id>();
        for(OpportunityLineItem oli:(List<OpportunityLineItem>)Trigger.old){    
            //US W-000834                         
            if(canTriggerByFeature('CalculateOppyEstProjectWorkload__c') && oli.TECH_IsOppyPrimaryQuote__c){
                oppIds.add(oli.OpportunityId);              
            }
        }
        
        if(!oppIds.isEmpty()){
            SM009_CalcEstProjectWorkload.calcOLIProjectWorkload(oppIds);
        }
    }
    
    public void computeSaasAmount(List<OpportunityLineItem> oppLines) {
        for(OpportunityLineItem oppLine : oppLines) {
            oppLine.Saas_Amount__c = oppLine.Saas_Amount_Calculated__c;
        }
    }

}