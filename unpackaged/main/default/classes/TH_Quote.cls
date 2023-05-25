/**
 * @author Keshav M - Comforth Karoo
 * @date 2020-11-23
 * @description Trigger handler class for SBQQ__Quote__c
 * Test classes: SM018_RedistributionOfDiscount_TEST, SM004_QuoteService_Test
*/
public with sharing class TH_Quote extends TriggerHandler {
    public static final String PENDINGPS= 'Pending PS';
    public static final String DRAFT= 'Draft';
    public static final String REJECTED = 'Rejected'; 

    /** 
     * @author Keshav M - Comforth Karoo
     * @date 2020-11-23
     * @description beforeInsert logic          
    */
    public override void beforeInsert() {
        //Check If User = Docusign user 
        List<PermissionSetAssignment> listDocuSignPermAssignmt = new List<PermissionSetAssignment>();
        if(PermissionSetAssignment.sObjectType.getDescribe().isAccessible()){
            //check if user executing the update is a DocuSign admin based on permission set assigned
            listDocuSignPermAssignmt = [SELECT id,AssigneeId from PermissionSetAssignment 
                                                WHERE PermissionSet.Name ='DocuSign_Administrator' 
                                                AND  Assignee.Name = 'User Docusign'
                                                AND AssigneeId = :UserInfo.getUserId()
                                                LIMIT 1];
        }

        if(isBypassed('TH_Quote_beforeInsert')){
            return;
        }
        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        try{
            Set<Id> quoteIds = new set<Id>();
            system.debug('beforeInsert TH_Quote');
            SM012_QuotePriceRule.ProcessBuilderInIt((List<SBQQ__Quote__c>)Trigger.new);
            SM012_QuotePriceRule.ProcessBuilderInItNoPriceBook((List<SBQQ__Quote__c>)Trigger.new);
            SM012_QuotePriceRule.ProcessBuilderPOModified((List<SBQQ__Quote__c>)Trigger.new,new Map<Id, SBQQ__Quote__c>(), true);

            for(SBQQ__Quote__c quo:(List<SBQQ__Quote__c>)Trigger.new){
                quoteIds.add(quo.Id);  
            }

            //Flow
            if(quoteIds.size()>0 && (listDocuSignPermAssignmt.size() == null ||  listDocuSignPermAssignmt.size() == 0)){
                SM012_QuotePriceRule.quoteFlowBilling((List<SBQQ__Quote__c>)Trigger.new);
            }
              
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        
        bypass('TH_Quote_beforeInsert');
    }

    /**
     * @author Keshav M - Comforth Karoo
     * @date 2020-11-23
     * @description beforeUpdate logic          
    */
    public override void beforeUpdate(){
        // if(isBypassed('TH_Quote_beforeUpdate')){
        //     return;
        // }

        //Check If User = Docusign user 
        List<PermissionSetAssignment> listDocuSignPermAssignmt = new List<PermissionSetAssignment>();
        if(PermissionSetAssignment.sObjectType.getDescribe().isAccessible()){
            //check if user executing the update is a DocuSign admin based on permission set assigned
            listDocuSignPermAssignmt = [SELECT id,AssigneeId from PermissionSetAssignment 
                                                WHERE PermissionSet.Name ='DocuSign_Administrator' 
                                                AND  Assignee.Name = 'User Docusign'
                                                AND AssigneeId = :UserInfo.getUserId()
                                                LIMIT 1];
        }
        
        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        try{
            Set<Id> quoteIds = new set<Id>();
            List<SBQQ__Quote__c> listQuoteContractTypeApproval = new List<SBQQ__Quote__c>();
            system.debug('beforeUpdate TH_Quote');
            SM012_QuotePriceRule.ProcessBuilderPOModified((List<SBQQ__Quote__c>)Trigger.new,(Map<Id, SBQQ__Quote__c>) Trigger.OldMap, false);
            
            for(SBQQ__Quote__c quo:(List<SBQQ__Quote__c>)Trigger.new){
                SBQQ__Quote__c oldQut = (SBQQ__Quote__c)trigger.oldMap.get(quo.Id);
                quoteIds.add(quo.Id);
                //Manage Contract Type Approval > if criteria have changed and not equals to the Original values
                if(quo.TECH_CurrentUser__c!= null && !quo.TECH_CurrentUser__c.contains(System.Label.username) && 
                   (quo.Payment_Method__c != oldQut.Payment_Method__c || quo.Payment_Term__c != oldQut.Payment_Term__c || quo.Payment_Date__c != oldQut.Payment_Date__c || quo.Billing_Frequency__c  != oldQut.Billing_Frequency__c)
                  && quo.OriginalPayment_Method__c != null){
                       listQuoteContractTypeApproval.add(quo);
                   }
                
                if(quo.SBQQ__Status__c != oldQut.SBQQ__Status__c && quo.SBQQ__Status__c == DRAFT){
                    Id QuoteRTID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
                    quo.RecordTypeId = QuoteRTID;
                }
            }
            //Flow
            if(quoteIds.size()>0 && (listDocuSignPermAssignmt.size() == null ||  listDocuSignPermAssignmt.size() == 0)){
                SM012_QuotePriceRule.quoteFlowBilling((List<SBQQ__Quote__c>)Trigger.new);  
            }
            //Contract Type Approval
            if(!listQuoteContractTypeApproval.isEmpty()){
                  SM004_QuoteService.contractTypeApprovalCalculation(listQuoteContractTypeApproval);
            }

        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }

        // bypass('TH_Quote_beforeUpdate');
    }

     /**
     * @author Keshav M - Comforth Karoo
     * @date 2020-11-23
     * @description afterInsert logic          
    */
    public override void afterInsert() {
        if(isBypassed('TH_Quote_afterInsert')){
            return;
        }

        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();

        try{
            system.debug('after Insert TH_Quote');
            Set<Id> setOppIds = new set<Id>();
            Set<String> setOppIdsToDelete = new set<String>();
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setAmendQuoteIds = new Set<Id>();
            Set<Id> setRedistributionQuote = new Set<Id>();
            Set<String> setStructure = new Set<String>();
			List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>();//B-1923
            
            for(SBQQ__Quote__c quo:(List<SBQQ__Quote__c>)Trigger.new){
                
                setOppIds.add(quo.SBQQ__Opportunity2__c);
                
                //Manage Quote for Amendment
                if(quo.SBQQ__Type__c == SM004_QuoteService.TYPEAMENDMENT){
                    setAmendQuoteIds.add(quo.Id);
                }
                system.debug('quo.SBQQ__PriceBook__c : ' + quo.SBQQ__PriceBook__c);
                if(quo.SBQQ__PriceBook__c != null && quo.Billing_Account__c != null && quo.XRP_Data_retrieved__c == false && (
                    quo.Sale_Purpose__c == SM012_QuotePriceRule.SALESPURPOSENEWCLI ||  quo.Sale_Purpose__c == SM012_QuotePriceRule.SALESPURPOSENEWBIZ)){
                        setQuoteIds.add(quo.Id);
                    }
                
                if(quo.SBQQ__Status__c == PENDINGPS) {
                    lstQuotes.add(quo);
                }
            }
            
            if(setOppIds.size()>0){
                SM012_QuotePriceRule.ProcessBuilderOpportunityQuote(setOppIds);
            }
    		//Manage New Quotes for Amendment
            if(!setAmendQuoteIds.isEmpty()){
                SM004_QuoteService.manageNewQuoteAmendment(setAmendQuoteIds);
            }
            
             //B-1923
            if(lstQuotes.size()>0){
				SM012_QuotePriceRule.createCasePS(lstQuotes,new Map<Id, SBQQ__Quote__c>());
            }
            //SM012_QuotePriceRule.createCasePS((List<SBQQ__Quote__c>)Trigger.new,new Map<Id, SBQQ__Quote__c>());//B-1923
            
            SM012_QuotePriceRule.createChatterAndCase((List<SBQQ__Quote__c>)Trigger.new);
            
    		//Execute for SalesPurpose == newcli, newbiz only set is above
        	system.debug('------TRIGGER BEFORE CONDITION  : ');
            if(!System.isBatch() && !Test.isRunningTest()){
                if(setQuoteIds.size()>0){
        			system.debug('------TRIGGER INSIDE CONDITION  : ');
                    SM016_EclatementContrats.executeWebService(setQuoteIds);
                }
            } 
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        
        bypass('TH_Quote_afterInsert');
    }

    /**
     * @author Keshav M - Comforth Karoo
     * @date 2020-11-23
     * @description afterUpdate logic           
    */
    public override void afterUpdate() {
        if(isBypassed('TH_Quote_afterUpdate')){
            return;
        }

        //Adding Bypass for CPQ Trigger To Decrease SOQL LIMIT
        SBQQ.TriggerControl.disable();
        try{
            system.debug('after Update TH_Quote');
            //SM012_QuotePriceRule.createCasePS((List<SBQQ__Quote__c>)Trigger.new,(Map<Id, SBQQ__Quote__c>) Trigger.OldMap);//B-1923
            SM012_QuotePriceRule.createChatterAndCase((List<SBQQ__Quote__c>)Trigger.new);
           
			Set<Id> approvedQuoteIds = new set<Id>(); //Used for SM004_QuoteService.DiscountManagementAfterApproval
            Set<Id> rccApprovalQuoteIds = new set<Id>(); //Used for SM004_QuoteService.rccApprovalCalculation
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setQCQuoteIds = new Set<Id>();
            Set<Id> setAccountEbilling = new Set<Id>();
            Set<Id> setRedistributionQuote = new Set<Id>();	// W-000450	
            Map<Id, set<string>> mapQuoteStructures = new Map<Id, set<string>>();
			List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>();//B-1923
            Set<Id> setQuoIds = new Set<Id>();//W-002442
            
            for(SBQQ__Quote__c quote:(List<SBQQ__Quote__c>)Trigger.new){
                SBQQ__Quote__c oldQut = (SBQQ__Quote__c)trigger.oldMap.get(quote.Id);
				Set<string> setStructure = new Set<string>();
               
                SBQQ__Quote__c oldQuote = (SBQQ__Quote__c)trigger.oldMap.get(quote.Id);
                if(quote.SBQQ__PriceBook__c != null  && quote.Billing_Account__c != null && 
                   (oldQut.Billing_Account__c != quote.Billing_Account__c || oldQut.SBQQ__PriceBook__c != quote.SBQQ__PriceBook__c) &&
                   (quote.Sale_Purpose__c == SM012_QuotePriceRule.SALESPURPOSENEWCLI ||  quote.Sale_Purpose__c == SM012_QuotePriceRule.SALESPURPOSENEWBIZ)){
                       setQuoteIds.add(quote.Id);
                }
                setQCQuoteIds.add(quote.Id);
                
                // W-000450	
                if(quote.TargetedPriceForHardware__c != oldQuote.TargetedPriceForHardware__c 
                   || quote.TargetedPriceForLicense__c != oldQuote.TargetedPriceForLicense__c 
                   ||quote.TargetedPriceForMaintenance__c != oldQuote.TargetedPriceForMaintenance__c 
                   || quote.TargetedPriceForProfessional_Services__c != oldQuote.TargetedPriceForProfessional_Services__c	
                   || quote.TargetedPriceForSaas__c != oldQuote.TargetedPriceForSaas__c
                   || quote.TargetedPriceForGlobal__c != oldQuote.TargetedPriceForGlobal__c){ 
                       
                    if(quote.TargetedPriceForHardware__c != null){	
                        if(quote.TargetedPriceForHardware__c > 0){	
                            setStructure.add('190');	
                        }	
                    }	
                    if(quote.TargetedPriceForLicense__c != null){	
                        if(quote.TargetedPriceForLicense__c > 0){	
                            setStructure.add('110');	
                        }	
                    }	
                    if(quote.TargetedPriceForMaintenance__c != null){	
                        if(quote.TargetedPriceForMaintenance__c > 0){	
                            setStructure.add('120');	
                        }	
                    }	
                    if(quote.TargetedPriceForProfessional_Services__c != null){	
                        if(quote.TargetedPriceForProfessional_Services__c > 0){	
                            setStructure.add('140');	
                        }	
                    }	
                    if(quote.TargetedPriceForSaas__c != null ){	
                        if(quote.TargetedPriceForSaas__c > 0){	
                            setStructure.add('130');	
                        }	
                    }	
                       
                    if(quote.TargetedPriceForGlobal__c != null ){	
                        if(quote.TargetedPriceForGlobal__c > 0){	
                            setStructure.add('110');
                            setStructure.add('120');
                            setStructure.add('130');
                            setStructure.add('140');
                            setStructure.add('190');
                        }	
                    }	
                }	
                
                if(setStructure.size() > 0){	
                    mapQuoteStructures.put(quote.Id, setStructure);	
                }

                //B-1835
                if(quote.SBQQ__Status__c == 'Accepted'  && quote.Email_e_billing__c != null){
                    setAccountEbilling.add(quote.Id);
                }
                
                //B-1923
                if(quote.SBQQ__Status__c == PENDINGPS && quote.SBQQ__Status__c != oldQuote.SBQQ__Status__c ){
                    lstQuotes.add(quote);
                }
                //US-2242 - Manage Discount approval validation
                if((quote.ApprovalStatus__c == 'Approved' || quote.ApprovalStatus__c == 'Rejected' || quote.ApprovalStatus__c == 'Recalled') && quote.ApprovalStatus__c != oldQut.ApprovalStatus__c){
                    approvedQuoteIds.add(quote.Id);
                }
                //US-2371 - Calculate if RCC Approval is required and approvers > on change of Quote Total / Billing Account / Sales Rep
                if(quote.SBQQ__Status__c != SM004_QuoteService.QUOTE_STATUSACCEPTED && (quote.CEGID_Quote_Total__c != oldQut.CEGID_Quote_Total__c || quote.Billing_Account__c != oldQut.Billing_Account__c || quote.SBQQ__SalesRep__c != oldQut.SBQQ__SalesRep__c) && (quote.CEGIDQuoteTotalValidatedByRCCWF__c == null || quote.CEGID_Quote_Total__c > quote.CEGIDQuoteTotalValidatedByRCCWF__c)){
                    rccApprovalQuoteIds.add(quote.Id);
                }
                //W-002442 - Gestion du statut rejected
                system.debug('MCU quote.SBQQ__Status__c : ' + quote.SBQQ__Status__c);
                system.debug('MCU oldQuote.SBQQ__Status__c : ' + oldQuote.SBQQ__Status__c);
                if(quote.SBQQ__Status__c != oldQuote.SBQQ__Status__c && quote.SBQQ__Status__c == REJECTED){
                    setQuoIds.add(quote.Id);
                }
                
            }
            
            //B-1923
            if(lstQuotes.size()>0){
				SM012_QuotePriceRule.createCasePS(lstQuotes,(Map<Id, SBQQ__Quote__c>) Trigger.OldMap);
            }

            //B-1835
            if(setAccountEbilling.size()>0){
                SM012_QuotePriceRule.setAccountEbilling((List<SBQQ__Quote__c>)Trigger.new);
            }

            if(setQCQuoteIds.size()>0){
                //W-001430
                //Qualification Sheet Creation when Quote updated
                //SM012_QuotePriceRule.qualificationQuoteCreation(setQCQuoteIds);
            }
            
            //W-000450	
            if(mapQuoteStructures.size()>0){	
                SM018_RedistributionOfDiscount.recalculationv1(mapQuoteStructures,(Map<Id,SBQQ__Quote__c>)Trigger.newMap);	
            }
            system.debug('MCU setQuoIds : ' + setQuoIds);
            if(setQuoIds.size() > 0){
                SM004_QuoteService.closeQuoteChildRecords(setQuoIds);
            }


            if(!System.isBatch() && !Test.isRunningTest()){
                if(setQuoteIds.size()>0){
                    SM016_EclatementContrats.executeWebService(setQuoteIds);
                }
            }
            // Launch SM004_QuoteService.DiscountManagementAfterApproval
            if(!approvedQuoteIds.isEmpty()){
                SM004_QuoteService.approvalManagementAfterValidation(approvedQuoteIds);
            }
            // Launch SM004_QuoteService.DiscountManagementAfterApproval
            if(!rccApprovalQuoteIds.isEmpty()){
                SM004_QuoteService.rccApprovalCalculation(rccApprovalQuoteIds);
            }
        }finally{
            //After All logic execute we enable the CPQ Package Trigger(S)
            SBQQ.TriggerControl.enable();
        }
        
        bypass('TH_Quote_afterUpdate');
        
    }
}