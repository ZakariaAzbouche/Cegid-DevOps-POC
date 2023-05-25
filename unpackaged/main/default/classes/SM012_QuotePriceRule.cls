/**
* @author Keshav - Comforth
* @date Creation 07 Dec-2020
* @Modified Creation 02 Feb-2021
* @description SM012_QuotePriceRule
*              
*/

public class SM012_QuotePriceRule {
    
    public static final String OUI = 'Oui';
    public static final String NON = 'Non';
    public static final String EDITLINES = 'SBQQ__LineEditor';
    public static final String TYPEAMENDMENT = 'Amendment';
    public static final String PENDINGPS= 'Pending PS';
    public static final String APPROVALSTATUSREJECTED= 'Rejected';
    public static final String APPROVALSTATUSRECALL = 'Recalled';
    public static final String APPROVALSTATUSAPPROVE = 'Approved';
    public static final String APPROVALSTATUSPENDING = 'Pending';
    public static final String STATUSINREVIEW = 'In Review';
    public static final String STATUSDRAFT = 'Draft';
    public static final String STATUSAPPROVED = 'Approved';
    public static final String STATUSBLOCKED = 'Blocked';
    public static final String STATUSREJECTED = 'Rejected';
    public static final String STATUSACCEPTED = 'Accepted';
    public static final String DOCUMENTSTATUS = 'Signed';
    public static final String STATUSPSOK = 'PS OK';
    public static final String STATUSPRESENTED = 'Presented';
    public static final String SALESPURPOSENEWCLI = '111';
    public static final String SALESPURPOSENEWBIZ = '121';
    public static final String SALESPURPOSEOPSAAS = '611';
    public static final String SALESPURPOSESAAS = '612';
    public static final String SALESPURPOSEOP = '613';
    public static final String SALESPURPOSEUPSELLONLY = '411';
    public static final String QUOORIGIN = 'Internal';
    public static final String QUOSTATUSNEW = 'New';
    public static final String QUOSUBJECT = 'Approval needed for Quote';
    public static final String QUOSTATUSASSIGNED  = 'New';
    public static final String QUOCURRENCY = 'EUR';
    public static final String QUOTECHTYPEFUNCTIONAL = 'Functional';
    public static final String QUOTECHTYPEINFRA = 'Infra';
    public static final String OPPSTAGECLOSEDWON  = 'Closed Won';
    public static final String OPPCONGCLOSINGYES  = 'Yes';
    
