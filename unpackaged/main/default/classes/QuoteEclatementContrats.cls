/**
* @author Keshav - Comforth
* @date 2021-01-03
* @modified 
* @group TH_Quote
* @object Quote
* @description Will be handle if the webservice value is set XRP
*/
public class QuoteEclatementContrats {

    public static void fetchCompanyLabel(Set<Id> setQuoteIds,Map<String, Object> mapResponse, Boolean isTrue){
        SBQQ.TriggerControl.disable();

        String PaymentMethod =  (mapResponse.get('paymentMethod') != null)?mapResponse.get('paymentMethod').toString():null;
        String paymentTerms =  (mapResponse.get('numberOfDaysForPayment') != null)?mapResponse.get('numberOfDaysForPayment').toString():null;
        String paymentDate = (mapResponse.get('paymentDate') != null)?mapResponse.get('paymentDate').toString():null;

        Set<Id> setEntityId = new Set<Id>();
        List<SBQQ__Quote__c> listQuoteToUpdate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> listQuote = [SELECT Id,OriginalPaymentTerms__c,Payment_Method__c,Payment_Term__c,Payment_Date__c,SBQQ__PriceBook__c,OriginalPayment_Date__c,
        OriginalPayment_Method__c,Billing_Frequency__c,OriginalBilling_Frequency__c, SBQQ__PriceBook__r.Cegid_Entity__c FROM SBQQ__Quote__c WHERE Id =:setQuoteIds];

        

        for(SBQQ__Quote__c quote:listQuote){
            setEntityId.add(quote.SBQQ__PriceBook__r.Cegid_Entity__c);
        }

        List<Entity__c> listEntity =[SELECT  Id, PaymentTerm__c,PaymentMethod__c,Date__c, PaymentDateCalculationMethod__c,
        RenewalTerm__c,IncreaseMode__c,NoticePeriodMonths__c,RenewalMode__c,ExtensionMode__c,SubscriptionTerm__c, DefaultBillingFrequency__c
        FROM Entity__c WHERE Id IN:setEntityId];

        system.debug('listEntity : ' + listEntity.size());

        for(SBQQ__Quote__c SQ:listQuote){
            SQ.Payment_Method__c = null;
            SQ.Payment_Term__c = null;
            SQ.Payment_Date__c = null;
            SQ.OriginalPaymentTerms__c = null;
            SQ.OriginalPayment_Date__c = null;
            SQ.OriginalPayment_Method__c = null;
            SQ.Billing_Frequency__c = null;
            SQ.OriginalBilling_Frequency__c = null;

            for(Entity__c LE:listEntity){

                if(PaymentMethod != null && paymentTerms != null && paymentDate != null){
                    //Populating Fields
                    SQ.Payment_Method__c = (PaymentMethod != null)?PaymentMethod:null;
                    SQ.Payment_Term__c = (paymentTerms != null)?paymentTerms:null;
                    SQ.Payment_Date__c = (paymentDate != null)?paymentDate:null;
                    SQ.XRP_Data_retrieved__c = true;
                    SQ.OriginalPaymentTerms__c =  (paymentTerms != null)?paymentTerms:null;
                    SQ.OriginalPayment_Date__c =  (paymentDate != null)?paymentDate:null;
                    SQ.OriginalPayment_Method__c =  (PaymentMethod != null)?PaymentMethod:null;
                    SQ.Billing_Frequency__c = (LE.DefaultBillingFrequency__c != null)?LE.DefaultBillingFrequency__c:null;
                    SQ.OriginalBilling_Frequency__c = (LE.DefaultBillingFrequency__c != null)?LE.DefaultBillingFrequency__c:null;
                }else{
                    SQ.Payment_Method__c = (LE.PaymentMethod__c != null)?LE.PaymentMethod__c:null;
                    SQ.Payment_Term__c = (LE.PaymentTerm__c != null)?LE.PaymentTerm__c:null;
                    SQ.Payment_Date__c = (LE.Date__c != null)?LE.Date__c:null;
                    SQ.XRP_Data_retrieved__c = true;
                    SQ.OriginalPaymentTerms__c = (LE.PaymentTerm__c != null)?LE.PaymentTerm__c:null;
                    SQ.OriginalPayment_Date__c = (LE.Date__c != null)?LE.Date__c:null;
                    SQ.OriginalPayment_Method__c = (LE.PaymentMethod__c != null)?LE.PaymentMethod__c:null;
                    SQ.Billing_Frequency__c = (LE.DefaultBillingFrequency__c != null)?LE.DefaultBillingFrequency__c:null;
                    SQ.OriginalBilling_Frequency__c = (LE.DefaultBillingFrequency__c != null)?LE.DefaultBillingFrequency__c:null;
                }
                SQ.SBQQ__RenewalTerm__c = (LE.RenewalTerm__c != null)?LE.RenewalTerm__c:null;
                SQ.Increase_Mode__c = (LE.IncreaseMode__c != null)?LE.IncreaseMode__c:null;
                SQ.Notice_Period_Months__c = (LE.NoticePeriodMonths__c != null)?LE.NoticePeriodMonths__c:null;
                SQ.SBQQ__SubscriptionTerm__c = (LE.SubscriptionTerm__c != null)?integer.valueof(LE.SubscriptionTerm__c):null;
                SQ.Company_Label_Initialized__c = true;
                SQ.Folder_Entity__c = (LE.Id != null)?LE.Id:null;
                SQ.Renewal_Mode__c = (LE.RenewalMode__c != null)?LE.RenewalMode__c:null;
                SQ.Extension_Mode__c = (LE.ExtensionMode__c != null)?LE.ExtensionMode__c:null;
                SQ.Full_Service__c = false;
                SQ.Payment_Date_Calculation_Method__c = (LE.PaymentDateCalculationMethod__c != null)?LE.PaymentDateCalculationMethod__c:null;
            }
            listQuoteToUpdate.add(SQ);
        }
        if(listQuoteToUpdate.size()>0){
            update listQuoteToUpdate;
       }


        SBQQ.TriggerControl.enable();
    }


}