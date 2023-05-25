/**
* @author Keshav M- Comforth
* @date Creation 1/19/2021
* @description Test class for trigger logic SM015_FindCorrectAttachedDocument
*              
*/
@isTest
public class SM015_FindCorrectAttachedDocument_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'primarycontact@email.com';
    static BypassTrigger__c bt= new BypassTrigger__c();

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
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
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
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                    new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
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

    @isTest static void SM015_FindCorrectAttachedDocumentUpdate() {
        System.runAs(adminUser){
            List<Product2> listProduct = [SELECT id, Name,Family from Product2 WHERE Family = '110'];
            for(Product2 pro:listProduct){
                pro.Family = '140';   
            }
            Test.startTest();
            update listProduct;
            Test.stopTest();
        }
    }
}