/**
* @author Shamina M - Comforth Karoo
* @date 2020-08-31
* @description Trigger handler class for SBQQ__QuoteLine__c
* @modified by VMO 20211015: Commented CountEmptyTrainingSessions__c references
*/
public with sharing class TH_QuoteLine extends TriggerHandler{
    public static map<Id, SBQQ__Quote__c> mapAllQuote = new map<Id, SBQQ__Quote__c>();
    public static map<Id, SBQQ__Quote__c> mapUpdateQuote = new map<Id, SBQQ__Quote__c>();
    public static Decimal currentAppliedDiscount = 0;
    public static Decimal oldAppliedDiscount = 0; 
    public static Boolean flagSkip = false;
    
    /**
	* @author Keshav M - Comforth Karoo
	* @date 2021-02-22
	* @description beforeInsert logic          
	*/
    public override void beforeInsert() {
        
        if(isBypassed('TH_QuoteLine_beforeInsert')){
            return;
        }
        
        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        
        try{
            system.debug('Before Insert TH_QuoteLine');
            SM013_QuoteLineCalculation.processBuilderBeforeInsert((List<SBQQ__QuoteLine__c>)Trigger.new);
            SM013_QuoteLineCalculation.processBuilderBeforeUpdate((List<SBQQ__QuoteLine__c>)Trigger.new);
            //SM027_QuoteApplyPromotiononInsert.applyPromotionIfFound((List<SBQQ__QuoteLine__c>)Trigger.new,false);
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        
        bypass('TH_QuoteLine_beforeInsert');
    }
    
    
    /**
	* @author Shamina M - Comforth Karoo
	* @date 2020-08-31
	* @modified 2020-10-23 
	* @description afterInsert logic          
	*/
    public override void afterInsert() {
        if(isBypassed('TH_QuoteLine_afterInsert')){
            return;
        }
        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        try{
            system.debug('After Insert TH_QuoteLine');
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setQuoteIdsCalc = new Set<Id>();
            Set<Id> setQuoteIdsQualification = new Set<Id>();
            Boolean doCalcRollUp = false;
            //List<SBQQ__QuoteLine__c> listQLinesElearn = new List<SBQQ__QuoteLine__c>();
            set<Id> updateQualificationSheet = new set<id>();
            
            for(SBQQ__QuoteLine__c qutLine:(List<SBQQ__QuoteLine__c>)Trigger.new){
                
                //handle custom calculation of SBQQ__QuoteLine__c rollup fields           
                doCalcRollUp = qutLine.SBQQ__NetTotal__c != NULL || qutLine.Category__c != NULL || 
                    qutLine.SBQQ__ChargeType__c != NULL || qutLine.StructureLevel1__c != NULL || 
                    qutLine.TECH_CopyGrossTotal__c != NULL || qutLine.SBQQ__AdditionalDiscount__c != NULL;                             
                if(canTriggerByFeature('CalculateQuoteLineRollUp__c') && doCalcRollUp){
                    system.debug('after Insert roolUPs');
                    setQuoteIds.add(qutLine.SBQQ__Quote__c);               
                }
                //W-001430
                //if(qutLine.StructureLevel1__c == '140'){
                setQuoteIdsQualification.add(qutLine.SBQQ__Quote__c);
                //}
                setQuoteIdsCalc.add(qutLine.SBQQ__Quote__c);
            }
            
            Set<Id> setAllQuoteIds = new Set<Id>();
            setAllQuoteIds.addAll(setQuoteIds);
            setAllQuoteIds.addAll(setQuoteIdsCalc);  
            
            mapAllQuote = new map<Id, SBQQ__Quote__c>([SELECT Id, Recurring_Training_Amount__c,Recurring_Services_Amount__c,Recurring_SaaS_Amount__c,Sale_Purpose__c,
                                                       Recurring_Maintenance_Amount__c,Recurring_Licenses_Amount__c,One_Time_Training_Amount__c,One_Time_Services_Amount__c,
                                                       One_Time_SaaS_Amount__c,One_Time_Maintenance_Amount__c,One_Time_Licenses_Amount__c,Total_Subscription_Discount__c,Gross_Total_Total__c,
                                                       countELearningLinesWOAllTraining__c,TECH_Recalculating__c, 
                                                       ApprovalStatus__c,Tech_MaxLastModifiedDate__c,SBQQ__Status__c,recordtypeId,SBQQ__WatermarkShown__c,Max_Saas_Contract_Duration__c,SBQQ__Opportunity2__c,Payslips__c,Terms_of_Sale_and_Service_Booklets__c,
                                                       Coef_Swing__c,
                                                       (SELECT Id,Category__c,StructureLevel1__c,SBQQ__ChargeType__c,
                                                        NetTotal_Display__c,Subscribed_Total__c,TECH_CopyGrossTotal__c,SBQQ__AdditionalDiscount__c /*, CountEmptyTrainingSessions__c */ /* VMO 20211008: Commented code to be able to delete ROLLUP field, so that the masterdetail field on the Training Session can be converted to lookup */
                                                        FROM SBQQ__LineItems__r
                                                        WHERE NetTotal_Display__c != NULL OR Category__c != NULL OR SBQQ__ChargeType__c != NULL 
                                                        OR StructureLevel1__c != NULL OR TECH_CopyGrossTotal__c != NULL OR SBQQ__AdditionalDiscount__c != NULL ) 
                                                       FROM SBQQ__Quote__c 
                                                       WHERE Id IN:setAllQuoteIds]);
            
            //To be deployed afterwards
            /*if(listQLinesElearn.size()>0){
			SM008_CreateTrainingSessionsElearning.initSessions(listQLinesElearn); //Classe vide donc commenté ici
			}*/
            
            if(setQuoteIds.size()>0){
                SM006_CalculateQuoteLineRollUp.calculateRollUp(setQuoteIds);
            }
            //kmm
            if(setQuoteIdsCalc.size()>0){
                SM013_QuoteLineCalculation.processBuilderAfter((List<SBQQ__QuoteLine__c>)Trigger.new, true);
            }
            
            //W-001430
            if(setQuoteIdsQualification.size()>0){
                SM025_QualificationQuoteCreation.qualificationsheetsCreationUpdated(setQuoteIdsQualification);
            }
            
            //To be deployed afterwards
            //SM004_QuoteService.calculateSwing((List<SBQQ__QuoteLine__c>)Trigger.new);
            //SM030_OnsiteAutomation.setFraisDeDeplacement((List<SBQQ__QuoteLine__c>)Trigger.new);
            
            update mapUpdateQuote.values();
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        bypass('TH_QuoteLine_afterInsert');
    }
    
    /**
	* @author Keshav M - Comforth Karoo
	* @date 2021-01-12
	* @description BeforeUpdate logic          
	*/
    public override void BeforeUpdate() {
        system.debug('Before Update TH_QuoteLine');
        SM013_QuoteLineCalculation.processBuilderBeforeUpdate((List<SBQQ__QuoteLine__c>)Trigger.new);
    }
    
    /**
	* @author Shamina M - Comforth Karoo
	* @date 2020-08-31
	* @description afterUpdate logic          
	*/
    public override void afterUpdate() {
        
        if(isBypassed('TH_QuoteLine_afterUpdate')){
            return;
        }
        
        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        try{
            system.debug('After Update TH_QuoteLine');
            
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setQuoteIdsCalc = new Set<Id>();
            Boolean doCalcRollUp = false;
            Set<Id> setQuoteIdsQualification = new set<Id>();
            
            for(SBQQ__QuoteLine__c qutLine:(List<SBQQ__QuoteLine__c>)Trigger.new){    
                SBQQ__QuoteLine__c oldQutLine = (SBQQ__QuoteLine__c)trigger.oldMap.get(qutLine.Id);
                
                //handle custom calculation of SBQQ__QuoteLine__c rollup fields           
                doCalcRollUp = qutLine.SBQQ__NetTotal__c != oldQutLine.SBQQ__NetTotal__c || 
                    qutLine.Category__c != oldQutLine.Category__c || 
                    qutLine.SBQQ__ChargeType__c != oldQutLine.SBQQ__ChargeType__c || 
                    qutLine.StructureLevel1__c != oldQutLine.StructureLevel1__c || 
                    qutLine.TECH_CopyGrossTotal__c != oldQutLine.TECH_CopyGrossTotal__c || 
                    qutLine.SBQQ__AdditionalDiscount__c != oldQutLine.SBQQ__AdditionalDiscount__c ||
                    qutLine.SBQQ__SubscriptionTerm__c != oldQutLine.SBQQ__SubscriptionTerm__c/*  ||
					qutLine.CountEmptyTrainingSessions__c != oldQutLine.CountEmptyTrainingSessions__c */ /* VMO 20211008: Commented code to be able to delete ROLLUP field, so that the masterdetail field on the Training Session can be converted to lookup */ ;               
                if(canTriggerByFeature('CalculateQuoteLineRollUp__c') && doCalcRollUp){
                    setQuoteIds.add(qutLine.SBQQ__Quote__c);               
                } 
                //W-001430
                setQuoteIdsQualification.add(qutLine.SBQQ__Quote__c);
                
                //kmm
                setQuoteIdsCalc.add(qutLine.SBQQ__Quote__c);
            }
            
            Set<Id> setAllQuoteIds = new Set<Id>();
            setAllQuoteIds.addAll(setQuoteIds);
            setAllQuoteIds.addAll(setQuoteIdsCalc);
            
            mapAllQuote = new map<Id, SBQQ__Quote__c>([SELECT Id, Recurring_Training_Amount__c,Recurring_Services_Amount__c,Recurring_SaaS_Amount__c,Sale_Purpose__c,
                                                       Recurring_Maintenance_Amount__c,Recurring_Licenses_Amount__c,One_Time_Training_Amount__c,One_Time_Services_Amount__c,
                                                       One_Time_SaaS_Amount__c,One_Time_Maintenance_Amount__c,One_Time_Licenses_Amount__c,Total_Subscription_Discount__c,Gross_Total_Total__c,
                                                       countELearningLinesWOAllTraining__c, 
                                                       ApprovalStatus__c,Tech_MaxLastModifiedDate__c,SBQQ__Status__c,recordtypeId,SBQQ__WatermarkShown__c,Max_Saas_Contract_Duration__c,SBQQ__Opportunity2__c,Payslips__c,Terms_of_Sale_and_Service_Booklets__c,
                                                       Coef_Swing__c,
                                                       (SELECT Id,Category__c,StructureLevel1__c,SBQQ__ChargeType__c,
                                                        NetTotal_Display__c,Subscribed_Total__c,TECH_CopyGrossTotal__c,SBQQ__AdditionalDiscount__c/* , CountEmptyTrainingSessions__c */ /* VMO 20211008: Commented code to be able to delete ROLLUP field, so that the masterdetail field on the Training Session can be converted to lookup */
                                                        FROM SBQQ__LineItems__r
                                                        WHERE NetTotal_Display__c != NULL OR Category__c != NULL OR SBQQ__ChargeType__c != NULL 
                                                        OR StructureLevel1__c != NULL OR TECH_CopyGrossTotal__c != NULL OR SBQQ__AdditionalDiscount__c != NULL ) 
                                                       FROM SBQQ__Quote__c 
                                                       WHERE Id IN:setAllQuoteIds]); 
            
            if(setQuoteIds.size()>0){
                SM006_CalculateQuoteLineRollUp.calculateRollUp(setQuoteIds); 
            } 
            //kmm
            if(setQuoteIdsCalc.size()>0){
                SM013_QuoteLineCalculation.processBuilderAfter((List<SBQQ__QuoteLine__c>)Trigger.new, false);
            }
            
            //W-001430
            if(setQuoteIdsQualification.size()>0){
                SM025_QualificationQuoteCreation.qualificationsheetsCreationUpdated(setQuoteIdsQualification);
            }
            
            //W-001460
            //SM004_QuoteService.calculateSwing((List<SBQQ__QuoteLine__c>)Trigger.new);
            
            system.debug('MCU mapUpdateQuote: ' + mapUpdateQuote);
            update mapUpdateQuote.values();
            
            //SM030_OnsiteAutomation.setFraisDeDeplacement((List<SBQQ__QuoteLine__c>)Trigger.new);
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        bypass('TH_QuoteLine_afterUpdate');
    }
    
    /**
	* @author Shamina M - Comforth Karoo
	* @date 2020-08-31
	* @description afterDelete logic          
	*/
    public override void afterDelete() {
        system.debug('afterDelete : ');
        
        if(isBypassed('TH_QuoteLine_afterDelete')){
            return;
        }
        
        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        try{
            Set<Id> setQuoteIds = new Set<Id>();
            Boolean doCalcRollUp = false;
            Boolean isQuoteLineMod = false; //W-002330 - MCU - 28/10/2022 
            
            for(SBQQ__QuoteLine__c qutLine:(List<SBQQ__QuoteLine__c>)Trigger.old){ 
                //handle custom calculation of SBQQ__QuoteLine__c rollup fields
                doCalcRollUp = qutLine.SBQQ__NetTotal__c != NULL || qutLine.Category__c != NULL || 
                    qutLine.SBQQ__ChargeType__c != NULL || qutLine.StructureLevel1__c != NULL || 
                    qutLine.TECH_CopyGrossTotal__c != NULL || qutLine.SBQQ__AdditionalDiscount__c != NULL;             
                if(canTriggerByFeature('CalculateQuoteLineRollUp__c') && doCalcRollUp){
                    setQuoteIds.add(qutLine.SBQQ__Quote__c);
                }
            }
            
            Set<Id> setAllQuoteIds = new Set<Id>();
            setAllQuoteIds.addAll(setQuoteIds);
            
            mapAllQuote = new map<Id, SBQQ__Quote__c>([SELECT Id, Recurring_Training_Amount__c,Recurring_Services_Amount__c,Recurring_SaaS_Amount__c,
                                                       Recurring_Maintenance_Amount__c,Recurring_Licenses_Amount__c,One_Time_Training_Amount__c,One_Time_Services_Amount__c,
                                                       One_Time_SaaS_Amount__c,One_Time_Maintenance_Amount__c,One_Time_Licenses_Amount__c,Total_Subscription_Discount__c,Gross_Total_Total__c,
                                                       countELearningLinesWOAllTraining__c, 
                                                       ApprovalStatus__c,Tech_MaxLastModifiedDate__c,SBQQ__Status__c,recordtypeId,SBQQ__WatermarkShown__c,Max_Saas_Contract_Duration__c,SBQQ__Opportunity2__c,Payslips__c,Terms_of_Sale_and_Service_Booklets__c,
                                                       Coef_Swing__c,
                                                       (SELECT Id,Category__c,StructureLevel1__c,SBQQ__ChargeType__c,
                                                        NetTotal_Display__c,Subscribed_Total__c,TECH_CopyGrossTotal__c,SBQQ__AdditionalDiscount__c/* , CountEmptyTrainingSessions__c */ /* VMO 20211008: Commented code to be able to delete ROLLUP field, so that the masterdetail field on the Training Session can be converted to lookup */
                                                        FROM SBQQ__LineItems__r
                                                        WHERE NetTotal_Display__c != NULL OR Category__c != NULL OR SBQQ__ChargeType__c != NULL 
                                                        OR StructureLevel1__c != NULL OR TECH_CopyGrossTotal__c != NULL OR SBQQ__AdditionalDiscount__c != NULL ) 
                                                       FROM SBQQ__Quote__c 
                                                       WHERE Id IN:setAllQuoteIds]);
            
            if(setQuoteIds.size()>0){
                SM006_CalculateQuoteLineRollUp.calculateRollUp(setQuoteIds);
            }
            
            //SM030_OnsiteAutomation.setFraisDeDeplacement((List<SBQQ__QuoteLine__c>)Trigger.old);
            
            update mapUpdateQuote.values();
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        
        bypass('TH_QuoteLine_afterDelete');
    }
    
}