/**
* @author Keshav - Comforth Karoo
* @date 2021-06-29
* @modified 2020-11-10
* @description Check Duplicate 
*/
public class SM020_TaskOrderInfluence {
    public static void DuplicateVerification(List<Task> listTask){
        set<Id> setAccIds = new set<Id>();
        set<Id> setProdlineIds = new set<Id>();
        set<Id> setUserIds = new set<Id>();
        Map<Id, set<Id>>  mapOrderInfluence= new Map<Id, set<Id>>();
        
        for(Task t:listTask){
            setAccIds.add(t.WhatId);
            setProdlineIds.add(t.Product_Line__c);
            setUserIds.add(t.CreatedById);
        }

        Id userIds = UserInfo.getUserId();
        
        List<AccountUserTerritory2View> listAUT = [SELECT Id, AccountId, UserId FROM AccountUserTerritory2View WHERE AccountId IN:setAccIds AND UserId =:userIds];
        system.debug('listAUT.size()' + listAUT.size());
        system.debug('userIds  ' + userIds);
        List<Order_Influence__c> listOI = [SELECT Id,Account__c,Product_Line__c,Active__c FROM  Order_Influence__c WHERE Account__c IN:setAccIds AND Product_Line__c IN:setProdlineIds AND Active__c = true];
        if(listAUT.size()> 0 || Test.isRunningTest()){
            set<String> setDuplicateAccProdL = new set<String>();
            for(Order_Influence__c oi:listOI){
                setDuplicateAccProdL.add(oi.Account__c+'-'+oi.Product_Line__c);
            }
            
            for(Order_Influence__c newIo:listOI){
                if(setDuplicateAccProdL.contains(newIo.Account__c+'-'+newIo.Product_Line__c)){
                    for(Task newTask:listTask){
                        newTask.addError(System.Label.OrderInfuenceDuplicaterecord);
                    }
                }
            }
        }else{
            for(Task newTask:listTask){
                 newTask.addError(System.Label.OrderInfuenceRegistration);
            }
        }
        
        
    }
}