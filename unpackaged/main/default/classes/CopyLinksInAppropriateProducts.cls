public class CopyLinksInAppropriateProducts {
    public static String methodTest(String st){
        If(st == 'Coucou'){
        return 'ok';
        } else {
        return 'ko';
        }
    }
 /* 
    // Used to copy each Document Link into the right Products (those with the same characteristics as the Document)
    public static void upsertLinksInAppropriateProducts(List<Document_Annexe__c> documentList, Boolean operationIsUpdate, Map<Id, Document_Annexe__c > oldDocumentMap){
       
        // Retrieve the RecordType Ids
        Id recordTypeIdCGV = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get('General_Terms_And_Conditions').getRecordTypeId();    
        Id recordTypeIdServiceBook = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get('Service_Book').getRecordTypeId();
        
        // Build the lists and maps that will be useful later 
        Map<String, String> condGenVenteMap = new Map<String, String>();
        
        Set<String> ServiceBookStructLvl1List = new Set<String>();
        Map<List<String>, String> ServiceBookMap = new Map<List<String>, String>();
        Map<List<String>, String> oldServiceBookMap = new Map<List<String>, String>();
        
        // For each document created or updated
        for(Attached_Document__c doc : documentList){
            if(doc.RecordTypeId == recordTypeIdCGV){
                // If the Document RecordType is CGV, put the StructureLevel2 and Document Link in the CGV Map
                condGenVenteMap.put(doc.StructureLevel2__c, doc.Document_Link__c);
            }
            else if(doc.RecordTypeId == recordTypeIdServiceBook){
                // If the Document RecordType is 'Service Book', put the StructureLevel1 in a Set which will later be used to narrow the search to 
                // a smaller amount of Products
                ServiceBookStructLvl1List.add(doc.StructureLevel1__c);
                
                // Then put the elements used to find the right Products in a List, in order to create a Key
                List<String> serviceLevels = doc.Service_Level__c.split('\\;');
                
                // For each 'Service Level', build a Key with the same structure as the one above
                for(String service : serviceLevels){
                    
                    List<String> ServiceBookKey = new List<String>();  
                    ServiceBookKey.add(doc.StructureLevel1__c);
                    ServiceBookKey.add(service);
                    ServiceBookKey.add(doc.Product_Line__c);
                    // Put the resulting Key and the Document Link in the Book Map
                    ServiceBookMap.put(ServiceBookKey, doc.Document_Link__c);
                    System.debug('>>>>> CopyLinksInAppropriateProducts ServiceBookMap = ' + ServiceBookMap);
                
                    // ********** In case of Update operation **********
                    if(operationIsUpdate){
                        // If it is an Update, fill also a Map with the older version of the Document
                        Attached_Document__c oldDocVersion = oldDocumentMap.get(doc.Id);
                        oldServiceBookMap.put(ServiceBookKey, oldDocVersion.Document_Link__c);
                    }
                    // *************************************************
                
                }
            }
        }     
        
        // Create a List which will contain the Products to update with new CGVs
        List<Product2> productsToUpdateWithCGV = new List<Product2>();
        if(condGenVenteMap.size() > 0){
            // If some of the Documents are CGVs, search for the associated Products and fill their own CGVs with the Links
            Set<String> condGenVenteStructLvl2List = condGenVenteMap.keySet();
            productsToUpdateWithCGV = [Select Id, StructureLevel2__c
                                       From Product2
                                       Where StructureLevel2__c = :condGenVenteStructLvl2List];
            for(Product2 prod : productsToUpdateWithCGV){
                 prod.General_Terms_And_Conditions__c = condGenVenteMap.get(prod.StructureLevel2__c);
            }    
        }
        
        // Create a List which will contain the Products to update with new Books
        List<Product2> productsToUpdateWithBook = new List<Product2>();
        if(ServiceBookStructLvl1List.size() > 0){
            // Regarding the 'Service Book' Documents : be careful with the field naming, as Product Family is now filled with StructureLevel1 values
            // If some of the Documents are Books, search for Products with the same StructureLevel1
            List<Product2> productsToPotentiallyUpdate = [Select Id, Family, Service_Levels__c, Service_Book__c , Product_Line__c
                                                          From Product2 
                                                          Where Family IN :ServiceBookStructLvl1List
                                                          And Service_Levels__c != null
                                                          And Product_Line__c != null];
            System.debug('>>>>> CopyLinksInAppropriateProducts ProductsToPotentiallyUpdate = ' + ProductsToPotentiallyUpdate);
            // For each Product retrieved by the query, check that it's one that really needs to be updated  
            for(Product2 prod : productsToPotentiallyUpdate){
                // Since 'Service Levels' is a Multi-Select Picklist, we need to split the field value
                List<String> serviceLevels = prod.Service_Levels__c.split('\\;');
                System.debug('>>>>> CopyLinksInAppropriateProducts serviceLevels = ' + serviceLevels);
                
                Boolean productNeedsAnUpdate = false;
                // For each 'Service Level', build a Key with the same structure as the one above
                for(String service : serviceLevels){
                    List<String> ServiceBookPotentialKey = new List<String>();
                    ServiceBookPotentialKey.add(prod.Family);
                    ServiceBookPotentialKey.add(service);
                    ServiceBookPotentialKey.add(prod.Product_Line__c);
                    System.debug('>>>>> CopyLinksInAppropriateProducts ServiceBookPotentialKey = ' + ServiceBookPotentialKey);
                    
                    // By comparing the current key with those existing in the Book Map, check that it's a Product that really needs to be updated
                    if(ServiceBookMap.containsKey(ServiceBookPotentialKey)){
                        productNeedsAnUpdate = true;
                        
                        // ********** In case of Update operation **********
                        if(operationIsUpdate){
                            if(oldServiceBookMap.containsKey(ServiceBookPotentialKey)){
                                // If it is an Update, retrieve the old value of the Document Link using the Map
                                String oldBookToRemove = oldServiceBookMap.get(ServiceBookPotentialKey);
                                System.debug('>>>>> CopyLinksInAppropriateProducts oldBookToRemove = ' + oldBookToRemove);
                                
                                // And remove it from the Product 'Service Book' field
                                String prodBook = prod.Service_Book__c;
                                system.debug('prodBook' + prodBook);
                                if(prodBook != null){
                                    Integer BookIndex = prodBook.indexOf(oldBookToRemove);
                                    System.debug('>>>>> CopyLinksInAppropriateProducts BookIndex = ' + BookIndex);
                                    if(BookIndex != 0 && prodBook.substring(BookIndex - 1, BookIndex) == '>'){
                                        prodBook = prodBook.substring(0, BookIndex - 4) + prodBook.substring(BookIndex);
                                    }
                                    prod.Service_Book__c = prodBook.remove(oldBookToRemove);
                                    System.debug('>>>>> CopyLinksInAppropriateProducts prod.Service_Book__c after remove = ' + prod.Service_Book__c);
                                }
                            }
                        }
                        // ************************************************
                        
                        // Add the Document Link to the Product 'Service Book' field
                        if(String.isEmpty(prod.Service_Book__c)){
                            prod.Service_Book__c = ServiceBookMap.get(ServiceBookPotentialKey);
                        }
                        else{
                            prod.Service_Book__c += '<br>';
                            prod.Service_Book__c += ServiceBookMap.get(ServiceBookPotentialKey);
                        }
                        System.debug('>>>>> CopyLinksInAppropriateProducts prod.Service_Book__c end = ' + prod.Service_Book__c);
                    }
                }
                
                // If the Product is one that really needs an update, clean the 'Service Book' field if needed and add the Record to a List 
                if(productNeedsAnUpdate){
                    // ********** In case of Update operation **********
                    String prodBook = prod.Service_Book__c;
                    if(prodBook.startsWith('<br>')){
                        prod.Service_Book__c = prodBook.removeStart('<br>');
                    }
                    // *************************************************
                    productsToUpdateWithBook.add(prod);
                }
            }
            System.debug('>>>>> CopyLinksInAppropriateProducts productsToUpdateWithBook = ' + productsToUpdateWithBook);
        }
        
        // By combining the two previous Lists, create a Map which will contain all the Products to Update 
        Map<Id, Product2> productsToUpdateMap = new Map<Id, Product2>(productsToUpdateWithCGV);
        for(Product2 prod : productsToUpdateWithBook){
            if(productsToUpdateMap.containsKey(prod.Id)){
                productsToUpdateMap.get(prod.Id).Service_Book__c = prod.Service_Book__c;
            }
            else{
                productsToUpdateMap.put(prod.Id, prod);
            }
        }
        
        // Try updating the Products
        List<Product2> productsToUpdate = productsToUpdateMap.values();
        if(productsToUpdate.size() > 0){
            try{
                System.debug('>>>>> CopyLinksInAppropriateProducts productsToUpdate = ' + productsToUpdate);
                Update productsToUpdate;
            }
            catch(DmlException exc){
                System.debug('>>>>> CopyLinksInAppropriateProducts After Insert DML EXception : ' + exc);  
                for(Attached_Document__c doc : documentList){
                    doc.addError('A problem was encountered while inserting/updating the Products : ' + exc.getMessage());
                }
            }
        }
    }*/
}