    //before Insert
    public static void ProcessBuilderInIt(List<SBQQ__Quote__c> listQuote){
        
        set<Id> setAccIds = new set<Id>();
        set<Id> setOppIds = new set<Id>();
        set<Id> setBillingAccIds = new set<Id>();//B-1829
        
        for(SBQQ__Quote__c q:listQuote){
            setAccIds.add(q.SBQQ__Account__c);
            setOppIds.add(q.SBQQ__Opportunity2__c);
            setBillingAccIds.add(q.Billing_Account__c);//B-1829
        }

        Map<Id,Account> mapBilliAcc = new Map<Id,Account>([SELECT Id,POMandatory__c,Invoice_City__c,Invoice_Company_Name__c,Invoice_Country__c,Name,Invoice_Postal_Code__c,Invoice_Street__c,
        BillingCity,BillingCountry,BillingPostalCode,BillingStreet,BillingState
        FROM Account 
        WHERE Id IN:setAccIds]);
        
        Map<Id,Account> mapAcc = new map<Id,Account>([SELECT Id,POMandatory__c,Invoice_City__c,Invoice_Company_Name__c,Invoice_Country__c,Name,Invoice_Postal_Code__c,Invoice_Street__c,
                                                      BillingCity,BillingCountry,BillingPostalCode,BillingStreet,BillingState
                                                      FROM Account 
                                                      WHERE Id IN:setAccIds]);
        
        Map<Id,Opportunity> mapOpp = new map<Id,Opportunity>([SELECT Id,Sales_Purpose__c, SubSalesPurpose__c, DirectIndirect__c,TECH_Has_a_CPQ_quote__c,ContractId_from_Zuora__c
                                                              FROM Opportunity 
                                                              WHERE Id IN:setOppIds]);
        
        
        for(SBQQ__Quote__c quo:listQuote){
            //B-1829
            if(quo.Billing_Account__c != null){
                quo.Invoice_City__c = mapBilliAcc.get(quo.Billing_Account__c).Invoice_City__c;
                quo.Invoice_Company_Name__c = mapBilliAcc.get(quo.Billing_Account__c).Invoice_Company_Name__c;
                quo.Invoice_Country__c = mapBilliAcc.get(quo.Billing_Account__c).Invoice_Country__c;
                quo.Invoice_Postal_Code__c = mapBilliAcc.get(quo.Billing_Account__c).Invoice_Postal_Code__c;
                quo.Invoice_Street__c = mapBilliAcc.get(quo.Billing_Account__c).Invoice_Street__c;
            }
            //End Of B-1829
            system.debug('quo ' + quo);
            if(quo.SBQQ__Account__c != null){
                quo.Billing_Account__c = mapAcc.get(quo.SBQQ__Account__c).Id;
                quo.EditLinesFieldSetName__c = EDITLINES;
                quo.Invoice_City__c = mapAcc.get(quo.SBQQ__Account__c).Invoice_City__c;
                quo.Invoice_Company_Name__c = mapAcc.get(quo.SBQQ__Account__c).Invoice_Company_Name__c;
                quo.Invoice_Country__c = mapAcc.get(quo.SBQQ__Account__c).Invoice_Country__c;
                quo.Invoice_Postal_Code__c = mapAcc.get(quo.SBQQ__Account__c).Invoice_Postal_Code__c;
                quo.Invoice_Street__c = mapAcc.get(quo.SBQQ__Account__c).Invoice_Street__c;
                quo.Ordering_Account_City__c = mapAcc.get(quo.SBQQ__Account__c).BillingCity;
                quo.Ordering_Account_Country__c = mapAcc.get(quo.SBQQ__Account__c).BillingCountry;
                quo.Ordering_Account_Name__c = mapAcc.get(quo.SBQQ__Account__c).Name;
                quo.OrderingAccountId__c = mapAcc.get(quo.SBQQ__Account__c).Id;
                quo.Ordering_Account_Postal_Code__c = mapAcc.get(quo.SBQQ__Account__c).BillingPostalCode;
                quo.Ordering_Account_Street__c = mapAcc.get(quo.SBQQ__Account__c).BillingStreet;
                //W-002243
                quo.Service_Delivery_Company_Name__c = mapAcc.get(quo.SBQQ__Account__c).Name;
                quo.Service_Delivery_Street__c =  mapAcc.get(quo.SBQQ__Account__c).BillingStreet;
                quo.Service_Delivery_City__c = mapAcc.get(quo.SBQQ__Account__c).BillingCity;
                quo.Service_Delivery_Postal_Code__c = mapAcc.get(quo.SBQQ__Account__c).BillingPostalCode;
                quo.Service_Delivery_Country__c = mapAcc.get(quo.SBQQ__Account__c).BillingCountry;
                quo.Service_Delivery_State__c = mapAcc.get(quo.SBQQ__Account__c).BillingState;
                //End W-002243
                quo.Payer_Account__c = mapAcc.get(quo.SBQQ__Account__c).Id;
                quo.Payer_City__c = mapAcc.get(quo.SBQQ__Account__c).BillingCity;
                quo.Payer_Country__c = mapAcc.get(quo.SBQQ__Account__c).BillingCountry;
                quo.Payer_Name__c = mapAcc.get(quo.SBQQ__Account__c).Name;
                quo.Payer_Postal_Code__c = mapAcc.get(quo.SBQQ__Account__c).BillingPostalCode;
                quo.Payer_Street__c = mapAcc.get(quo.SBQQ__Account__c).BillingStreet;
                quo.SBQQ__BillingCity__c = mapAcc.get(quo.SBQQ__Account__c).BillingCity;
                quo.SBQQ__BillingCountry__c = mapAcc.get(quo.SBQQ__Account__c).BillingCountry;
                quo.SBQQ__BillingName__c = mapAcc.get(quo.SBQQ__Account__c).Name;
                quo.SBQQ__BillingPostalCode__c = mapAcc.get(quo.SBQQ__Account__c).BillingPostalCode;
                quo.SBQQ__BillingStreet__c = mapAcc.get(quo.SBQQ__Account__c).BillingStreet;
                quo.SBQQ__ShippingCity__c = mapAcc.get(quo.SBQQ__Account__c).BillingCity;
                quo.SBQQ__ShippingCountry__c = mapAcc.get(quo.SBQQ__Account__c).BillingCountry;
                quo.SBQQ__ShippingName__c = mapAcc.get(quo.SBQQ__Account__c).Name;
                quo.SBQQ__ShippingPostalCode__c =  mapAcc.get(quo.SBQQ__Account__c).BillingPostalCode;
                quo.SBQQ__ShippingStreet__c = mapAcc.get(quo.SBQQ__Account__c).BillingStreet;
                quo.SBQQ__WatermarkShown__c = true;
                quo.Shipping_Account__c = mapAcc.get(quo.SBQQ__Account__c).Id;
                //Ajout service delivery
                quo.Service_Delivery_Company_Name__c = mapAcc.get(quo.SBQQ__Account__c).Name; 
                quo.Service_Delivery_Street__c = mapAcc.get(quo.SBQQ__Account__c).BillingStreet;
                quo.Service_Delivery_City__c = mapAcc.get(quo.SBQQ__Account__c).BillingCity;
                quo.Service_Delivery_Postal_Code__c = mapAcc.get(quo.SBQQ__Account__c).BillingPostalCode;
                quo.Service_Delivery_Country__c = mapAcc.get(quo.SBQQ__Account__c).BillingCountry;
                
                //Asked By AC 3/23/2021
                if(mapAcc.get(quo.SBQQ__Account__c).POMandatory__c == 'Yes'){
                    quo.POMandatoryTemp__c = 'Oui';
                }else if(mapAcc.get(quo.SBQQ__Account__c).POMandatory__c == 'No'){
                    quo.POMandatoryTemp__c = 'Non';
                }
            }
            
            if(quo.SBQQ__Opportunity2__c != null){
                quo.Sale_Purpose__c = mapOpp.get(quo.SBQQ__Opportunity2__c).Sales_Purpose__c;
                quo.SubSalesPurpose__c = mapOpp.get(quo.SBQQ__Opportunity2__c).SubSalesPurpose__c;
                quo.DirectIndirect__c =  mapOpp.get(quo.SBQQ__Opportunity2__c).DirectIndirect__c;
            }
            
        }
    }
    
