/**
* @author Keshav - Comforth
* @date Creation 17 Jan-2020
* @description TH_Opportunity
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
 * Ver       Date            Author              Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    31/07/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
 * 1.1    13/04/2021         SCH              1.1
 * ---    -----------       -------           ------------------------ 
 * 2.0    10/01/2022         BCR              
**/

public without sharing class TH_Opportunity extends TriggerHandler {
    /**
* @author
* @date
* @description Constructor
* @return void
*/
    public static final String  STAGE_VALIDATE_THE_SOLUTION = 'C - Validate the solution';
    public static final String STAGE_G_MQL  = 'G - MQL';
    public static final String STAGE_G_SALES_READY  = 'G - Sales Ready';
    public static final String STAGE_F_IDENTIFY_NEED  = 'F - Identify the needs';
    public static final String STAGE_E_ANALYSE_NEED  = 'E - Analyze the needs';
    public static final String STAGE_D_DRAWUP_SOLUTION  = 'D - Draw up the solution';
/**
* @author
* @date
* @description Handler Method for before Insert Event
* @return void
*/
    public override void beforeInsert() {
        system.debug('TH_Opportunity beforeInsert');  
        
        /**BCR W-1858 start */
        affectLeadSourceFromUserType((List<Opportunity>)Trigger.new);
        /**BCR W-1858 end */
        
        /**BCR W-1854 start */
        oppyTerritoryCalculation((List<Opportunity>)Trigger.new, true);
        /**BCR W-1854 end */
        
        /*BCR W-001892 start */
        getLeadPartnerDistributor((List<Opportunity>)Trigger.new);
        /*BCR W-001892 end */
        
        bookingDimensionMangement((List<Opportunity>)Trigger.new);
        
        // W-002375
        gsalesReadyTypeLeadSource((List<Opportunity>)Trigger.new);
        
        // W-002307
        storeStageNameToTechCreatedStage((List<Opportunity>)Trigger.new);
    }

// US W-002375

public void gsalesReadyTypeLeadSource(List<Opportunity> opps) {
    Set<Id> ownerIds = new Set<Id>();
    for(Opportunity opp : opps) {
        ownerIds.add(opp.ownerId);
    }

    Map<Id, User> users = new Map<Id, User>([SELECT id, Profile.name, Sale_Type__c FROM user WHERE id IN: ownerIds]);
    // List<Opportunity> Opps2Update = new List<Opportunity>();

    for(Opportunity opp : opps) {

        if (opp.StageName == 'G - Sales Ready' && users.get(opp.ownerId).Sale_Type__c == 'EuroCRM' && users.get(opp.ownerId).profile.Name == 'Cegid Sales') {
            opp.LeadSource = 'EuroCRM';
        } 
    }
    // if(Opps2Update.isEmpty == false){
    //     Opps2Update.update();
    // }
}

// US W-002448

    
    

/**
* @author
* @date
* @description Handler Method for before Update Event
* @return void
*/
    public override void beforeUpdate() {
        system.debug('TH_Opportunity beforeUpdate');
        Map<Id, Opportunity> oppysToBeProcess = (Map<Id, Opportunity>) CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.BEFORE_UPDATE);
        if(oppysToBeProcess.isEmpty()) {//Control recursiv call from trigger
            System.debug('No Oppy to be processed');
        } else {
            //All trigger logic should be here
            List<User> users = [ SELECT id, Profile.name FROM user where id = :UserInfo.getUserId() ];
       
            String profileName = null;
            if (users.size() > 0){
               profileName = users.get(0).Profile.Name;
            }
            set<Id> setAccId = new set<Id>();
            set<Id> setOpp = new set<Id>();
            //SCH13042021
            // checkValidEmailDecisionMaker ((List<Opportunity>)Trigger.New) ;
            //SCH13042021        

            Integer cpt = 0;
            for(Opportunity o : oppysToBeProcess.values()){
                system.debug('o.Oppy_converted_from_Lead__c ' + o.Oppy_converted_from_Lead__c);
                system.debug('o.TECHOwnerCalculated__c' + o.TECHOwnerCalculated__c);
                system.debug('OppID before Update' + o.Id);
                if(o.Oppy_converted_from_Lead__c == true && o.TECHOwnerCalculated__c == false){
                    setAccId.add(o.AccountId);
                    setOpp.add(o.Id);
                }
                //AYZ14042021 Debut  

                if(canTriggerByFeature('CalculateOppyEstProjectWorkload__c') && 
                    o.TECH_Professional_Services_Workload__c != ((Opportunity)Trigger.oldMap.get(o.Id)).TECH_Professional_Services_Workload__c){
                o.Estimated_Project_Workload__c = o.TECH_Professional_Services_Workload__c;              
                } 
                    
                Opportunity oldOpportunity = (Opportunity)Trigger.old[cpt];  
                getUpdatedOppyWinningCompetitor(o, oldOpportunity);    //L'output n'est pas utilisé         
                 
                 if(o.StageName.equals('Closed Lost') && o.Loss_Reason__c == 'Competition choosen'){ 
                    if (!String.isEmpty(o.Competitors__c)){
                        o.Winning_competitor__c = o.Winning_Competitor_hidden__c; // => Winning_Competitor_hidden__c correspond au dernier compétitor ajouté                 
                    }else{
                        if (profileName != 'System Administrator' ) {
                            o.addError(System.Label.VR_Check_Competitors_Empty);                    
                        }
                    }                
                 }
                 cpt++;
                //AYZ14042021 Fin
                
                /**AZI W-001691**/ 
                if(o.Oppy_converted_from_Lead__c && o.Origin_Lead_Id__c ==  null){ //potentiellement à supprimé
                    o.Origin_Lead_Id__c = o.TECH_Lead_Id__c;
                }    
                /**Fin AZI W-001691**/
                /****BCR B-1321 */
                if(!o.Oppy_converted_from_Lead__c) {
                    o.TECH_Lead_Id__c = '';
                } 
                /****Fin BCR B-1321 */
            } 
            
            /** AZI W-001685**/
            checkContactBeforValidateTheSolutionStage(oppysToBeProcess);
            /**End AZI W-001685**/

            /**BCR W-1854 start */
            oppyTerritoryCalculation(oppysToBeProcess.values(), false);
            /**BCR W-1854 end */

            bookingDimensionMangement(oppysToBeProcess.values());
    
            /** BCR W-001896 start */
            partnerAccountInPartnerDistributor(oppysToBeProcess.values(), (Map<Id, Opportunity>)Trigger.oldMap);
            /**BCR W-1896 end */
            System.debug('setOpp'+setOpp);
            if(setOpp.size()>0){
                if(System.IsBatch() == false && System.isFuture() == false) { 
                    SM001_Opportunity.setOppOwner(setOpp, setAccId);
                }
            }
        }
        

        system.debug('TH_Opportunity End beforeUpdate');
    }

