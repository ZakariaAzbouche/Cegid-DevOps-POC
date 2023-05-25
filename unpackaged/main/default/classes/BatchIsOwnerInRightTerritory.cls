/**
* @author BCR - Capgemini
* @date Creation 12 Jan-2023
* @description BatchIsOwnerInRightTerritory
*        
*/ 
/**
 * @File Name          : BatchIsOwnerInRightTerritory
 * @Description        : update IsOwnerInRightTerritory__c field based on account territory and owner territory
 * @Author             : SRA   
 * @Group              : Capgemini
 * @Last Modified By   : BCR
 * @Last Modified On   : 17/01/2023
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    17/01/2023         BCR              Initial Version
 * ---    -----------       -------           ------------------------ 
           
**/
public class BatchIsOwnerInRightTerritory implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC) {
                 
        return Database.getQueryLocator([SELECT Id, IsOwnerInRightTerritory__c, OwnerId FROM Account]);
    }
     
    public void execute(Database.BatchableContext BC, List<Account> accs) {
        Set<Id> accIds = new Set<Id>();
        Set<Id> ownerIds = new Set<Id>();
        List<Account> accsToUpdate = new List<Account>();
        Map<Id, Set<Id>> mapAccByTerritorys = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> mapUsrByTerritorys = new Map<Id, Set<Id>>();

        for(Account acc : accs) {
            accIds.add(acc.Id);
            ownerIds.add(acc.OwnerId);
        }

        //get all accounts territory2 in the active Territory2Model
        List<ObjectTerritory2Association> accTerritories = [SELECT Id, ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId IN: accIds AND 
                                                                                                                                     Territory2.Territory2Model.State = 'Active'];
        //get all accounts owner territory2 in the active Territory2Model
        List<UserTerritory2Association> usrTerrAssociations = [SELECT Id, UserId, Territory2Id FROM UserTerritory2Association WHERE isActive = true AND 
                                                                                                                                    UserId IN: ownerIds AND 
                                                                                                                                    RoleInTerritory2 = 'Opportunity Owner' AND 
                                                                                                                                    Territory2.Territory2Model.State = 'Active'];
        //fill mapAccByTerritorys
        for(ObjectTerritory2Association accTerrAssociation : accTerritories) {
            if(!mapAccByTerritorys.containsKey(accTerrAssociation.ObjectId)) {
                mapAccByTerritorys.put(accTerrAssociation.ObjectId, new Set<Id>());
            }
            mapAccByTerritorys.get(accTerrAssociation.ObjectId).add(accTerrAssociation.Territory2Id);
                
        }
        System.debug(mapAccByTerritorys);

        //fill mapUsrByTerritorys
        for(UserTerritory2Association usrTerrAssociation : usrTerrAssociations) {
            if(!mapUsrByTerritorys.containsKey(usrTerrAssociation.UserId)) {
                mapUsrByTerritorys.put(usrTerrAssociation.UserId, new Set<Id>());
            }
            mapUsrByTerritorys.get(usrTerrAssociation.UserId).add(usrTerrAssociation.Territory2Id);
                
        }

        Boolean IsOwnerOldValue;

        for(Account acc : accs) {
            IsOwnerOldValue = acc.IsOwnerInRightTerritory__c;
            if(mapAccByTerritorys.get(acc.Id) != null && mapUsrByTerritorys.get(acc.OwnerId) != null) {

                mapAccByTerritorys.get(acc.Id).retainAll(mapUsrByTerritorys.get(acc.OwnerId));//For every accounts intersect account territory Set and Owner territory Set

                if(mapAccByTerritorys.get(acc.Id).isEmpty()) {
                    acc.IsOwnerInRightTerritory__c = false;
                } else {
                    acc.IsOwnerInRightTerritory__c = true;
                } 
            } else {
                acc.IsOwnerInRightTerritory__c = false;
            }
            if(IsOwnerOldValue != acc.IsOwnerInRightTerritory__c) {
                accsToUpdate.add(acc);
            }   
        }

        if(!accsToUpdate.isEmpty()) {
            update accsToUpdate;
        }
    }   
     
    public void finish(Database.BatchableContext BC) {
        
    }
}