    //before Insert
    public static void ProcessBuilderInItNoPriceBook(List<SBQQ__Quote__c> listQuote){
        system.debug('ProcessBuilderInItNoPriceBook');
        for(SBQQ__Quote__c quo:listQuote){
            if(quo.SBQQ__PriceBook__c == null){
                quo.Extension_Mode__c = null;
                quo.Payment_Date_Calculation_Method__c = null;
                quo.Payment_Method__c = null;
                quo.Renewal_Mode__c = null;
            }
        }
    }
    
    
    //after Insert
    public static void ProcessBuilderOpportunityQuote(Set<Id> setOppIds){
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        
        for(Opportunity opp:[SELECT Id, name,TECH_Has_a_CPQ_quote__c FROM Opportunity WHERE id IN:setOppIds AND TECH_Has_a_CPQ_quote__c = false]){
            opp.TECH_Has_a_CPQ_quote__c = true;
            listOppToUpdate.add(opp);
        }
        
        if(listOppToUpdate.size()>0){
            update listOppToUpdate;
        }
    }
    
    //Before Update
    public static void ProcessBuilderPOModified(List<SBQQ__Quote__c> listQuote, Map<Id, SBQQ__Quote__c> mapOldQuote ,Boolean isNew){
        
        system.debug('ProcessBuilderPOModified');
        set<Id> setBillingAccountIds = new set<Id>();
        set<Id> setContractIds = new set<Id>();
        set<Id> setShippingAccount = new set<Id>();
        set<Id> setPrimaryContact = new set<Id>();
        set<Id> setOppIds = new set<Id>(); 
        set<Id> setAccountIds = new set<Id>();
        set<Id> setPayerIds = new set<Id>();
        set<Id> setOppIdsToUpdate = new set<Id>(); 
        
        string username = userinfo.getUserName();
        system.debug('username : ' + username);
        
        for(SBQQ__Quote__c q:listQuote){
            setBillingAccountIds.add(q.Billing_Account__c);
            setContractIds.add(q.SBQQ__MasterContract__c);
            setShippingAccount.add(q.Shipping_Account__c);
            setPrimaryContact.add(q.SBQQ__PrimaryContact__c);
            setOppIds.add(q.SBQQ__Opportunity2__c);
            setAccountIds.add(q.SBQQ__Account__c);
            setPayerIds.add(q.Payer_Account__c);
        }
        
        Map<Id,Opportunity> mapOpp = new map<Id,Opportunity>([SELECT Id,Partner_Distributor__c,Partner_Distributor__r.BillingCity,Partner_Distributor__r.BillingCountry,Partner_Distributor__r.Name,
                                                              Partner_Distributor__r.BillingPostalCode,Partner_Distributor__r.BillingStreet
                                                              FROM Opportunity WHERE Id IN:setOppIds]);
        //B-2026 - Manage indirect opp
        for(Opportunity opp:mapOpp.values()){
            if(opp.Partner_Distributor__c != null){
                setBillingAccountIds.add(opp.Partner_Distributor__c);
            }
        }
        Map<Id,Account> mapAcc = new map<Id,Account>([SELECT Id,POMandatory__c,National_ID_Active__c,BillingCity,BillingCountry,Name,BillingPostalCode,BillingStreet,
        Invoice_City__c,Invoice_Company_Name__c,Invoice_Country__c,Invoice_Postal_Code__c,Invoice_Street__c,
        Administrative_Compliance__c,IntercommunityVATnumber__c,PO_Mandatory__c FROM Account WHERE Id IN:setBillingAccountIds OR Id IN:setPayerIds OR Id IN:setShippingAccount OR Id IN:setAccountIds]);
        
        Map<Id,Contract> mapContract = new map<Id,Contract>([SELECT Id,Bank_City__c,Bank_Name__c,AccountId,Account.BillingCity,Account.BillingCountry,Account.Name,Account.BillingPostalCode,Account.BillingStreet,
                                                             PaymentTerms__c,RUM__c,Billing_Account__c,Payment_Method__c,Payment_Term__c,Payment_Date__c,Billing_Frequency__c,Increase_Type__c,Increase_Mode__c,
                                                             Billing_Account__r.BillingCity,Billing_Account__r.BillingCountry,Billing_Account__r.Name,Billing_Account__r.BillingPostalCode,Billing_Account__r.BillingStreet
                                                             FROM Contract WHERE Id IN:setContractIds]);
        
        for(SBQQ__Quote__c quote:listQuote){
            SBQQ__Quote__c oldQuote = (mapOldQuote.containsKey(quote.Id)) ? mapOldQuote.get(quote.Id) : new SBQQ__Quote__c();
            Boolean isBillingAccChanged  = quote.Billing_Account__c  != oldQuote.Billing_Account__c;
            //Partner Quote
            if( quote.SBQQ__Opportunity2__c != null && mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__c != null && quote.SBQQ__Opportunity2__c != oldQuote.SBQQ__Opportunity2__c){
                //condition partner Quote to be added 
                quote.Billing_Account__c = mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__c;
                quote.Partner_Distributor__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__c;
                quote.Payer_Account__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__c;
                quote.Payer_City__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingCity;
                quote.Payer_Country__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingCountry;
                quote.Payer_Name__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.Name;
                quote.Payer_Postal_Code__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingPostalCode;
                quote.Payer_Street__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingStreet;
                quote.SBQQ__BillingCity__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingCity;
                quote.SBQQ__BillingCountry__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingCountry;
                quote.SBQQ__BillingName__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.Name;
                quote.SBQQ__BillingPostalCode__c =   mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingPostalCode;
                quote.SBQQ__BillingStreet__c =  mapOpp.get(quote.SBQQ__Opportunity2__c).Partner_Distributor__r.BillingStreet;
            }
            //B-1829
            if(quote.Billing_Account__c  != oldQuote.Billing_Account__c){
                quote.Invoice_City__c = mapAcc.get(quote.Billing_Account__c).Invoice_City__c;
                quote.Invoice_Company_Name__c = mapAcc.get(quote.Billing_Account__c).Invoice_Company_Name__c;
                quote.Invoice_Country__c = mapAcc.get(quote.Billing_Account__c).Invoice_Country__c;
                quote.Invoice_Postal_Code__c = mapAcc.get(quote.Billing_Account__c).Invoice_Postal_Code__c;
                quote.Invoice_Street__c = mapAcc.get(quote.Billing_Account__c).Invoice_Street__c;
            }
            //End Of B-1829
            
            //PO Modified and <> PO Temp
            if(quote.purchase_Order__c  != oldQuote.purchase_Order__c &&  quote.purchase_Order__c != quote.Purchase_Order_Temp__c ){
                quote.Purchase_Order_Temp__c = quote.purchase_Order__c;
            }
            
            //Ordering Account modified
            if(isNew == false && quote.SBQQ__Account__c  != oldQuote.SBQQ__Account__c && quote.SBQQ__Account__c != null ){
                quote.Ordering_Account_City__c = mapAcc.get(quote.SBQQ__Account__c).BillingCity;
                quote.Ordering_Account_Country__c = mapAcc.get(quote.SBQQ__Account__c).BillingCountry;
                quote.Ordering_Account_Name__c = mapAcc.get(quote.SBQQ__Account__c).Name;
                quote.OrderingAccountID__c = mapAcc.get(quote.SBQQ__Account__c).Id;  
                quote.Ordering_Account_Postal_Code__c = mapAcc.get(quote.SBQQ__Account__c).BillingPostalCode;
                quote.Ordering_Account_Street__c = mapAcc.get(quote.SBQQ__Account__c).BillingStreet;
                //Ajout Service Delivery
                quote.Service_Delivery_Company_Name__c = mapAcc.get(quote.SBQQ__Account__c).Name; 
                quote.Service_Delivery_Street__c = mapAcc.get(quote.SBQQ__Account__c).BillingStreet;
                quote.Service_Delivery_City__c = mapAcc.get(quote.SBQQ__Account__c).BillingCity;
                quote.Service_Delivery_Postal_Code__c = mapAcc.get(quote.SBQQ__Account__c).BillingPostalCode;
                quote.Service_Delivery_Country__c = mapAcc.get(quote.SBQQ__Account__c).BillingCountry;
            }
            
            //Billing Account modified
            system.debug('Billing acc' + quote.Billing_Account__c);
            system.debug('Billing acc1' + oldQuote.Billing_Account__c);
            
            if(isNew == false && quote.Billing_Account__c  != oldQuote.Billing_Account__c && quote.Billing_Account__c != null){
                system.debug('Billing acc');
                quote.Payer_Account__c = mapAcc.get(quote.Billing_Account__c).Id; 
                quote.Payer_City__c = mapAcc.get(quote.Billing_Account__c).BillingCity;
                quote.Payer_Country__c =mapAcc.get(quote.Billing_Account__c).BillingCountry;
                quote.Payer_Name__c = mapAcc.get(quote.Billing_Account__c).Name;
                quote.Payer_Postal_Code__c = mapAcc.get(quote.Billing_Account__c).BillingPostalCode;
                quote.Payer_Street__c = mapAcc.get(quote.Billing_Account__c).BillingStreet;
                quote.SBQQ__BillingCity__c = mapAcc.get(quote.Billing_Account__c).BillingCity;
                quote.SBQQ__BillingCountry__c = mapAcc.get(quote.Billing_Account__c).BillingCountry;
                quote.SBQQ__BillingName__c =mapAcc.get(quote.Billing_Account__c).Name;
                quote.SBQQ__BillingPostalCode__c = mapAcc.get(quote.Billing_Account__c).BillingPostalCode;
                quote.SBQQ__BillingStreet__c = mapAcc.get(quote.Billing_Account__c).BillingStreet;
                quote.Tech_BillingHasNationalIDActive__c = mapAcc.get(quote.Billing_Account__c).National_ID_Active__c;
                quote.Tech_BillingHasVATNumber__c = String.isNotBlank( mapAcc.get(quote.Billing_Account__c).IntercommunityVATnumber__c);
                //Asked By AC 3/23/2021
                if(mapAcc.get(quote.Billing_Account__c).POMandatory__c == 'Yes'){
                    quote.POMandatoryTemp__c = 'Oui';
                }else if(mapAcc.get(quote.Billing_Account__c).POMandatory__c == 'No'){
                    quote.POMandatoryTemp__c = 'Non';
                }
                
            }
            
            //Shipping Account modified
            if(isNew == false && quote.Shipping_Account__c != oldQuote.Shipping_Account__c && quote.Shipping_Account__c != null){
                system.debug('Shipping Account modified');
                quote.SBQQ__ShippingCity__c = mapAcc.get(quote.Shipping_Account__c).BillingCity;
                quote.SBQQ__ShippingCountry__c =  mapAcc.get(quote.Shipping_Account__c).BillingCountry;
                quote.SBQQ__ShippingName__c =  mapAcc.get(quote.Shipping_Account__c).Name;
                quote.SBQQ__ShippingPostalCode__c =  mapAcc.get(quote.Shipping_Account__c).BillingPostalCode;
                quote.SBQQ__ShippingStreet__c =  mapAcc.get(quote.Shipping_Account__c).BillingStreet;
            }
            
            //Payer Account modified
            if(isNew == false && quote.Payer_Account__c != oldQuote.Payer_Account__c && quote.Payer_Account__c != null  && quote.Payer_Account__c != quote.Billing_Account__c ){
                system.debug('Payer Account modified');
                quote.Payer_City__c = mapAcc.get(quote.Payer_Account__c).BillingCity;
                quote.Payer_Country__c = mapAcc.get(quote.Payer_Account__c).BillingCountry;
                quote.Payer_Name__c = mapAcc.get(quote.Payer_Account__c).Name;
                quote.Payer_Postal_Code__c = mapAcc.get(quote.Payer_Account__c).BillingPostalCode;
                quote.Payer_Street__c = mapAcc.get(quote.Payer_Account__c).BillingStreet;
            }
            
            
            //If a Quote Document is signed
            //W-001955
            if(quote.SBQQ__DocumentStatus__c == DOCUMENTSTATUS && 
               (quote.Is_RedBlack_Cust__c == false || quote.Tech_CollectionStatus_Approved__c == true) && mapAcc.get(quote.Billing_Account__c).Administrative_Compliance__c == true && mapAcc.get(quote.SBQQ__Account__c).Administrative_Compliance__c == true){
                   
                   system.debug('Start - If a Quote doc is signed');
                   Id QuoteRTID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Locked_Quote').getRecordTypeId();
                   quote.RecordTypeId  = QuoteRTID; 
                   quote.SBQQ__Status__c = STATUSACCEPTED;
                   quote.SBQQ__Ordered__c = true;
                   
                   setOppIdsToUpdate.add(quote.SBQQ__Opportunity2__c);
                   //
                   
                   system.debug('End - If a Quote doc is signed');
                   List<Opportunity> listOpptoClose = [SELECT Id,StageName,TECH_CPQ_Validation__c,Confirmation_of_opportunity_closing__c
                                                       FROM Opportunity WHERE Id IN:setOppIds];
                   
                   List<Opportunity> listOpptoCloseFinal = new List<Opportunity>();
                   
                   for(Opportunity opptoUpdate: listOpptoClose){                
                       opptoUpdate.StageName = OPPSTAGECLOSEDWON;
                       opptoUpdate.TECH_CPQ_Validation__c = true;
                       opptoUpdate.Confirmation_of_opportunity_closing__c = OPPCONGCLOSINGYES;
                       listOpptoCloseFinal.add(opptoUpdate);
                   }
                   
                   if (listOpptoCloseFinal != null){ 
                       system.debug('update opp finally');
                       update listOpptoCloseFinal;
                   }            
                   system.debug('End - Opp Update - Closed Won');
               }
            
            //If a Quote is signed with missing info
            //W-001955
            if(quote.SBQQ__DocumentStatus__c == DOCUMENTSTATUS && (mapAcc.get(quote.Billing_Account__c).Administrative_Compliance__c == false || mapAcc.get(quote.SBQQ__Account__c).Administrative_Compliance__c == false) 
               && quote.SBQQ__Status__c == STATUSPRESENTED){
                   quote.SBQQ__Status__c = STATUSBLOCKED;
               }
            
            //Copy non-encrypted temp fields
            if(quote.Purchase_Order_Temp__c != null && quote.purchase_Order__c != quote.Purchase_Order_Temp__c || quote.New_Bank_City_Temp__c != null || quote.New_Bank_Name_Temp__c != null){
                quote.Bank_City__c = (quote.New_Bank_City__c !=null)?quote.New_Bank_City__c:quote.New_Bank_City_Temp__c;
                quote.Bank_Name__c = (quote.New_Bank_Name__c !=null)?quote.New_Bank_Name__c:quote.New_Bank_Name_Temp__c;
                quote.Purchase_Order__c = (quote.Purchase_Order_Temp__c !=null)?quote.Purchase_Order_Temp__c:quote.purchase_Order__c;
            }
            
            //If a Quote is signed with RB Coll Status
            if(quote.Is_RedBlack_Cust__c == true && quote.Tech_CollectionStatus_Approved__c == false && quote.SBQQ__DocumentStatus__c == DOCUMENTSTATUS){
                Id QuoteRTID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Locked_Quote').getRecordTypeId();
                quote.RecordTypeId  = QuoteRTID; 
                quote.SBQQ__Status__c = STATUSBLOCKED;
            }
            
            //set email field validator
            quote.Email_Field_validator_lv_3__c = quote.Email_validator_lv_3__c;

            //UPSELL - traitement de l'en tête de devis
            if(quote.Sale_Purpose__c != SALESPURPOSENEWCLI && 
               quote.Sale_Purpose__c != SALESPURPOSENEWBIZ && 
               quote.Sale_Purpose__c != SALESPURPOSEOPSAAS &&
               quote.Sale_Purpose__c != SALESPURPOSESAAS &&
               quote.Sale_Purpose__c != SALESPURPOSEOP &&
               quote.SBQQ__MasterContract__c != null && 
               quote.SBQQ__MasterContract__c != oldQuote.SBQQ__MasterContract__c){
                quote.Bank_City__c = mapContract.get(quote.SBQQ__MasterContract__c).Bank_City__c;
                quote.Bank_Name__c =  mapContract.get(quote.SBQQ__MasterContract__c).Bank_Name__c;
                quote.Billing_Account__c = mapContract.get(quote.SBQQ__MasterContract__c).Billing_Account__c;
                quote.SBQQ__BillingCity__c =  mapContract.get(quote.SBQQ__MasterContract__c).Billing_Account__r.BillingCity;
                quote.SBQQ__BillingCountry__c =  mapContract.get(quote.SBQQ__MasterContract__c).Billing_Account__r.BillingCountry;
                quote.SBQQ__BillingName__c =  mapContract.get(quote.SBQQ__MasterContract__c).Billing_Account__r.Name;
                quote.SBQQ__BillingPostalCode__c =  mapContract.get(quote.SBQQ__MasterContract__c).Billing_Account__r.BillingPostalCode;
                quote.SBQQ__BillingStreet__c =  mapContract.get(quote.SBQQ__MasterContract__c).Billing_Account__r.BillingStreet;
                quote.Payment_Method__c = mapContract.get(quote.SBQQ__MasterContract__c).Payment_Method__c;
                quote.Payment_Term__c = mapContract.get(quote.SBQQ__MasterContract__c).Payment_Term__c;
                quote.Payment_Date__c = mapContract.get(quote.SBQQ__MasterContract__c).Payment_Date__c;
                quote.OriginalPaymentTerms__c =  mapContract.get(quote.SBQQ__MasterContract__c).Payment_Term__c;
                quote.OriginalPayment_Date__c =  mapContract.get(quote.SBQQ__MasterContract__c).Payment_Date__c;
                quote.OriginalPayment_Method__c =  mapContract.get(quote.SBQQ__MasterContract__c).Payment_Method__c;
                quote.Billing_Frequency__c = mapContract.get(quote.SBQQ__MasterContract__c).Billing_Frequency__c;
                quote.UMR__c =  mapContract.get(quote.SBQQ__MasterContract__c).RUM__c;
                quote.Increase_Mode__c = mapContract.get(quote.SBQQ__MasterContract__c).Increase_Mode__c;
                quote.Increase_Type__c = mapContract.get(quote.SBQQ__MasterContract__c).Increase_Type__c;
            }
            
        }
        
        
        
        
    }
    
    
    public static void createChatterAndCase(List<SBQQ__Quote__c> listQuote){
        system.debug('createChatterAndCase');
        list<case> cas = new list<case>();
        set<Id> setAccIds = new set<Id>();
        List<FeedItem> listFeedItems = new list<FeedItem>();
        
        for(SBQQ__Quote__c q:listQuote){
            setAccIds.add(q.Billing_Account__c);
        }
        
        Map<Id,Account> mapAcc = new map<Id,Account>([SELECT Id, Administrative_Compliance__c FROM Account WHERE Id IN:setAccIds]);
        
        for(SBQQ__Quote__c quo:listQuote){
            if(quo.Is_RedBlack_Cust__c == true && quo.Tech_CollectionStatus_Approved__c == true && quo.SBQQ__DocumentStatus__c == DOCUMENTSTATUS){
                case c = new case();
                Id QuoteRTID = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Quote_Approval_Request').getRecordTypeId();
                c.CurrencyIsoCode = quo.CurrencyIsoCode;
                c.Origin = QUOORIGIN;
                c.Quote__c = quo.Id;
                c.RecordTypeId  = QuoteRTID;
                c.Status = QUOSTATUSNEW;
                c.Subject = QUOSUBJECT;
                cas.add(c);
            }
            //If a Quote is signed with missing info chatter
            // if(quo.SBQQ__DocumentStatus__c == DOCUMENTSTATUS && mapAcc.get(quo.Billing_Account__c).Administrative_Compliance__c == false && quo.SBQQ__Status__c == STATUSPRESENTED){
            //     FeedItem post = new FeedItem();
            //     post.ParentId = quo.Id; 
            //     post.Body = 'Enter post text here';
            //     listFeedItems.add(post);
            // }
        }
        
        if(cas.size()>0){
            insert cas;
        }
        
        // if(listFeedItems.size()>0){
        //     insert listFeedItems;
        // }
    }
    
