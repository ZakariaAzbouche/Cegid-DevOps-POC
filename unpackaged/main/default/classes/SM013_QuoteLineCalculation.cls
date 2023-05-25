/**
* @author Keshav M - Comforth Karoo
* @date 2020-08-28
*/
public class SM013_QuoteLineCalculation {
	public static final String FRAIS_DE_DEPLACEMENT = 'Frais de déplacement';
    public static final String PRODUCTFAMILYSAAS = '130';
    public static final String STATUSAPPROVED = 'Approved';
    public static final String STATUSPRESENTED = 'Presented';
    public static final String STATUSREJECTED = 'Rejected';
    public static final String STATUSPENDINGPS = 'Pending PS';
    public static final String STATUSDRAFT = 'Draft';
    public static final String STATUSINPROGRESS = 'In progress';

    public static void processBuilderBeforeInsert(List<SBQQ__QuoteLine__c> listQuoteLine){
        system.debug('processBuilderBeforeInsert');

        set<Id> setQuoteIds = new set<Id>();

        for(SBQQ__QuoteLine__c quoteLine:listQuoteLine){
            setQuoteIds.add(quoteLine.SBQQ__Quote__c);
        }
        
        //get Frais Deplacement 
        //Quote Template 6/22/2022
        // Calcul des frais de déplacement
        List<Product2> FraisDeDeplacementProduct = [SELECT Id FROM Product2 WHERE Name LIKE:FRAIS_DE_DEPLACEMENT LIMIT 1];

        Map<Id, SBQQ__Quote__c> mapQuote = new map<Id, SBQQ__Quote__c>([SELECT Id, Email_validator_lv_3__c FROM SBQQ__Quote__c WHERE Id IN:setQuoteIds]);

        //set field email validator

        for(SBQQ__QuoteLine__c ql:listQuoteLine){
            ql.Email_validator_lv_3__c = mapQuote.get(ql.SBQQ__Quote__c).Email_validator_lv_3__c;
            
            //B-1924
            if(!FraisDeDeplacementProduct.isEmpty() && FraisDeDeplacementProduct[0].Id == ql.SBQQ__Product__c){
                ql.SBQQ__Quantity__c = ql.SBQQ__Quantity__c.round(System.RoundingMode.CEILING);
            }
        }

    }

    // public static void processBuilderPartnerSolutionProductAdd(List<SBQQ__QuoteLine__c> listQuoteLine){
    //     system.debug('processBuilderPartnerSolutionProductAdd');
    //     //set<Id> setQuoteIds = new set<Id>();
    //     set<Id> setProductIds = new set<Id>();

    //     for(SBQQ__QuoteLine__c quoteLine:listQuoteLine){
    //         //setQuoteIds.add(quoteLine.SBQQ__Quote__c);
    //         setProductIds.add(quoteLine.SBQQ__Product__c);
    //     }

    //     //Map<Id, SBQQ__Quote__c> mapQuote = new map<Id, SBQQ__Quote__c>([SELECT Id, Email_validator_lv3_sent__c FROM SBQQ__Quote__c WHERE Id IN:setQuoteIds]);
    //     Map<Id, Product2> mapProduct = new map<Id, Product2>([SELECT Id, Partner_Solution_Product__c FROM Product2 WHERE Id IN:setProductIds]);

    //     for(SBQQ__Quote__c q:[SELECT Id, Email_validator_lv3_sent__c FROM SBQQ__Quote__c WHERE Id IN:setQuoteIds]){
    //         if(mapProduct.get(QL.SBQQ__Product__c).Partner_Solution_Product__c){

    //         }
    //     }
    // }


    public static void processBuilderBeforeUpdate(List<SBQQ__QuoteLine__c> listQuoteLine){
        system.debug('processBuilderBeforeUpdate' );

        set<Id> setIdPro = new set<Id>();
		
        //get Frais Deplacement 
        //Quote Template 6/22/2022
        // Calcul des frais de déplacement
        List<Product2> FraisDeDeplacementProduct = [SELECT Id FROM Product2 WHERE Name LIKE:FRAIS_DE_DEPLACEMENT LIMIT 1];

        for(SBQQ__QuoteLine__c quoteLine:listQuoteLine){
            setIdPro.add(quoteLine.SBQQ__Product__c);
        }

        Map<Id, Product2> mapProduct = new map<Id, Product2>([SELECT Id, Family FROM Product2 WHERE Id IN:setIdPro]);

        for(SBQQ__QuoteLine__c QL:listQuoteLine){
            //Subscription Term to update ?
            if(QL.TECH_Subscription_Term__c != QL.TECH_Subscription_Term_Formula__c){
                QL.TECH_Subscription_Term__c = QL.TECH_Subscription_Term_Formula__c;
            }

            //Saas Line Calculate Saas MRR?
            if(QL.TECH_Saas_MRR__c != QL.NetTotal_Display__c && mapProduct.get(QL.SBQQ__Product__c).Family == PRODUCTFAMILYSAAS){
                QL.TECH_Saas_MRR__c = QL.NetTotal_Display__c;
            }

            if(QL.Latitude_Percentage__c > 1 && QL.Additionnal_Discount_Percentage__c > 0){
                //RedFlag needed?
                QL.LatitudeImage__c = System.Label.RedFlagId;
            }else if(QL.Latitude_Percentage__c > 0.666 && QL.Additionnal_Discount_Percentage__c > 0){
                //OrangeFlag needed?
                QL.LatitudeImage__c = System.Label.OrangeFlagId;
            }else if(QL.Latitude_Percentage__c > 0.333 && QL.Additionnal_Discount_Percentage__c > 0){
                //YellowFlag needed?
                QL.LatitudeImage__c = System.Label.YellowFlagId;
            }else if(QL.Latitude_Percentage__c > 0.333){
                //NoFlag needed?
                QL.LatitudeImage__c = '';
            }
            
            //B-1924
            if(!FraisDeDeplacementProduct.isEmpty() && FraisDeDeplacementProduct[0].Id == ql.SBQQ__Product__c){
                ql.SBQQ__Quantity__c = ql.SBQQ__Quantity__c.round(System.RoundingMode.CEILING);
            }

        }

    }

