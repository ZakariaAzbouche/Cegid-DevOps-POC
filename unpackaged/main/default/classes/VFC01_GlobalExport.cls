/**
 * @author Keshav - Comforth
 * @date Creation 2020-03-20
 * @description Export complete product catalogue in Excel
 *              Using Visualforce to benefit from 1M max records queried in readonly mode
 *              Rules as per specs:
 *              "Il peut exister un Package avec des Produits, avec des Charges et des Articles 
 *              Il peut exister des Produits SANS Packages, mais avec des Charges et des Articles
 *              Il peut exister des Articles ou des Charges sans Produit ni Package (fonctionnellement, ils ne sont pas encore apparenté).
 *              Il peut exister un Package lié directement à des Charges (les colonnes de Produits sont vides)
 */ 
public with sharing class VFC01_GlobalExport {
    
    private static final Id PACKAGE_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Package').getRecordTypeId();
    private static final Id PRODUCT_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
    private static final Id ARTICLE_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Article').getRecordTypeId();
    private static final Id CHARGE_RECTYPEID  =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId();
    private Set<Id> setChildProductIds;
    private Set<Id> setParentProductIds;
    private Set<Id> setPackageProductIds;
    public Integer i{get;set;} 
    public Map<Integer,ProductWrapper> mapProductWrapper{get;set;} 

    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Constructor method for visualforce controller
     * @param controller standard set controller
     */ 
    public VFC01_GlobalExport(ApexPages.StandardSetController controller) {
        //using map instead of list, because map allows to store more than 10,000 records in readonly mode
        mapProductWrapper = new Map<Integer,ProductWrapper>();
        i=0;
        setChildProductIds = new Set<Id>();
        setParentProductIds = new Set<Id>(); 
        setPackageProductIds = new Set<Id>();   
    }
    
    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Main apex page action method to launch database queries and return the wrapper result for Excel export
     * @return PageReference No redirection
     */      
    public PageReference getAllProduct() {
        //Get parent products and associated child products
        map<Id, Product2> mapProdChargeArticle = getParentProductWithChild();
        
        system.debug(LoggingLevel.DEBUG, '###1 Heap Size check = ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        
        //Get package products and their related parent product and related child products
        //Adding Limit to restrict data volume (as per discussion with Arnaud 2020-04-07)
        for(Product2 p:[SELECT Id,Name,Reference_Number__c,Family, 
                        (SELECT SBQQ__OptionalSKU__r.Id, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Reference_Number__c
                            , SBQQ__OptionalSKU__r.StructureLevel2__c
                            , SBQQ__OptionalSKU__r.RecordType.DeveloperName, SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                            , SBQQ__OptionalSKU__r.NoRoyalty__c
                            from SBQQ__Options__r 
                            where SBQQ__OptionalSKU__r.RecordTypeId IN (:PRODUCT_RECTYPEID
                                                        ,:CHARGE_RECTYPEID)
                            ORDER BY SBQQ__OptionalSKU__r.Reference_Number__c ASC NULLS LAST
                            LIMIT 100)
                            FROM Product2 
                            WHERE RecordTypeId=:PACKAGE_RECTYPEID
                            ORDER BY Reference_Number__c ASC]){
            
            setPackageProductIds.add(p.Id);
            
            //add package products with NO related parent products, NOR charge (NICE TO HAVE)
            if(p.SBQQ__Options__r.isEmpty()){
                productWrapper newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family
                                        , '', '', ''
                                        , '', '', '', '');
                mapProductWrapper.put(i++,newWrapperObj);                 
            }

            if(p.SBQQ__Options__r.size()>0){
                for(SBQQ__ProductOption__c proOption:p.SBQQ__Options__r){
                    if(proOption.SBQQ__OptionalSKU__r.RecordTypeId == CHARGE_RECTYPEID){
                        //store child products displayed
                        setChildProductIds.add(proOption.SBQQ__OptionalSKU__r.Id);                        
                        productWrapper newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                                    '','','',
                                                    proOption.SBQQ__OptionalSKU__r.RecordType.DeveloperName
                                                    , proOption.SBQQ__OptionalSKU__r.Name
                                                    , proOption.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                                                    , String.valueOf(proOption.SBQQ__OptionalSKU__r.NoRoyalty__c));
                        mapProductWrapper.put(i++,newWrapperObj); 
                    }

                    //use map to add related products to the package and add related child product to the parent 
                    if(mapProdChargeArticle.containsKey(proOption.SBQQ__OptionalSKU__r.Id)){
                        if(mapProdChargeArticle.get(proOption.SBQQ__OptionalSKU__r.Id).SBQQ__Options__r.isEmpty()){
                            productWrapper newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                        proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                                        proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                                        '', '','', '');
                            mapProductWrapper.put(i++,newWrapperObj); 
                        }

                        for(SBQQ__ProductOption__c po:mapProdChargeArticle.get(proOption.SBQQ__OptionalSKU__r.Id).SBQQ__Options__r){
                            //store child products displayed
                            setChildProductIds.add(po.SBQQ__OptionalSKU__r.Id);

                            productWrapper newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                    proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                                    proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                                    po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                                    po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                                    , String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c));                        
                            mapProductWrapper.put(i++,newWrapperObj); 
                        }
                        //store parent product now linked with package
                        setParentProductIds.add(proOption.SBQQ__OptionalSKU__r.Id);                          
                    }                                                        
                } 
            }            
        }

        //Get products with NO package
        getParentProductWithoutPkg(mapProdChargeArticle);
        
        system.debug(LoggingLevel.DEBUG, '###2 Heap Size check = ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());

        //Get child products with NO parent product, NO grand parent package
        getChildProductWithNoParent();

        system.debug(LoggingLevel.DEBUG, '###3 Heap Size check= ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
           
        return null;
    }

    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Fetch all parent products and their related child products (article/charge)
     * @return Map<Id, Product2> map of product2 id and product2
     */
    private Map<Id, Product2> getParentProductWithChild(){
        //Adding Limit to restrict data volume (as per discussion with Arnaud 2020-04-07)
        Map<Id, Product2> mapParentChildProd = new Map<Id, Product2>(
                                    [SELECT Id, Name,Reference_Number__c, StructureLevel2__c,
                                    (SELECT Id, SBQQ__OptionalSKU__r.Id,SBQQ__OptionalSKU__r.RecordType.DeveloperName,
                                        SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                                        , SBQQ__OptionalSKU__r.NoRoyalty__c
                                        FROM SBQQ__Options__r 
                                        where  SBQQ__OptionalSKU__r.RecordTypeID IN (:ARTICLE_RECTYPEID
                                                                                      ,:CHARGE_RECTYPEID)                                                                               
                                        ORDER BY SBQQ__OptionalSKU__r.Reference_Number__c ASC NULLS LAST
                                        LIMIT 100 ) 
                                    FROM Product2 
                                    WHERE RecordTypeID= :PRODUCT_RECTYPEID
                                    ORDER BY Reference_Number__c ASC
                                    ]
                                );
    
        return mapParentChildProd;    
    }

    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Constructor method for visualforce controller
     * @param mapProdChargeArticle map of parent product and related child products
     */
    private void getParentProductWithoutPkg(Map<Id,Product2> mapProdChargeArticle){
        Set<Id> setotherProdWithExistingPkg = new Set<Id>();
        //requery other products linked to same packages
        for(SBQQ__ProductOption__c pOpt : [SELECT SBQQ__OptionalSKU__r.Id
                FROM SBQQ__ProductOption__c
                WHERE SBQQ__OptionalSKU__r.RecordTypeId =:PRODUCT_RECTYPEID
                AND SBQQ__OptionalSKU__c NOT IN :setParentProductIds
                AND SBQQ__ConfiguredSKU__r.RecordTypeId =: PACKAGE_RECTYPEID
                AND SBQQ__ConfiguredSKU__c IN :setPackageProductIds]){
            setOtherProdWithExistingPkg.add(pOpt.SBQQ__OptionalSKU__r.Id);      
        }
        
        //CPU time is more optimised when using existing map data compared to than querying again
        for(Id parentProdId: mapProdChargeArticle.keySet()){                        
            Product2 parentProd = mapProdChargeArticle.get(parentProdId); 
            //exclude parent product already added & linked with package and exclude excess product linked to same pkg
            if(!setParentProductIds.contains(parentProdId) && !setOtherProdWithExistingPkg.contains(parentProdId)){
                if(mapProdChargeArticle.get(parentProdId).SBQQ__Options__r.isEmpty()){
                    productWrapper newWrapperObj = new productWrapper('', '', ''
                                ,parentProd.Name, parentProd.Reference_Number__c, parentProd.StructureLevel2__c 
                                ,'', '','', '');
                    mapProductWrapper.put(i++,newWrapperObj); 
                }

                //show parent products with child products, but without parent package
                for(SBQQ__ProductOption__c po:mapProdChargeArticle.get(parentProdId).SBQQ__Options__r){                                                
                    //store child products displayed
                    setChildProductIds.add(po.SBQQ__OptionalSKU__r.Id);
                    productWrapper newWrapperObj = new productWrapper('', '', '', 
                            parentProd.Name, parentProd.Reference_Number__c, parentProd.StructureLevel2__c , 
                            po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                            po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c, String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c));
                    mapProductWrapper.put(i++,newWrapperObj); 
                }
            }         
        }
    }

    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Find remaining child products NOT related to any grand parent NOR parent product
     *              Query excludes set of child products having parents and already added before        
     */
    private void getChildProductWithNoParent(){
        for(Product2 childProd : [SELECT Id, Name,RecordType.DeveloperName,SBQQ__ChargeType__c,NoRoyalty__c
                                  FROM Product2 
                                WHERE RecordTypeId IN (:ARTICLE_RECTYPEID,:CHARGE_RECTYPEID)
                                AND Id NOT IN: setChildProductIds]){
            productWrapper newWrapperObj = new productWrapper('', '', '', 
                                            '', '', '' , 
                                            childProd.RecordType.DeveloperName, childProd.Name, 
                                            childProd.SBQQ__ChargeType__c, String.valueOf(childProd.NoRoyalty__c));
            mapProductWrapper.put(i++,newWrapperObj); 
        }
    }
    
    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Wrapper class that combines details of grand-parent product field values,  
     *              parent product field values and child product field values
     *              Need to all several attributes so that all fields are displayed on same line     
     */ 
    public class ProductWrapper{
        /**
         * @author Keshav - Comforth
         * @date Creation 2020-03-20
         * @description Constructor method for the wrapper class
         * @param packProductName package product name
         * @param packReference package product reference
         * @param packStructure package structure field
         * @param prodProductName parent product name
         * @param prodRef parent product reference
         * @param prodStructure product structure field
         * @param artiRTName child product record type name
         * @param artiProductName child product name
         * @param articCharge child product charge field
         * @param artiRoyalty child product royalty field
         */ 
        public ProductWrapper(String packProductName, String packReference, String packStructure
                    , String prodProductName, String prodRef, String prodStructure
                    , String artiRTName, String artiProductName, String articCharge, String artiRoyalty) {
            this.packProductName = packProductName;
            this.packReference = packReference;
            this.packStructure = packStructure;
            this.prodProductName = prodProductName;
            this.prodRef = prodRef;
            this.prodStructure = prodStructure;
            this.artiRTName = artiRTName;
            this.artiProductName = artiProductName;
            this.articCharge = articCharge;
            this.artiRoyalty = artiRoyalty;
        }
        
        /**
         * @description packProductName grand-parent product name
         */
        public String packProductName {get; set;}

        /**
         * @description packReference grand-parent product reference
         */
        public String packReference {get; set;}

        /**
         * @description packStructure grand-parent product structure
         */
        public String packStructure {get; set;}

        /**
         * @description prodProductName parent product name
         */
        public String prodProductName {get; set;}

        /**
         * @description prodProductName parent product reference
         */
        public String prodRef {get; set;}
        
        /**
         * @description prodProductName parent product structure
         */
        public String prodStructure {get; set;}

        /**
         * @description artiRTName child product recordtype dev name
         */
        public String artiRTName {get; set;}
        
        /**
         * @description artiProductName child product name field
         */
        public String artiProductName {get; set;}
        
        /**
         * @description artiProductName child product charge field
         */
        public String articCharge {get; set;}

        /**
         * @description artiProductName child product royalty field
         */
        public String artiRoyalty {get; set;}
    }        
}