    // //Managed through the flow: Quote - Init RCC
    // public static void quoteInitRcc(List<SBQQ__Quote__c> listQuote){
    //     system.debug('quoteInitRcc : ');
    //     Set<String> setTeamLeader = new set<String>();
    //     Set<String> setRccValidator = new set<String>();
    //     Set<Id> setSalesRep = new set<Id>();
    //     //List<SBQQ__Quote__c> listQUoteToUpdate = new List<SBQQ__Quote__c>();
    //     List<UserTerritory2Association> listUTA = new List<UserTerritory2Association>();
    //     //List<Territory2> listTerritory = new List<Territory2>();
    //     List<Special_Assignment__c> listSpecialAssignment = new List<Special_Assignment__c>();
        
        
    //     for(SBQQ__Quote__c q:listQuote){
    //         setTeamLeader.add(q.RCC_Team_Leader__c);
    //         setRccValidator.add(q.RCC_Validator__c);
    //         setSalesRep.add(q.SBQQ__SalesRep__c);
    //     }
        
    //     listUTA = [SELECT Id,isActive,Territory2Id,UserId,RoleInTerritory2, Territory2.Agency__c, Territory2.BU__c
    //                FROM UserTerritory2Association 
    //                WHERE UserId IN:setSalesRep AND isActive = true limit 1];
        
