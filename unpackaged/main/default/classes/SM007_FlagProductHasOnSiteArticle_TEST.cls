/**
 * @author Shamina M - Comforth Karoo
 * @date 2020-09-15
 * @description Test class for SM007_FlagProductHasOnSiteArticle
*/
@isTest
private class SM007_FlagProductHasOnSiteArticle_TEST {
    
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'flagonsite@email.com';

    @TestSetup static void setup(){    
        //testing as admin because of issues with CPQ rights when testing as Cegid sales
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
                List<Product2> listProduct = new List<Product2>();
                for(Integer i=0; i<10;i++ ){
                    Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List');
                    Product2 article = new UTIL_TestFactory.ProductFactory().createProduct('Article', 'List');
                    article.Realization_Conditions__c = 'On Site';

                    //alternate value for StructureLevel1/ family
                    if(math.mod(i, 2) == 0){
                        prod.family = '140';
                        article.Catalog__c = true;
                        article.OPCA_Eligible__c =true;
                    }
                    else{
                        prod.family = '130';
                        article.Catalog__c = false;
                        article.OPCA_Eligible__c =false;
                    }

                    listProduct.add(prod);
                    listProduct.add(article);
                }
                insert listProduct;

                
            Test.stopTest();
        }
        
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-09-15
    * @description Generic method to create test data for product options
    */
    private static List<SBQQ__ProductOption__c> createProductOptions(){
        List<SBQQ__ProductOption__c> listProdOpt = new List<SBQQ__ProductOption__c>();
        List<Product2> listProd2Product = [SELECT Id from Product2 where RecordType.DeveloperName = 'Product'];
        List<Product2> listProd2Article = [SELECT Id from Product2 where RecordType.DeveloperName = 'Article'
                                                        AND Realization_Conditions__c = 'On Site'];

        for(Integer i=0; i<10;i++ ){
            SBQQ__ProductOption__c prodOpt = new UTIL_TestFactory.ProductOptionFactory().createProductOption(listProd2Article[i].Id,listProd2Product[i].Id);
            prodOpt.SBQQ__Number__c = i;
            prodOpt.SBQQ__Quantity__c =1;
            listProdOpt.add(prodOpt);
        }

        return listProdOpt;
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-09-15
    * @description Test insert product option
    */
    @isTest static void testInsertProductOption() {
        System.runAs(adminUser){
            List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();

            Test.startTest();                
                insert listProdOpt;
            Test.stopTest();

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c,OPCA_Eligible__c
                                        FROM Product2 
                                        WHERE RecordType.DeveloperName = 'Product']){
                if(prodConfSKU.family == '140'){
                    System.assertEquals(true, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c true');
                    System.assertEquals(true, prodConfSKU.Catalog__c, 'Catalog__c true');
                    System.assertEquals(true, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c true');
                }else{
                    System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c false');
                    System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                    System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
                }
            }

        }
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-09-15
    * @description Test delete all product option
    */
    @isTest static void testDeleteAllProductOption() {
        System.runAs(adminUser){
            List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();
            insert listProdOpt;

            Test.startTest(); 
                delete listProdOpt;               
            Test.stopTest();

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c, OPCA_Eligible__c
                                         from Product2 where RecordType.DeveloperName = 'Product']){
                //System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c false');
                //System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                //System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
            }

        }
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-09-15
    * @description Test update product option
    */
    @isTest static void testUpdateProductOption() {
        System.runAs(adminUser){
            List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();
            insert listProdOpt;

            List<Product2> listProd2 = new List<Product2>();
            List<Product2> listProd2Product = new List<Product2>();
            List<Product2> listProd2Article= new List<Product2>();

            for(Integer i=0; i<10;i++ ){
                Product2 prod = new UTIL_TestFactory.ProductFactory().createProduct('Product', 'List');
                prod.family = '130';
                listProd2Product.add(prod);

                Product2 article = new UTIL_TestFactory.ProductFactory().createProduct('Article', 'List');
                article.Realization_Conditions__c = 'Remote';
                listProd2Article.add(article);
            }

            listProd2.addAll(listProd2Product);
            listProd2.addAll(listProd2Article);
            insert listProd2;

            for(Integer i=0; i<listProdOpt.size();i++ ){
                listProdOpt[i].SBQQ__ConfiguredSKU__c = listProd2Product[i].Id;
                listProdOpt[i].SBQQ__OptionalSKU__c = listProd2Article[i].Id;
            } 
            
            Test.startTest();
                update listProdOpt;               
            Test.stopTest();

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c, OPCA_Eligible__c,
                                       (Select ID,Tech_HasOnSiteArticle__c,Catalog__c,OPCA_Eligible__c,SBQQ__OptionalSKU__c,Schedulable__c,Service_Term__c,Duration__c,Max_Trainee__c,Realization_Conditions__c 
                                        FROM SBQQ__Options__r 
                                        WHERE  SBQQ__ConfiguredSKU__r.Family = '140' 
                                        LIMIT 1
                                       ) 
                                       FROM Product2  
                                       WHERE RecordType.DeveloperName = 'Product']){
                                           if(listProd2Product.contains(prodConfSKU)){
                                               if(prodConfSKU.SBQQ__Options__r.size()> 0){
                                                   for(SBQQ__ProductOption__c prodOpt: prodConfSKU.SBQQ__Options__r){
                                                       System.assertEquals(prodOpt.Tech_HasOnSiteArticle__c, prodConfSKU.Tech_HasOnSiteArticle__c, 'updated Tech_HasOnSiteArticle__c false');
                                                       System.assertEquals(prodOpt.Catalog__c, prodConfSKU.Catalog__c, 'Catalog__c false');
                                                       System.assertEquals(prodOpt.OPCA_Eligible__c, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
                                                   }
                                               }else{
                                                   system.debug('------prodConfSKU'+ prodConfSKU);
                                                   System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'updated Tech_HasOnSiteArticle__c false');
                                                   System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                                                   System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
                                               }
                                           }
                                       }

        }
    }

    /*
    * @author Shamina M - Comforth
    * @created 2020-08-31
    * @description Test Bypass trigger
    */
    @isTest static void testBypassTrigger() {
        System.runAs(adminUser){
            BypassTrigger__c byPass = new BypassTrigger__c(SetupOwnerId =adminUser.Id,FlagHasOnSiteArticle__c = true );
            insert byPass;
            
            List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();

            Test.startTest();                
                insert listProdOpt;
            Test.stopTest();

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c, OPCA_Eligible__c
                                         from Product2 where RecordType.DeveloperName = 'Product']){
                //trigger not fired
                System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'Bypass enabled, checkbox not updated');
                System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
            }

        }
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-11-06
    * @description Test update flags on article products
    */
    @isTest static void testUpdateArticleProducts() {
        System.runAs(adminUser){
            List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();
            insert listProdOpt;

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c,OPCA_Eligible__c
                                        FROM Product2 
                                        WHERE RecordType.DeveloperName = 'Product']){
                if(prodConfSKU.family == '140'){
                    System.assertEquals(true, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c true');
                    System.assertEquals(true, prodConfSKU.Catalog__c, 'Catalog__c true');
                    System.assertEquals(true, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c true');
                }else{
                    System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c false');
                    System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                    System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
                }
            }

            List<Product2> listArticleProd = new List<Product2>();
            for(Product2 prod: [SELECT Id from Product2 where RecordType.DeveloperName = 'Article']){
                prod.Realization_Conditions__c = 'Remote';  
                prod.Catalog__c = false;
                prod.OPCA_Eligible__c = false; 
                listArticleProd.add(prod);                 
            }

            Test.startTest();  
                update listArticleProd;
            Test.stopTest();

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c,OPCA_Eligible__c,
                                       		(Select ID,Tech_HasOnSiteArticle__c,Catalog__c,OPCA_Eligible__c,SBQQ__OptionalSKU__c,Schedulable__c,Service_Term__c,Duration__c,Max_Trainee__c,Realization_Conditions__c 
                                        	FROM SBQQ__Options__r 
                                        	WHERE  SBQQ__ConfiguredSKU__r.Family = '140' 
                                        	LIMIT 1) 
                                       FROM Product2 
                                       WHERE RecordType.DeveloperName = 'Product']){
                                           if(prodConfSKU.SBQQ__Options__r.size() == 0){
                                               System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c false');
                                               System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                                               System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
                                           }
            }

        }
    }

    /*
    * @author Shamina M - Comforth Karoo
    * @created 2020-11-06
    * @description Test delete article products
    */
    @isTest static void testDeleteArticleProducts() {
        System.runAs(adminUser){
            List<SBQQ__ProductOption__c> listProdOpt = createProductOptions();
            insert listProdOpt;

            List<Product2> listArticleProd = [SELECT Id from Product2 where RecordType.DeveloperName = 'Article'];

            Test.startTest();  
                delete listArticleProd;
            Test.stopTest();

            for(Product2 prodConfSKU: [SELECT Id,Tech_HasOnSiteArticle__c,Family,Catalog__c,OPCA_Eligible__c
                                        FROM Product2 
                                        WHERE RecordType.DeveloperName = 'Product']){
                System.assertEquals(false, prodConfSKU.Tech_HasOnSiteArticle__c, 'Tech_HasOnSiteArticle__c false');
                System.assertEquals(false, prodConfSKU.Catalog__c, 'Catalog__c false');
                System.assertEquals(false, prodConfSKU.OPCA_Eligible__c, 'OPCA_Eligible__c false');
            }

        }
    }
}