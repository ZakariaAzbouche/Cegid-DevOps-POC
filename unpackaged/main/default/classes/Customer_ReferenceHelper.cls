public class Customer_ReferenceHelper {
    /***Bulk method => DON'T USE IT IN LOOP  */

    public static User getUserWithProfile(Id IdUser) {
        return [SELECT Id, Profile.Name FROM User WHERE Id =: IdUser]; 
    }

    public static Set<Id> getTerritoryUserIds(Id IdUser) {
        Set<Id> terrUserIds = new Set<Id>();
        
        List<UserTerritory2Association> userTerritory2Associations = [SELECT Territory2Id FROM UserTerritory2Association WHERE UserId =: IdUser];
           
        if(!userTerritory2Associations.isEmpty()) {
            for(UserTerritory2Association usrTerrAsso : userTerritory2Associations) {
                terrUserIds.add(usrTerrAsso.Territory2Id);
            }
        }
        return terrUserIds;
    }

    public static Map<Id, Set<Id>> extractSObjectTerritoryHierarchy(Set<Id> sobjIds) {
        //Extract all Territories
        Map<Id, Territory2> allOrgTerritories = new Map<Id, Territory2>([SELECT Id, ParentTerritory2Id, Name FROM Territory2 LIMIT 9800]);

        //Extract all account Territories associations
        List<ObjectTerritory2Association> sObjTerrAssos = [SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId IN: sobjIds];
        
         //Build result Map
        Map<Id, Set<Id>> mapSObjectTerritories = new Map<Id, Set<Id>>();
        //Extract all account Territories Id
        for(ObjectTerritory2Association sObjTerrAsso : sObjTerrAssos) {
            if(!mapSObjectTerritories.containsKey(sObjTerrAsso.ObjectId)) {
                mapSObjectTerritories.put(sObjTerrAsso.ObjectId, new Set<Id>());
            }
            mapSObjectTerritories.get(sObjTerrAsso.ObjectId).add(sObjTerrAsso.Territory2Id);
        }
       
        Territory2 tmp;
        for(Id SObjectId : mapSObjectTerritories.keySet()) {
            
            for(Id territoryId : mapSObjectTerritories.get(SObjectId)) {
                tmp = allOrgTerritories.get(territoryId);
                System.debug(tmp.Name);
                while (tmp.ParentTerritory2Id != null) {
                    tmp = allOrgTerritories.get(tmp.ParentTerritory2Id);
                    mapSObjectTerritories.get(SObjectId).add(tmp.Id);
                    System.debug(tmp.Name);
                }
            }
        }
        return mapSObjectTerritories;  
    }

    /** END BULK METHOD */

    /**BEFORE */

    public static void checkAccPermissionInsertUpdate(Customer_Reference__c cRef, User connectedUser,  Set<Id> terrUserIds, Map<Id, Set<Id>> accWithTerritoriesHieriarchy) {
        
        System.debug('CHECK CUSTOMER REFERENCE PERMISSION');
        
        if((connectedUser.Profile.Name == 'CEGID Sales')) {
            Set<Id> accIdNoRestriction = new Set<Id>();
            if(!terrUserIds.isEmpty()) {
                for(Id accId : accWithTerritoriesHieriarchy.keySet()) {
                    if(accWithTerritoriesHieriarchy.get(accId).removeAll(terrUserIds)) {
                        accIdNoRestriction.add(accId);  
                    }
                }
            }
            if(!accIdNoRestriction.contains(cRef.Account__c)) {
                cRef.addError(System.Label.VR_accountFieldsLocked);  
            }
        }
    }
    
    /**AFTER */

    public static void updateCustomerReferalOnAcc(Customer_Reference__c cRef, Map<Id, List<Customer_Reference__c>> customerRefsByAcc, Map<Id, SObject> sObjectToUpdate) {
        if(customerRefsByAcc.get(cRef.account__c).isEmpty()) {
            sObjectToUpdate.put(cRef.account__c, new Account(Id=cRef.account__c, Referral_Customer__c = false));
        }   
    }
}