    //     /*if(listUTA.size()>0){
    //         listTerritory= [SELECT Id, Agency__c, BU__c 
    //                         FROM Territory2 WHERE Id =: listUTA[0].Territory2Id limit 1];
    //     }*/
        
    //     if(listUTA.size()>0 && listUTA[0].Territory2Id != null){
    //         listSpecialAssignment = [SELECT Id,Agency__c, BU__c,RCC_Team_Leader__c,RCC_User__c  
    //                                  FROM Special_Assignment__c WHERE  Agency__c =: listUTA[0].Territory2.Agency__c AND BU__c =: listUTA[0].Territory2.BU__c limit 1 ];
    //     }
        
        
        
        
    //     for(SBQQ__Quote__c quo:listQuote){
    //         if(listUTA.size()>0 && listSpecialAssignment.size()>0){
    //             if(listSpecialAssignment[0].RCC_User__c != null){
    //                 quo.RCC_Validator__c = listSpecialAssignment[0].RCC_User__c;
    //                 quo.RCC_Team_Leader__c = listSpecialAssignment[0].RCC_Team_Leader__c;
    //             }else if(listSpecialAssignment[0].Agency__c == listUTA[0].Territory2.Agency__c){
    //                 if(listSpecialAssignment[0].RCC_User__c != null){
    //                     quo.RCC_Validator__c = listSpecialAssignment[0].RCC_User__c;
    //                     quo.RCC_Team_Leader__c = listSpecialAssignment[0].RCC_Team_Leader__c;
    //                 }
    //             }
    //             //listQUoteToUpdate.add(quo);
    //         }
            
