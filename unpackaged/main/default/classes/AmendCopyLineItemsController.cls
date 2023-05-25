/**
* @author Keshav - Comforth
* @date 2020-04-11
* @group AmendCopyLineItemsController
* @description cloner la lignes de devis et grouper
*/
public class AmendCopyLineItemsController {
    private Contract contractRecord;
    private Id quoteId;
    private Map < Id, SBQQ__QuoteLine__c > quoteLines;

    private Id contractId;
    private Map < Id, SBQQ__QuoteLine__c > contractQuoteLines;

    //These are for the switches to cover catch blocks. The purpose of this is to elevate the test class code coverage.
    public Boolean testRunningFlag = false;
    public Boolean testRunningFlag2 = false;

    // Do not proceed action method if there's an error in the constructor
    Boolean hasError = false;

    // Class constructor. This method queries all of the records needed for the clone action.
    public AmendCopyLineItemsController() {
        hasError = false;
		
        //system.debug('contractId : ' + contractId);
        //Get the parameters
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        system.debug('quoteId : ' + quoteId);
        //contractId = ApexPages.currentPage().getParameters().get('contractId');
		
        // Throw an error if one of the required parameters is null
        if (String.isBlank(quoteId) ) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'No quoteId/contractId parameter found.'));
            hasError = true;
            return;
        }

        /*Query the contract record for the amendment and its subscription records.
        contractRecord = [SELECT Id, Name, ContractNumber, EndDate, OwnerId, Account.Name,
            SBQQ__Opportunity__r.SBQQ__PrimaryQuote__c, SBQQ__Opportunity__c, SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Name,
            SBQQ__Opportunity__r.SBQQ__RenewedContract__r.ContractNumber,
            (SELECT Id, SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c,
                SBQQ__Discount__c, SBQQ__Quantity__c, SBQQ__SegmentIndex__c, SBQQ__SegmentKey__c,
                SBQQ__NetPrice__c, SBQQ__CustomerPrice__c, SBQQ__RegularPrice__c, SBQQ__StartDate__c, SBQQ__EndDate__c,
                SBQQ__OriginalQuoteLine__c, SBQQ__OriginalQuoteLine__r.SBQQ__Quote__c FROM SBQQ__Subscriptions__r)
            FROM Contract
            WHERE Id =: contractId
        ];

        // Collect all of the original quote line items from the contract's subscriptions
        Set < Id > contractQuoteLineIds = new Set < Id > ();
        for (SBQQ__Subscription__c sub: contractRecord.SBQQ__Subscriptions__r) {
            contractQuoteLineIds.add(sub.SBQQ__OriginalQuoteLine__c);
        } */
        
        
        // Query all the fields from the collected quote line ids
        if (quoteId != null) {
            quoteLines = new Map < Id, SBQQ__QuoteLine__c > ();
            contractQuoteLines = new Map < Id, SBQQ__QuoteLine__c > ();

            String query = 'SELECT  SBQQ__Quote__r.SBQQ__Type__c, SBQQ__UpgradedSubscription__r.SBQQ__NetPrice__c, ' +
                ' SBQQ__UpgradedSubscription__r.SBQQ__CustomerPrice__c, SBQQ__UpgradedSubscription__r.SBQQ__RegularPrice__c,SBQQ__Discount__c,' +
                ' SBQQ__AdditionalDiscountAmount__c, SBQQ__Bundle__c,SBQQ__RequiredBy__c,SBQQ__SegmentLabel__c,SBQQ__Number__c,SBQQ__Product__r.Id, SBQQ__NetPrice__c, ' +
                ' Reference_Number__c,	Product_Line__r.Id, Metric__c,SBQQ__AdditionalQuantity__c,SBQQ__Bundled__c, SBQQ__CarryoverLine__c, ' +
                'SBQQ__AllowAssetRefund__c,Available__c,SBQQ__BatchQuantity__c,SBQQ__BillingFrequency__c,Catalog__c,Coming_from_Zuora__c,';

            List < String > fieldsList = new List < String > ();
            for (Schema.FieldSetMember f: SObjectType.SBQQ__QuoteLine__c.FieldSets.Test_field_set.getFields()) {
                fieldsList.add(f.getFieldPath());
            }

            query += String.join(fieldsList, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId ORDER BY Name';

            for (SBQQ__QuoteLine__c ql: Database.query(query)) {
                    contractQuoteLines.put(ql.Id, ql);
                    quoteLines.put(ql.Id, ql);
                
            }
        }

    }


    // Method that executes the cloning action.


    public PageReference copyQuoteLineItems() {
        SBQQ.TriggerControl.disable();

        if (hasError) return null;

        Savepoint sp = Database.setSavepoint();
        


        // Mapped by the original quote line id to its clone
        Map < Id, SBQQ__QuoteLine__c > mapOrigIdToCloned = new Map < Id, SBQQ__QuoteLine__c > ();
        
        // Mapped inserted records for nested Bundles
        Map <Decimal, SBQQ__QuoteLine__c > mapNewQuoteLinedToNumber = new Map < Decimal, SBQQ__QuoteLine__c > ();
        
        //Create Group 
        Id groupNewVal = null;
        Id groupPreVal = null;
        for(SBQQ__QuoteLineGroup__c QLG:[Select Id, Name,SBQQ__Quote__c  FROM SBQQ__QuoteLineGroup__c where SBQQ__Quote__c  =:quoteId]){
            if(QLG.Name == 'New Value'){
               groupNewVal =  QLG.Id;
            }else if(QLG.Name == 'Previous Value'){
               groupPreVal =  QLG.Id;
            }
        }
        
        if(groupNewVal == null){
            SBQQ__QuoteLineGroup__c QLGNew = new SBQQ__QuoteLineGroup__c();
            QLGNew.SBQQ__Quote__c  = quoteId;
            QLGNew.Name =  System.Label.New_Group;
            QLGNew.SBQQ__Number__c = 1;
            Insert QLGNew;
            groupNewVal = QLGNew.Id;
        }
        
        if(groupPreVal == null){
            SBQQ__QuoteLineGroup__c QLGPrevious = new SBQQ__QuoteLineGroup__c();
            QLGPrevious.SBQQ__Quote__c  = quoteId;
            QLGPrevious.Name =  System.Label.Previous_Value;
            QLGPrevious.SBQQ__Number__c = 2;
            Insert QLGPrevious; 
            groupPreVal = QLGPrevious.Id;
        }
        
        // The contract quote lines is the one we will clone
        // We will start with the bundle items
        decimal quoteNumber = 999;
        for (SBQQ__QuoteLine__c ql: contractQuoteLines.values()) {
            system.debug('contractQuoteLines : ' + contractQuoteLines.values());
            if (ql.SBQQ__Bundle__c) { //If the product is a bundle,
                SBQQ__QuoteLine__c ql_cloned = ql.clone(false, true, false, false);
                ql_cloned.SBQQ__Quote__c = quoteId; //attach this quoteline to the amendment quote
                ql_cloned.SBQQ__Existing__c = false;
                ql_cloned.SBQQ__PriceEditable__c = true;
                ql_cloned.SBQQ__Number__c = quoteNumber;
                ql_cloned.Coming_from_Zuora__c  = false;
                ql_cloned.SBQQ__Group__c = groupNewVal;
                ql_cloned.TECH_isCloned__c = true; //MCU - B-2068
                /*ql_cloned.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c = true;
                ql_cloned.SBQQ__Quote__r.SBQQ__OrderByQuoteLineGroup__c = true;
                ql_cloned.SBQQ__Quote__r.SBQQ__OrderGroupID__c = QLG.Id;*/
                quoteNumber = quoteNumber + 1;
                
                mapNewQuoteLinedToNumber.put(ql.SBQQ__Number__c, ql_cloned);
                
                mapOrigIdToCloned.put(ql.Id, ql_cloned);
                system.debug('mapOrigIdToCloned : ' + mapOrigIdToCloned);
            }
        }
        

        try {
            
            // Insert this first as we will be needing the bundle id
            insert mapOrigIdToCloned.values();
            if (Test.isRunningTest() && testRunningFlag) {
                throw new CustomException('Error message in Test Class.');
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
            Database.rollback(sp);
            return null;
        }

        Map < Id, SBQQ__QuoteLine__c > mapOrigIdToCloned_nonBundle = new Map < Id, SBQQ__QuoteLine__c > ();
		
        

        // Then to the non-bundle items

        for (SBQQ__QuoteLine__c ql: contractQuoteLines.values()) {
            if (!ql.SBQQ__Bundle__c || (ql.SBQQ__Bundle__c && ql.SBQQ__RequiredBy__c != null)) { //If the product is not a bundle,
                SBQQ__QuoteLine__c ql_cloned;
                
                // this is a bundle as well child, especially nested bundles
                if(ql.SBQQ__Bundle__c && ql.SBQQ__RequiredBy__c != null) {
                    ql_cloned = mapNewQuoteLinedToNumber.get(ql.sbqq__Number__c);    
                
                } else {
                    ql_cloned = ql.clone(false, true, false, false);
                    ql_cloned.SBQQ__Quote__c = quoteId; //attach this quoteline to the amendment quote
                    ql_cloned.SBQQ__Existing__c = false;
                    ql_cloned.SBQQ__PriceEditable__c = true;
                    ql_cloned.Coming_from_Zuora__c  = false;
                    ql_cloned.SBQQ__Group__c = groupNewVal;
                }

                
                //Re-map its parent bundle to the bundle we inserted earlier
                if (ql_cloned.SBQQ__RequiredBy__c != null && mapOrigIdToCloned.containsKey(ql_cloned.SBQQ__RequiredBy__c)) {
                    ql_cloned.SBQQ__RequiredBy__c = mapOrigIdToCloned.get(ql_cloned.SBQQ__RequiredBy__c).Id;
                }
                
                if(!ql.SBQQ__Bundle__c) {
                    mapOrigIdToCloned_nonBundle.put(ql.Id, ql_cloned);
                }
            }
        }


        for (SBQQ__QuoteLine__c ql: quoteLines.values()) {
            ql.SBQQ__Quantity__c = 0;
            // ql.SBQQ__PriorQuantity__c = 3;
            // ql.SBQQ__UpgradedQuantity__c = 1;
            ql.SBQQ__Group__c = groupPreVal; 
            
        }

        //Editing Record to Group 
        SBQQ__Quote__c qUpdate = [SELECT id,Name from SBQQ__Quote__c where Id =:quoteId];
        qUpdate.SBQQ__LineItemsGrouped__c = true;
        update qUpdate;
        //Re-evaluate numberings for segmented and non-segmented line items
        Integer count = 1;
        List < SBQQ__QuoteLine__c > mergedList = new List < SBQQ__QuoteLine__c > ();
        mergedList.addAll(quoteLines.values());
        //mergedList.addAll(mapOrigIdToCloned.values());
        
        // only add the bundle products
        // don't add the bundle products with child like Nested Parent
        for(SBQQ__QuoteLine__c qlBundle : mapOrigIdToCloned.values()) {
            qlBundle.SBQQ__Number__c = null;
            mergedList.add(qlBundle);
            
        }
        
        mergedList.addAll(mapOrigIdToCloned_nonBundle.values());

        for (SBQQ__QuoteLine__c ql: mergedList) {
            if (ql.SBQQ__SegmentLabel__c != null) {
                ql.SBQQ__Number__c = count++;
            }
        }

        for (SBQQ__QuoteLine__c ql: mergedList) {
            if (ql.SBQQ__SegmentLabel__c == null) {
                ql.SBQQ__Number__c = count++;
            }
        }

        //DML Statements go here
        try {
            upsert mergedList;
            if (Test.isRunningTest() && testRunningFlag2) {
                throw new CustomException('Error message in Test Class.');
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(
                ApexPages.Severity.ERROR,
                'DML operation has failed. More info: ' + ex.getMessage() + '\nStack Trace:' + ex.getStackTraceString()));
            Database.rollback(sp);
            return null;
        }
        
        SBQQ.TriggerControl.enable();

        return new PageReference('/apex/SBQQ__sb?id=' + quoteId + '#quote/le?qId=' + quoteId);
    }

    public class CustomException extends Exception {

    }
}