/**
* @author Keshav - Comforth
* @date 2021-19-01
* @modified 
* @group TH_Product2
* @object Product2
* @description 
*/
public class SM015_FindCorrectAttachedDocument {

    public static void updateLinkProduct(Set<Id> setProductIds){
        system.debug('updateLinkProduct');
        // Retrieve the RecordType Ids
        Id rtGeneralTerms = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get('General_Terms_And_Conditions').getRecordTypeId();    
        Id rtServiceBook = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get('Service_Book').getRecordTypeId();
        List<Product2> listProdToUpdate = new List<Product2>();
        List<Attached_Document__c> listAttDoc = new List<Attached_Document__c>();
        Set<String> setStruc1 = new Set<String>();
        Set<String> setStruc2 = new Set<String>();
        Set<Id> setProductLine = new Set<Id>();
        Set<String> setServiceLevel = new Set<String>();

        List<Product2> listProduct2 = [SELECT Id,Name,Family,StructureLevel2__c,General_Terms_And_Conditions__c,Product_Line__c,Service_Levels__c  From Product2 where Id IN :setProductIds];

        for(Product2 pro:listProduct2){
            setStruc1.add(pro.Family);
            setStruc2.add(pro.StructureLevel2__c);
            String productService = pro.Service_Levels__c;
            setServiceLevel.addAll(productService.split(';'));
            setProductLine.add(pro.Product_Line__c);
        }

        if(setStruc1.size()>0 && setStruc2.size()>0){

            set<String> setDocLink = new set<String>();

            for(Product2 p:listProduct2){
                p.General_Terms_And_Conditions__c = null;
                for(Attached_Document__c attDoc:[SELECT Id,StructureLevel1__c,StructureLevel2__c,Document_Link__c 
                FROM Attached_Document__c  WHERE StructureLevel1__c IN:setStruc1 AND StructureLevel2__c IN:setStruc2 AND RecordTypeId =:rtGeneralTerms]){

                    if(attDoc.Document_Link__c != null){
                        setDocLink.add(attDoc.Document_Link__c);
                    }

                    if(p.Family == attDoc.StructureLevel1__c && p.StructureLevel2__c == attDoc.StructureLevel2__c ){
                        p.General_Terms_And_Conditions__c = String.join(new List<String>(setDocLink),';');
                    }else{
                        p.General_Terms_And_Conditions__c = null;
                    }
                }
            }

            
        }

        if(setStruc1.size()>0 && setServiceLevel.Size()>0 && setProductLine.size()>0){

            List<String> listService = new List<String>(setServiceLevel);
            List<Attached_Document__c> listAttch = new List<Attached_Document__c>();
            String queryString = 'SELECT Id,Name,StructureLevel1__c,StructureLevel2__c,Document_Link__c,Service_Level__c,Product_Line__c from Attached_Document__c WHERE StructureLevel1__c IN :setStruc1 AND RecordTypeId =:rtServiceBook AND Product_Line__c IN :setProductLine AND Service_Level__c INCLUDES(';
            for(String includeValue :listService)
            queryString += '\'' + includeValue + '\'' + ',';
            queryString = queryString.removeEnd(',') +')';
            system.debug('queryString' + queryString);
            listAttch = (List<Attached_Document__c>)Database.query(queryString);

            system.debug('listAttachedDoc ' + listAttch);

            for(Product2 p:listProduct2){
                for(Attached_Document__c attachedDoc:listAttch){
                  

                    set<String> setDocLink = new set<String>();
                    if(attachedDoc.Document_Link__c != null){
                        setDocLink.add(attachedDoc.Document_Link__c);
                    }

                    if(attachedDoc.StructureLevel1__c == p.Family && attachedDoc.Product_Line__c == p.Product_Line__c){
                        p.TECHServiceBook__c = String.join(new List<String>(setDocLink),';');
                        p.Service_Book__c = '';
                        for(String docLink:setDocLink){
                            p.Service_Book__c += p.Service_Book__c +  '<a href="'+ docLink +'">' + attachedDoc.Name +'</a><BR/>';
                        }
                    }
                }
            }
        }

        if(listProduct2.Size() > 0){
            update listProduct2;
        }

    }

}