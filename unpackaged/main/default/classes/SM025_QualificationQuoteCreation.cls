/**
 * @description       : W-001430 @future was used due to conflict with CPQ Package thus this class is executed separately 
 * 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 05-13-2022
 * @last modified by  : Keshav Matabadul
**/
public with sharing class SM025_QualificationQuoteCreation {
    @future(callout=true)
    public static void qualificationsheetsCreationUpdated(Set<Id> quoteIds){

        Map<Id, set<Id>> mapQuoteOffers = new Map<Id, set<Id>>();
        Map<Id, set<Id>> mapQualification = new Map<Id, set<Id>>();
        List<Qualification_Sheet__c> listQSCreate = new List<Qualification_Sheet__c>();

        //Query All Quoteline related to Quote 
        List<SBQQ__QuoteLine__c> listQL = [SELECT Id, SBQQ__Quote__c,Offer__c,Offer_Lookup__c,Offer_Lookup__r.Generate_Sheet_in_PS_Context__c,StructureLevel1__c 
        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quoteIds AND StructureLevel1__c = '140' AND Offer_Lookup__c != null];

        system.debug('listQL : ' + listQL.size());
        //Query Qualification Sheet related with Quote ID
        List<Qualification_Sheet__c> listQS = [SELECT Id, Quote__c,Offer__c FROM Qualification_Sheet__c WHERE Quote__c IN:quoteIds];

        //Loop On QuoteLines 
        for(SBQQ__QuoteLine__c ql:listQL){
            set<Id> tmpSetOffer = mapQuoteOffers.containsKey(ql.SBQQ__Quote__c) ? mapQuoteOffers.get(ql.SBQQ__Quote__c) : new set<Id>();
            if(ql.Offer_Lookup__r.Generate_Sheet_in_PS_Context__c ){
                tmpSetOffer.add(ql.Offer_Lookup__c);
            }
            system.debug('tmpSetOffer : ' + tmpSetOffer);
            mapQuoteOffers.put(ql.SBQQ__Quote__c, tmpSetOffer);
        }

        //Loop on Qualificationsheet
        for(Qualification_Sheet__c QS:listQS){
            set<Id> tmpSetQualification = mapQualification.containsKey(QS.Quote__c) ? mapQualification.get(QS.Quote__c) : new set<Id>();
            tmpSetQualification.add(QS.Offer__c);
            mapQualification.put(QS.Quote__c, tmpSetQualification);
        }

        system.debug('mapQuoteOffers : ' + mapQuoteOffers);
        for(Id quoteId : mapQuoteOffers.keySet()){
            for(Id offerId:mapQuoteOffers.get(quoteId)){
                set<Id> setQSOffers = (mapQualification.containsKey(quoteId)) ? mapQualification.get(quoteId) : new set<Id>();
                if(!setQSOffers.contains(offerId)){
                    Qualification_Sheet__c objQS = new Qualification_Sheet__c();
                    //objQS.Name = 'Auto-generated Qualification Sheet';
                    objQS.Offer__c = offerId;
                    objQS.Quote__c = quoteId;
                    listQSCreate.add(objQS);
                }
            }
        }

        if(listQSCreate.size()>0){
            insert listQSCreate;
        }

    }

    public static void qualificationQuoteCreation(Set<Id> quoteIds){ 
        List<Id> listQualificationIds = new List<Id>();
        map<Id, set<Id>> mapQualification = new map<Id, set<Id>>();
        List<Qualification_Sheet__c> listQSCreate = new List<Qualification_Sheet__c>();
        map<Id, set<Id>> mapQuoteOffers = new map<Id, set<Id>>();
        //Query Quoteline related to Quote 
        List<SBQQ__QuoteLine__c> listQL = [SELECT Id, SBQQ__Quote__c,Offer__c,Offer_Lookup__c,Offer_Lookup__r.Generate_Sheet_in_PS_Context__c 
        FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN:quoteIds ];

        //Query Qualification Sheet related with Quote ID
        List<Qualification_Sheet__c> listQS = [SELECT Id, Quote__c,Offer__c FROM Qualification_Sheet__c WHERE Quote__c IN:quoteIds];
        

        //Loop On QuoteLines 
        for(SBQQ__QuoteLine__c ql:listQL){
            set<Id> tmpSetOffer = mapQuoteOffers.containsKey(ql.SBQQ__Quote__c) ? mapQuoteOffers.get(ql.SBQQ__Quote__c) : new set<Id>();
            if( ql.Offer_Lookup__c != null && ql.Offer_Lookup__r.Generate_Sheet_in_PS_Context__c == true ){
                tmpSetOffer.add(ql.Offer_Lookup__c);
            }
            mapQuoteOffers.put(ql.SBQQ__Quote__c, tmpSetOffer);
        }
        

        //Loop on Qualificationsheet
        for(Qualification_Sheet__c QS:listQS){
            set<Id> tmpSetQualification = mapQualification.containsKey(QS.Quote__c) ? mapQualification.get(QS.Quote__c) : new set<Id>();
            tmpSetQualification.add(QS.Offer__c);
            mapQualification.put(QS.Quote__c, tmpSetQualification);
        }
        for(Id quoteId : mapQuoteOffers.keySet()){
            for(Id offerId:mapQuoteOffers.get(quoteId)){
                set<Id> setQSOffers = (mapQualification.containsKey(quoteId)) ? mapQualification.get(quoteId) : new set<Id>();
                if(!setQSOffers.contains(offerId)){
                    Qualification_Sheet__c objQS = new Qualification_Sheet__c();
                    //objQS.Name = 'Auto-generated Qualification Sheet';
                    objQS.Offer__c = offerId;
                    objQS.Quote__c = quoteId;
                    listQSCreate.add(objQS);
                }
            }
        }
        
        if(listQSCreate.size()>0){
            insert listQSCreate;
        }
    }

}