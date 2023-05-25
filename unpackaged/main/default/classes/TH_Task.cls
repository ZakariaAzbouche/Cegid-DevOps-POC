/**
* @author Keshav - Comforth Karoo
* @date 2021-06-29
* @modified 2020-11-10
* @description Trigger handler class for Order_Influence__c
*/
public  with sharing class TH_Task extends TriggerHandler{
    public override void beforeInsert(){
        Boolean createOrderInf = false;
        for(Task t:(List<Task>)Trigger.new){
            if(t.Generates_Order_Influence__c == true && t.Product_Line__c != null){
                createOrderInf = true;
            }
        }
        
        if(createOrderInf){
           SM020_TaskOrderInfluence.DuplicateVerification(Trigger.New); 
        }
    }
}