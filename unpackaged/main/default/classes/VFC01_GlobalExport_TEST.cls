@isTest
public class VFC01_GlobalExport_TEST {
/**
* @author Keshav - Comforth
* @date 2020-02-04
* @group UTIL
* @description Classe VFC01_GlobalExport
*/
    
static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @testSetup static void setup(){
        System.runAs(adminUser){ 

            //create Package List
            List<Product2> listPackageList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'List')
            };
            insert listPackageList;

            //create Package Block
            List<Product2> listPackageBlock = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Package', 'Block')
            };
            insert listPackageBlock;

            //create product List
            List<Product2> listProductList = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List')
            };
            insert listProductList;


            //create product Block
            List<Product2> listProductBlock = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block'),
                new UTIL_TestFactory.ProductFactory().createProduct('Product', 'Block')
            };
            insert listProductBlock;


            //create charge
            List<Product2> listCharge = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Charge', '')
            };
            insert listCharge;


            //create Article
            List<Product2> listArticle = new List<Product2>{
                new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Article', ''),
                new UTIL_TestFactory.ProductFactory().createProduct('Article', '')
            };
            insert listArticle;

            List<SBQQ__ProductOption__c> listPackageToProduct = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[0].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[1].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProductList[2].Id ,listPackageList[0].Id)
            };
            insert listPackageToProduct;


            List<SBQQ__ProductOption__c> listProductToArticle = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[0].Id ,listProductList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[1].Id ,listProductList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listArticle[2].Id ,listProductList[0].Id)
            };
            insert listProductToArticle;


            List<SBQQ__ProductOption__c> listPackageToCharge = new List<SBQQ__ProductOption__c>{
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[0].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[1].Id ,listPackageList[0].Id),
                new UTIL_TestFactory.ProductOptionFactory().createProductOption(listCharge[2].Id ,listPackageList[0].Id)
            };
            insert listPackageToCharge;

        }
    }


    @isTest static void testExportBulk() {
       
        List<Product2> listExportProduct = [select id, name from product2 ];
 
        System.runAs(adminUser){ 
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listExportProduct);
            stdSetController.setSelected(listExportProduct);
            VFC01_GlobalExport ext = new VFC01_GlobalExport(stdSetController);
            ext.getAllProduct();
            system.System.debug('ext.mapProductWrapper' + ext.mapProductWrapper);
            system.System.debug('listExportProduct' + listExportProduct);
            for(product2 p:listExportProduct){
                System.debug('P' + p );
            }

            for(VFC01_GlobalExport.ProductWrapper pWrap:ext.mapProductWrapper.Values()){
                system.debug('pWrap ' + pWrap);
            }
            system.assertEquals( 22 ,ext.mapProductWrapper.size());
        }   
    }
    

}