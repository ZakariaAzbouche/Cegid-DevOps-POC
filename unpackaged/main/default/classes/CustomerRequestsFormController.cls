/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * created on  : 28/04/2022
**/

public with sharing class CustomerRequestsFormController {

    public static String getToken(){
        try{
            Map <string,object> mapToken = new Map<string,object>();
            HttpRequest request = new HttpRequest();     
            request.setEndpoint(Customer_Requests_API_Properties__c.getValues('Access_Token_Endpoint').Value__c + '?client_id=' + Customer_Requests_API_Properties__c.getValues('Client_Id').Value__c + '&client_secret=' + Customer_Requests_API_Properties__c.getValues('Client_Secret').Value__c + '&grant_type=client_credentials&scope=READ');
            request.setMethod('POST');            
            Http http = new Http();
            HttpResponse response = http.send(request);
            mapToken = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String token = string.valueof(mapToken.get('access_token'));
            return token;
        } catch(Exception e){
            System.debug('Error from getToken Method' + e.getMessage());    
            return 'ERROR'; 
        } 
    }

    @AuraEnabled
    public static List<lineWrapper> getInvoiceLinesData(String erpNumber, String domain, String origin, String businessUnitExternalId, String currencyIsoCode, String contractNumber, String invoiceNumber, String minAmount, String maxAmount, String minDate, String maxDate, String tierslivre, String offset){
        try{
            List<lineWrapper> invoicesItems = new List<lineWrapper>();
            Map<String, Object> invoiceMap = new Map<String, Object>();    
            Map<String, List<Object>> invoicesMap = new Map<String, List<Object>>();    
            Map<String, Object> invoiceLineMap = new Map<String, Object>();  
            Decimal totalAmount = 0;
            String token = getToken();  
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(100000);
            String endPoint = Customer_Requests_API_Properties__c.getValues('InvoiceLines_Endpoint').Value__c + '?erpNumber=' + erpNumber + '&currency=' + currencyIsoCode + '&domain=' + domain + '&origin=' + origin;
            if(String.isNotBlank(businessUnitExternalId)){
                endPoint += '&calculatedBu=' + businessUnitExternalId;
            } else {
                endPoint += '&calculatedBu=';
            }
            if(String.isNotBlank(contractNumber)){
                endPoint += '&contractNumber=' + contractNumber;
            }
            if(String.isNotBlank(invoiceNumber)){
                endPoint += '&invoiceNumber=' + invoiceNumber;
            }
            if(String.isNotBlank(minAmount)){
                endPoint += '&minAmount=' + minAmount;
            }
            if(String.isNotBlank(maxAmount)){
                endPoint += '&maxAmount=' + maxAmount;
            }
            if(String.isNotBlank(minDate)){
                endPoint += '&minDate=' + minDate;
            }
            if(String.isNotBlank(maxDate)){
                endPoint += '&maxDate=' + maxDate;
            }
            endPoint += '&offset=' + offset +'&limit=25';
            endPoint = endPoint.replace(' ','%20');
            System.debug('endPoint : ' + endPoint);
            request.setEndpoint(endPoint);  
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+token);
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==200){
                string invoices= response.getBody();
                if(invoices!=null){
                    invoiceMap = (Map<String, Object>)JSON.deserializeUntyped(invoices);
                    List<Object> invoiceLinesList = (List<Object>)invoiceMap.get('lines');  
                    if(invoiceLinesList != null && invoiceLinesList.size() > 0){
                        for(Object invoiceLine : invoiceLinesList){
                            invoiceLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine));
                            String tierslivreLower = (String.valueOf(invoiceLineMap.get('tierslivre'))).toLowercase();
                            if(tierslivre == '' || tierslivre == null || tierslivreLower.contains(tierslivre.toLowercase())){
                                if(invoicesMap.containsKey(String.valueOf(invoiceLineMap.get('invoiceNumber')))) {
                                    invoicesMap.get(String.valueOf(invoiceLineMap.get('invoiceNumber'))).add(invoiceLine);
                                } else {
                                    invoicesMap.put(String.valueOf(invoiceLineMap.get('invoiceNumber')), new List<Object> { invoiceLine });
                                }
                            }
                        }
                        for(String invoiceName: invoicesMap.keyset()){
                            lineWrapper invWrapper = new lineWrapper();
                            invWrapper.totalLines = String.valueOf(invoicesMap.get(invoiceName).size());
                            invWrapper.name = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoicesMap.get(invoiceName)[0]))).get('invoiceNumber'));
                            invWrapper.lineNumber = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoicesMap.get(invoiceName)[0]))).get('invoiceNumber'));
                            invWrapper.contractNumber = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoicesMap.get(invoiceName)[0]))).get('contractNumber'));
                            invWrapper.amount = null;
                            invWrapper.lineDate = null;
                            invWrapper.tierslivre = null;
                            List<Items> invItems = new List<Items>();   
                            for(Object invoiceLine : invoicesMap.get(invoiceName)){
                                totalAmount = totalAmount + Decimal.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('amount')));
                                Items invoiceLineWrapp = new Items();
                                invoiceLineWrapp.name = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('invoiceLineName')));
                                invoiceLineWrapp.lineName = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('invoiceNumber'))) + '-' + String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('invoiceLineName')));
                                invoiceLineWrapp.buOffer = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('buOffer')));
                                invoiceLineWrapp.calculatedBu = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('calculatedBu')));     
                                invoiceLineWrapp.loadName = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('chargeName')));                         
                                invoiceLineWrapp.lineNumber = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('invoiceNumber')));
                                invoiceLineWrapp.contractNumber = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('contractNumber')));
                                invoiceLineWrapp.amount = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('amount')));
                                invoiceLineWrapp.lineDate = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('date')).SubStringBefore('T'));
                                invoiceLineWrapp.startDate = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('serviceStartDate')).SubStringBefore('T'));
                                invoiceLineWrapp.endDate = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('serviceEndDate')).SubStringBefore('T'));
                                invoiceLineWrapp.tierslivre = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('tierslivre')));
                                invoiceLineWrapp.sectorAgency3Part = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('sectorAgency3Part')));
                                invoiceLineWrapp.domain = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('domain')));
                                invoiceLineWrapp.origin = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine))).get('origin')));   
                                invItems.add(invoiceLineWrapp);   
                            } 
                            invWrapper.items = invItems;
                            invWrapper.totalAmount = String.valueOf(totalAmount);
                            totalAmount = 0;
                            invoicesItems.add(invWrapper);                   
                        }
                        return invoicesItems ;
                    } else {
                        return new List<lineWrapper>();
                    }
                } else {
                    return new List<lineWrapper>();
                }
            } else {
                return new List<lineWrapper>();
            }
        } catch(Exception e){
            System.debug('Error from getInvoiceLinesData Method' + e.getMessage()); 
            List<lineWrapper> invoicesItemsError = new List<lineWrapper>(); 
            lineWrapper invWrapperError = new lineWrapper();
            invWrapperError.name = 'ERROR';
            invoicesItemsError.add(invWrapperError); 
            return invoicesItemsError;
        } 
    }

    @AuraEnabled
    public static List<lineWrapper> getSubscriptionLinesData(String erpNumber, String origin, String currencyIsoCode, String businessUnit, String offset){
        try{
            List<lineWrapper> subscriptionsItems = new List<lineWrapper>();
            Map<String, Object> subscriptionMap = new Map<String, Object>();
            Map<String, List<Object>> subscriptionsMap = new Map<String, List<Object>>();
            Map<String, Object> subscriptionLineMap = new Map<String, Object>();  
            Decimal totalAmount = 0;    
            String token = getToken();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(100000);
            String endPoint = Customer_Requests_API_Properties__c.getValues('Subscriptions_Endpoint').Value__c + '?erpNumber=' + erpNumber + '&origin=' + origin + '&currency=' + currencyIsoCode + '&offset=' + offset +'&limit=25';
            if(String.isNotBlank(businessUnit)){
                endPoint += '&calculatedBu=' + businessUnit;
            } else {
                endPoint += '&calculatedBu=';
            }
            System.debug('endPoint : ' + endPoint);
            request.setEndpoint(endPoint);                   
            request.setMethod('GET');
            request.setHeader('Authorization','Bearer '+token);
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==200){
                string subscriptions= response.getBody();
                if(subscriptions!=null){
                    subscriptionMap = (Map<String, Object>)JSON.deserializeUntyped(subscriptions);
                    List<Object> subscriptionLinesList = (List<Object>)subscriptionMap.get('lines');
                    if(subscriptionLinesList != null && subscriptionLinesList.size() > 0){
                        for(Object subscriptionLine : subscriptionLinesList){
                            subscriptionLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine));
                            if(subscriptionsMap.containsKey(String.valueOf(subscriptionLineMap.get('subscriptionNumber')))) {
                                subscriptionsMap.get(String.valueOf(subscriptionLineMap.get('subscriptionNumber'))).add(subscriptionLine);
                            } else {
                                subscriptionsMap.put(String.valueOf(subscriptionLineMap.get('subscriptionNumber')), new List<Object> { subscriptionLine });
                            }
                        }
                        for(String subscriptionName: subscriptionsMap.keyset()){
                            lineWrapper subWrapper = new lineWrapper() ;
                            subWrapper.totalLines = String.valueOf(subscriptionsMap.get(subscriptionName).size());
                            subWrapper.name = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionsMap.get(subscriptionName)[0]))).get('subscriptionNumber'));
                            subWrapper.lineNumber = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionsMap.get(subscriptionName)[0]))).get('subscriptionNumber'));
                            subWrapper.contractNumber = String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionsMap.get(subscriptionName)[0]))).get('contractNumber'));
                            subWrapper.amount = null;
                            subWrapper.lineDate = null;
                            subWrapper.nextDateRenewal = null;   
                            subWrapper.startDate = null;
                            subWrapper.tierslivre = null;
                            List<Items> invItems = new List<Items>(); 
                            for(Object subscriptionLine : subscriptionsMap.get(subscriptionName)){
                                totalAmount = totalAmount + Decimal.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('amount')));
                                Items subscriptionLineWrapp = new Items();
                                subscriptionLineWrapp.name = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('subscriptionLineName')));
                                subscriptionLineWrapp.lineName = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('subscriptionNumber'))) + String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('subscriptionLineName')));
                                subscriptionLineWrapp.buOffer = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('buOffer')));
                                subscriptionLineWrapp.calculatedBu = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('calculatedBu')));
                                subscriptionLineWrapp.loadName = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('chargeName')));
                                subscriptionLineWrapp.loadType = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('chargeType')));
                                subscriptionLineWrapp.lineNumber = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('subscriptionNumber')));
                                subscriptionLineWrapp.contractNumber = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('contractNumber')));
                                subscriptionLineWrapp.amount = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('amount')));
                                subscriptionLineWrapp.lineDate = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('contractEndDate'))).SubStringBefore('T');
                                subscriptionLineWrapp.nextDateRenewal = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('nextDateRenewal'))).SubStringBefore('T');
                                subscriptionLineWrapp.startDate = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('startDate'))).SubStringBefore('T');
                                subscriptionLineWrapp.tierslivre = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('tierslivre')));
                                subscriptionLineWrapp.unitPrice = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('unitPrice')));
                                subscriptionLineWrapp.quantity = String.valueOf(String.valueOf(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine))).get('quantity')));                               
                                invItems.add(subscriptionLineWrapp);                               
                            }
                            subWrapper.items = invItems;
                            subWrapper.totalAmount = String.valueOf(totalAmount);
                            totalAmount = 0;
                            subscriptionsItems.add(subWrapper); 
                        }
                        return subscriptionsItems ;

                    } else{
                        return new List<lineWrapper>();
                    }
                } else{
                    return new List<lineWrapper>();
                }
            } else {
                return new List<lineWrapper>();
            }
        } catch(Exception e){
            System.debug('Error from getSubscriptionLinesData Method' + e.getMessage()); 
            List<lineWrapper> subscriptionsItemsError = new List<lineWrapper>(); 
            lineWrapper subWrapperError = new lineWrapper();
            subWrapperError.name = 'ERROR';
            subscriptionsItemsError.add(subWrapperError); 
            return subscriptionsItemsError;
        } 
    }

    @AuraEnabled
    public static String saveLines(String customerRequestId, String lines, String objectName, String domainIndex){
        String result = 'ERROR';
        if(objectName == 'InvoiceLine'){
            result = saveInvoiceLines(customerRequestId, lines, domainIndex);
        } else{
            result = saveSubscriptionLines(customerRequestId, lines);
        }
        return result;
    }

    public static String saveInvoiceLines(String customerRequestId, String invoiceLines, String domainIndex){
        try{
            Id invoiceId;
            Invoice__c[] invoicesToSave = new Invoice__c[] {};
            InvoiceLine__c[] invoiceLinesToSave = new InvoiceLine__c[] {};
            Map<String, Object> invoiceLineMap = new Map<String, Object>();
            String invoiceNumbers = '';
            List<Object> invoiceLinesList = (List<Object>)JSON.deserializeUntyped(invoiceLines);  
            for(Object invoiceLine : invoiceLinesList){
                invoiceLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine));
                if(!invoiceNumbers.contains(String.valueOf(invoiceLineMap.get('lineNumber')))){
                    invoiceNumbers = invoiceNumbers + String.valueOf(invoiceLineMap.get('lineNumber')) + ' ';
                    Invoice__c invoice = new Invoice__c(
                        Name = String.valueOf(invoiceLineMap.get('lineNumber'))
                    );
                    invoicesToSave.add(invoice);
                }
            }
            insert(invoicesToSave);  
            for(Object invoiceLine : invoiceLinesList){
                invoiceLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine));
                for(Invoice__c savedInvoice : invoicesToSave){
                    if(savedInvoice.Name == String.valueOf(invoiceLineMap.get('lineNumber'))){
                        invoiceId = savedInvoice.Id;
                    }
                } 
                String lineName = String.valueOf(String.valueOf(invoiceLineMap.get('lineName')));
                invoiceLinesToSave.add(new InvoiceLine__c(
                    Name = lineName,
                    Line__c = lineName.substringAfter('-'),
                    Invoice__c = invoiceId,
                    CustomerRequest__c = customerRequestId,
                    StartDate__c = Date.valueOf(String.valueOf(invoiceLineMap.get('startDate'))),
                    EndDate__c = Date.valueOf(String.valueOf(invoiceLineMap.get('endDate'))),
                    Amount__c = Decimal.valueOf(String.valueOf(invoiceLineMap.get('amount'))),
                    CreditNoteAmount__c = Decimal.valueOf(String.valueOf(invoiceLineMap.get('amount'))),
                    AgencyCode__c = String.valueOf(String.valueOf(invoiceLineMap.get('sectorAgency3Part'))),
                    BusinessUnit__c = String.valueOf(String.valueOf(invoiceLineMap.get('buOffer'))),
                    //Domain__c = String.valueOf(String.valueOf(invoiceLineMap.get('domain'))),
                    StructureLevel1__c = domainIndex,
                    LoadName__c = String.valueOf(String.valueOf(invoiceLineMap.get('loadName'))),
                    Origin__c = String.valueOf(String.valueOf(invoiceLineMap.get('origin'))),
                    ContractNumber__c = String.valueOf(String.valueOf(invoiceLineMap.get('contractNumber'))),
                    ThirdPartyDelivered__c = String.valueOf(String.valueOf(invoiceLineMap.get('tierslivre')))
                ));
            }
            insert(invoiceLinesToSave);
            return 'Success';
        } catch(Exception e){
            System.debug('Error from saveInvoiceLines Method' + e.getMessage());    
            return 'ERROR'; 
        } 
    }

    public static String saveSubscriptionLines(String customerRequestId, String subscriptionLines){
        try{
            Id subscriptionId;
            Subscription__c[] subscriptionsToSave = new Subscription__c[] {};
            SubscriptionLine__c[] subscriptionLinesToSave = new SubscriptionLine__c[] {};
            Map<String, Object> subscriptionLineMap = new Map<String, Object>();
            String subscriptionNumbers = '';
            List<Object> subscriptionLinesList = (List<Object>)JSON.deserializeUntyped(subscriptionLines);  
            String subscriptionName = '';
            for(Object subscriptionLine : subscriptionLinesList){
                subscriptionLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine));
                subscriptionName = String.valueOf(subscriptionLineMap.get('lineNumber'));
                if(subscriptionName.length() > 80){
                    subscriptionName = subscriptionName.substring(0, 77) + '...';
                }
                if(!subscriptionNumbers.contains(subscriptionName)){
                    subscriptionNumbers = subscriptionNumbers + subscriptionName + ' ';
                    Subscription__c subscription = new Subscription__c(
                        Name = subscriptionName
                    );
                    subscriptionsToSave.add(subscription);
                }
            }
            insert(subscriptionsToSave);  
            for(Object subscriptionLine : subscriptionLinesList){
                subscriptionLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine));
                for(Subscription__c savedSubscription : subscriptionsToSave){
                    if(savedSubscription.Name == String.valueOf(subscriptionLineMap.get('lineNumber'))){
                        subscriptionId = savedSubscription.Id;
                    }
                }
                String subscriptionLineName = String.valueOf(subscriptionLineMap.get('loadName'));
                if(subscriptionLineName.length() > 80){
                    subscriptionLineName = subscriptionLineName.substring(0, 77) + '...';
                }
                subscriptionLinesToSave.add(new SubscriptionLine__c(
                    Name = String.valueOf(subscriptionLineName),
                    SubscriptionNumber__c = String.valueOf(subscriptionLineMap.get('lineNumber')),
                    Subscription__c = subscriptionId,
                    CustomerRequest__c = customerRequestId,
                    BusinessUnit__c = String.valueOf(String.valueOf(subscriptionLineMap.get('buOffer'))),
                    LoadType__c = String.valueOf(String.valueOf(subscriptionLineMap.get('loadType'))),
                    UnitPrice__c = Decimal.valueOf(String.valueOf(subscriptionLineMap.get('unitPrice'))),
                    Quantity__c = Integer.valueOf(String.valueOf(subscriptionLineMap.get('quantity'))),
                    QuantityCancelled__c = Integer.valueOf(String.valueOf(subscriptionLineMap.get('quantity'))),
                    CancellationDate__c = Date.valueOf(String.valueOf(subscriptionLineMap.get('lineDate'))),
                    TotalAmount__c = Decimal.valueOf(String.valueOf(subscriptionLineMap.get('amount'))),
                    ContractEndDate__c = Date.valueOf(String.valueOf(subscriptionLineMap.get('lineDate'))),
                    NextDateRenewal__c = Date.valueOf(String.valueOf(subscriptionLineMap.get('nextDateRenewal'))),
                    ThirdPartyDelivered__c = String.valueOf(String.valueOf(subscriptionLineMap.get('tierslivre')))
                ));
            }
            insert(subscriptionLinesToSave);
            return 'Success';
        } catch(Exception e){           
            System.debug('Error from saveSubscriptionLines Method' + e.getMessage());    
            return 'ERROR'; 
        } 
    }

    @AuraEnabled
    public static Map<String,String> getDomainPicklist(){
        try{
            SObjectField picklistUsingGlobal = SObjectType.CustomerRequest__c.fields.StructureLevel1__c.getSObjectField();
            List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
            Map<String,String> mapPicklistValues = new Map<String,String>();

            for(PicklistEntry entry: entries){
                mapPicklistValues.put(entry.getValue(), entry.getLabel());
            }
            return mapPicklistValues;
        } catch(Exception e){           
            System.debug('Error from getDomainPicklist Method' + e.getMessage());    
            return new Map<String,String>();
        } 
    }

    @AuraEnabled
    public static Business_Unit__c getBUExternalId(Id buId){
        try{
            ///Business_Unit__c bu = [SELECT Name, BU_ExternalId__c FROM Business_Unit__c WHERE Id =: buId];
            Business_Unit__c bu = [SELECT Name, API_Code__c FROM Business_Unit__c WHERE Id =: buId];
            return bu;
        } catch(Exception e){           
            System.debug('Error from getBUExternalId Method' + e.getMessage());    
            return new Business_Unit__c(); 
        }
    }

    @AuraEnabled
    public static Map<Id, Business_Unit__c> getBUIdByExternalId(List<String> ExternalIds){
        try{
            Map<Id, Business_Unit__c> buMap = new Map<Id, Business_Unit__c>([SELECT Id, API_Code__c FROM Business_Unit__c WHERE API_Code__c IN :ExternalIds LIMIT 5]);
            return buMap;
        } catch(Exception e) {
            System.debug('Error from getBUIdByExternalId Method' + e.getMessage());  
            return new Map<Id, Business_Unit__c>();
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<InvoiceLineWrapper> getInvoiceLinesByCustomerRequestId(Id customerRequestId){
        try {
            InvoiceLine__c[] invoiceLines = [SELECT Name, Invoice__c, Invoice__r.Name, LoadName__c, Amount__c, ThirdPartyDelivered__C, CreditNoteAmount__c, Discount__c FROM InvoiceLine__c WHERE CustomerRequest__c =: customerRequestId];
            List<InvoiceLineWrapper> response = new List<InvoiceLineWrapper>();
            for(InvoiceLine__c invoiceLine : invoiceLines){
                InvoiceLineWrapper obj = new InvoiceLineWrapper();
                obj.InvoiceLineId = invoiceLine.Id;
                obj.InvoiceLineName = invoiceLine.Name;
                obj.InvoiceLineUrl = '/'+invoiceLine.Id;
                obj.InvoiceId = invoiceLine.Invoice__c;
                obj.InvoiceName = invoiceLine.Invoice__r.Name;
                obj.InvoiceUrl = '/'+invoiceLine.Invoice__c;
                obj.ThirdPartyDelivered = invoiceLine.ThirdPartyDelivered__C;
                obj.LoadName = invoiceLine.LoadName__c;
                obj.Amount = invoiceLine.Amount__c;
                obj.CreditNoteAmount = invoiceLine.CreditNoteAmount__c;
                obj.Discount = invoiceLine.Discount__c;
                response.add(obj);
            }
            return response;
        } catch(Exception e) {
            System.debug('Error from getInvoiceLinesByCustomerRequestId Method' + e.getMessage());  
            return new List<InvoiceLineWrapper>();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<SubscriptionLineWrapper> getSubscriptionLinesByCustomerRequestId(Id customerRequestId){
        try {
            SubscriptionLine__c[] subscriptionLines = [SELECT SubscriptionNumber__c, Name, LoadType__c, Subscription__r.Name, UnitPrice__c, Quantity__c, TotalAmount__c, CancellationDate__c, ContractEndDate__c, NextDateRenewal__c, QuantityCancelled__c, NewQuantity__c, MRR_Cancelled__c, MRR_New__c FROM SubscriptionLine__c WHERE CustomerRequest__c =: customerRequestId];
            List<SubscriptionLineWrapper> response = new List<SubscriptionLineWrapper>();
            for(SubscriptionLine__c subscriptionLine : subscriptionLines){
                SubscriptionLineWrapper obj = new SubscriptionLineWrapper();
                obj.SubscriptionLineId = subscriptionLine.Id;
                obj.LoadName = subscriptionLine.Name;
                obj.SubscriptionLineUrl = '/'+subscriptionLine.Id;
                obj.SubscriptionId = subscriptionLine.Subscription__c;
                obj.SubscriptionNumber = subscriptionLine.Subscription__r.Name;
                obj.SubscriptionUrl = '/'+subscriptionLine.Subscription__c;
                obj.LoadType = subscriptionLine.LoadType__c;
                obj.UnitPrice = subscriptionLine.UnitPrice__c;
                obj.Quantity = subscriptionLine.Quantity__c;
                obj.TotalAmount = subscriptionLine.TotalAmount__c;
                obj.CancellationDate = subscriptionLine.CancellationDate__c;
                obj.ContractEndDate = subscriptionLine.ContractEndDate__c;
                obj.NextDateRenewal = subscriptionLine.NextDateRenewal__c;
                obj.QuantityCancelled = subscriptionLine.QuantityCancelled__c;
                obj.NewQuantity = subscriptionLine.NewQuantity__c;
                obj.MRR_Cancelled = subscriptionLine.MRR_Cancelled__c;
                obj.MRR_New = subscriptionLine.MRR_New__c;
                response.add(obj);
            }
            return response;
        } catch(Exception e) {
            System.debug('Error from getSubscriptionLinesByCustomerRequestId Method' + e.getMessage());  
            return new List<SubscriptionLineWrapper>();
        }
    }

    @AuraEnabled
    public static String updateInvoiceLines(String invoiceLineListStr){
        try {
            Map<String, Object> InvoiceLinesMap = new Map<String, Object>();    
            List<InvoiceLine__c> invoiceLinesToSave = new List<InvoiceLine__c>();
            List<Object> invoiceLines = (List<Object>)JSON.deserializeUntyped(invoiceLineListStr);
            for(Object invoiceLine : invoiceLines){
                InvoiceLine__c invLine = new InvoiceLine__c() ;
                InvoiceLinesMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(invoiceLine));
                invLine.Id = (ID)(InvoiceLinesMap.get('InvoiceLineId'));
                invLine.CreditNoteAmount__c = Decimal.valueOf(String.valueOf(InvoiceLinesMap.get('CreditNoteAmount')));
                invoiceLinesToSave.add(invLine);
            }
            update invoiceLinesToSave;
            return 'Success';
        } catch(Exception e) {
            System.debug('Error from updateInvoiceLines Method' + e.getMessage());  
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String updateSubscriptionLines(String subscriptionLinesStr){
        try {
            Map<String, Object> subscriptionLineMap = new Map<String, Object>();
            List<SubscriptionLine__c> subscriptionLinesToSave = new List<SubscriptionLine__c>();
            List<Object> subscriptionLines = (List<Object>)JSON.deserializeUntyped(subscriptionLinesStr);     
            for(Object subscriptionLine : subscriptionLines){
                SubscriptionLine__c SubsLine = new SubscriptionLine__c() ;
                subscriptionLineMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(subscriptionLine));
                SubsLine.Id = (ID)(subscriptionLineMap.get('SubscriptionLineId'));
                if(subscriptionLineMap.containsKey('CancellationDate')){
                    SubsLine.CancellationDate__c = Date.valueOf(String.valueOf(subscriptionLineMap.get('CancellationDate')));
                }
                if(subscriptionLineMap.get('QuantityCancelled') != null){
                    SubsLine.QuantityCancelled__c = Decimal.valueOf(String.valueOf(subscriptionLineMap.get('QuantityCancelled')));
                }
                subscriptionLinesToSave.add(SubsLine);
            }
            update subscriptionLinesToSave;
            return 'Success';
        } catch(Exception e) {
            System.debug('Error from updateSubscriptionLines Method' + e.getMessage());  
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String deleteInvoiceLine(String invoiceLineId){
        try {
            InvoiceLine__c invoiceLine = [SELECT Id FROM InvoiceLine__c WHERE Id =: invoiceLineId];
            delete invoiceLine;
            return 'Success';
        } catch(Exception e) {
            return 'ERROR';
        }
    }

    @AuraEnabled
    public static String deleteSubscriptionLine(String subscriptionLineId){
        try {
            SubscriptionLine__c subscriptionLine = [SELECT Id FROM SubscriptionLine__c WHERE Id =: subscriptionLineId];
            delete subscriptionLine;
            return 'Success';
        } catch(Exception e) {
            return 'ERROR';
        }
    }

    @AuraEnabled
    public static List<ErpnumberWrapper> searchLookUp(String searchTerm){

        List<ErpnumberWrapper> ErpnumberItems = new List<ErpnumberWrapper>();
        List<Account> accountSearchList = new List<Account>();
        searchTerm = '%'+searchTerm+'%';
        accountSearchList = [SELECT Name, ERP_Number__c FROM Account WHERE Name LIKE :searchTerm OR ERP_Number__c LIKE :searchTerm LIMIT 5];

        for(Account accountSearch : accountSearchList){
            ErpnumberWrapper ErpnumberItem = new ErpnumberWrapper();
            ErpnumberItem.id = accountSearch.Id;
            ErpnumberItem.name = accountSearch.Name;
            ErpnumberItem.erpnumber = accountSearch.ERP_Number__c;
            ErpnumberItems.add(ErpnumberItem); 
        }
        return ErpnumberItems;
    }



    public Class lineWrapper{
        @AuraEnabled
        public String totalLines {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String lineNumber {get;set;}
        @AuraEnabled
        public String contractNumber {get;set;}
        @AuraEnabled
        public String amount {get;set;}
        @AuraEnabled
        public String totalAmount {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public String lineDate {get;set;}
        @AuraEnabled
        public String nextDateRenewal {get;set;}
        @AuraEnabled
        public String tierslivre {get;set;}
        @AuraEnabled
        public List<Items> items {get;set;}
    }

    public Class Items{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String lineNumber {get;set;}
        @AuraEnabled
        public String lineName {get;set;}
        @AuraEnabled
        public String buOffer {get;set;}
        @AuraEnabled
        public String calculatedBu {get;set;}
        @AuraEnabled
        public String contractNumber {get;set;}
        @AuraEnabled
        public String amount {get;set;}
        @AuraEnabled
        public String startDate {get;set;}
        @AuraEnabled
        public String endDate {get;set;}
        @AuraEnabled
        public String lineDate {get;set;}
        @AuraEnabled
        public String nextDateRenewal {get;set;}
        @AuraEnabled
        public String tierslivre {get;set;}
        @AuraEnabled
        public String loadName {get;set;}
        @AuraEnabled
        public String loadType {get;set;}
        @AuraEnabled
        public String unitPrice {get;set;}
        @AuraEnabled
        public String quantity {get;set;}
        @AuraEnabled
        public String sectorAgency3Part {get;set;}  
        @AuraEnabled
        public String domain {get;set;}
        @AuraEnabled
        public String origin {get;set;}   
    }

    public class InvoiceLineWrapper{
        @AuraEnabled
        public Id InvoiceLineId {get;set;}
        @AuraEnabled
        public String InvoiceLineName {get;set;}
        @AuraEnabled
        public String InvoiceLineUrl {get;set;}
        @AuraEnabled
        public Id InvoiceId {get;set;}
        @AuraEnabled
        public String InvoiceName {get;set;}
        @AuraEnabled
        public String InvoiceUrl {get;set;}
        @AuraEnabled
        public String ThirdPartyDelivered {get;set;}
        @AuraEnabled
        public String LoadName {get;set;}
        @AuraEnabled
        public Decimal Amount {get;set;}
        @AuraEnabled
        public Decimal CreditNoteAmount {get;set;}
        @AuraEnabled
        public Decimal Discount {get;set;}
    }

    public class SubscriptionLineWrapper{
        @AuraEnabled
        public Id SubscriptionLineId {get;set;}
        @AuraEnabled
        public String LoadName {get;set;}
        @AuraEnabled
        public String LoadType {get;set;}
        @AuraEnabled
        public String SubscriptionLineUrl {get;set;}
        @AuraEnabled
        public Id SubscriptionId {get;set;}
        @AuraEnabled
        public String SubscriptionNumber {get;set;}
        @AuraEnabled
        public String SubscriptionUrl {get;set;}
        @AuraEnabled
        public Decimal UnitPrice {get;set;}
        @AuraEnabled
        public Decimal Quantity {get;set;}
        @AuraEnabled
        public Decimal TotalAmount {get;set;}
        @AuraEnabled
        public Date CancellationDate {get;set;}
        @AuraEnabled
        public Date ContractEndDate {get;set;}
        @AuraEnabled
        public Date NextDateRenewal {get;set;}
        @AuraEnabled
        public Decimal QuantityCancelled {get;set;}
        @AuraEnabled
        public Decimal NewQuantity {get;set;}
        @AuraEnabled
        public Decimal MRR_Cancelled {get;set;}
        @AuraEnabled
        public Decimal MRR_New {get;set;}
    }

    public Class ErpnumberWrapper{
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String erpnumber {get;set;}
    }
}