    //     }
        
    //     //update listQUoteToUpdate;
        
        
    // }
    
    
    public static void quoteFlowBilling(List<SBQQ__Quote__c> listQuote){
        system.debug('quoteFlowBilling');
        set<Id> setBillingAccount = new set<Id>();
        
        for(SBQQ__Quote__c q:listQuote){
            setBillingAccount.add(q.Billing_Account__c);
        }
        
        List<AccountContactRelation> listAccountContactRelation = [SELECT Id ,AccountId, Contact.CreatedDate, Contact.Email,Contact.FirstName,Contact.LastName,Contact.Salutation,Contact.Phone,Contact.MobilePhone 
                                                                   FROM AccountContactRelation
                                                                   WHERE
                                                                   AccountId IN:setBillingAccount AND Contact.HasCegidRoleContactPayment__c = True ORDER BY Contact.CreatedDate DESC  LIMIT 1 ];
        
        for(SBQQ__Quote__c q:listQuote){
            if(listAccountContactRelation.size()>0){
                q.BillingContactEmail__c = listAccountContactRelation[0].Contact.Email;
                q.BillingContactFirstName__c = listAccountContactRelation[0].Contact.FirstName;
                q.BillingContactLastName__c = listAccountContactRelation[0].Contact.LastName;
                q.BillingContactSalutation__c = listAccountContactRelation[0].Contact.Salutation;
                q.BillingContactPhone__c = listAccountContactRelation[0].Contact.Phone;
                q.BillingContactMobilePhone__c =  listAccountContactRelation[0].Contact.MobilePhone;
            }else {
                q.BillingContactEmail__c = null;
                q.BillingContactFirstName__c = null;
                q.BillingContactLastName__c = null;
                q.BillingContactSalutation__c = null;
                q.BillingContactPhone__c = null;
                q.BillingContactMobilePhone__c = null;
            }
        }
    }
    