/**
* @author
* @date
* @description Handler Method for before Update Event
* @return void
*/
public override void afterUpdate() {
    system.debug('TH_Opportunity afterUpdate');
    Map<Id, Opportunity> oppysToBeProcess = (Map<Id, Opportunity>) CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.AFTER_UPDATE);
    if(oppysToBeProcess.isEmpty()) {//Control recursiv call from trigger
        System.debug('No Oppy to be processed');
    } else {
        Set<Id> oppiesId = oppysToBeProcess.keySet();
        Set<Id> setOppIdsSubSalesPurpose = new Set<Id>(); //MLE - W-002573
        
        /***AZI W-001666 */   
        if(System.IsBatch() == false && System.isFuture() == false && oppiesId.size()>0){  
            TH_FutureMethods.isOppyOwnerIsActifMemberOfTerritory(oppiesId);
        }
        passAccountToCustomerOppyTSWin(oppysToBeProcess.values(), (Map<Id, Opportunity>) Trigger.oldMap);
        
        for(Opportunity opp:(List<Opportunity>)Trigger.new){
            Opportunity oldOpportunity = (Opportunity)trigger.oldMap.get(opp.Id);
            /*MLE W-002573 start */
            if((opp.Sales_Purpose__c == '411' && (opp.Sales_Purpose__c != oldOpportunity.Sales_Purpose__c || opp.Product_Line__c != oldOpportunity.Product_Line__c || opp.SubSalesPurpose__c == null))
               || (opp.Sales_Purpose__c != oldOpportunity.Sales_Purpose__c && oldOpportunity.Sales_Purpose__c == '411')){
                setOppIdsSubSalesPurpose.add(opp.Id); 
            }
        }
        if(!setOppIdsSubSalesPurpose.isEmpty()){
           SM001_Opportunity.calculateOpportunitySubSalesPurpose(setOppIdsSubSalesPurpose); 
        }
        /*MLE W-002573 end */        
    }
    /*****Start Ajout ligne Comforth ******/
        /*set<Id> setOppQuote = new set<Id>();

		for(Opportunity o:(List<Opportunity>)Trigger.old){
             Opportunity oldOppy = (Opportunity)trigger.oldMap.get(o.Id);
    
              //Opty has a primary quote and needs to be updated ?
             if(o.TECH_HasOppLineItem__c > 0 && 
                 (
                  (oldOppy.SBQQ__PrimaryQuote__c <> o.SBQQ__PrimaryQuote__c && o.SBQQ__PrimaryQuote__c != null) ||
                  (oldOppy.Contract_Duration__c <> o.Contract_Duration__c && o.Contract_Duration__c != null)
                 )
               ){
               setOppQuote.add(o.Id);
             }
         }
         /*if(setOppQuote.size()>0){
             SM011_OpportunityCalculation.calculateOppQuote(setOppQuote);
         }*/

        /********End Ajout ligne Comforth*******/

    /***AZI W-001666 */
    system.debug('TH_Opportunity End afterUpdate');
   }
    
     /**
     * check if the email Adress is valid on decision maker
     */
    /*public static void checkValidEmailDecisionMaker (List<Opportunity> ListOppy ) {
        
        Set<Id> setOppId = (new Map<Id,Opportunity>(ListOppy)).keySet();
        for (Opportunity opportunity : ListOppy) {
            
            if (opportunity.StageName != STAGE_DRAW_UP_THE_SOLUTION) return ;
            List<OpportunityContactRole > opportunityContactRole  = new List<OpportunityContactRole >();
            opportunityContactRole  =  [Select id from OpportunityContactRole  where OpportunityId IN:setOppId 
                                        and Contact.Mkto_email_invalid__c = :GLOBAL_TRUE
                                        and Opportunity.TECH_Has_a_decision_maker__c = :GLOBAL_TRUE 
                                        and role = :CONTACT_ROLE];
      
            if (opportunityContactRole.size() >  0 ) {
                ListOppy[0].addError(System.Label.VR_checkEmailValidDecisionMaker);
            }                                                            
        }
     }*/

    
