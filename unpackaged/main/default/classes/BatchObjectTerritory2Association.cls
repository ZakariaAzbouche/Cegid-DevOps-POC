/**
 * @File Name          : TH_ObjectTerritory2Association
 * @Description        : Update Account Values with territory  
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    15/06/2021         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
global class BatchObjectTerritory2Association implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute         
        String query = 'SELECT Id, OwnerId, IsOwnerInRightTerritory__c FROM Account';
        //String query = 'SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE IsDeleted= false';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Account> accountsList) {
        
        // process each batch of records default size is 200
        
        try {
            // Update the Account Record
            update objectTerritory2Changed (accountsList);
         
        } catch(Exception e) {
            System.debug(e);
        }         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }

        /***AZI W-001713 */

        private List<Account> objectTerritory2Changed (List<Account> accountsList){
			System.debug('BatchObjectTerritory2Association objectTerritory2Changed Start');
            List<Account> accList = new List<Account>();
            List<Id> idAccsList = new List<Id>();
            List<Id> idTerrsList = new List<Id>();
            
            for(Account acc: accountsList){
                idAccsList.add(acc.Id);
            }
            System.debug('BatchObjectTerritory2Association objectTerritory2Changed accountsList : ' + accountsList.size());
            List<ObjectTerritory2Association> listObjectTerritory2Association = [SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association Where ObjectId IN:idAccsList];

            for(ObjectTerritory2Association objectTerritory2Association: listObjectTerritory2Association){
                idTerrsList.add(objectTerritory2Association.Territory2Id);
            }

            System.debug('BatchObjectTerritory2Association objectTerritory2Changed listObjectTerritory2Association : ' + listObjectTerritory2Association.size());

            List<UserTerritory2Association> userTerrs = [Select UserId, Territory2Id From UserTerritory2Association WHERE Territory2Id IN:idTerrsList];
            
            System.debug('BatchObjectTerritory2Association objectTerritory2Changed userTerrs : ' + userTerrs.size());

            boolean userFound  = false;   
            for(Account account: accountsList){                
                userFound  = false;              
                for(ObjectTerritory2Association objectTerritory2Association: listObjectTerritory2Association){
                      if(account.Id.equals(objectTerritory2Association.ObjectId)){
                          for(UserTerritory2Association userTerr: userTerrs){                              
                            if(account.OwnerId.equals(userTerr.UserId) && userTerr.Territory2Id.equals(objectTerritory2Association.Territory2Id)){
                                userFound  = true;  
                                break;
                            }                            
                          }
                      }                        
                  }
                  
                  if(!userFound){
                    account.IsOwnerInRightTerritory__c = false;                          
                  }else{
                    account.IsOwnerInRightTerritory__c = true;      
                  }  
                  accList.add(account);                                                                                                                
            }
            System.debug('BatchObjectTerritory2Association objectTerritory2Changed End');
            return accList;
        }       
       /***Fin AZI W-001713 */
}