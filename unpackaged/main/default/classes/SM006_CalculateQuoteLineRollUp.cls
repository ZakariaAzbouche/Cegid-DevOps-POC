/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-08-28
 * @modified 2020-10-23
 * @description Custom calculation of some SBQQ__Quote__c rollup summary feilds on SBQQ__QuoteLine__c
 *              to reduce number of rollup fields used because max rollup limit was already increased (US W-001320) 
 *              Added logic to calculate count of missing training sessions (US W-001277) 
*/
public with sharing class SM006_CalculateQuoteLineRollUp {
    //SBQQ__QuoteLine__c picklist Category__c / StructureLevel3
    public static final String CATEGORY_CERTIFICATION = '302'; //'Certification'
    public static final String CATEGORY_ELEARNING = '314'; //'eLearning'
    public static final String CATEGORY_ONCEGID_CENTER = '301'; //'On Cegid Center in-class courses'
    public static final String CATEGORY_ONSITE_TRAINING = '300'; //'On-site training'
    
    //SBQQ__QuoteLine__c picklist SBQQ__ChargeType__c / Charge Type
    public static final String CHARGETYPE_RECURRING = 'Recurring';
    public static final String CHARGETYPE_ONETIME = 'One-Time';
    
    //SBQQ__QuoteLine__c picklist StructureLevel1__c / StructureLevel1
    public static final String STRUCLEVEL1_PROF_SERVICES = '140'; //'Professional services'
    public static final String STRUCLEVEL1_SAAS = '130'; //'Saas'
    public static final String STRUCLEVEL1_MAINT = '120'; //'Maintenance'
    public static final String STRUCLEVEL1_LICENSES = '110'; //'Licenses'
 

    /**
     * @author Shamina M - Comforth Karoo
     * @date 2020-08-28
     * @description calculate custom rollup fields
     * @param setQuoteIds Set of quote ids related to quote lines triggered
     */
    public static void calculateRollUp(Set<Id> setQuoteIds){
        system.debug('calculateRollUp');
        List<SBQQ__Quote__c> listQuoteToUpd = new List<SBQQ__Quote__c>();
        Decimal recurTrAmt = 0.00;
        Decimal recurServAmt = 0.00;
        Decimal recurSaasAmt = 0.00;
        Decimal recurMaintAmt = 0.00;
        Decimal recurLiscAmt = 0.00;
        Decimal oneTimeTrAmt = 0.00;
        Decimal oneTimeServAmt = 0.00;
        Decimal oneTimeSaasAmt = 0.00;
        Decimal oneTimeMaintAmt = 0.00;
        Decimal oneTimeLiscAmt = 0.00;
        Decimal totalSubsDisc = 0.00;
        Decimal grossTotal = 0.00;
        Integer countELearnWithoutAllTrainingSession=0;
        Integer loopNumber = 0;
        
        for(Id quoteId : setQuoteIds){
            SBQQ__Quote__c qut = (TH_QuoteLine.mapUpdateQuote.get(quoteId) != null) ? TH_QuoteLine.mapUpdateQuote.get(quoteId) : TH_QuoteLine.mapAllQuote.get(quoteId);
            system.debug('Quote : ' + qut);
            /*recurTrAmt = 0.00;
            recurServAmt = 0.00;
            recurSaasAmt = 0.00;
            recurMaintAmt = 0.00;
            recurLiscAmt = 0.00;
            oneTimeTrAmt = 0.00;
            oneTimeServAmt = 0.00;
            oneTimeSaasAmt = 0.00;
            oneTimeMaintAmt = 0.00;
            oneTimeLiscAmt = 0.00;
            totalSubsDisc = 0.00;
            grossTotal = 0.00;
            countELearnWithoutAllTrainingSession = 0;
            loopNumber = 0;*/
            system.debug('qut.SBQQ__LineItems__r : '  + qut.SBQQ__LineItems__r.size());
            for(SBQQ__QuoteLine__c qutLine : qut.SBQQ__LineItems__r){
                loopNumber++;
                //RECURRING
                if((qutLine.Category__c == CATEGORY_CERTIFICATION || qutLine.Category__c == CATEGORY_ELEARNING || 
                    qutLine.Category__c == CATEGORY_ONCEGID_CENTER || qutLine.Category__c == CATEGORY_ONSITE_TRAINING) &&
                    (qutLine.SBQQ__ChargeType__c == CHARGETYPE_RECURRING)){
                    recurTrAmt += (qutLine.Subscribed_Total__c == null ? 0 : qutLine.Subscribed_Total__c);
                }

                if(qutLine.StructureLevel1__c == STRUCLEVEL1_PROF_SERVICES && qutLine.SBQQ__ChargeType__c == CHARGETYPE_RECURRING &&
                    (qutLine.Category__c != CATEGORY_CERTIFICATION && qutLine.Category__c != CATEGORY_ELEARNING && 
                    qutLine.Category__c != CATEGORY_ONCEGID_CENTER && qutLine.Category__c != CATEGORY_ONSITE_TRAINING)){
                    recurServAmt += (qutLine.Subscribed_Total__c == null ? 0 : qutLine.Subscribed_Total__c);
                        system.debug('recurServAmt : ' + recurServAmt);
                }
                else if(qutLine.StructureLevel1__c == STRUCLEVEL1_SAAS && qutLine.SBQQ__ChargeType__c == CHARGETYPE_RECURRING){
                    system.debug('qutLine.Subscribed_Total__c : ' + qutLine.Subscribed_Total__c);
                    recurSaasAmt += (qutLine.Subscribed_Total__c == null ? 0 : qutLine.Subscribed_Total__c);
                    system.debug('recurSaasAmt : ' + recurSaasAmt);
                }
                else if(qutLine.StructureLevel1__c == STRUCLEVEL1_MAINT && qutLine.SBQQ__ChargeType__c == CHARGETYPE_RECURRING){
                    recurMaintAmt += (qutLine.Subscribed_Total__c == null ? 0 : qutLine.Subscribed_Total__c);
                    system.debug('recurMaintAmt : ' + recurMaintAmt);
                }
                else if(qutLine.StructureLevel1__c == STRUCLEVEL1_LICENSES && qutLine.SBQQ__ChargeType__c == CHARGETYPE_RECURRING){
                    recurLiscAmt += (qutLine.Subscribed_Total__c == null ? 0 : qutLine.Subscribed_Total__c);
                    system.debug('recurLiscAmt : ' + recurLiscAmt);
                }

                //ONE-TIME
                if((qutLine.Category__c == CATEGORY_CERTIFICATION || qutLine.Category__c == CATEGORY_ELEARNING || 
                    qutLine.Category__c == CATEGORY_ONCEGID_CENTER || qutLine.Category__c == CATEGORY_ONSITE_TRAINING) &&
                    (qutLine.SBQQ__ChargeType__c == CHARGETYPE_ONETIME)){
                    oneTimeTrAmt += (qutLine.NetTotal_Display__c == null ? 0 : qutLine.NetTotal_Display__c);
                        system.debug('oneTimeTrAmt : ' + oneTimeTrAmt);
                }

                if(qutLine.StructureLevel1__c == STRUCLEVEL1_PROF_SERVICES && qutLine.SBQQ__ChargeType__c == CHARGETYPE_ONETIME &&
                    (qutLine.Category__c != CATEGORY_CERTIFICATION && qutLine.Category__c != CATEGORY_ELEARNING && 
                    qutLine.Category__c != CATEGORY_ONCEGID_CENTER && qutLine.Category__c != CATEGORY_ONSITE_TRAINING)){
                    oneTimeServAmt += (qutLine.NetTotal_Display__c == null ? 0 : qutLine.NetTotal_Display__c);
                        system.debug('oneTimeServAmt : ' + oneTimeServAmt);
                }
                else if(qutLine.StructureLevel1__c == STRUCLEVEL1_SAAS && qutLine.SBQQ__ChargeType__c == CHARGETYPE_ONETIME){
                    oneTimeSaasAmt += (qutLine.NetTotal_Display__c == null ? 0 : qutLine.NetTotal_Display__c);
                    system.debug('oneTimeSaasAmt : ' + oneTimeSaasAmt);
                }
                else if(qutLine.StructureLevel1__c == STRUCLEVEL1_MAINT && qutLine.SBQQ__ChargeType__c == CHARGETYPE_ONETIME){
                    oneTimeMaintAmt += (qutLine.NetTotal_Display__c == null ? 0 : qutLine.NetTotal_Display__c);
                    system.debug('oneTimeMaintAmt : ' + oneTimeMaintAmt);
                }
                else if(qutLine.StructureLevel1__c == STRUCLEVEL1_LICENSES && qutLine.SBQQ__ChargeType__c == CHARGETYPE_ONETIME){
                    oneTimeLiscAmt += (qutLine.NetTotal_Display__c == null ? 0 : qutLine.NetTotal_Display__c);
                    system.debug('oneTimeLiscAmt : ' + oneTimeLiscAmt);
                }

                //DISCOUNT & TOTAL
                totalSubsDisc += (qutLine.SBQQ__AdditionalDiscount__c == null ? 0 : qutLine.SBQQ__AdditionalDiscount__c);
                system.debug('totalSubsDisc : ' + totalSubsDisc);
                grossTotal += (qutLine.TECH_CopyGrossTotal__c == null ? 0 : qutLine.TECH_CopyGrossTotal__c);
                system.debug('grossTotal : ' + grossTotal);
				//To be deployed afterwards
                //W-001277 - Count empty Training sessions details for Quote line product eLearning
                /*if(qutLine.Category__c == CATEGORY_ELEARNING && qutLine.CountEmptyTrainingSessions__c > 0){
                    countELearnWithoutAllTrainingSession++;
                }*/
            }
            
            system.debug('loopNumber : '  + loopNumber);

            //set calculated amount or 0 if no quote lines found
            //qut.Recurring_Training_Amount__c = recurTrAmt;
            //qut.Recurring_Services_Amount__c = recurServAmt;
            //qut.Recurring_SaaS_Amount__c = recurSaasAmt;
            //qut.Recurring_Maintenance_Amount__c = recurMaintAmt;
            //qut.Recurring_Licenses_Amount__c = recurLiscAmt;
            //qut.One_Time_Training_Amount__c = oneTimeTrAmt;
            //qut.One_Time_Services_Amount__c = oneTimeServAmt;
            //qut.One_Time_SaaS_Amount__c = oneTimeSaasAmt;
            //qut.One_Time_Maintenance_Amount__c = oneTimeMaintAmt;
            //qut.One_Time_Licenses_Amount__c = oneTimeLiscAmt;
            //qut.Total_Subscription_Discount__c = totalSubsDisc;
            //qut.Gross_Total_Total__c = grossTotal;

            system.debug('qut : @@@@@@@ ' + qut);

            //W-001277 - Count missing Training sessions for Quote line product eLearning
            //To be deployed afterwards
            //qut.countELearningLinesWOAllTraining__c = countELearnWithoutAllTrainingSession;

            //listQuoteToUpd.add(qut);
            TH_QuoteLine.mapUpdateQuote.put(qut.Id, qut);
        }

        /* if(SBQQ__Quote__c.sObjectType.getDescribe().isUpdateable()){
            update listQuoteToUpd;
        } */
    }

    
}