// TMG 04/04/2023
// W-002450 
 
    public void  preventCreatorModification(Map<Id, Opportunity> oppMap) {
    Set<Id> creatorIds = new Set<Id>();

    for(Opportunity opp : oppMap.values()) {
        system.debug('Created By' + opp.createdById);
        creatorIds.add(opp.createdById);

    }

    Map<Id, User> users = new Map<Id, User>([SELECT id, Profile.name, BU__c FROM user WHERE id IN: creatorIds]);
    
    List<Opportunity> opps = ([SELECT id, createdById FROM Opportunity WHERE id IN: oppMap.keySet()]);
    
	for(Opportunity opp : opps) {

        if(users.get(opp.createdById).BU__c == 'Not Assigned'){

            opp.TECH_BU_Created_By_2__c = 'Not Assigned';

        } else {
            opp.TECH_BU_Created_By_2__c  = users.get(opp.createdById).BU__c;
        }
   	} 
    
    update opps;
}

// W-002307

public void storeStageNameToTechCreatedStage(List<Opportunity> opps) {
   

    for(Opportunity opp : opps) {      
            opp.TECH_Created_Stage__c = opp.StageName;      
    } 

}


        
    public override void afterInsert() {
        system.debug('TH_Opportunity afterInsert');
        set<Id> setAccId = new set<Id>();
        set<Id> setOpp = new set<Id>();
        Set<Id> oppiesId = new Set<Id>();
        Set<Id> setOppIdsSubSalesPurpose = new Set<Id>(); //MLE - W-002573
        
        for(Opportunity o:(List<Opportunity>)Trigger.New){
            system.debug('OppID afterInsert' + o.Id);
            
            if(o.Oppy_AutoCreated__c == true && !o.TECH_Force_Owner__c && !o.Oppy_converted_from_Lead__c){
                setAccId.add(o.AccountId);
                setOpp.add(o.Id);
                system.debug('setOpp'+setOpp);
            } 
            
            /*MLE W-002573 start */
            if(o.Sales_Purpose__c == '411'){
                setOppIdsSubSalesPurpose.add(o.Id); 
            }
            /*MLE W-002573 end */        
            oppiesId.add(o.Id);          
        } 
        
        /*MLE W-002573 start */
        if(!setOppIdsSubSalesPurpose.isEmpty()){
            SM001_Opportunity.calculateOpportunitySubSalesPurpose(setOppIdsSubSalesPurpose);
        }
		/*MLE W-002573 end */   
        /***AZI W-001666 */
        if(System.IsBatch() == false && System.isFuture() == false && oppiesId.size()>0){  
            TH_FutureMethods.isOppyOwnerIsActifMemberOfTerritory(oppiesId);
        }
        /***AZI W-001666 */

        if(setOpp.size()>0){
            if(System.IsBatch() == false && System.isFuture() == false) { 
                SM001_Opportunity.setOppOwner(setOpp,setAccId);
            }
        }      

        preventCreatorModification((Map<Id, Opportunity>) Trigger.NewMap);
		
 
    }
    
    
    
    
    /** BCR W-001896 start */
    @TestVisible 
    private void partnerAccountInPartnerDistributor(List<Opportunity> opps, Map<Id, Opportunity> oldMap) {
        for(opportunity opp : opps) {
            if((opp.ImpartnerPRM__PartnerAccount__c != null && oldMap == null) || (opp.ImpartnerPRM__PartnerAccount__c != oldMap.get(opp.Id).ImpartnerPRM__PartnerAccount__c)) {
                opp.Partner_Distributor__c = opp.ImpartnerPRM__PartnerAccount__c;
            }
        }
    }
    /**BCR W-1896 end */

    /**BCR W-001919 start */
    @TestVisible
    private void bookingDimensionMangement(List<Opportunity> opps) {
        System.debug('Booking');
        Decimal decreasePart;

        //Get Primary Quote info about booking
        Set<Id> setOppIds = new Set<Id>();
        for(Opportunity opp : opps) {
            setOppIds.add(opp.Id);
        }
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Id,SBQQ__PrimaryQuote__r.Recurring_SaaS_Amount_Monthly__c,SBQQ__PrimaryQuote__r.Recurring_Licenses_Amount_Monthly__c,SBQQ__PrimaryQuote__r.Recurring_Services_Amount_Monthly__c,SBQQ__PrimaryQuote__r.Recurring_Training_Amount_Monthly__c,SBQQ__PrimaryQuote__r.Recurring_Maintenance_Amount_Monthly__c, 
                                                                SBQQ__PrimaryQuote__r.One_Time_SaaS_Amount__c,SBQQ__PrimaryQuote__r.One_Time_Licenses_Amount__c,SBQQ__PrimaryQuote__r.One_Time_Services_Amount__c,SBQQ__PrimaryQuote__r.One_Time_Training_Amount__c,SBQQ__PrimaryQuote__r.One_Time_Maintenance_Amount__c
                                                                FROM Opportunity WHERE Id IN : setOppIds]);

        for(Opportunity opp : opps) {
            decreasePart = 0;
            if(opp.SBQQ__PrimaryQuote__c != null) { //Si il y a une quote CPQ
                System.debug('Booking CPQ');
                //Booking = Recurring amount * 12 + OneTime amount
                opp.SaaS_Booking_Amount__c = convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.Recurring_SaaS_Amount_Monthly__c)*12 +  convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.One_Time_SaaS_Amount__c);
                opp.Licences_Booking_Amount__c =  convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.Recurring_Licenses_Amount_Monthly__c)*12 +  convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.One_Time_Licenses_Amount__c);
                opp.Prof_Services_Booking_Amount__c = convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.Recurring_Services_Amount_Monthly__c)*12 +  convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.One_Time_Services_Amount__c) + convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.Recurring_Training_Amount_Monthly__c)*12 +  convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.One_Time_Training_Amount__c);
                opp.Other_Amount__c = convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.Recurring_Maintenance_Amount_Monthly__c)*12 +  convertNullToZero(mapOpp.get(opp.Id).SBQQ__PrimaryQuote__r.One_Time_Maintenance_Amount__c);

            } else if(opp.Buy_Me_Quote_Id__c != null) { //Si il y a une quote buy Me
                System.debug('Booking BUY ME');
                if(opp.Old_SaaS_Booking_BuyMe__c > 0) {
                    decreasePart = opp.Old_SaaS_Booking_BuyMe__c;
                    opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_BuyMe__c) - decreasePart;
                    
                } else if(opp.Old_MRR__c > 0 && opp.Sales_Purpose__c == '612') { //&& opp.Sales_Purpose__c == '612'
                    if(opp.Contract_Duration__c != null) {
                        if(opp.Contract_Duration__c < 12) {
                            decreasePart = convertNullToZero(opp.Old_MRR__c) * opp.Contract_Duration__c;
                            opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_BuyMe__c) - decreasePart;
                            
                        } else {
                            decreasePart = convertNullToZero(opp.Old_MRR__c) * 12;
                            opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_BuyMe__c) - decreasePart;
                            
                        }
                    } else {
                        opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_BuyMe__c);
                    }
                    
                } else {
                    opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_BuyMe__c);
                }
                opp.amount = convertNullToZero(opp.Licences_Booking_Amount__c) + convertNullToZero(opp.Prof_Services_Booking_Amount__c) + convertNullToZero(opp.New_SaaS_Booking_BuyMe__c) - decreasePart + convertNullToZero(opp.Other_Amount__c);  
            
            } else if(opp.Oppy_TS__c && !String.isEmpty(opp.ID_TS__c) && (opp.New_SaaS_Booking_CPQ_TS__c != 0) && (opp.New_SaaS_Booking_CPQ_TS__c != null)) { 
                System.debug('Booking TS'); //Si l'oppy est TS
                if(opp.Sales_Purpose__c == '612') {
                    if(opp.Contract_Duration__c != null) {
                        if(opp.Contract_Duration__c < 12 ) {
                            opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_CPQ_TS__c) - convertNullToZero(opp.Old_MRR__c) * opp.Contract_Duration__c;
                        } else {
                            opp.Saas_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_CPQ_TS__c) - convertNullToZero(opp.Old_MRR__c) * 12;
                        }
                    } else {
                        opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_CPQ_TS__c);
                    } 
                } else {
                    opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_SaaS_Booking_CPQ_TS__c);
                }  

            } else { //Si il n'y a aucune quote
            System.debug('Booking R');
                if(opp.Contract_Duration__c != null) {
                    if(opp.Sales_Purpose__c == '612') {
                        if(opp.Contract_Duration__c < 12 ) {
                            opp.SaaS_Booking_Amount__c = (convertNullToZero(opp.New_MRR__c) - convertNullToZero(opp.Old_MRR__c)) * opp.Contract_Duration__c;
                        } else {
                            opp.Saas_Booking_Amount__c = (convertNullToZero(opp.New_MRR__c) - convertNullToZero(opp.Old_MRR__c)) * 12;
                        }
                    } else {
                        if(opp.Contract_Duration__c < 12 ) {
                            opp.SaaS_Booking_Amount__c = convertNullToZero(opp.New_MRR__c) * opp.Contract_Duration__c;
                        } else {
                            opp.Saas_Booking_Amount__c = convertNullToZero(opp.New_MRR__c) * 12;
                        }
                    }  
                } else {
                    opp.Saas_Booking_Amount__c = null;
                }
                opp.Amount = convertNullToZero(opp.Licences_Booking_Amount__c) + convertNullToZero(opp.Prof_Services_Booking_Amount__c) + convertNullToZero(opp.Saas_Booking_Amount__c) + convertNullToZero(opp.Other_Amount__c);
            
            }
        }
    }

    private Double convertNullToZero(Decimal nb) {
        if(nb == null) {
            return 0.00;
        } else {
            return nb;
        }
    }
 
    /**BCR W-001919 end */

    /****AZI W-00785 */
    private static Opportunity getUpdatedOppyWinningCompetitor (Opportunity newOpportunity, Opportunity oldOpportunity){   
                
        if (String.isEmpty(newOpportunity.Competitors__c))return newOpportunity;   

        if(newOpportunity.Competitors__c.equals(oldOpportunity.Competitors__c))return newOpportunity;
        
        String[] competitorsTab = newOpportunity.Competitors__c.split(';');

        boolean existedValue = false;
        String addedValue = null;

        if(String.isEmpty(oldOpportunity.Competitors__c)){
            addedValue = competitorsTab[competitorsTab.size()-1];
        }else{     
            String[] oldCompetitorsTab = oldOpportunity.Competitors__c.split(';');                   
            for(Integer i=0; i<competitorsTab.size(); i++){
                for(Integer j=0; j<oldCompetitorsTab.size(); j++){    
                    if(competitorsTab[i].equals(oldCompetitorsTab[j])){
                        existedValue = true;
                        break;
                    }    
                }
    
                if(!existedValue){
                    addedValue = competitorsTab[i];
                    break;
                }
                existedValue = false;
            }                
        }
        
        newOpportunity.Winning_Competitor_hidden__c = addedValue;
            
        return newOpportunity;
    }
    /***Fin W-00785 */    

    /** AZI W-001685
     * check if the opportunity contains enough contacts
     */
    private void checkContactBeforValidateTheSolutionStage(Map<Id, Opportunity> newMapOpp) {
        
        String profileName = null;
        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : newMapOpp.values()) {
            accIds.add(opp.AccountId);
        }

        Map<Id, Account> accsMap = new Map<Id, Account>([SELECT Id, NumberOfEmployees FROM Account WHERE Id IN: accIds]);

        Map<Id, AggregateResult> contactRoleNbByOpp = new Map<Id, AggregateResult>([SELECT Count(Id) cRoleNb, OpportunityId Id FROM OpportunityContactRole WHERE OpportunityId  IN:newMapOpp.keySet() GROUP BY OpportunityId]);
        
        for(Opportunity opp : newMapOpp.values()) {
            //New version
            if(opp.Sales_Purpose__c != '411' &&
               opp.StageName != STAGE_G_MQL && 
               opp.StageName != STAGE_G_SALES_READY  && 
               opp.StageName != STAGE_F_IDENTIFY_NEED && 
               opp.StageName != STAGE_E_ANALYSE_NEED && 
               opp.StageName != STAGE_D_DRAWUP_SOLUTION &&
               opp.IsClosed != true &&

             accsMap.get(opp.AccountId).NumberOfEmployees >= 2000 && ((Integer)contactRoleNbByOpp.get(opp.Id).get('cRoleNb')) < 3) {
                opp.addError(System.Label.VR_checkContactBeforValidateTheSolutionStage);    
            }                                                   
        }
     }

    /**BCR W-1858 start */
    @TestVisible
    private void affectLeadSourceFromUserType(List<Opportunity> opps) {
        User connectedUser = [SELECT Id, Profile.Name, Sale_Type__c FROM User WHERE Id =: UserInfo.getUserId()];

        System.debug('Connected user '+connectedUser);
        if(connectedUser.Profile.Name == 'CEGID Sales') {

            Set<String> territoryExpertises = new Set<String>();
            Set<Id> accIds = new Set<Id>();
            Map<Id, Set<String>> expertiseByAccs = new Map<Id, Set<String>>();

            List<PermissionSetAssignment> permissions = [SELECT Id,
                                                            PermissionSet.Name,
                                                            PermissionSet.ProfileId,
                                                            PermissionSet.Profile.Name,
                                                            AssigneeId, Assignee.Name 
                                                            FROM PermissionSetAssignment 
                                                            WHERE PermissionSet.Name = 'Ecosystem_Relationships_Management'
                                                            AND AssigneeId =: connectedUser.Id];

            List<UserTerritory2Association> userTerrAssos = [SELECT id, Territory2.Expertise__c 
                                                             FROM userTerritory2Association 
                                                             WHERE isActive = true AND UserId =: UserInfo.getUserId()];

            for(UserTerritory2Association usrTerrAsso : userTerrAssos) {
                territoryExpertises.add(usrTerrAsso.Territory2.Expertise__c);
            }            

            for(Opportunity opp : opps) {
                accIds.add(opp.AccountId);
            }

            List<Account_Expertise__c> accExps = [SELECT expertise__c, Account__c FROM Account_Expertise__c WHERE Account__c IN: accIds]; 

            for(Account_Expertise__c accExp : accExps) {
                if(!expertiseByAccs.containsKey(accExp.Account__c)) {
                    expertiseByAccs.put(accExp.Account__c, new Set<String>());    
                }
                expertiseByAccs.get(accExp.Account__c).add(accExp.expertise__c);
            }

            for(Opportunity opp : opps) {
                if(opp.StageName == 'G - Sales Ready') {
                    if(connectedUser.Sale_Type__c == 'SDR') {
                        System.debug('Opp :' + opp);
                        opp.LeadSource = 'SDR';
                    } else if (permissions.size() > 0) {
                        opp.LeadSource = 'Partner';
                    } 
                }
                
            }
        }
        
     }
     /**BCR W-1858 end */

     /**BCR W-1854 start */
     @TestVisible
     private void oppyTerritoryCalculation(List<Opportunity> opps, Boolean isInsert) {
        Set<Id> ownerIds = new Set<Id>(); //all oppys owner ID
        Set<Id> accIds = new Set<Id>(); //All oppy acc ID
        Map<Id, List<Territory2>> userTerrAssoMap = new Map<Id, List<Territory2>>(); //user ID in key List of territory ID as value
        Map<Id, List<Territory2>> accTerrAsso = new Map<Id, List<Territory2>>(); //Account ID in key List of territory ID as value

        Set<Id> allOppyAccTerritories = new Set<Id>(); //all territory ID extract from parent account

        Map<Id, User> mapTerritoryIdUserOppOwnerId = new Map<Id, User>(); //territory ID in key, user which is oppy owner of territory in value

        for(Opportunity opp : opps) {
            ownerIds.add(opp.OwnerId); //extract all owner IDs
            accIds.add(opp.accountId); //extract all acc ID
        }

        Map<Id, User> usrs = new Map<Id, User>([SELECT Id, 
                                                       Profile.Name, 
                                                       Sale_type__c, 
                                                       Agency__c 
                                                       FROM User WHERE Id IN: ownerIds]);//Get owner IDs profile
        
        List<Territory2> listTerritorys = [SELECT Id,
                                                  DeveloperName,
                                                  Main__c,
                                                  BU__c, 
                                                  CommercialOrganization__c, 
                                                  Sales_Region__c, 
                                                  Job__c, 
                                                  TerritoryCode__c,
                                                  Channel__c,
                                                  Agency__c
                                                  FROM Territory2 
                                                  WHERE Territory2Model.State = 'Active' AND 
                                                  DeveloperName = 'No_Territory'
                                                  LIMIT 1]; //Get No Territory ID and HCM France ID
        
        Territory2 noTerritory = listTerritorys[0];
        Territory2 hcmFranceTerritory;
        User hcmFranceTerritoryOppyOwner;

        List<ObjectTerritory2Association> accTerrAssos = [SELECT Id, 
                                                                 Territory2Id,
                                                                 Territory2.expertise__c, 
                                                                 Territory2.BU__c, 
                                                                 Territory2.CommercialOrganization__c, 
                                                                 Territory2.Sales_Region__c, 
                                                                 Territory2.Job__c, 
                                                                 Territory2.TerritoryCode__c,
                                                                 Territory2.Channel__c,
                                                                 Territory2.Agency__c,
                                                                 ObjectId 
                                                                 FROM ObjectTerritory2Association 
                                                                 WHERE ObjectId IN: accIds AND Territory2.Territory2Model.State = 'Active'];//Get all Account territory association (Territory is filter by active territory model)
        
        if(accTerrAssos.size() > 0) {
            for(ObjectTerritory2Association objTerrAsso : accTerrAssos) {
                if(!accTerrAsso.containsKey(objTerrAsso.ObjectId)) {
                    accTerrAsso.put(objTerrAsso.ObjectId, new List<Territory2>());
                }
                accTerrAsso.get(objTerrAsso.ObjectId).add(new Territory2(Id = objTerrAsso.territory2Id, expertise__c = objTerrAsso.Territory2.expertise__c,
                                                                           BU__c = objTerrAsso.territory2.BU__c,
                                                                           CommercialOrganization__c = objTerrAsso.territory2.CommercialOrganization__c,
                                                                           Sales_Region__c = objTerrAsso.territory2.Sales_Region__c,
                                                                           Job__c = objTerrAsso.territory2.Job__c,
                                                                           TerritoryCode__c = objTerrAsso.territory2.TerritoryCode__c,
                                                                           Channel__c = objTerrAsso.territory2.Channel__c,
                                                                           Agency__c = objTerrAsso.territory2.Agency__c));
                allOppyAccTerritories.add(objTerrAsso.territory2Id);
                
            }
        }

        List<UserTerritory2Association> userTerrAssosList = [SELECT Id, 
                                                                UserId, 
                                                                User.Profile.Name,
                                                                User.Sale_type__c, 
                                                                User.Agency__c,  
                                                                Territory2Id,
                                                                Territory2.DeveloperName, 
                                                                Territory2.Main__c,
                                                                Territory2.BU__c, 
                                                                Territory2.CommercialOrganization__c, 
                                                                Territory2.Sales_Region__c, 
                                                                Territory2.Job__c, 
                                                                Territory2.TerritoryCode__c,
                                                                Territory2.Channel__c,
                                                                Territory2.Agency__c
                                                         FROM UserTerritory2Association 
                                                         WHERE RoleInTerritory2 = 'Opportunity owner' 
                                                         AND ((UserId IN: ownerIds AND User.Profile.Name = 'Cegid Sales' AND Territory2.Main__c = true) 
                                                         OR Territory2Id IN: allOppyAccTerritories
                                                         OR Territory2.DeveloperName = 'HCM_France')
                                                         AND IsActive = true 
                                                         AND Territory2.Territory2Model.State = 'Active']; //Get user territory association (Territory is filter by active territory model and user by profile Sales and role Opportunity owner)

        if(userTerrAssosList.size() > 0) {
            for(UserTerritory2Association usrTerrAsso : userTerrAssosList) {
                if(usrTerrAsso.User.Profile.Name == 'Cegid Sales' && usrTerrAsso.Territory2.Main__c == true && ownerIds.contains(usrTerrAsso.UserId)) {
                    if(!userTerrAssoMap.containsKey(usrTerrAsso.userId)) {
                        userTerrAssoMap.put(usrTerrAsso.userId, new List<Territory2>());
                    }
                                                                
                    userTerrAssoMap.get(usrTerrAsso.userId).add(new Territory2(Id = usrTerrAsso.territory2Id, BU__c = usrTerrAsso.territory2.BU__c,
                                                                               CommercialOrganization__c = usrTerrAsso.territory2.CommercialOrganization__c,
                                                                               Sales_Region__c = usrTerrAsso.territory2.Sales_Region__c,
                                                                               Job__c = usrTerrAsso.territory2.Job__c,
                                                                               TerritoryCode__c = usrTerrAsso.territory2.TerritoryCode__c,
                                                                               Channel__c = usrTerrAsso.territory2.Channel__c,
                                                                               Agency__c = usrTerrAsso.territory2.Agency__c));
                } else if(usrTerrAsso.Territory2.DeveloperName == 'HCM_France') {
                    hcmFranceTerritory = new Territory2(Id = usrTerrAsso.territory2Id, BU__c = usrTerrAsso.territory2.BU__c,
                                                        CommercialOrganization__c = usrTerrAsso.territory2.CommercialOrganization__c,
                                                        Sales_Region__c = usrTerrAsso.territory2.Sales_Region__c,
                                                        Job__c = usrTerrAsso.territory2.Job__c,
                                                        TerritoryCode__c = usrTerrAsso.territory2.TerritoryCode__c,
                                                        Channel__c = usrTerrAsso.territory2.Channel__c,
                                                        Agency__c = usrTerrAsso.territory2.Agency__c);

                    hcmFranceTerritoryOppyOwner = new User(Id = usrTerrAsso.UserId, sale_type__c = usrTerrAsso.User.Sale_type__c, Agency__c = usrTerrAsso.User.Agency__c);
                } else {
                    if(!mapTerritoryIdUserOppOwnerId.containsKey(usrTerrAsso.Territory2Id)) {
                        mapTerritoryIdUserOppOwnerId.put(usrTerrAsso.Territory2Id, new User(Id = usrTerrAsso.userId, Sale_type__c = usrTerrAsso.User.Sale_type__c, Agency__c = usrTerrAsso.User.Agency__c));
                    }
                } 
            }
        }

        Boolean territoryFound;
        for(Opportunity opp : opps) { //For each oppy
            territoryFound = false;
           // if(opp.ID_TS__c != null) {
                //Do nothing
           // } else {
                if(usrs.get(opp.OwnerId).profile.Name == 'Cegid Sales') { //Check the profile
                    if(userTerrAssoMap.containsKey(opp.ownerId)) {
                        updateOppyAttributes(opp, userTerrAssoMap.get(opp.OwnerId)[0], opp.Owner);//fill the territory oppy field with the first territory match 
                    } else {
                        updateOppyAttributes(opp, noTerritory, null); //If no territory match => no territory ID
                    }
                } else if(isInsert) { //If oppy owner isn't a Cegid Sales and if oppy is new
                    if(accTerrAsso.containsKey(opp.accountId)) {
                        for(territory2 terr : accTerrAsso.get(opp.accountId)) {//iterate over all territory for each account
                            if(opp.expertise__c == terr.expertise__c) { //If there is a match expertise oppy with territory expertise
                                if(mapTerritoryIdUserOppOwnerId.containsKey(terr.Id)) {                                    
                                    territoryFound = true;
                                    updateOppyAttributes(opp, terr, mapTerritoryIdUserOppOwnerId.get(terr.Id));
                                    break;
                                }
                                
                            } else if(opp.expertise__c == '380') {
                                if(terr.expertise__c == '320' ) {
                                    if(mapTerritoryIdUserOppOwnerId.containsKey(terr.Id)) {
                                        territoryFound = true;
                                        updateOppyAttributes(opp, terr, mapTerritoryIdUserOppOwnerId.get(terr.Id));
                                        break;
                                    }
                                }
                            } else if(opp.expertise__c == '360' || opp.expertise__c == '370' || opp.expertise__c == '310' || opp.expertise__c == '340' || opp.expertise__c == '350') {
                                if(terr.expertise__c == '360' || terr.expertise__c == '370' || terr.expertise__c == '310' || terr.expertise__c == '340' || terr.expertise__c == '350') {
                                    if(mapTerritoryIdUserOppOwnerId.containsKey(terr.Id)) {
                                        territoryFound = true;
                                        updateOppyAttributes(opp, terr, mapTerritoryIdUserOppOwnerId.get(terr.Id));
                                        break;
                                    }
                                }
                            }
                        }
                        if(territoryFound == false) { //If there is no territory with expertise Treasury, Banking, TAX, ERP Middle or ERP High associated with the account witch is associated with Oppy => no territory
                            updateOppyAttributes(opp, noTerritory, null);
                            
                        } 
                    } else { //If there is no territory associated with the account witch is associated with Oppy => no territory
                        updateOppyAttributes(opp, noTerritory, null);
                    }
                } else {
                    updateOppyAttributes(opp, noTerritory, null);
                }
            // }
        }
    }

    @TestVisible
    private void updateOppyAttributes(Opportunity opp, Territory2 terr, User usr) {
        opp.territory2Id = terr.Id;
        opp.TECH_Territory_Id__c = terr.Id;
        opp.BU__c = terr.BU__c;
        opp.CommercialOrganization__c = terr.CommercialOrganization__c;
        opp.Sales_Region__c = terr.Sales_Region__c;
        opp.Job__c = terr.Job__c;
        opp.TerritoryCode__c = terr.TerritoryCode__c;
        

        if(usr != null) {
            opp.ownerId = usr.Id;
            if(usr.Sale_Type__c == 'Inside Sales') {
                opp.Channel__c = '003';
                opp.Agency__c = usr.Agency__c;
            } else {
                opp.Channel__c = terr.Channel__c;
                opp.Agency__c = terr.Agency__c;
            }
        } else {
            opp.Channel__c = terr.Channel__c;
            opp.Agency__c = terr.Agency__c;
        }
    }
    /**BCR W-1854 end */

    
    private void getLeadPartnerDistributor(List<Opportunity> opps) {
        Map<String, Opportunity> oppysByTECHLeadId = new Map<String, Opportunity>();

        for(Opportunity opp : opps) {
            oppysByTECHLeadId.put(opp.TECH_Lead_Id__c, opp);
        }

        Map<Id, Lead> lds = new Map<Id, Lead>([SELECT Id, Partner_Distributor__c FROM Lead WHERE Id IN: oppysByTECHLeadId.keySet() AND Partner_Distributor__c != null]);

        for(Opportunity opp : opps) {
            if(lds.containsKey((Id) opp.TECH_Lead_Id__c)) {
                opp.Partner_Distributor__c = lds.get(opp.TECH_Lead_Id__c).Partner_Distributor__c;
            }
        }

    }

    private void passAccountToCustomerOppyTSWin(List<Opportunity> opps, Map<Id, Opportunity> oppOldMap) {

        Set<Id> oppyAccIds = new Set<Id>();

        for(Opportunity opp : opps) {
            if(opp.StageName == 'Closed Won' && opp.ID_TS__c != null && opp.Oppy_TS__c == true && oppOldMap.get(opp.Id).StageName != 'Closed Won') {
                oppyAccIds.add(opp.AccountId);
            }
        }

        List<Account> accs = [SELECT Id, Nature__c FROM Account WHERE Id IN: oppyAccIds AND Nature__c != 'CLI'];
        
        for(Account acc : accs) {
            acc.Nature__c = 'CLI';
        }

        update accs;
    }
}