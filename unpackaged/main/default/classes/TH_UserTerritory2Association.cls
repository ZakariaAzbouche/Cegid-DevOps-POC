/**
 * @File Name          : TH_UserTerritory2Association
 * @Description        : Update UserTerritory2Association Values with territory  
 * @Author             : SRA   
 * @Group              : CAP
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    15/06/2021         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
public with sharing class TH_UserTerritory2Association extends TriggerHandler{
    public TH_UserTerritory2Association() {

    }

    public override void afterInsert() {
        system.debug('TH_UserTerritory2Association afterInsert');
        /** AZI W-001713**/
         UserTerritory2Changed ((List<UserTerritory2Association>)Trigger.New);
        /** END AZI W-001713**/
    }

    /*public override void afterUpdate() {
        
        UserTerritory2Changed ((List<UserTerritory2Association>)Trigger.New);
        
    }*/

    public override void afterDelete() {
        system.debug('TH_UserTerritory2Association afterDelete');
        /** AZI W-001713**/
       UserTerritory2Changed ((List<UserTerritory2Association>)Trigger.Old);
        /**END AZI W-001713**/
    }

        /***AZI W-001713 */

        private void UserTerritory2Changed (List<UserTerritory2Association> listUserTerritory2Association){
                system.debug('TH_UserTerritory2Association UserTerritory2Changed begin ');
                List<Id> usersId =  new List<Id>();
                for(UserTerritory2Association userTerritory2Association: listUserTerritory2Association) {
                usersId.add(userTerritory2Association.UserId);
                }

                List<Account> accounts = [SELECT Id, Name, IsOwnerInRightTerritory__c, OwnerId FROM Account WHERE OwnerId IN :usersId];
                set<Id> accsId = new set<Id>();
                for(Account acc : accounts){                    
                    accsId.add(acc.Id);
                }
                TH_Account.IsAccountOwnerInRightTerritory(accsId);        
                system.debug('TH_UserTerritory2Association UserTerritory2Changed End ' + accsId.size());                                                                
        }

}