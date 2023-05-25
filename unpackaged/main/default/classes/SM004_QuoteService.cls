/**
 * @author Easyfront Consulting
 * @date 2022-11-10
 * @description Service class for SBQQ__Quote__c object
*/
public without sharing class SM004_QuoteService {
    
    public static final String QUOTE_APPROVALSTATUSREJECTED= 'Rejected';
    public static final String QUOTE_APPROVALSTATUSRECALL = 'Recalled';
    public static final String QUOTE_APPROVALSTATUSAPPROVE = 'Approved';
    public static final String QUOTE_APPROVALSTATUSPENDING = 'Pending';
    public static final String QUOTE_STATUSINREVIEW = 'In Review';
    public static final String QUOTE_STATUSDRAFT = 'Draft';
    public static final String QUOTE_STATUSAPPROVED = 'Approved';
    public static final String QUOTE_STATUSBLOCKED = 'Blocked';
    public static final String QUOTE_STATUSDENIED = 'Denied';
    public static final String QUOTE_STATUSREJECTED = 'Rejected';
    public static final String QUOTE_STATUSACCEPTED = 'Accepted';
    public static final String QUOTE_STATUSPSOK = 'PS OK';
    public static final String QUOTE_STATUSPRESENTED = 'Presented';
    public static final List<String> QUOTE_STATUSCLOSED = new List<String>{'Accepted', 'Blocked', 'Rejected'};
    public static final String RCCVALIDATOR = 'RCC Validator';
    public static final String RCCTEAMLEADER = 'RCC Team Leader';
    public static final String SALESPURPOSE_OPOP = '613'; //'Migration OP/OP'
    public static final String SALESPURPOSE_OPSAAS = '611'; //'Migration OP/SaaS'
    public static final String SALESPURPOSE_SAASSAAS = '612'; //'Migration SaaS/SaaS'
    public static final String TYPEAMENDMENT = 'Amendment';
    
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-10
 	* @description Method to manage approvals & quotes after validation
	*/
    public static void approvalManagementAfterValidation(Set<Id> setQuoteIds){
        List<SBQQ__QuoteLine__c> listQLIToUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__Quote__c> listQuoteToUpdate = new List<SBQQ__Quote__c>();
        Map<Id, List<sbaa__Approval__c>> mapQuoteApproval = new Map<Id, List<sbaa__Approval__c>>();
        
        //Retrieve all not reviewed approved approvals for Discount & RCC
        List<sbaa__Approval__c> listApproval = [SELECT Id, Quote__c, HasBeenReviewed__c, sbaa__ApprovalStep__c, sbaa__Rule__r.Name, sbaa__ApprovalChain__r.Name FROM sbaa__Approval__c WHERE Quote__c IN : setQuoteIds AND (sbaa__ApprovalChain__r.Name LIKE '%Discount Workflow%' OR sbaa__ApprovalChain__r.Name LIKE '%RCC Chain%' OR sbaa__ApprovalChain__r.Name LIKE '%Contract Type Chain%')AND sbaa__Status__c = 'Approved' AND HasBeenReviewed__c = false
                                                       ORDER BY Quote__c DESC, sbaa__ApprovalStep__c DESC NULLS LAST];
        
        //Build map between approvals & quotes
        if(!listApproval.isEmpty()){
            For(sbaa__Approval__c app:listApproval){
                if(!mapQuoteApproval.containsKey(app.Quote__c)){
                    mapQuoteApproval.put(app.Quote__c, new List<sbaa__Approval__c>{app});
                }else{
                    mapQuoteApproval.get(app.Quote__c).add(app);
                }
            }
            //Retrieve all quotes with related quote lines where discount has been applied
            List<SBQQ__Quote__c> listQuotewithQLI = [SELECT Id, Launch_ContractType_Workflow__c, CEGID_Quote_Total__c, CEGIDQuoteTotalValidatedByRCCWF__c, RCC_Workflow_Level_1_validated__c, RCC_Workflow_Level_2_validated__c, (SELECT Id, ValidatedAddDiscountPercentageLv1__c, ValidatedAddDiscountPercentageLv2__c, ValidatedAddDiscountPercentageLv3__c, Additionnal_Discount_Percentage__c,
                                                     Tech_Discount_exceeding_limits__c,Tech_Discount_exceed_limits_GrpLvl2__c, Tech_Discount_exceed_limits_GrpLvl3__c FROM SBQQ__LineItems__r WHERE Additionnal_Discount_Percentage__c != 0) 
                                                     FROM SBQQ__Quote__c WHERE Id IN : mapQuoteApproval.keySet()];
            
            for(SBQQ__Quote__c quo:listQuotewithQLI){
                if(mapQuoteApproval.containsKey(quo.Id)){
                    /////////////////////  Manage RCC Approvals ////////////////////
                    //For all related approved approval
                    for(sbaa__Approval__c app:mapQuoteApproval.get(quo.Id)){
                        //If there is a validated RCC Chain, tick the validated field to true
                        if(app.sbaa__Rule__r.Name.contains('Approval RCC')){ //Level 1
                            quo.RCC_Workflow_Level_1_validated__c = true;
                            quo.Launch_RCC_Workflow_Lv1__c = false;
                            quo.CEGIDQuoteTotalValidatedByRCCWF__c = quo.CEGID_Quote_Total__c;
                        }else if(app.sbaa__Rule__r.Name.contains('RCC Team Leader')){ //Level 2 - Team Leader
                            quo.RCC_Workflow_Level_2_validated__c = true;
                            quo.CEGIDQuoteTotalValidatedByRCCWF__c = quo.CEGID_Quote_Total__c;
                            quo.Launch_RCC_Workflow_Lv2__c = false;
                        }
                    }
                     /////////////////////  Manage Contract Type Approval ////////////////////
                    //For all related approved approval
                    for(sbaa__Approval__c app:mapQuoteApproval.get(quo.Id)){
                        //If there is a validated Contract Type, untick the Launch_ContractType_Workflow__c
                        if(app.sbaa__Rule__r.Name.contains('Contract Type')){
                            quo.Launch_ContractType_Workflow__c = false;
                        }
                    }
                    /////////////////////  Manage Discount Approvals ////////////////////
                    if(!quo.SBQQ__LineItems__r.isEmpty()){
                        for(SBQQ__QuoteLine__c qli:quo.SBQQ__LineItems__r){
                            //For all related approved approval
                            for(sbaa__Approval__c app:mapQuoteApproval.get(quo.Id)){
                                //Rule for Validator level 1
                                if(app.sbaa__Rule__r.Name.contains('Discount > Level 1')){ 
                                    if(qli.ValidatedAddDiscountPercentageLv1__c == null || qli.ValidatedAddDiscountPercentageLv1__c < qli.Additionnal_Discount_Percentage__c){
                                        qli.ValidatedAddDiscountPercentageLv1__c = qli.Additionnal_Discount_Percentage__c; //NB: Save validated discount if previous validated discount is less
                                    }
                                    qli.Tech_Discount_exceeding_limits__c = false; //Lv1 has been approved
                                }
                                //Rule for Validator level 2
                                if(app.sbaa__Rule__r.Name.contains('Discount > Level 2')){ 
                                       if(qli.ValidatedAddDiscountPercentageLv2__c == null || qli.ValidatedAddDiscountPercentageLv2__c < qli.Additionnal_Discount_Percentage__c){
                                           qli.ValidatedAddDiscountPercentageLv2__c = qli.Additionnal_Discount_Percentage__c;
                                       }
                                       qli.Tech_Discount_exceed_limits_GrpLvl2__c = false; //Lv2 has been approved
                                   }
                                //Rule for Validator level 3
                                if(app.sbaa__Rule__r.Name.contains('Discount > Level 3')){ 
                                       if(qli.ValidatedAddDiscountPercentageLv3__c == null || qli.ValidatedAddDiscountPercentageLv3__c < qli.Additionnal_Discount_Percentage__c){
                                           qli.ValidatedAddDiscountPercentageLv3__c = qli.Additionnal_Discount_Percentage__c;
                                       }
                                       qli.Tech_Discount_exceed_limits_GrpLvl3__c = false; //Lv3 has been approved
                                   }
                            }
                            listQLIToUpdate.add(qli);
                        }
                    }
                }
                listQuoteToUpdate.add(quo);
            }
            if(!listQuoteToUpdate.isEmpty()){
                update listQuoteToUpdate;
            }
            if(!listQLIToUpdate.isEmpty()){
                update listQLIToUpdate;
            }
            //Mark all approvals has reviewed
            for(sbaa__Approval__c app:listApproval){
                app.HasBeenReviewed__c = true;
            }
            update listApproval;
        }
    }
    
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-21
 	* @description Method to calculate if RCC Approval is required and approvers on quote
    * @details Call by TH_Quote (see criteria of execution)
	*/
    public static void rccApprovalCalculation(Set<Id> setQuoteIds){
        Map<Id, Special_Assignment__c> mapSalesRepSpecialAssign = new Map<Id, Special_Assignment__c>();
        List<SBQQ__Quote__c> listQuoteToUpdate = new List<SBQQ__Quote__c>();
        
        //Retrieve all require quotes information with billing account
        List<SBQQ__Quote__c> listQuotes = [SELECT Id, SBQQ__Status__c, SBQQ__SalesRep__c, RCC_Team_Leader__c, TECH_SalesRepAgency__c, CEGIDQuoteTotalValidatedByRCCWF__c, CEGID_Quote_Total__c, Launch_RCC_Workflow_Lv1__c, One_Time_Total__c, Recurring_Total_Monthly__c, Launch_RCC_Workflow_Lv2__c, Billing_Account__c, Billing_Account__r.Nature__c, Billing_Account__r.Risk_Level__c,
                                           Billing_Account__r.Amount_of_delay_0_1_month__c, Billing_Account__r.Amount_of_delay_1_month__c, Billing_Account__r.Amount_of_delay_3_months__c, Billing_Account__r.Amount_of_delay_6_months__c, 
                                           Billing_Account__r.Amount_of_delay_12_months__c, Billing_Account__r.Amount_of_delay_over_24_months__c, Billing_Account__r.Total_Amount_of_delay__c
                                           FROM SBQQ__Quote__c WHERE Id IN : setQuoteIds AND Billing_Account__c != null];
        
        if(!listQuotes.isEmpty()){
            //Get All RCC Conditions
            List<RCC_Condition__c> listRCC = [SELECT Id,Account_Nature__c,RCC_Workflow_Level__c,Account_Risk_Level__c,One_Time_Total__c,Account_Aston_Amount__c,Account_Aston_Delay__c,Recurring_Total_Monthly__c from RCC_Condition__c];
            
            //Get Agency Sales Rep and Team Leader Validator
            mapSalesRepSpecialAssign = getRCCTeamLeaderAndAgency(listQuotes);
            
            //Calculate RCC Approval for each quote
            for(SBQQ__Quote__c quo:listQuotes){
                //Manage Agency & Team Leader info
                String RCCTeamLeader = Label.AADefault_RCC_Team_Leader;
                String Agency = 'Agency not found';
                if(mapSalesRepSpecialAssign.containsKey(quo.SBQQ__SalesRep__c)){
                    Agency = mapSalesRepSpecialAssign.get(quo.SBQQ__SalesRep__c).Agency__c;
                    if(mapSalesRepSpecialAssign.get(quo.SBQQ__SalesRep__c).RCC_Team_Leader__c != null){
                        RCCTeamLeader = mapSalesRepSpecialAssign.get(quo.SBQQ__SalesRep__c).RCC_Team_Leader__c;
                    }
                }
                
                //Reseting checkbox Launch_RCC_Workflow_Lv1/2__c to false on quote
                Boolean RCC_Lv1 = false;
                Boolean RCC_Lv2 = false;
                for(RCC_Condition__c rcc: listRCC){
                    if(quo.Billing_Account__r.Nature__c == rcc.Account_Nature__c && quo.Billing_Account__r.Risk_Level__c == rcc.Account_Risk_Level__c && (quo.One_Time_Total__c >= rcc.One_Time_Total__c || quo.Recurring_Total_Monthly__c >= rcc.Recurring_Total_Monthly__c)){
                        if( rcc.Account_Aston_Amount__c == null
                           ||(rcc.Account_Aston_Delay__c == '0' && quo.Billing_Account__r.Total_Amount_of_delay__c >= rcc.Account_Aston_Amount__c)
                           || (rcc.Account_Aston_Delay__c == '1' && quo.Billing_Account__r.Amount_of_delay_1_month__c >= rcc.Account_Aston_Amount__c)
                           || (rcc.Account_Aston_Delay__c == '3' && quo.Billing_Account__r.Amount_of_delay_3_months__c >= rcc.Account_Aston_Amount__c)
                           || (rcc.Account_Aston_Delay__c == '6' && quo.Billing_Account__r.Amount_of_delay_6_months__c >= rcc.Account_Aston_Amount__c)
                           || (rcc.Account_Aston_Delay__c == '12' && quo.Billing_Account__r.Amount_of_delay_12_months__c >= rcc.Account_Aston_Amount__c)
                           || (rcc.Account_Aston_Delay__c == '24' && quo.Billing_Account__r.Amount_of_delay_over_24_months__c >= rcc.Account_Aston_Amount__c)
                           || (rcc.Account_Aston_Delay__c == '24+' && quo.Billing_Account__r.Total_Amount_of_delay__c >= rcc.Account_Aston_Amount__c)){
                               RCC_Lv1 = true;
                               if(rcc.RCC_Workflow_Level__c == 'RCC Team Leader'){
                                   RCC_Lv2 = true;
                               }
                           }
                    }
                }
                
                //Update only if changes > LaunchWorkflow fields or Special Assignment fields
                if(quo.Launch_RCC_Workflow_Lv1__c != RCC_Lv1 || quo.Launch_RCC_Workflow_Lv2__c != RCC_Lv2 || quo.RCC_Team_Leader__c != RCCTeamLeader || quo.TECH_SalesRepAgency__c != Agency){
                    quo.Launch_RCC_Workflow_Lv1__c = RCC_Lv1;
                    quo.Launch_RCC_Workflow_Lv2__c = RCC_Lv2;
                    quo.RCC_Team_Leader__c = RCCTeamLeader;
                    quo.RCC_Validator__c = Label.AADefault_RCC;
                    quo.TECH_SalesRepAgency__c = Agency;
                    
                    //Manage roll back if previous validation is obsolete
                    if(quo.Launch_RCC_Workflow_Lv1__c == true){ 
                        quo.RCC_Workflow_Level_1_validated__c = false;
                        if(quo.SBQQ__Status__c != QUOTE_STATUSDRAFT && !QUOTE_STATUSCLOSED.contains(quo.SBQQ__Status__c)){
                            quo.SBQQ__Status__c = QUOTE_STATUSPSOK;
                        }
                        quo.ApprovalStatus__c = null;
                    }
                    if(quo.Launch_RCC_Workflow_Lv2__c == true){
                        quo.RCC_Workflow_Level_2_validated__c = false;
                        if(quo.SBQQ__Status__c != QUOTE_STATUSDRAFT && !QUOTE_STATUSCLOSED.contains(quo.SBQQ__Status__c)){
                            quo.SBQQ__Status__c = QUOTE_STATUSPSOK;
                        }
                        quo.ApprovalStatus__c = null;
                    }
                    listQuoteToUpdate.add(quo);
                }
            }
            if(!listQuoteToUpdate.isEmpty()){
                update listQuoteToUpdate;
            }
        }
    }
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-21
 	* @description Method to recalculate if RCC Approval is required and approvers on related quote from accounts
	*/
    public static void rccApprovalCalculationFromAccount(Set<Id> setAccountIds){
        Set<Id> setQuoteIds = new Set<Id>();
        //Get all related Quotes to recalculate only for Quotes not already approved
        List<SBQQ__Quote__c> listQuotes = [SELECT Id FROM SBQQ__Quote__c WHERE Billing_Account__c IN : setAccountIds AND (SBQQ__Status__c = : QUOTE_STATUSDRAFT OR SBQQ__Status__c =: QUOTE_STATUSPSOK OR SBQQ__Status__c =: QUOTE_STATUSDENIED OR SBQQ__Status__c =: QUOTE_STATUSAPPROVED)];
        if(!listQuotes.isEmpty()){
            for(SBQQ__Quote__c quo:listQuotes){
                setQuoteIds.add(quo.Id);
            }
            rccApprovalCalculation(setQuoteIds);
        }
    }
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-21
 	* @description Method to calculate the Sales Rep Agency and Team Leader Validator
	*/
    public static Map<Id, Special_Assignment__c> getRCCTeamLeaderAndAgency(List<SBQQ__Quote__c> listQuotes){
        Set<Id> setSalesRepIds = new Set<Id>();
        Map<Id, String> mapSalesRepAgency = new Map<Id, String>();
        Map<String, Special_Assignment__c> mapAgencySpecialAssign = new Map<String, Special_Assignment__c>();
        Map<Id, Special_Assignment__c> mapSalesRepSpecialAssign = new Map<Id, Special_Assignment__c>();
        
        //Get Agency by Sales Rep
        for(SBQQ__Quote__c quo:listQuotes){
            mapSalesRepAgency.put(quo.SBQQ__SalesRep__c, null); //Put all Sales Reps
        }
        //Agency is filled on the territory object linked to the UserTerritory2Association
        List<UserTerritory2Association> listUserTerAssSalesReps = [SELECT Id, UserId, Territory2.Agency__c FROM UserTerritory2Association WHERE UserId IN : mapSalesRepAgency.keySet() AND Territory2.Territory2ModelId != null AND Territory2.Territory2Model.State = 'Active'];
        if(!listUserTerAssSalesReps.isEmpty()){
            for(UserTerritory2Association userterr:listUserTerAssSalesReps){
                mapSalesRepAgency.put(userterr.UserId, userterr.Territory2.Agency__c); //Assosiation of Sales Reps with related Agency Territory
            }
        }
        //Check if the territory agency exist into the Special Assignment table for RCC
        List<Special_Assignment__c> listSpecialAssignment = [SELECT Id, RCC_User__c, Second_User__c, RCC_Team_Leader__c, Agency__c FROM Special_Assignment__c WHERE Agency__c IN : mapSalesRepAgency.values() AND RecordTypeId =: TH_SpecialAssignment.rccRecordTypeId];
        if(!listSpecialAssignment.isEmpty()){
            for(Special_Assignment__c spa:listSpecialAssignment){
                mapAgencySpecialAssign.put(spa.Agency__c, spa);
            }
            for(Id salesRep:mapSalesRepAgency.keySet()){
                if(mapAgencySpecialAssign.containsKey(mapSalesRepAgency.get(salesRep))){ //If the agency is known into Special Assignment
                    mapSalesRepSpecialAssign.put(salesRep, mapAgencySpecialAssign.get(mapSalesRepAgency.get(salesRep)));
                }
            }
        }
        return mapSalesRepSpecialAssign;
    }
    
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-21
 	* @description Method to calculate if Contract Type Approval is required and approvers on quote
    * @details Call by TH_Quote (see criteria of execution)
	*/
    public static void contractTypeApprovalCalculation(List<SBQQ__Quote__c> listQuoteContractTypeApproval){
        for(SBQQ__Quote__c quo:listQuoteContractTypeApproval){
            //If values are different from Orignal values > contract type approval is required
            if(quo.Payment_Method__c != quo.OriginalPayment_Method__c || quo.Payment_Term__c != quo.OriginalPaymentTerms__c ||quo.Payment_Date__c != quo.OriginalPayment_Date__c || quo.Billing_Frequency__c  != quo.OriginalBilling_Frequency__c){
                quo.Launch_ContractType_Workflow__c = true;
                if(quo.SBQQ__Status__c != QUOTE_STATUSDRAFT && !QUOTE_STATUSCLOSED.contains(quo.SBQQ__Status__c)){
                    quo.SBQQ__Status__c = QUOTE_STATUSPSOK;
                }
                quo.ApprovalStatus__c = null;
            //If come back to original values > approval not required
            }else if(quo.Payment_Method__c == quo.OriginalPayment_Method__c && quo.Payment_Term__c == quo.OriginalPaymentTerms__c && quo.Payment_Date__c == quo.OriginalPayment_Date__c && quo.Billing_Frequency__c  == quo.OriginalBilling_Frequency__c){
                quo.Launch_ContractType_Workflow__c = false;
            }
        }
    }
    
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-21
 	* @description Method to calculate Coef Swing on Quote
    * @details Call by TH_QuoteLine > US-1461
	*/
     public static void calculateSwing(List<SBQQ__QuoteLine__c> listQuoteLine){
        system.debug('SM014_MigrationSwing');
        List<SBQQ__Quote__c> listQuoteToUpd = new List<SBQQ__Quote__c>();
        Decimal positiveAmt=0;
        Decimal negativeAmt=0;
        SBQQ__Quote__c q;
        
        Set<Id> setQuoteId = new Set<Id>();
		for(SBQQ__QuoteLine__c ql:listQuoteLine ){
            setQuoteId.add(ql.SBQQ__Quote__c);
        }
        
        for(SBQQ__QuoteLine__c ql:[SELECT Id,SBQQ__Quote__c,Subscribed_Total__c 
                                   FROM SBQQ__QuoteLine__c 
                                   WHERE SBQQ__Quote__c IN : setQuoteId] ){
                                       
            q = (TH_QuoteLine.mapUpdateQuote.get(ql.SBQQ__Quote__c) != null) ? TH_QuoteLine.mapUpdateQuote.get(ql.SBQQ__Quote__c) : TH_QuoteLine.mapAllQuote.get(ql.SBQQ__Quote__c);
            
            q.Coef_Swing__c = null;

            system.debug('MCU q.Sale_Purpose__c : ' + q.Sale_Purpose__c);
            if(q.Sale_Purpose__c == SALESPURPOSE_OPOP || q.Sale_Purpose__c == SALESPURPOSE_OPSAAS || q.Sale_Purpose__c == SALESPURPOSE_SAASSAAS){
                system.debug('MCU ql.Subscribed_Total__c : ' + ql.Subscribed_Total__c);

                if(ql.Subscribed_Total__c  > 0){
                    positiveAmt +=(ql.Subscribed_Total__c != null)?ql.Subscribed_Total__c:0;
                }else if(ql.Subscribed_Total__c  < 0){
    				system.debug('MCU NEGATIVE : ');
                    negativeAmt +=(ql.Subscribed_Total__c != null)?ql.Subscribed_Total__c:0;
                }
               
            }

        }//endfor
        
        system.debug('MCU1 positiveAmt : ' + positiveAmt);
        system.debug('MCU1 negativeAmt : ' + negativeAmt);
        
        if(positiveAmt > 0 && negativeAmt < 0){
			q.Coef_Swing__c = positiveAmt / negativeAmt; 
		}else if(negativeAmt == 0 && positiveAmt > 0){
			q.Coef_Swing__c = 0;//positiveAmt;
		}else {
			q.Coef_Swing__c = null;
		}
        system.debug('MCU1 q.Id : ' + q.Id);
		system.debug('MCU1 q.Coef_Swing__c : ' + q.Coef_Swing__c);
		TH_QuoteLine.mapUpdateQuote.put(q.Id, q);
    }
    
    /**
 	* @author Easyfront Consulting
 	* @date 2022-12-13
 	* @description Method to manage new quote for amendment (upsell, migration, renew)
    * @details Call by TH_Quote > B-2036
	*/
    public static void manageNewQuoteAmendment(Set<Id> setQuoteIds){
        List<Opportunity> listOppToDelete = new List<Opportunity>();
        List<SBQQ__Quote__c> listQuotesToUpdate = new List<SBQQ__Quote__c>();
        Set<Id> setOppToDeleteIds = new Set<Id>();
        Set<Id> setOppIds = new Set<Id>();
        Map<Id, Id> mapOppAndPrimaryQuote = new Map<Id, Id>();
        
        //Get Quote information
        List<SBQQ__Quote__c> listQuotes = [SELECT Id, SBQQ__PrimaryContact__c, TECH_Subscriptions_Subscription_Term__c,ContractId_from_Zuora__c, SBQQ__Primary__c, EditLinesFieldSetName__c, Original_Service_Level__c, SBQQ__SubscriptionTerm__c, Service_Level__c,
                                           SBQQ__Opportunity2__c, SBQQ__MasterContract__r.SBQQ__Opportunity__r.Primary_Contact__c, SBQQ__MasterContract__r.ContractId_from_Zuora__c, SBQQ__MasterContract__r.Service_Level__c,
                                           SBQQ__MasterContract__c, SBQQ__MasterContract__r.SBQQ__Opportunity__c, SBQQ__MasterContract__r.SBQQ__Opportunity__r.SubSalesPurpose__c FROM SBQQ__Quote__c WHERE Id IN:setQuoteIds];
        //Update quote info
        for(SBQQ__Quote__c quo:listQuotes){
            setOppToDeleteIds.add(quo.SBQQ__Opportunity2__c);
            setOppIds.add(quo.SBQQ__MasterContract__r.SBQQ__Opportunity__c);
            mapOppAndPrimaryQuote.put(quo.SBQQ__MasterContract__r.SBQQ__Opportunity__c, quo.Id);
            quo.SBQQ__Opportunity2__c = quo.SBQQ__MasterContract__r.SBQQ__Opportunity__c;
            quo.SBQQ__Primary__c = true;
            quo.EditLinesFieldSetName__c = 'Amendment';
            quo.ContractId_from_Zuora__c = quo.SBQQ__MasterContract__r.ContractId_from_Zuora__c;
            quo.SBQQ__SubscriptionTerm__c = quo.TECH_Subscriptions_Subscription_Term__c;
            quo.Original_Service_Level__c = quo.SBQQ__MasterContract__r.Service_Level__c;
            quo.Service_Level__c = quo.SBQQ__MasterContract__r.Service_Level__c;
            quo.SBQQ__PrimaryContact__c = quo.SBQQ__MasterContract__r.SBQQ__Opportunity__r.Primary_Contact__c; //B-2062
            quo.SubSalesPurpose__c = quo.SBQQ__MasterContract__r.SBQQ__Opportunity__r.SubSalesPurpose__c; //W-002573
            system.debug('quo '+quo);
            listQuotesToUpdate.add(quo);
        }
        
        //Set Primary tofalse for all other quotes (see why: https://help.salesforce.com/s/articleView?id=000381222&type=1)
        List<SBQQ__Quote__c> listOtherPrimaryQuotes = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :setOppIds AND Id NOT IN:setQuoteIds AND SBQQ__Primary__c = true];
        if(!listOtherPrimaryQuotes.isEmpty()){
            for(SBQQ__Quote__c quo:listOtherPrimaryQuotes){
                quo.SBQQ__Primary__c = false;
                system.debug('quo '+quo);
                listQuotesToUpdate.add(quo);
            }
        }
        
        //Update quotes with new info
        update listQuotesToUpdate;
        
        //Delete default opportunities created by CPQ
        listOppToDelete = [SELECT Id from Opportunity WHERE Id IN:setOppToDeleteIds];
        if(!listOppToDelete.isEmpty()){
            delete listOppToDelete;
        }
        
        //Update Primary Quote on Opportunity
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        For(Opportunity opp: [SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id IN : mapOppAndPrimaryQuote.keySet()]){
            opp.SBQQ__PrimaryQuote__c = mapOppAndPrimaryQuote.get(opp.Id);
            listOppToUpdate.add(opp);
        }
        update listOppToUpdate;
    }
    
     /**
 	* @author Comforth-Easyfront Consulting
 	* @date 13-01-2023
 	* @description W-002442 : Gestion du statut rejected
	*/
    public static void closeQuoteChildRecords(Set<Id> setQuoIds){
        Set<String> setCaseStatus = new Set<String>();
        List<sbaa__Approval__c> lstApprovals = new List<sbaa__Approval__c>();
        List<Case> lstCases = new List<Case>();
        
        Id caseProSerReqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Professional_Services_Request').getRecordTypeId();
        Id caseInternalReqRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Internal_Request').getRecordTypeId();

        for (CaseStatus cs : [SELECT Id, MasterLabel FROM CaseStatus WHERE IsClosed = true])
            setCaseStatus.add(cs.MasterLabel);

        for(Case cas : [SELECT id, Status
                        FROM Case 
                        WHERE Quote__c IN: setQuoIds
                        AND toLabel(Status) NOT IN: setCaseStatus
                        AND (recordTypeId =: caseProSerReqRTId OR recordTypeId =: caseInternalReqRTId)]){
        	cas.Status = 'Revoked';
            lstCases.add(cas);   
                            
        }//endFor
        
        for(sbaa__Approval__c app : [SELECT id, sbaa__Status__c
                                     FROM sbaa__Approval__c
                                     WHERE Quote__c IN: setQuoIds
                                     AND sbaa__Status__c IN ('Assigned','Requested')]){
            app.sbaa__Status__c = 'Revoked';
            app.sbaa__Archived__c = true;
        	lstApprovals.add(app);  
                                         
        }//endFor
            
        if(lstCases.size() > 0)
            update lstCases;
        
		if(lstApprovals.size() > 0)
            update lstApprovals;
        
    }
    
}