    public static void processBuilderAfter(List<SBQQ__QuoteLine__c> listQuoteLine, Boolean isNew){
        system.debug('processBuilderAfterInsert');
        List<Case> listCaseUpdate = new list<Case>();
        List<Opportunity> listOpportunityUpdate = new list<Opportunity>();
        set<Id> setIdPro = new set<Id>();

        for(SBQQ__QuoteLine__c quoteLine:listQuoteLine){
            setIdPro.add(quoteLine.SBQQ__Product__c);
        }

        Map<Id, Product2> mapProduct = new map<Id, Product2>([SELECT Id, Family,General_Terms_And_Conditions__c,Service_Book__c FROM Product2 WHERE Id IN:setIdPro]);


        for(SBQQ__QuoteLine__c ql:listQuoteLine ){
            
            SBQQ__Quote__c q = (TH_QuoteLine.mapUpdateQuote.get(ql.SBQQ__Quote__c) != null) ? TH_QuoteLine.mapUpdateQuote.get(ql.SBQQ__Quote__c) : TH_QuoteLine.mapAllQuote.get(ql.SBQQ__Quote__c);
            
            //Quote Line Modified
            q.Tech_MaxLastModifiedDate__c = date.newinstance(ql.LastModifiedDate.year(), ql.LastModifiedDate.month(),ql.LastModifiedDate.day());
                //Quote Line needs to be reviewed by PS
                if(!ql.Catalog__c && !(q.SBQQ__Status__c == STATUSPENDINGPS) && isNew){
                    q.SBQQ__Status__c = STATUSDRAFT ;
                    q.ApprovalStatus__c=null;
                    q.TECH_Passed_in_PS_OK_Status__c = false;

                    for(case c:q.Cases__r){
                        if(c.recordtypeId == Label.Professional_Services_Request_Record_Type_Id ){
                            case cas = new case(Id = c.Id, Status = STATUSINPROGRESS);
                            listCaseUpdate.add(cas);
                        }
                    }

                }
				
                //Quote Line modified when Quote already Approved/Presented/Rejected
                if(q.ApprovalStatus__c != STATUSAPPROVED){
                    if(q.SBQQ__Status__c == STATUSAPPROVED || q.SBQQ__Status__c == STATUSPRESENTED || q.SBQQ__Status__c == STATUSREJECTED){/*q.SBQQ__Status__c == STATUSAPPROVED ||*/
                        Id QuoteRTID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Default').getRecordTypeId();
                        q.ApprovalStatus__c = null;
                        q.recordtypeId = QuoteRTID;
                        q.SBQQ__Status__c = STATUSDRAFT;
                        q.SBQQ__WatermarkShown__c = true;
                    } 
                }

                //Saas Line Update SaaS Duration on Quote?
                if(mapProduct.get(QL.SBQQ__Product__c).Family == PRODUCTFAMILYSAAS){
                    Decimal SaaSContractDuration = (q.Max_Saas_Contract_Duration__c > 36)?36:q.Max_Saas_Contract_Duration__c;
                    Opportunity opp = new Opportunity(Id = q.SBQQ__Opportunity2__c, SaaS_Contract_Duration__c = SaaSContractDuration);
                    listOpportunityUpdate.add(opp);
                }

                //IsSubscriptionMetricPayslip?
                if((ql.Metric__c == '' || ql.Metric__c == null) && ql.SBQQ__DefaultSubscriptionTerm__c == 1){
                    q.Payslips__c = ql.SBQQ__Quantity__c * 0.80;
                }

                //New Quote line with booklet or CGV
                if(ql.SBQQ__Product__r.Service_Book__c != null || mapProduct.get(QL.SBQQ__Product__c).General_Terms_And_Conditions__c != null && isNew){
                    q.Terms_of_Sale_and_Service_Booklets__c = q.Terms_of_Sale_and_Service_Booklets__c +' '+ mapProduct.get(QL.SBQQ__Product__c).General_Terms_And_Conditions__c +' '+ mapProduct.get(QL.SBQQ__Product__c).Service_Book__c;
                }

            
            TH_QuoteLine.mapUpdateQuote.put(q.Id, q);

        }

        if(listCaseUpdate.size()>0){
            update listCaseUpdate;
        }

        if(listOpportunityUpdate.size()>0){
            //update listOpportunityUpdate;
        }
        

    }
      
}