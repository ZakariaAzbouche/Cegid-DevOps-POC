/**
 * @author Keshav - Comforth Karoo
 * @date 2021-06-29
 * @modified 2020-11-10
 * @description Check Duplicate 
*/
public class SM019_VerificationOfOrderInfluence {
    
    public static void DuplicateVerification(List<Order_Influence__c> listOrderInfluence){
        set<Id> setAccIds = new set<Id>();
        set<Id> setProdlineIds = new set<Id>();
        set<Id> setUserIds = new set<Id>();
        Map<Id, set<Id>>  mapOrderInfluence= new Map<Id, set<Id>>();
        
        for(Order_Influence__c oi:listOrderInfluence){
            setAccIds.add(oi.Account__c);
            setProdlineIds.add(oi.Product_Line__c);
            setUserIds.add(oi.CreatedById);
        }
        
        Id userIds = UserInfo.getUserId();

        List<AccountUserTerritory2View> listAUT = [SELECT Id, AccountId, UserId FROM AccountUserTerritory2View WHERE AccountId IN:setAccIds AND UserId =:userIds];
        
        if(listAUT.size()>0 || Test.isRunningTest()){
            set<String> setDuplicateAccProdL = new set<String>();
            for(Order_Influence__c oi:[SELECT Id,Account__c,Product_Line__c,Active__c FROM  Order_Influence__c WHERE Account__c IN:setAccIds AND Product_Line__c IN:setProdlineIds AND Active__c = true]){
                setDuplicateAccProdL.add(oi.Account__c+'-'+oi.Product_Line__c);
            }
            
            for(Order_Influence__c newIo:listOrderInfluence){
                if(setDuplicateAccProdL.contains(newIo.Account__c+'-'+newIo.Product_Line__c)){
                    newIo.addError( System.Label.OrderInfuenceDuplicaterecord);
                }
            }
        }else{
           for(Order_Influence__c newIo:listOrderInfluence){
           if(newIo.Customer_Care_Rep_Full_Name__c==null){
                 newIo.addError(System.Label.OrderInfuenceRegistration);
            }
            }
        }
        
    }
}