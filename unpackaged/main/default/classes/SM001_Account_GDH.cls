public class SM001_Account_GDH {
	public static void setAccountTerritoryCode(List<Account> listAcc, Map <Id, Id> mapAccountIdOwnerId){
        Set <Id> setProcessedAccountIds = new Set <Id>();
        Map <Id, Set <Id>> mapUserIdSetTerritoryIds = new Map <Id, Set <Id>>();	// Account.Owner => Set of territories
        Map <Id, List <Territory2>> mapAccountIdListTerritories = new Map <Id, List <Territory2>>();
        Set <Id> setTerritoryIdsAssociatedWithAccount = new Set <Id>();
        Map <Id, Territory2> mapTerritoryIdTerritoryWithOppOwner = new Map <Id, Territory2>();
        Map <Id, Territory2> mapTerritories = new Map <Id, Territory2>();		// store all Territories
        
        system.debug('listAcc Trigger'+listAcc);
        system.debug('listAcc Trigger'+listAcc[0].OwnerId);
        system.debug('mapAccountIdOwnerId'+mapAccountIdOwnerId);
        // get all territories associated with Account Owner(s)
        for(UserTerritory2Association ut2a : [SELECT UserId, Territory2Id, Territory2.TerritoryCode__c, Territory2.Channel__c, Territory2.BU__c 
                                              FROM UserTerritory2Association 
                                              WHERE UserId IN :mapAccountIdOwnerId.values()
                                              AND IsActive = true]){
                                                  
            Territory2 territory = (Territory2)ut2a.Territory2;
            mapTerritories.put(territory.Id, territory);
        	if(mapUserIdSetTerritoryIds.containsKey(ut2a.UserId)){
                mapUserIdSetTerritoryIds.get(ut2a.UserId).add(ut2a.Territory2Id);
            }else{
                mapUserIdSetTerritoryIds.put(ut2a.UserId, new Set <Id> {ut2a.Territory2Id});
            }                 
        }
        system.debug('mapUserIdSetTerritoryIds'+mapUserIdSetTerritoryIds);
        
        // get all territories associated with Account(s)
        for(ObjectTerritory2Association ot2a : [SELECT Territory2Id, ObjectId, Territory2.TerritoryCode__c, Territory2.Channel__c, Territory2.BU__c  
                                                FROM ObjectTerritory2Association 
                                                WHERE ObjectId IN :mapAccountIdOwnerId.keySet()]){
			setTerritoryIdsAssociatedWithAccount.add(ot2a.Territory2Id);
            Territory2 territory = (Territory2)ot2a.Territory2;
            mapTerritories.put(territory.Id, territory);                                        
        	if(mapAccountIdListTerritories.containsKey(ot2a.ObjectId)){
                mapAccountIdListTerritories.get(ot2a.ObjectId).add(territory);
            }else{
                mapAccountIdListTerritories.put(ot2a.ObjectId, new List <Territory2> {territory});
            }   
        }
        system.debug('mapAccountIdListTerritories'+mapAccountIdListTerritories);
        // get all Territories associated with member having Role "Opportunity Owner"
        for(UserTerritory2Association ut2a : [SELECT UserId, Territory2Id, Territory2.TerritoryCode__c, Territory2.Channel__c, Territory2.BU__c  
                                              FROM UserTerritory2Association 
                                              WHERE Territory2Id IN :setTerritoryIdsAssociatedWithAccount
                                              AND IsActive = true
                                              AND RoleInTerritory2 = 'Opportunity Owner']){
        	mapTerritoryIdTerritoryWithOppOwner.put(ut2a.Territory2Id, (Territory2)ut2a.Territory2);       
        }
        
        for(Account acc : listAcc){
            acc.CodeFollowedBy__c = null;	// default to null
            Territory2 selectedTerritory;
            if(mapUserIdSetTerritoryIds.containsKey(acc.OwnerId)){// Owner is a member of a territory
                system.debug('acc.OwnerId'+acc.OwnerId);
                // On prend le premier territoire du compte où le owner du compte est membre, et on prend la valeur de TerritoryCode__c
                // (Account.Owner IS A member of an AssignedTerritory on Account)
                if(mapAccountIdListTerritories.containsKey(acc.Id)){
                    
                    // loop over territories assigned to Account
                    for(Territory2 territory : mapAccountIdListTerritories.get(acc.Id)){
                        if(mapUserIdSetTerritoryIds.get(acc.OwnerId).contains(territory.Id)){
                      		selectedTerritory = territory;
                            system.debug('selected Territory *'+selectedTerritory);
                            break;
                        }
                    }
                }
                
                if(selectedTerritory==null){
                    // On prend le premier territoire où le owner du compte est membre, et on prend la valeur de TerritoryCode__c
                	// Account.Owner IS A member of a Territory
                    for(Id territoryId : mapUserIdSetTerritoryIds.get(acc.OwnerId)){
                            selectedTerritory = mapTerritories.get(territoryId);
                            system.debug('selected Territory **'+selectedTerritory);
                            break;
                        }
                }
                
            }else if(mapAccountIdListTerritories.containsKey(acc.Id)){
                // On prend le premier territoire du compte qui a un membre avec le rôle opportuny Owner et on prend la valeur de TerritoryCode__c
                for(Territory2 territory : mapAccountIdListTerritories.get(acc.Id)){
                    if(mapTerritoryIdTerritoryWithOppOwner.containsKey(territory.Id)){
                        selectedTerritory = territory;
                        system.debug('selectedTerritory ***'+territory);
                        break;
                    }
                }
            }
            
            System.debug('## selectedTerritory : ' + selectedTerritory);
            if(selectedTerritory != null){
                acc.CodeFollowedBy__c = selectedTerritory.TerritoryCode__c;
                acc.ReferentCode__c = acc.CodeFollowedBy__c; // par défaut
                if(selectedTerritory.Channel__c != '003'){// Si le Channel du Territoire sélectionné pour le Code Followed By est différent de 003 (Inside Sales)
                    acc.SedentaryCode__c = null;
                }else{
                    acc.SedentaryCode__c = acc.CodeFollowedBy__c;
                    // cherche le premier secteur présent dans les territoires du compte dont la BU est identique à la BU du territoire trouvé pour "Code Followed By" 
                    // et dont le Canal est différent de 003 (Inside Sales) et je prends la valeur de TerritoryCode__c, 
                    // si pas de résultat, = "Code Followed By" (ligne 86)
                    
                    if(mapAccountIdListTerritories.containsKey(acc.Id)){
                        system.debug('mapAccountIdListTerritories BU'+mapAccountIdListTerritories);
                        // loop over territories assigned to Account
                        for(Territory2 territory : mapAccountIdListTerritories.get(acc.Id)){
                            system.debug('territory **'+territory);
                            if(territory.BU__c == selectedTerritory.BU__c && territory.Channel__c != '003'){
                                acc.ReferentCode__c = territory.TerritoryCode__c;
                            }
                        }
                    }
                }
            }
            
            if(acc.CodeFollowedBy__c == null){// Si pas de Territoire sélectionné pour déterminer le Code Followed By, "Referent Code" et "Sedentary Code" = Valeur vide (ou null)
                acc.ReferentCode__c = null;
                acc.SedentaryCode__c = null;
            }
        }
        
    }
}