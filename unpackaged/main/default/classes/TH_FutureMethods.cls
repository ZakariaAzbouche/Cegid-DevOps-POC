public with sharing class TH_FutureMethods {

    public static final String  STAGE_DRAW_UP_THE_SOLUTION = 'D - Draw up the solution';
    public static final String  STAGE_VALIDATE_THE_SOLUTION = 'C - Validate the solution';
    public static final String  STAGE_NEGOCIATE = 'B - Negotiate';
    public static final String  STAGE_SIGN = 'A - Sign';
    public static final Boolean GLOBAL_TRUE = true;
    public static final String  CONTACT_ROLE = 	'Decision Maker';
    
    
    /*public static void IsAccountOwnerInRightTerritory(List<Id> accsId){ 
        system.debug('TH_FutureMethods IsAccountOwnerInRightTerritory Begin ');   
        List<Account> accounts = [Select Id, Name, IsOwnerInRightTerritory__c, OwnerId From Account Where Id IN :accsId];
        
        List<Id> ownersId =  new List<Id>();
        List<Account> accsUpdated = new List<Account>();

        for (Account acc: accounts) {
            ownersId.add(acc.OwnerId);
            //break;
        }
               System.debug('IsAccountOwnerInRightTerritory ownersId ' + ownersId.size());   

               List<ObjectTerritory2Association> objectTerritory2AssociationList = 
                      [Select Territory2Id, ObjectId From  ObjectTerritory2Association  Where IsDeleted = false  and ObjectId in :accsId];

               System.debug('IsAccountOwnerInRightTerritory :: objectTerritory2AssociationList.size ' +objectTerritory2AssociationList.size() );

                List<UserTerritory2Association> usersTerr = 
                                   [Select UserId, Territory2Id From UserTerritory2Association Where isActive = true and UserId in :ownersId];

                System.debug('IsAccountOwnerInRightTerritory :: usersTerr.size ' +usersTerr.size() );


                for (Account acc: accounts) {
                    boolean userFound  = false;
                    acc.IsOwnerInRightTerritory__c = true;
                    
                    for(ObjectTerritory2Association objectTerritory2Association: objectTerritory2AssociationList){
                        if(objectTerritory2Association.ObjectId.equals(acc.Id)){
                            for(UserTerritory2Association userTerr : usersTerr){                                    
                                if (userTerr.Territory2Id.equals(objectTerritory2Association.Territory2Id) && userTerr.UserId.equals(acc.OwnerId)){
                                    userFound = true;  
                                    break; 
                                }                                                                                                                 
                            } 
                        }                                                                         
                    }       
    
            System.debug('IsAccountOwnerInRightTerritory userFound  : ' + userFound+' For Account  : ' + acc.Name);   
                if(!userFound){
                   acc.IsOwnerInRightTerritory__c = false;                   
                }
                accsUpdated.add(acc);
            } 
            
            if(accsUpdated.size()>0){
                update accsUpdated;
            }                
            System.debug('TH_FutureMethods IsAccountOwnerInRightTerritory End');   
    }

        /***AZI W-001713 TH_Account*/
        /*@future
        public static void IsAccountOwnerInRightTerritoryForTHAccount(List<Id> accsId){

        List<Account> listAccount = new List<Account>();
        listAccount = [Select Id, Name, IsOwnerInRightTerritory__c, OwnerId From Account Where Id IN :accsId];
        
        List<Id> ownersId =  new List<Id>();
        List<Account> accsUpdated = new List<Account>();

        for (Account acc: listAccount) {
            ownersId.add(acc.OwnerId);
        }
            System.debug('IsAccountOwnerInRightTerritoryForTHAccount :: listAccount.size ' +listAccount.size() );
    
            List<ObjectTerritory2Association> objectTerritory2AssociationList = 
                              [Select Territory2Id, ObjectId From  ObjectTerritory2Association  Where IsDeleted = false  and ObjectId in :accsId];
        
            System.debug('IsAccountOwnerInRightTerritoryForTHAccount :: objectTerritory2AssociationList.size ' +objectTerritory2AssociationList.size() );
        
            List<UserTerritory2Association> usersTerr = 
                                           [Select UserId, Territory2Id From UserTerritory2Association Where isActive = true and UserId in :ownersId];
    
            System.debug('IsAccountOwnerInRightTerritoryForTHAccount :: usersTerr.size ' +usersTerr.size() );
    
            for (Account acc: listAccount) {
                    boolean userFound  = false;
                    acc.IsOwnerInRightTerritory__c = true;
                    
                    for(ObjectTerritory2Association objectTerritory2Association: objectTerritory2AssociationList){
                        if(objectTerritory2Association.ObjectId.equals(acc.Id)){
                            for(UserTerritory2Association userTerr : usersTerr){    
                                if (userTerr.Territory2Id.equals(objectTerritory2Association.Territory2Id) && userTerr.UserId.equals(acc.OwnerId)){
                                    userFound = true;  
                                    break; 
                                }                                        
                                                                         
                            } 
                        }                                                                         
                    }       
            
                if(!userFound){
                   acc.IsOwnerInRightTerritory__c = false;
                }
                accsUpdated.add(acc);
            } 

            if(accsUpdated.size()>0){                
                update accsUpdated;
            }

        System.debug('End IsAccountOwnerInRightTerritoryForTHAccount :: ');  
    
        }

   /***Fin AZI W-001713 */

   /** AZI W-001685
     * check if the opportunity contains enough contacts
     */
   /* @future
    public static void checkContactBeforValidateTheSolutionStage (Set<Id> oppiesId) {
        List<User> users = [ SELECT id, Profile.name  FROM user where id = :UserInfo.getUserId() ];
        String profileName = null;
        if (users.size()>0){
           profileName = users.get(0).Profile.Name;
        }
        
        List<Id>  territory2Ids = new List<Id>();
        List<Opportunity> listOppy = [Select Id, Territory2Id, StageName, Sales_Purpose__c From Opportunity Where Id IN :oppiesId];
        for (Opportunity opportunity : listOppy) {
            territory2Ids.add(opportunity.Territory2Id);       
        }
        system.debug('TH_FutureMethods checkContactBeforValidateTheSolutionStage  listOppy: ' + listOppy.size());
        
        List<Territory2> terrList = [SELECT Business__c From Territory2 Where Id IN :territory2Ids];

        List<OpportunityContactRole> OpportunityContactRoleList = [Select Id From OpportunityContactRole Where OpportunityId  IN:oppiesId];
        List<Opportunity> oppiesUpdated = new List<Opportunity>();
        for (Opportunity opportunity : listOppy) {
            
            if (!STAGE_VALIDATE_THE_SOLUTION.equals(opportunity.StageName) 
                 && !STAGE_NEGOCIATE.equals(opportunity.StageName)
                 && !STAGE_SIGN.equals(opportunity.StageName)) return ;

            //411==> Upsell only
            if('411'.equals(opportunity.Sales_Purpose__c))return;
            
                 for (Territory2 territory2 : terrList) {
                     if(territory2.Id.equals(opportunity.Territory2Id)){

                        if(!'Value'.equals(territory2.Business__c))return;

                     }
                 
                }
                Integer contactNumber = 0;
                for (OpportunityContactRole opportunityContactRole: OpportunityContactRoleList){
                    if(opportunityContactRole.OpportunityId.equals(opportunity.Id)){
                        contactNumber++;
                    }

                }
            
            if (contactNumber <  3 && profileName != 'System Administrator' ) {
                listOppy[0].addError(System.Label.VR_checkContactBeforValidateTheSolutionStage);
            }                                                            
        }
     }*/
     /****AZI W-001685 */

     /***AZI W-001666 */
    @future
    public static void isOppyOwnerIsActifMemberOfTerritory(Set<Id> oppiesId){       
        system.debug('TH_FutureMethods isOppyOwnerIsActifMemberOfTerritory Begin ');   
        List<Id> ownersIdList = new List<Id>();
        List<Id> territoriesId = new List<Id>();
        List<Opportunity> listOppy = [Select Id, Territory2Id, OwnerId From Opportunity Where Id IN :oppiesId];
        for (Opportunity oppy: listOppy) {
            ownersIdList.add(oppy.OwnerId);
            territoriesId.add(oppy.Territory2Id);
        }

        system.debug('TH_FutureMethods isOppyOwnerIsActifMemberOfTerritory  listOppy: ' + listOppy.size());

        system.debug('TH_FutureMethods isOppyOwnerIsActifMemberOfTerritory  ownersIdList / territoriesId: ' + ownersIdList.size() +' / '+territoriesId.size());

        List<UserTerritory2Association> usersTerrList = [Select Id, UserId, Territory2Id From UserTerritory2Association Where IsActive= true And  UserId IN:ownersIdList And Territory2Id IN:territoriesId];
        
        system.debug('TH_FutureMethods isOppyOwnerIsActifMemberOfTerritory  usersTerrList: ' + usersTerrList.size());

        List<Opportunity> oppiesUpdated = new List<Opportunity>();
        for (Opportunity oppy: listOppy) {
            oppy.Owner_not_on_account_territory__c=true;
            for(UserTerritory2Association userTerritory2Association :usersTerrList){                
                system.debug('TH_FutureMethods isOppyOwnerIsActifMemberOfTerritory : ' + userTerritory2Association.UserId +' '+oppy.OwnerId+' | '+ userTerritory2Association.Territory2Id+' '+oppy.Territory2Id);   
                if(userTerritory2Association.UserId.equals(oppy.OwnerId) && userTerritory2Association.Territory2Id.equals(oppy.Territory2Id)){
                    oppy.Owner_not_on_account_territory__c=false;
                }
            }
            oppiesUpdated.add(oppy);
        }
        
        if(oppiesUpdated.size()>0){
            update oppiesUpdated;
        }   

        system.debug('TH_FutureMethods isOppyOwnerIsActifMemberOfTerritory End ');   
    }
    /***Fin AZI W-001666 */
}