    // //Flow Create Case PS
    public static void createCasePS(List<SBQQ__Quote__c> listQuote,Map<Id, SBQQ__Quote__c> mapOldQuote ){
        system.debug('createCasePS');
        
        set<Id> setQuoteIds = new set<Id>();
        set<Id> setSalesRepIds = new set<Id>();
        set<String> setExpertise = new set<String>();
        set<String> setExpertiseInfra = new set<String>();
        list<Case> listCasToInsert = new list<case>();
        
        //B-1923
        map<Id,Integer> mapOpenCasesPs = new map<Id,Integer>();
        List<SBQQ__Quote__c> lstQuotetoUpdate = new List<SBQQ__Quote__c>();
        
        map<String, String> mapExpertise = new map<String, String>();
        mapExpertise.put(null, '');
        mapExpertise.put('', '');
        String transco = Label.CreatecasePSExpertise;
        for(String s : transco.split(';')){
            List<String> transcoList = s.split('=');
            string key = (transcoList.size() == 2) ? transcoList[0] : '';
            string val = (transcoList.size() == 2) ? transcoList[1] : '';
            mapExpertise.put(key, val);
        }
        
        
        map<String, String> mapExpertiseInfra = new map<String, String>();
        mapExpertiseInfra.put(null, '');
        mapExpertiseInfra.put('', '');
        String transcov1 = Label.CreateQueueInfra;
        for(String s : transcov1.split(';')){
            List<String> transcoList = s.split('=');
            string key = (transcoList.size() == 2) ? transcoList[0] : '';
            string val = (transcoList.size() == 2) ? transcoList[1] : '';
            mapExpertiseInfra.put(key, val);
        }
        
        
        for(SBQQ__Quote__c quo:listQuote){
            setQuoteIds.add(quo.Id);
            setSalesRepIds.add(quo.SBQQ__SalesRep__c);
            setExpertise.add('%' + mapExpertise.get(quo.Expertise__c)+ '%');
            setExpertiseInfra.add('%' + mapExpertiseInfra.get(quo.Expertise__c)+ '%');
        }
        
        
        list<Group> listGroup = [SELECT Id, Type,Name FROM Group  WHERE Name LIKE:setExpertise AND  Type = 'Queue' LIMIT 1];
        list<Group> listGroupInfra = [SELECT Id, Type,Name FROM Group  WHERE Name LIKE:setExpertiseInfra AND  Type = 'Queue' LIMIT 1];
        list<Group> listGroupBillingPlan = [SELECT Id, Type,Name FROM Group  WHERE developerName = 'PS_Functional_CPA_Queue_Group' AND  Type = 'Queue' LIMIT 1];
        Map<Id,User> mapSalesRep = new Map<Id,User>([SELECT Id, Profile.Name, ProfileId, Name FROM User  WHERE Id IN :setSalesRepIds]);
        system.debug('listGroup : ' + listGroup.size());
        system.debug('listGroupInfra : ' + listGroupInfra.size());
        string username = userinfo.getUserName();
        system.debug('username : '  + username);
        
        //11032021 ACO, comment : if(username.contains('mulesoftprd')){
        for(SBQQ__Quote__c quo:listQuote){
            //SBQQ__Quote__c oldQuote = (mapOldQuote.containsKey(quo.Id)) ? mapOldQuote.get(quo.Id) : new SBQQ__Quote__c();
            //if(quo.SBQQ__Status__c == PENDINGPS && quo.SBQQ__Status__c != oldQuote.SBQQ__Status__c ){
            Id QuoteRTID = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('Professional_Services_Request').getRecordTypeId();
            Integer countOpenCasesPs = 0;
            if(quo.Functional_Product__c > 0 && listGroup.size()>0){
                case c = new case();
                c.CurrencyIsoCode= QUOCURRENCY;
                c.Origin= QUOORIGIN;
                c.OwnerId=listGroup[0].Id;
                c.Quote__c=quo.Id;
                c.RecordTypeId=QuoteRTID;
                c.Status=QUOSTATUSASSIGNED;
                c.Subject=listGroup[0].Name;
                c.TECH_type__c= QUOTECHTYPEFUNCTIONAL;
                
                listCasToInsert.add(c);
                countOpenCasesPs = countOpenCasesPs + 1;
            }
            // W-002548 > approval for the billing plan added
            if((quo.Infra_Product__c > 0 || (quo.BillingPlan__c && (quo.SBQQ__SalesRep__c == null || (mapSalesRep.containsKey(quo.SBQQ__SalesRep__c) && mapSalesRep.get(quo.SBQQ__SalesRep__c).ProfileId != '00e7S0000015xGXQAY')))) 
               && listGroupInfra.size()>0){
                   case c = new case();
                   c.CurrencyIsoCode= QUOCURRENCY;
                   c.Origin= QUOORIGIN;
                   c.OwnerId=listGroupInfra[0].Id;
                   c.Quote__c=quo.Id;
                   c.RecordTypeId=QuoteRTID;
                   c.Status=QUOSTATUSASSIGNED;
                   c.Subject=listGroupInfra[0].Name;
                   if(quo.BillingPlan__c){
                       c.Description='The related quote has a billing plan to review.';
                   }
                   c.TECH_type__c= QUOTECHTYPEINFRA;
                   
                   listCasToInsert.add(c);
                   countOpenCasesPs = countOpenCasesPs + 1;
               }
            
            if(countOpenCasesPs > 0)
                mapOpenCasesPs.put(quo.Id,countOpenCasesPs);
            
            //}
        }
        system.debug('listCasToInsert : ' + listCasToInsert.size());
        if(listCasToInsert.size()>0){
            Insert listCasToInsert;
        }
        
        if(mapOpenCasesPs.size() > 0){
            for(Id quoteId : mapOpenCasesPs.keySet()){
                SBQQ__Quote__c quote = new SBQQ__Quote__c(Id=quoteId,Open_PS_Cases__c = mapOpenCasesPs.get(quoteId));
                lstQuotetoUpdate.add(quote);
            }
        }
        
        if(lstQuotetoUpdate.size() > 0)
            update lstQuotetoUpdate;
        
    }
    
