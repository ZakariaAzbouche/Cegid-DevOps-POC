/**
 * @author Easyfront Consulting - MLE
 * @date 28/07/2022
 * @description Calculate estimated project workload on oppy (US W-000834) 
*/
public with sharing class SM009_CalcEstProjectWorkload {
    
    /**
     * @author Easyfront Consulting - MLE
     * @date 28/07/2022
     * @description Calculate estimated project workload on oppy (US W-000834) 
     * @param oppIds ids of opportunities
     */
    public static void calcOLIProjectWorkload(Set<Id> oppIds){
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        Set<Id> setProductIds = new Set<Id>();
        Map<Id, Decimal> mapProductDuration = new Map<Id, Decimal>();
        //Retrieve opportunities with related opp line items
        List<Opportunity> listOpp = [SELECT Id, Estimated_Project_Workload__c, (SELECT Id, Quantity, Product2Id FROM OpportunityLineItems) 
                                     FROM Opportunity WHERE Id IN :oppIds];
        //Get Product options info linked to opp line item products
        For(Opportunity opp:listOpp){
            For(OpportunityLineItem oli:opp.OpportunityLineItems){
                setProductIds.add(oli.Product2Id);
            }
        }
        system.debug('setProductIds '+setProductIds);
        //Get product info to calculate the Professional Services Workload on opportunity
        //Only product recordtype, family 140, service terms not to null and SBQQ__OptionalSKU__r is Article
        For(Product2 prod: [SELECT Id,
                (Select ID,SBQQ__ConfiguredSKU__r.Family, SBQQ__OptionalSKU__r.Service_Term__c, SBQQ__OptionalSKU__r.Duration__c
                    FROM SBQQ__Options__r 
                    WHERE SBQQ__ConfiguredSKU__r.RecordType.DeveloperName = 'Product' AND SBQQ__ConfiguredSKU__r.Family = '140' AND SBQQ__OptionalSKU__r.RecordType.DeveloperName = 'Article' AND SBQQ__OptionalSKU__r.Service_Term__c != null)
            FROM Product2 WHERE Id IN :setProductIds]){

            if(!prod.SBQQ__Options__r.isEmpty()){
                For(SBQQ__ProductOption__c opt:prod.SBQQ__Options__r){
                    //Calculate the duration of the option by product
                    Decimal durationInDays = 0;
                    if(opt.SBQQ__OptionalSKU__r.Service_Term__c == 'Days' && opt.SBQQ__OptionalSKU__r.Duration__c != null){
                        durationInDays = opt.SBQQ__OptionalSKU__r.Duration__c;
                    }else if(opt.SBQQ__OptionalSKU__r.Service_Term__c == 'Hours'  && opt.SBQQ__OptionalSKU__r.Duration__c != null  && opt.SBQQ__OptionalSKU__r.Duration__c != 0){
                        durationInDays = opt.SBQQ__OptionalSKU__r.Duration__c / 24;
                    }
                    system.debug('durationInDays '+durationInDays);
                    if(mapProductDuration.containsKey(prod.Id)){
                        mapProductDuration.put(prod.Id, mapProductDuration.get(prod.Id) + durationInDays);
                    }else{
                        mapProductDuration.put(prod.Id, durationInDays);
                    }
                }
            }
        }
        //Then, calculate the Professional Services Workload by opportunity
        For(Opportunity opp:listOpp){
            Decimal psAmount = 0;
            For(OpportunityLineItem oli:opp.OpportunityLineItems){
                if(mapProductDuration.containsKey(oli.Product2Id)){
                    psAmount = psAmount + (oli.Quantity * mapProductDuration.get(oli.Product2Id));
                }
            }
            system.debug('psAmount '+psAmount);
            if(opp.Estimated_Project_Workload__c != psAmount){
                opp.Estimated_Project_Workload__c = psAmount.round();
                listOppToUpdate.add(opp);
            }
        }
        system.debug('listOppToUpdate '+listOppToUpdate);
        if(!listOppToUpdate.isEmpty()){
            update listOppToUpdate;
        }
    }
}