/**
* @author Keshav M- Comforth
* @date Creation 17 June 2020
* @description Test class for trigger logic SM005_AttachedDocument
*              
*/
@isTest
public class SM005_AttachedDocument_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();
    //static Product_Line__c productLine = new Product_Line__c();
    @TestSetup static void setup(){ 
        System.runAs(adminUser){ 
            
            bt.Activatetrigger__c = true;
            bt.SetupOwnerId = UserInfo.getOrganizationId();
            insert bt;
            
            List<Product_Line__c> listProductLine = new List<Product_Line__c>{
                 new UTIL_TestFactory.ProductLineFactory().createProductLinePrice('ProductLineTest', 'tyhjy')
            };
            insert listProductLine;
            //productLine = new UTIL_TestFactory.ProductLineFactory().createProductLinePrice('ProductLineTest', 'ProductLineTest');
            //insert productLine;
            
            //create product List
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost')
                    };
                        
                        listProductList[0].Family = '110';
            listProductList[1].Family = '110';
            listProductList[2].Family = '110';
            listProductList[0].StructureLevel2__c = '111';
            listProductList[1].StructureLevel2__c = '111';
            listProductList[2].StructureLevel2__c = '111';
            
            listProductList[0].Service_Levels__c = 'C30';
            listProductList[1].Service_Levels__c = 'C30';
            listProductList[2].Service_Levels__c = 'C30';
            
            listProductList[0].Product_Line__c = listProductLine[0].Id;
            listProductList[1].Product_Line__c = listProductLine[0].Id;
            listProductList[2].Product_Line__c = listProductLine[0].Id;
            insert listProductList;
            
            
            
            List<Product2> listProductListService = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Cost')
                    };
                        
                        listProductListService[0].Family = '140';
            listProductListService[1].Family = '140';
            listProductListService[2].Family = '140';
            listProductListService[0].Service_Levels__c = 'C30';
            listProductListService[1].Service_Levels__c = 'C30';
            listProductListService[2].Service_Levels__c = 'C30';
            listProductListService[0].Product_Line__c = listProductLine[0].Id;
            listProductListService[1].Product_Line__c = listProductLine[0].Id;
            listProductListService[2].Product_Line__c = listProductLine[0].Id;
            insert listProductListService;
            
            
            
            List<Attached_Document__c> listAttGeneral = new List<Attached_Document__c>{
                //140 --> Professional services
                //224 --> System installation
                new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc1', '110','111','http://www.googleva.com','',null,'General_Terms_And_Conditions'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc2', '110','111','http://www.googleva.com','',null,'General_Terms_And_Conditions'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc3', '110','111','http://www.googleva.com','',null,'General_Terms_And_Conditions')
                    };
                        
                        insert listAttGeneral;
            
            
            List<Attached_Document__c> listAttService = new List<Attached_Document__c>{
                //140 --> Professional services
                //224 --> System installation
                	new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc11', '140','','http://www.googleva.com','C30',listProductLine[0].Id,'Service_Book'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc22', '140','','http://www.googleva.com','C30',listProductLine[0].Id,'Service_Book'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc33', '140','','http://www.googleva.com','C30',listProductLine[0].Id,'Service_Book')
                    };
                        
                        insert listAttService;
            
        }
    }

    
   @isTest static void testSM005_AttachedDocumentInsertGeneralTerms() {
        System.runAs(adminUser){
            List<Attached_Document__c> listAtt = new List<Attached_Document__c>{
                //140 --> Professional services
                //224 --> System installation
                new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc1', '110','111','http://www.googleva.com','',null,'General_Terms_And_Conditions'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc2', '110','111','http://www.googleva.com','',null,'General_Terms_And_Conditions'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc3', '110','111','http://www.googleva.com','',null,'General_Terms_And_Conditions')
                    };
                        
            Test.startTest();
            insert listAtt;
            List<Product2> listp = [SELECT id, name, Family, StructureLevel2__c, General_Terms_And_Conditions__c FROM product2 where Family ='110' AND StructureLevel2__c ='111' limit 1];
            //system.assertEquals(listp[0].General_Terms_And_Conditions__c, listAtt[0].Document_Link__c);
            Test.stopTest();
        }
    }
    
    @isTest static void testSM005_AttachedDocumentInsertService() {
        System.runAs(adminUser){
             List<Product_Line__c> listProductLine = [SELECT Id FROM Product_Line__c];
            List<Attached_Document__c> listAttService = new List<Attached_Document__c>{
                //140 --> Professional services
                //224 --> System installation
                new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc11', '140','','http://www.googleva.com','C30',listProductLine[0].Id,'Service_Book'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc22', '140','','http://www.googleva.com','C30',listProductLine[0].Id,'Service_Book'),
                    new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('AttDoc33', '140','','http://www.googleva.com','C30',listProductLine[0].Id,'Service_Book')
                    };
                        
                        Test.startTest();
            insert listAttService;
            List<Product2> listp = [SELECT id, name, Family, Service_Book__c FROM product2 where Family ='140' AND Product_Line__c =: listProductLine[0].Id AND Service_Levels__c='C30' limit 1];
            system.assertNotEquals(listp[0].Service_Book__c, listAttService[0].Document_Link__c);
            
            Test.stopTest();
        }
    }
    
    @isTest static void testSM005_AttachedDocumentUpdateService() {
        System.runAs(adminUser){
            List<Attached_Document__c> listAtt = [SELECT id, Name from Attached_Document__c  WHERE recordtype.developername ='Service_Book'  ];
            for(Attached_Document__c at:listAtt){
                at.Document_Link__c = 'http://www.google.com';   
            }
            Test.startTest();
            update listAtt;
            Test.stopTest();
        }
    }
    
    
    @isTest static void testSM005_AttachedDocumentDeleteService() {
        System.runAs(adminUser){
            List<Attached_Document__c> listAtt = [SELECT id, Name from Attached_Document__c  WHERE recordtype.developername ='Service_Book' limit 1];
            Test.startTest();
            delete listAtt;
            Test.stopTest();
        }
    }
    
    
}