    //Flow
    public static void qualificationQuoteCreation(Set<Id> quoteIds){ 
        system.debug('qualificationQuoteCreation');
        
        
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

    //B-1835
    //Une fois que le statut du Quote est passé à "Accepted", 
    //Si le champ Email e-billing" du Quote est non-vide, 
    //le copier dans le champ Email e-billing du Compte (SBQQ__Account__c) du Quote ; 
    //et insérer la valeur "Email" dans le champ Invoice_Sending_Mode__c. 
    public static void setAccountEbilling(List<SBQQ__Quote__c> listQuote){
        set<Id> setAccountIds = new set<Id>();
        map<Id,SBQQ__Quote__c> mapQuote= new map<Id,SBQQ__Quote__c>();
        list<Account> listAccTobeUpdated = new List<Account>();

        for(SBQQ__Quote__c quo:listQuote){
            setAccountIds.add(quo.Billing_Account__c);
            mapQuote.put(quo.Billing_Account__c,quo);
        }

        for(Account acc:[SELECT Id,Email_e_Billing__c,Invoice_Sending_Mode__c FROM Account WHERE Id IN:setAccountIds]){
            acc.Email_e_Billing__c = mapQuote.get(acc.Id).Email_e_Billing__c;
            acc.Invoice_Sending_Mode__c = 'Email';
            listAccTobeUpdated.add(acc);
        }

        if(listAccTobeUpdated.size()>0){
            update listAccTobeUpdated;
        }
    }
    
    
}