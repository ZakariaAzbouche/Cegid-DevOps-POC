global class BatchAlertOwnerOppyStageMql implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute 
        System.debug('BatchAlertOwnerOppyStageMql start');
        DateTime dateTwoDaysBefore = calculateCreatedDate();              
               
        return Database.getQueryLocator([SELECT Id, OwnerId, CreatedById, Territory2.Name, Name, Owner.email, Last_Alerte_For_Sales_MQL__c, Account.Id, Account.Name, Owner.Name FROM Opportunity WHERE StageName LIKE '%MQL' AND ((CreatedDate < :dateTwoDaysBefore AND Last_Alerte_For_Sales_MQL__c = null) OR (Last_Alerte_For_Sales_MQL__c < :dateTwoDaysBefore ))]);
    }
     
    global void execute(Database.BatchableContext BC, List<Opportunity> opportunityAssList) {
        System.debug('BatchAlertOwnerOppyStageMql execute opportunityAssList.size() :: ' + opportunityAssList.size());

        Set<Id> createdByUserIds = new Set<Id>();
        Set<Id> createdByUserAllianceIds = new Set<Id>();

        for(Opportunity opp : opportunityAssList) {
            createdByUserIds.add(opp.CreatedById);
        }
        
        
        for(UserTerritory2Association userTerrAs : [SELECT UserId
                                                    FROM UserTerritory2Association 
                                                    WHERE UserId 
                                                    IN:createdByUserIds 
                                                    AND (Territory2.Name LIKE '%Alliance%' 
                                                    OR Territory2.Name LIKE '%alliance%')]) {
            createdByUserAllianceIds.add(userTerrAs.UserId);
        }
        // process each batch of records default size is 200
        List<Opportunity> updatedOppies = new List<Opportunity>();

        for (Opportunity oppy : opportunityAssList) {
              if(!createdByUserAllianceIds.contains(oppy.CreatedById)) {
                oppy.Last_Alerte_For_Sales_MQL__c = Datetime.now();   
                updatedOppies.add(oppy);
              }               
        }

        List<Database.SaveResult> results = Database.update(updatedOppies, false);

        List<Id> oppIds = new List<Id>();
        for (Database.SaveResult sr : results) {
            if (sr.isSuccess()) {                            
                oppIds.add(sr.getId());             
                System.debug('Successfully updated oppy. Oppy ID: ' + sr.getId());
            }
            else {
            // Operation failed, so get all errors                
            for(Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Opportunities fields that affected this error: ' + err.getFields());
                }
            }
        }

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for (Opportunity oppy: updatedOppies){
            for (Id idOppy: oppIds){            
                if(idOppy.equals(oppy.Id)) {
                    String body = ' \n The opportunity '+oppy.Name+' has to be processed. ';                    
                    String userId = oppy.OwnerId;
                    if(Utility.isEmpty(userId)) userId = UserInfo.getUserId();
                    
                    batchInputs.add(Utility.createBatchInput(userId, oppy.Id, body));    
                }
            }            
        }
        if (!Test.isRunningTest()) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
        
        System.debug('End BatchAlertOwnerOppyStageMql execute ');
                 
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }

    private Datetime calculateCreatedDate() {

        if (DateTime.now().format('EEEE').equals('Monday') || DateTime.now().format('EEEE').equals('Tuesday')){
            return Datetime.now().addDays(-4);  
        }

        return Datetime.now().addDays(-2);  
    }

}