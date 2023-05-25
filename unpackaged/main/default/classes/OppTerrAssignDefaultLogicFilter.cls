/* 
----------------------------------------------------------------------
-- - Name          : OppTerrAssignDefaultLogicFilter
-- - Author        : Comforth
-- - Description   : Set Account territory
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 09 Jan-2020  KMM    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/

global class OppTerrAssignDefaultLogicFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter { 
   
     global OppTerrAssignDefaultLogicFilter() {}

  
    global Map<Id,Id> getOpportunityTerritory2Assignments(List<Id> opportunityIds) { 
        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();

        // Get the active territory model Id
        Id activeModelId = getActiveModelId();

        if(activeModelId != null){
            
            //add query field to select 
            List<Opportunity> opportunities = [Select Id, AccountId,Expertise__c, Territory2Id from Opportunity where Id IN :opportunityIds];
            
            List<Territory2> noTerritory2 = [Select Id,DeveloperName ,Name from Territory2 where Name ='No Territory' limit 1];
       
            
            Map<Id,String> accountIdToOpportunityExpertiseMap= new Map<Id,String>();
            
            //Set<Id> accountIds = new Set<Id>();
            // Create set of parent accountIds
            for(Opportunity opp:opportunities){
                if(opp.AccountId != null && opp.Expertise__c != null){
                    accountIdToOpportunityExpertiseMap.put(opp.AccountId,opp.Expertise__c);
                    //accountIds.add(opp.AccountId);
                    }
                }
			Map<Id,territory2Expertise> accountMaxPriorityTerritory = getAccountMaxPriorityTerritory( activeModelId,accountIdToOpportunityExpertiseMap);
            
               
            // For each opportunity, assign the highest priority territory if there is no conflict, else assign null.
            for(Opportunity opp: opportunities){
                if(accountMaxPriorityTerritory.containsKey(opp.AccountId)){
                   OppIdTerritoryIdResult.put(opp.Id, accountMaxPriorityTerritory.get(opp.AccountId).territory2Id); 
                    system.debug('accountMaxPriorityTerritory.get(opp.AccountId).territory2Id : ' + accountMaxPriorityTerritory.get(opp.AccountId).territory2Id);
                }else{
                    OppIdTerritoryIdResult.put(opp.Id, noTerritory2[0].Id);
                    system.debug('No territory : ' + noTerritory2[0].Id);
                }
          		
            }
        }
        
        system.debug('OppIdTerritoryIdResult : ' + OppIdTerritoryIdResult);
        return OppIdTerritoryIdResult;
    }
    
      
    /**
      * Query assigned territoryIds in active model for given accountIds.
      * Create a map of accountId to opportunity expertise territory .
      */
    @testVisible
     private Map<Id,territory2Expertise> getAccountMaxPriorityTerritory(Id activeModelId, Map<Id,String> accountIdToOpportunityExpertiseMap){
        Map<Id,territory2Expertise> accountMaxPriorityTerritory = new Map<Id,territory2Expertise>();
         system.debug('accountIdToOpportunityExpertiseMap : ' + accountIdToOpportunityExpertiseMap);
        for(ObjectTerritory2Association ota:[Select ObjectId, Territory2Id, Territory2.Expertise__c from ObjectTerritory2Association where objectId IN :accountIdToOpportunityExpertiseMap.keySet() and Territory2.Territory2ModelId = :activeModelId]){
            //territory2Expertise tp = accountMaxPriorityTerritory.get(ota.ObjectId);
            territory2Expertise tp = new territory2Expertise(ota.Territory2Id,ota.Territory2.Expertise__c);
            system.debug('accountMaxPriorityTerritory  :' + accountMaxPriorityTerritory);
            
            if(ota.Territory2.Expertise__c == accountIdToOpportunityExpertiseMap.get(ota.ObjectId)){
               accountMaxPriorityTerritory.put(ota.ObjectId, tp);
            }
        }
        return accountMaxPriorityTerritory;
    }

    /**
     * Get the Id of the Active Territory Model.
     * If none exists, return null.
     */
    @testVisible
    private Id getActiveModelId() {
        List<Territory2Model> models = [Select Id from Territory2Model where State = 'Active'];
        Id activeModelId = null;
        if(models.size() == 1){
            activeModelId = models.get(0).Id;
        }

        return activeModelId;
    }
      /**
    * Helper class to help capture territory2Expertise.
    */
    @testVisible
    private class territory2Expertise {
        @testVisible
        public Id territory2Id { get; set; }
        @testVisible
        public String expertise { get; set; }
		@testVisible
        territory2Expertise(Id territory2Id,  String expertise){
            this.territory2Id = territory2Id;
            this.expertise = expertise;
        }
    }
}