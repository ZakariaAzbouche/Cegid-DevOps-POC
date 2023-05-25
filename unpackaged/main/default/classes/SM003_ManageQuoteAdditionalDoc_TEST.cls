/**
 * @author Shamina M - Comforth
 * @date Creation 05 May 2020
 * @description Test class for trigger logic SM003_ManageQuoteAdditionalDoc
 *              
*/
@isTest
private class SM003_ManageQuoteAdditionalDoc_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';

    @TestSetup static void setup(){    
        //testing as admin because of issues with CBQQ rights when testing as Cegid sales
        System.runAs(adminUser){             
            Test.startTest(); //to prevent SOQL limits from SBQQ package
                //create account
                Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
                insert acc;

                //create contact
                Contact primaryContact = new UTIL_TestFactory.ContactFactory().createContact(acc.Id);
                primaryContact.Email = PRIMARY_CONTACT_EMAIL;
                insert primaryContact;

                PriceBook2 standardPricebook = new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();

                //create opportunity
                Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
                opp.Pricebook2Id = standardPricebook.Id; 
                insert opp;

                //create product2
                List<Product2> listProduct = new List<Product2>{
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
                };
                insert listProduct;

                List<PricebookEntry> listPBE = new List<PricebookEntry>{
                    new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[0].id),
                    new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[1].id),
                    new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(standardPricebook.id, listProduct[2].id)
                };
                insert listPBE; 

                //create oppline item
                List<OpportunityLineItem> listOppLineItem = new List<OpportunityLineItem>{
                    new UTIL_TestFactory.OpportunityFactory().createOppLineItem(opp.Id, listPBE[0].Id),
                    new UTIL_TestFactory.OpportunityFactory().createOppLineItem(opp.Id, listPBE[1].Id),
                    new UTIL_TestFactory.OpportunityFactory().createOppLineItem(opp.Id, listPBE[2].Id)
                };
                insert listOppLineItem;

                //create quote in mass (cannot create more than that because of SOQL & CPU limit exceeded from CPQ SBQQ package)
                List<SBQQ__Quote__c> listQuotes = new List<SBQQ__Quote__c>();
                for(Integer i=0; i<2;i++ ){
                    listQuotes.add(new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(opp.Id, acc.Id, primaryContact.Id));
                }
                insert listQuotes;
                
            Test.stopTest();
        }
        
    }


    /*
    * @author Shamina M - Comforth
    * @created 2020-05-08
    * @description Test additional document created for PDF files attached to quote
    */
    @isTest static void testAdditionalDocCreated() {

        System.runAs(adminUser){
            List<ContentDocumentLink> listContDocLink = new List<ContentDocumentLink>();
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setContDocIds = new Set<Id>();

            List<ContentVersion> listContVersion = new List<ContentVersion>{
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('AAAreportPdf', 'Report1.pdf'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('BBBreportdoc', 'Report2.doc'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('CCCreportxls', 'Report3.xls'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('DDDreportPdf', 'Report4.pdf')
            };
            insert listContVersion;

            for(SBQQ__Quote__c qut : [select Id, IBAN__c, BIC__c 
                                                FROM SBQQ__Quote__c 
                                                WHERE SBQQ__PrimaryContact__r.Email = :PRIMARY_CONTACT_EMAIL
                                                 ]){
                setQuoteIds.add(qut.Id);
                for(ContentVersion docVersion : [SELECT Id, Title, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE Id IN :listContVersion
                                                LIMIT 4]){
                    setContDocIds.add(docVersion.ContentDocumentId);
                    listContDocLink.add(new UTIL_TestFactory.ContentDocumentFactory().createContentDocLink(qut.Id, docVersion.ContentDocumentId));                                      
                }                                      
            }

            Test.startTest();                
                insert listContDocLink;            
                List<SBQQ__RelatedContent__c> listAddDoc = [select Id 
                                                            FROM SBQQ__RelatedContent__c 
                                                            WHERE SBQQ__ExternalId__c IN :setContDocIds
                                                            AND SBQQ__Quote__c IN :setQuoteIds];
                system.assertEquals(4, listAddDoc.size(), '4 pdf additional doc created');
            Test.stopTest();                                                                         
            
        }
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-05-08
    * @description Test no additional doc created because non-pdf file was attached to quote
    */
    @isTest static void testAdditionalDocNOTCreated() {

        System.runAs(adminUser){
            List<ContentDocumentLink> listContDocLink = new List<ContentDocumentLink>();
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setContDocIds = new Set<Id>();

            List<ContentVersion> listContVersion = new List<ContentVersion>{
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('BBBreportdoc', 'Report2.doc'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('CCCreportxls', 'Report3.xls')
            };
            insert listContVersion;

            for(SBQQ__Quote__c qut : [select Id, IBAN__c, BIC__c 
                                                FROM SBQQ__Quote__c 
                                                WHERE SBQQ__PrimaryContact__r.Email = :PRIMARY_CONTACT_EMAIL
                                                 ]){
                setQuoteIds.add(qut.Id);
                for(ContentVersion docVersion : [SELECT Id, Title, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE Id IN :listContVersion
                                                LIMIT 4]){
                    setContDocIds.add(docVersion.ContentDocumentId);
                    listContDocLink.add(new UTIL_TestFactory.ContentDocumentFactory().createContentDocLink(qut.Id, docVersion.ContentDocumentId));                                      
                }                                      
            }

            Test.startTest();                
                insert listContDocLink;            
                List<SBQQ__RelatedContent__c> listAddDoc = [select Id 
                                                            FROM SBQQ__RelatedContent__c 
                                                            WHERE SBQQ__Quote__c IN :setQuoteIds];
                system.assertEquals(0, listAddDoc.size(), 'No additional doc created because none were PDF');
            Test.stopTest();                                                                         
            
        }
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-05-08
    * @description Test content document link deleted
    */
    @isTest static void testAdditionalDocDeletedByContentLink() {

        System.runAs(adminUser){
            List<ContentDocumentLink> listContDocLink = new List<ContentDocumentLink>();
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setContDocIds = new Set<Id>();

            List<ContentVersion> listContVersion = new List<ContentVersion>{
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('AAAreportPdf', 'Report1.pdf'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('BBBreportdoc', 'Report2.doc'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('CCCreportxls', 'Report3.xls'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('DDDreportPdf', 'Report4.pdf')
            };
            insert listContVersion;

            for(SBQQ__Quote__c qut : [select Id, IBAN__c, BIC__c 
                                                FROM SBQQ__Quote__c 
                                                WHERE SBQQ__PrimaryContact__r.Email = :PRIMARY_CONTACT_EMAIL
                                                 ]){
                setQuoteIds.add(qut.Id);
                for(ContentVersion docVersion : [SELECT Id, Title, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE Id IN :listContVersion
                                                LIMIT 4]){
                    setContDocIds.add(docVersion.ContentDocumentId);
                    listContDocLink.add(new UTIL_TestFactory.ContentDocumentFactory().createContentDocLink(qut.Id, docVersion.ContentDocumentId));                                      
                }                                      
            }

            insert listContDocLink; 

            Test.startTest();                
                delete listContDocLink;       
                List<SBQQ__RelatedContent__c> listAddDoc = [select Id 
                                                            FROM SBQQ__RelatedContent__c 
                                                            WHERE SBQQ__Quote__c IN :setQuoteIds];
                system.assertEquals(0, listAddDoc.size(), 'Additional doc deleted after related content doclink were deleted');
            Test.stopTest();                                                                         
            
        }
    }


    /*
    * @author Shamina M - Comforth
    * @created 2020-05-08
    * @description Test content document deleted
    */
    @isTest static void testAdditionalDocDeletedByContentDoc() {

        System.runAs(adminUser){
            List<ContentDocumentLink> listContDocLink = new List<ContentDocumentLink>();
            List<ContentDocument> listContDoc= new List<ContentDocument>();
            Set<Id> setQuoteIds = new Set<Id>();
            Set<Id> setContDocIds = new Set<Id>();

            List<ContentVersion> listContVersion = new List<ContentVersion>{
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('AAAreportPdf', 'Report1.pdf'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('BBBreportdoc', 'Report2.doc'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('CCCreportxls', 'Report3.xls'),
                new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('DDDreportPdf', 'Report4.pdf')
            };
            insert listContVersion;

            for(SBQQ__Quote__c qut : [select Id, IBAN__c, BIC__c 
                                                FROM SBQQ__Quote__c 
                                                WHERE SBQQ__PrimaryContact__r.Email = :PRIMARY_CONTACT_EMAIL
                                                 ]){
                setQuoteIds.add(qut.Id);
                for(ContentVersion docVersion : [SELECT Id, Title, ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE Id IN :listContVersion
                                                LIMIT 4]){
                    setContDocIds.add(docVersion.ContentDocumentId);
                    listContDocLink.add(new UTIL_TestFactory.ContentDocumentFactory().createContentDocLink(qut.Id, docVersion.ContentDocumentId));                                      
                }                                      
            }

            //build content document list
            for(Id contDocId : setContDocIds ){
                listContDoc.add(new ContentDocument(Id = contDocId));
            }

            insert listContDocLink; 

            Test.startTest();                
                delete listContDoc;       
                List<SBQQ__RelatedContent__c> listAddDoc = [select Id 
                                                            FROM SBQQ__RelatedContent__c 
                                                            WHERE SBQQ__Quote__c IN :setQuoteIds];
                system.assertEquals(0, listAddDoc.size(), 'Additional doc deleted after related content doc were deleted');
            Test.stopTest();                                                                         
            
        }
    }
}