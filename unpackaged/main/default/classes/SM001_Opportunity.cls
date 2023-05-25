/**
* @author Keshav - Comforth
* @date Creation 17 Jan-2020
* @description SM001_Opportunity
*              Assign Opportunity OWner based upon Territory
*/ 
/**
 * @File Name          : SM001_Opportunity
 * @Description        : Update owner field based on territory when an opportunity is created from a contact
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Last Modified By   : SRA
 * @Last Modified On   : 31/07/2020
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    31/07/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
public class SM001_Opportunity {
    private static final String TERRITORY = 'Territory';
    private static final String TERRITORY_ASSOCIATION_MANUAL = 'Territory2AssociationManual';
    private static final String NO_TERRITORY = 'No Territory';
    private static final String OPPORTUNITY_OWNER = 'Opportunity Owner';
    
    @future
    public static void setOppOwner(set<Id> setOppId, set<Id> setAccId){
        
        //system.debug('listOppId'+setOppId);
        
        List<Opportunity> listOpp = [Select Id ,Name,Oppy_AutoCreated__c,AccountId,Territory2Id,Expertise__c,Oppy_converted_from_Lead__c from Opportunity where Id IN:setOppId ];
        system.debug('listOpp'+listOpp);
        
        // Create Set which store Account Territory Id
        Territory2 territoryObj = new Territory2();
        Set<Id> setAccTerritoryIds = new Set<Id>();
        Set<opportunity> setOpportunityUpdate = new Set<opportunity>();
        List<Opportunity> listOpportunityToUpdate = new List<Opportunity>();
        List<Opportunity> result = new List<Opportunity>();
        Map<Id, List<Id>> mapAccountShare = new Map<Id, List<Id>>();
        set<Id> userOrGroupIds = new set<Id>();
        Map<Id, Id> mapGroup = new Map<Id, Id>();
        Map<Id, Territory2> mapUserTerritory = new Map<Id, Territory2>();
        Map<Id, UserTerritory2Association> mapUserTerritory2Association = new Map<Id,UserTerritory2Association>();
        
        // Query in Account Share object
        for(AccountShare objAcctShare : [SELECT Id, UserOrGroupId, AccountId 
                                         FROM AccountShare 
                                         WHERE (RowCause =:TERRITORY OR RowCause =:TERRITORY_ASSOCIATION_MANUAL) 
                                         AND AccountId IN :setAccId]){
                                             system.debug('objAcctShare'+objAcctShare);
                                             if(mapAccountShare.containsKey(objAcctShare.AccountId)){
                                                 mapAccountShare.get(objAcctShare.AccountId).add(objAcctShare.UserOrGroupId);
                                             }else{
                                                 mapAccountShare.put(objAcctShare.AccountId, new List<Id>{objAcctShare.UserOrGroupId});
                                             }
                                             
                                             userOrGroupIds.add(objAcctShare.UserOrGroupId);
                                             
                                         }  
        //system.debug('userOrGroupIds'+userOrGroupIds);
        // Query in Group object from where access RelatedId
        // Map of Group object
        for(Group objGroupRecord : [SELECT Id,Name, RelatedId ,DeveloperName 
                                    FROM Group 
                                    WHERE Type =:TERRITORY 
                                    AND Id IN : userOrGroupIds]){
                                        system.debug('objGroupRecord'+objGroupRecord);
            mapGroup.put(objGroupRecord.Id, objGroupRecord.RelatedId);         
        }
        //system.debug('mapGroup'+mapGroup);
        // Populate Territory details of assigned Territory of Account.
        // Query in Territory object
        Map<Id, Territory2> mapTerritories = new Map<Id, Territory2>([SELECT Id, Name, ParentTerritory2Id, ForecastUserId, Description, Agency__c,
                                                                      BU__c,Channel__c,CommercialOrganization__c,Job__c,Sales_Region__c,TerritoryCode__c,Expertise__c
                                                                      FROM Territory2 
                                                                      WHERE Id IN:mapGroup.Values() And Expertise__c=:listOpp[0].Expertise__c]);
        
        //system.debug('mapTerritories'+mapTerritories);
        // If the Id of NO TERRITORY is found on the Opp the owner of the opp will stay the same
        List<Territory2> listTerritory2 = [SELECT Id,DeveloperName ,Name 
                                           FROM Territory2 
                                           WHERE Name =:NO_TERRITORY limit 1];

        for(UserTerritory2Association uts:[SELECT Id, RoleInTerritory2, Territory2Id, UserId 
                                           FROM UserTerritory2Association  
                                           WHERE Territory2Id IN:mapTerritories.keySet() 
                                           AND  RoleInTerritory2 =:OPPORTUNITY_OWNER]){
            mapUserTerritory2Association.put(uts.Territory2Id,uts);
        }
        //system.debug('mapUserTerritory2Association'+mapUserTerritory2Association);
        
        for(Opportunity opp:listOpp){
            //system.debug('opp'+opp);
            if(mapAccountShare.containsKey(opp.AccountId)){
                for(Id userGroupId: mapAccountShare.get(opp.AccountId)){
                    //system.debug('userGroupId'+userGroupId);
                    Id territoryId = mapGroup.get(userGroupId);
    
                    if(mapTerritories.containsKey(territoryId)){
                        territoryObj = mapTerritories.get(territoryId);
                    }
                    else{
                        territoryObj = mapTerritories.get(opp.Territory2Id);
                    }
                    //system.debug('opp.Oppy_AutoCreated__c'+opp.Oppy_AutoCreated__c);
                    //system.debug('opp.Territory2Id'+opp.Territory2Id);
                    //system.debug('territoryObj'+territoryObj);
                    //system.debug('listTerritory2'+listTerritory2);
                    if(opp.Oppy_AutoCreated__c == true || (opp.Territory2Id != listTerritory2[0].Id && opp.Territory2Id != null && opp.Territory2Id == territoryObj.Id)){
                        if(territoryObj != null && mapUserTerritory2Association.get(territoryObj.Id) != null){ 
                            system.debug('territoryObj'+territoryObj);
                            system.debug('mapUserTerritory2Association'+mapUserTerritory2Association);
                            UserTerritory2Association ut2a = mapUserTerritory2Association.get(territoryObj.Id);
                            if(opp.Oppy_converted_from_Lead__c ){
                                opp.TECHOwnerCalculated__c = true;
                            }
                            opp.OwnerId = ut2a.UserId;
                            //removed from Process builder 
                            opp.BU__c = territoryObj.BU__c;
                            opp.CommercialOrganization__c = territoryObj.CommercialOrganization__c;
                            opp.Agency__c =territoryObj.Agency__c;
                            opp.Job__c = territoryObj.Job__c;
                            opp.Channel__c = territoryObj.Channel__c;
                            opp.Sales_Region__c = territoryObj.Sales_Region__c;
                            
                            listOpportunityToUpdate.add(opp);
                        }
                    } else if(opp.Territory2Id == listTerritory2[0].Id && opp.Territory2Id != null){
                        //System.debug('***ESLE IF');
                        if(opp.Oppy_converted_from_Lead__c ){
                            opp.TECHOwnerCalculated__c = true;
                            listOpportunityToUpdate.add(opp);
                        }
                    }
                    
                }
            }
        }
        setOpportunityUpdate.addAll(listOpportunityToUpdate);
        result.addAll(setOpportunityUpdate);
        if(result.size()>0){
            update result;
        }
    }
    
    /**
 	* @author Easyfront Consulting
 	* @date 2023-04-26
 	* @description Method to calculate "Sub Sales Purpose" on Opportunity for Upsell Only Sales Purpose
    * @details Call by TH_Opportunity > W-002573
	*/
    public static void calculateOpportunitySubSalesPurpose(Set<Id> setOppIds){
        Set<String> setProductLineCode = new Set<String>();
        Set<Id> setAccountId = new Set<Id>();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        Map<Id, Set<String>> mapAccountProductLine = new Map<Id, Set<String>>(); //Use to know if the related account has Product Line into AccountCoreBusiness
        Map<String, Boolean> mapCoreProductLine = new Map<String, Boolean>(); //Use to know if the product line is Core
        
        List<Opportunity> listOpp = [SELECT Id, Product_Line__c, AccountId, SubSalesPurpose__c, Sales_Purpose__c FROM Opportunity WHERE Id IN : setOppIds];
        For(Opportunity opp:listOpp){
            setProductLineCode.add(opp.Product_Line__c);
            setAccountId.add(opp.AccountId);
        }
        //Get related AccountCoreBusiness__c of the account and fill the map
        List<AccountCoreBusiness__c> listAccountCoreBusiness = [SELECT AccountExpertise__r.Account__c, ProductLine__c FROM AccountCoreBusiness__c 
                                                                WHERE AccountExpertise__r.Account__c IN : setAccountId AND ProductLine__c IN: setProductLineCode];
        if(!listAccountCoreBusiness.isEmpty()){
            for(AccountCoreBusiness__c acb:listAccountCoreBusiness){
                if(!mapAccountProductLine.containsKey(acb.AccountExpertise__r.Account__c)){
                    mapAccountProductLine.put(acb.AccountExpertise__r.Account__c, new Set<String>{acb.ProductLine__c});
                }else{
                    Set<String> setString = mapAccountProductLine.get(acb.AccountExpertise__r.Account__c);
                    setString.add(acb.ProductLine__c);
                    mapAccountProductLine.put(acb.AccountExpertise__r.Account__c, setString);
                }
            }
        }
        //Get Product Line and fill the map
        List<Product_Line__c> listProductLine = [SELECT Core__c, API_Code__c FROM Product_Line__c WHERE API_Code__c IN: setProductLineCode];
        if(!listProductLine.isEmpty()){
            for(Product_Line__c pl:listProductLine){
                mapCoreProductLine.put(pl.API_Code__c, pl.Core__c);
            }
        }
        system.debug('mapAccountProductLine '+mapAccountProductLine);
        system.debug('mapCoreProductLine '+mapCoreProductLine);
        
        //Fill "Sub Sales Purpose" on opp
        For(Opportunity opp:listOpp){
            if(opp.Sales_Purpose__c != '411'){
                opp.SubSalesPurpose__c = null;
            }else if(mapCoreProductLine.containsKey(opp.Product_Line__c) && mapCoreProductLine.get(opp.Product_Line__c) == false //Check product line is non-core
               && (!mapAccountProductLine.containsKey(opp.AccountId) || (mapAccountProductLine.containsKey(opp.AccountId) && !mapAccountProductLine.get(opp.AccountId).contains(opp.Product_Line__c)))){ //Check account don't have Product Line into "Account Core Business"
                   opp.SubSalesPurpose__c = 'Upsell Only - New Product';
               }else{
                   opp.SubSalesPurpose__c = 'Upsell Only - More of the same';
               }
            oppToUpdate.add(opp);
        }
        update oppToUpdate;
    }
}