/**
 * @author Keshav - Comforth
 * @date Creation 2020-04-22
 * @description Export package and product pricing info
 *              Using Visualforce to benefit from 1M max records queried in readonly mode
 *              Reuses the global export but contains only pricing info related to product or package
 */ 
public with sharing class VFC02_ExportPricing {
    
    private static final Id PACKAGE_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Package').getRecordTypeId();
    private static final Id PRODUCT_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
    private static final Id ARTICLE_RECTYPEID =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Article').getRecordTypeId();
    private static final Id CHARGE_RECTYPEID  =Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId();
    private static final Id BLOCKPRICING_RECTYPEID  =Schema.SObjectType.Service_Level_Price__c.getRecordTypeInfosByDeveloperName().get('Block_Pricing').getRecordTypeId();
    private static final Id LISTPRICING_RECTYPEID  =Schema.SObjectType.Service_Level_Price__c.getRecordTypeInfosByDeveloperName().get('List_Pricing').getRecordTypeId();

    private Set<Id> setParentProductIds;
    private Set<Id> setPackageProductIds;
    public Integer i{get;set;}  
    public Map<Integer,ProductWrapper> mapProductWrapper{get;set;} 
    private map<Id, Product2> mapProdChargeArticle;
    private Map<Id, List<PricingWrapper>> mapServiceLevelPrice;
    private final Product2 product;
    public String recordId {get; set;}
    private Id recordTypeId;
    private Set<Id> setPackageId;
    private Set<Id> setProductId;

    /**
     * @author Keshav - Comforth
     * @date Creation 2020-04-22
     * @description Constructor method for visualforce controller
     * @param stdController standard set controller
     */ 
    public VFC02_ExportPricing(ApexPages.StandardController stdController) {
        //using map instead of list, because map allows to store more than 10,000 records in readonly mode
        mapProdChargeArticle = new map<Id, Product2>();
        mapProductWrapper = new Map<Integer,ProductWrapper>();
        mapServiceLevelPrice = new Map<Id, List<PricingWrapper>>();
        i=0;
        setParentProductIds = new Set<Id>(); 
        setPackageProductIds = new Set<Id>();
        setPackageId = new Set<Id>();
        setProductId = new Set<Id>();
        product = (product2)stdController.getRecord();
        recordId = product.Id;

        //fetch record type id to know if its a product or package
        for(Product2 prod : [SELECT recordtypeId FROM Product2 where Id=:recordId]){
            recordTypeId = prod.recordtypeId;   
        }
                 
        if(recordTypeId == PACKAGE_RECTYPEID){
            setPackageId.add(recordId);
            //fetch all products related to this package
            for(SBQQ__ProductOption__c opt:[SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c 
                    FROM SBQQ__ProductOption__c 
                    WHERE SBQQ__ConfiguredSKU__c =:recordId 
                    AND SBQQ__OptionalSKU__r.RecordTypeId =:PRODUCT_RECTYPEID
                    limit 100]){
                setProductId.add(opt.SBQQ__OptionalSKU__c);
            }
            System.debug(LoggingLevel.DEBUG, 'setProductIds : ' + setProductId);
            
        }else if(recordTypeId == PRODUCT_RECTYPEID){
            setProductId.add(recordId); 
            system.System.debug('setProductIds : ' + setProductId);
            //product can be child of 1 or many packages, querying their parent packages
            for(SBQQ__ProductOption__c opt:[SELECT SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c 
                    FROM SBQQ__ProductOption__c 
                    WHERE SBQQ__OptionalSKU__c =:recordId
                    AND SBQQ__ConfiguredSKU__r.RecordTypeId =:PACKAGE_RECTYPEID
                    limit 100]){
                setPackageId.add(opt.SBQQ__ConfiguredSKU__c);
            }
        }else{
            return;
        }
    }
    
    /**
     * @author Keshav - Comforth
     * @date Creation 2020-03-20
     * @description Main apex page action method to launch database queries and return the wrapper result for Excel export
     * @return PageReference No redirection
     */      
    public PageReference getAllProduct() {
        system.debug(LoggingLevel.DEBUG,'Record Id  : ' + recordId);
        system.debug(LoggingLevel.DEBUG,'Record Type : ' + recordTypeId);
        //Get parent products and associated child products
        mapProdChargeArticle = getParentProductWithChild();
        mapServiceLevelPrice = getServiceLevelPrice();
        
        system.debug(LoggingLevel.DEBUG, '###1 Heap Size check = ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());

        
        //Get package products and their related parent product and related child products
        //Adding Limit to restrict data volume (as per discussion with Arnaud 2020-04-07)
        for(Product2 p:[SELECT Id,Name,Reference_Number__c,Family, 
                        (SELECT SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.Reference_Number__c
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
                            AND Id IN :setPackageId
                            ORDER BY Reference_Number__c ASC]){
            
            setPackageProductIds.add(p.Id);
            
            //add package products with NO related parent products, NOR charge (NICE TO HAVE)
            if(p.SBQQ__Options__r.isEmpty()){
                for(PricingWrapper pricingPkg : mapServiceLevelPrice.get(p.Id)){
                    PricingWrapper pkgPrice = new PricingWrapper(pricingPkg.slpPriceBook,pricingPkg.salesPurpose
                            , pricingPkg.lowerBound, pricingPkg.upperBound, pricingPkg.price
                            ,pricingPkg.discountTierLowerBound,pricingPkg.discountTierUpperBound,pricingPkg.discountTierDiscount
                            );
                    productWrapper newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family
                                            , '', '', ''
                                            , '', '', '', '',pkgPrice,null);                                
                    mapProductWrapper.put(i++,newWrapperObj);                                             
                }
            }

            for(SBQQ__ProductOption__c proOption:p.SBQQ__Options__r){
                productWrapper newWrapperObj;
                if(proOption.SBQQ__OptionalSKU__r.RecordTypeId == CHARGE_RECTYPEID){                                                
                    for(PricingWrapper pricingPkg : mapServiceLevelPrice.get(p.Id)){
                        PricingWrapper pkgPrice = new PricingWrapper(pricingPkg.slpPriceBook,pricingPkg.salesPurpose
                                , pricingPkg.lowerBound, pricingPkg.upperBound, pricingPkg.price
                                ,pricingPkg.discountTierLowerBound,pricingPkg.discountTierUpperBound
                                ,pricingPkg.discountTierDiscount
                                );
                        newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                                '','','',
                                                proOption.SBQQ__OptionalSKU__r.RecordType.DeveloperName
                                                , proOption.SBQQ__OptionalSKU__r.Name
                                                , proOption.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                                                , String.valueOf(proOption.SBQQ__OptionalSKU__r.NoRoyalty__c)
                                                ,pkgPrice,null);                                
                        mapProductWrapper.put(i++,newWrapperObj);                                             
                    }                    
                }else if(proOption.SBQQ__OptionalSKU__r.RecordTypeId == PRODUCT_RECTYPEID){
                    //use map to add related products to the package and add related child product to the parent 
                    addProductRelatedInfo(p,proOption );
                    system.debug('***getCpuTime()***'+Limits.getCpuTime());
                                            
                }                                                 
            }                         
        }
       
		
        system.debug(LoggingLevel.DEBUG, '###1 mapProductWrapper.size() = ' + mapProductWrapper.size());

        //Get products with NO package
        if(recordTypeId == PRODUCT_RECTYPEID){
            getParentProductWithoutPkg();
        }
        
        system.debug(LoggingLevel.DEBUG, '###2 Heap Size check = ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize());
        system.debug(LoggingLevel.DEBUG, '###2 mapProductWrapper.size() = ' + mapProductWrapper.size());

        //No need to fetch articles/charges independent of parent
        
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
                                (SELECT Id, SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.RecordType.DeveloperName,
                                    SBQQ__OptionalSKU__r.Name, SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                                    , SBQQ__OptionalSKU__r.NoRoyalty__c
                                    FROM SBQQ__Options__r 
                                    where  SBQQ__OptionalSKU__r.RecordTypeID IN (:ARTICLE_RECTYPEID
                                                                                    ,:CHARGE_RECTYPEID)                                                                               
                                    ORDER BY SBQQ__OptionalSKU__r.Reference_Number__c ASC NULLS LAST
                                    LIMIT 100 ) 
                                FROM Product2 
                                WHERE RecordTypeID= :PRODUCT_RECTYPEID
                                AND Id IN:setProductId
                                ORDER BY Reference_Number__c ASC
                                ]
                            );
                
        return mapParentChildProd;    
    }


    /**
     * @author Keshav - Comforth
     * @date Creation 2020-04-24
     * @description Add related product, article, charge and pricing info
     * @param p Product2 matching the package
     * @param proOption SBQQ__ProductOption__c record
     */
    private void addProductRelatedInfo(Product2 p,SBQQ__ProductOption__c proOption ){
        ProductWrapper newWrapperObj;
        if(mapProdChargeArticle.containsKey(proOption.SBQQ__OptionalSKU__c)){
            if(mapProdChargeArticle.get(proOption.SBQQ__OptionalSKU__c).SBQQ__Options__r.isEmpty()){
                if(mapServiceLevelPrice.containsKey(p.Id) && mapServiceLevelPrice.containsKey(proOption.SBQQ__OptionalSKU__c)){
                    for(PricingWrapper pricingPkg : mapServiceLevelPrice.get(p.Id)){
                        PricingWrapper pkgPrice = new PricingWrapper(pricingPkg.slpPriceBook,pricingPkg.salesPurpose
                            , pricingPkg.lowerBound, pricingPkg.upperBound, pricingPkg.price
                            ,pricingPkg.discountTierLowerBound,pricingPkg.discountTierUpperBound,pricingPkg.discountTierDiscount
                            );
                            
                        for(PricingWrapper pricingProduct : mapServiceLevelPrice.get(proOption.SBQQ__OptionalSKU__c)){
                            PricingWrapper prdPrice = new PricingWrapper(pricingProduct.slpPriceBook,pricingProduct.salesPurpose
                                    , pricingProduct.lowerBound, pricingProduct.upperBound, pricingProduct.price
                                    ,pricingProduct.discountTierLowerBound,pricingProduct.discountTierUpperBound
                                    ,pricingProduct.discountTierDiscount
                                    );
                            
                            newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                                proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                                '', '','', '',pkgPrice,prdPrice);
                            
                            mapProductWrapper.put(i++,newWrapperObj); 
                        }
                    }
                    system.debug('***getCpuTime()***'+Limits.getCpuTime());
                }
                else if(mapServiceLevelPrice.containsKey(p.Id) && !mapServiceLevelPrice.containsKey(proOption.SBQQ__OptionalSKU__c)){
                    for(PricingWrapper pricingPkg : mapServiceLevelPrice.get(p.Id)){
                        PricingWrapper pkgPrice = new PricingWrapper(pricingPkg.slpPriceBook,pricingPkg.salesPurpose
                                , pricingPkg.lowerBound, pricingPkg.upperBound, pricingPkg.price
                                ,pricingPkg.discountTierLowerBound,pricingPkg.discountTierUpperBound,pricingPkg.discountTierDiscount
                                );
                        newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                    proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                                    proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                                    '', '','', '',pkgPrice,null);
                                    
                        mapProductWrapper.put(i++,newWrapperObj);                                             
                    }
                }
                else if(!mapServiceLevelPrice.containsKey(p.Id) && mapServiceLevelPrice.containsKey(proOption.SBQQ__OptionalSKU__c)){
                    for(PricingWrapper pricingProduct : mapServiceLevelPrice.get(proOption.SBQQ__OptionalSKU__c)){
                        PricingWrapper prdPrice = new PricingWrapper(pricingProduct.slpPriceBook,pricingProduct.salesPurpose
                                , pricingProduct.lowerBound, pricingProduct.upperBound, pricingProduct.price
                                ,pricingProduct.discountTierLowerBound,pricingProduct.discountTierUpperBound
                                ,pricingProduct.discountTierDiscount
                                );
                        
                        newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                            proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                            proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                            '', '','', '',null,prdPrice);
                        
                        mapProductWrapper.put(i++,newWrapperObj); 
                    }
                }
                else {
                    //all pricing field are null
                    newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                        proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                        proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                        '', '','', '',null,null);
                    mapProductWrapper.put(i++,newWrapperObj);
                }
                
            }
            
            //parent product have child article/charge
            for(SBQQ__ProductOption__c po:mapProdChargeArticle.get(proOption.SBQQ__OptionalSKU__c).SBQQ__Options__r){                                                                
                ///adding pricing info pkg and/or prod
                if(mapServiceLevelPrice.containsKey(p.Id) && mapServiceLevelPrice.containsKey(proOption.SBQQ__OptionalSKU__c)){
                    for(PricingWrapper pricingPkg : mapServiceLevelPrice.get(p.Id)){
                        PricingWrapper pkgPrice = new PricingWrapper(pricingPkg.slpPriceBook,pricingPkg.salesPurpose
                            , pricingPkg.lowerBound, pricingPkg.upperBound, pricingPkg.price
                            ,pricingPkg.discountTierLowerBound,pricingPkg.discountTierUpperBound,pricingPkg.discountTierDiscount
                            );
                            
                        for(PricingWrapper pricingProduct : mapServiceLevelPrice.get(proOption.SBQQ__OptionalSKU__c)){
                            PricingWrapper prdPrice = new PricingWrapper(pricingProduct.slpPriceBook,pricingProduct.salesPurpose
                                , pricingProduct.lowerBound, pricingProduct.upperBound, pricingProduct.price
                                ,pricingProduct.discountTierLowerBound,pricingProduct.discountTierUpperBound
                                ,pricingProduct.discountTierDiscount
                                );
                            
                            newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                                    proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                                    proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                                    po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                                    po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                                    , String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c)
                                ,pkgPrice,prdPrice);
                            
                            mapProductWrapper.put(i++,newWrapperObj); 
                        }
                    }
                }
                else if(mapServiceLevelPrice.containsKey(p.Id) && !mapServiceLevelPrice.containsKey(proOption.SBQQ__OptionalSKU__c)){
                    for(PricingWrapper pricingPkg : mapServiceLevelPrice.get(p.Id)){
                        PricingWrapper pkgPrice = new PricingWrapper(pricingPkg.slpPriceBook
                            ,pricingPkg.salesPurpose, pricingPkg.lowerBound, pricingPkg.upperBound, pricingPkg.price
                            ,pricingPkg.discountTierLowerBound,pricingPkg.discountTierUpperBound
                            ,pricingPkg.discountTierDiscount
                            );
                        newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                        proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                        proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                        po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                        po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                        ,String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c)
                        ,pkgPrice,null);
                                    
                        mapProductWrapper.put(i++,newWrapperObj);                                             
                    }
                }
                else if(!mapServiceLevelPrice.containsKey(p.Id) && mapServiceLevelPrice.containsKey(proOption.SBQQ__OptionalSKU__c)){
                    for(PricingWrapper pricingProduct : mapServiceLevelPrice.get(proOption.SBQQ__OptionalSKU__c)){
                        PricingWrapper prdPrice = new PricingWrapper(pricingProduct.slpPriceBook
                            ,pricingProduct.salesPurpose, pricingProduct.lowerBound, pricingProduct.upperBound, pricingProduct.price
                            ,pricingProduct.discountTierLowerBound,pricingProduct.discountTierUpperBound
                            ,pricingProduct.discountTierDiscount
                            );
                        
                        newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                        proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                        proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                        po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                        po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                        , String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c)
                            ,null,prdPrice);
                        
                        mapProductWrapper.put(i++,newWrapperObj); 
                    }
                }
                else {
                    //all pricing field are null
                    newWrapperObj = new productWrapper(p.Name, p.Reference_Number__c, p.Family, 
                        proOption.SBQQ__OptionalSKU__r.Name, proOption.SBQQ__OptionalSKU__r.Reference_Number__c,
                        proOption.SBQQ__OptionalSKU__r.StructureLevel2__c , 
                        po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                        po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c
                        , String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c)
                        ,null,null);
                    mapProductWrapper.put(i++,newWrapperObj);
                }
                ////
            }
            //store parent product now linked with package
            setParentProductIds.add(proOption.SBQQ__OptionalSKU__c);                          
        }  
        
    }

    /**
     * @author Keshav - Comforth
     * @date Creation 2020-04-22
     * @description Find SLP (Service level Price)
     * @return Map<Id, List<PricingWrapper>> map of list pricing wrapper           
     */
    private Map<Id, List<PricingWrapper>> getServiceLevelPrice(){
        Map<Id, List<PricingWrapper>> mapProductPricing= new Map<Id, List<PricingWrapper>>();
        Set<Id> setProdIds = new Set<Id>();
        setProdIds.addAll(setPackageId);        
        setProdIds.addAll(setProductId);        
        //setProdIds.addAll(mapProdChargeArticle.keySet());

        system.debug('setPackageId : ' + setPackageId);
        system.debug('setProductId : ' + setProductId);
        system.debug('mapProdChargeArticle.keySet() : ' + mapProdChargeArticle.keySet());
        system.debug('mapProdChargeArticle.keySet().size() : ' + mapProdChargeArticle.keySet().size());
        system.debug('setProdIds ' + setProdIds.size());

        system.debug('***getCpuTime()***'+Limits.getCpuTime());
        
        system.debug(LoggingLevel.DEBUG, 'setProdIds = '+ setProdIds);
        for(Service_Level_Price__c slp : [SELECT id,Product__c,Product__r.Reference_Number__c
                        , Product__r.RecordType.Developername, Price_Book__r.Name
                        ,RecordType.Developername, tolabel(Sales_Purpose__c), Lower_Bound__c, Upper_Bound__c , RegularPrice__c 
                        from Service_Level_Price__c
                        where Product__r.RecordTypeID IN (:PACKAGE_RECTYPEID, :PRODUCT_RECTYPEID)
                        AND Product__c IN :setProdIds
                        and RecordtypeId =:BLOCKPRICING_RECTYPEID
                        and Discount_Schedule__c =null
                        order by Product__r.Reference_Number__c asc, RecordType.Developername asc
                        ]){
            
            PricingWrapper pricingWraps = new PricingWrapper(slp.Price_Book__r.Name, slp.Sales_Purpose__c, slp.Lower_Bound__c
                                                             , slp.Upper_Bound__c,slp.RegularPrice__c
                                                             , null, null, null
                                                            );
            
            List<PricingWrapper> lstPriceWrap = mapProductPricing.containsKey(slp.Product__c) ? 
                mapProductPricing.get(slp.Product__c) : new List<PricingWrapper>();
            lstPriceWrap.add(pricingWraps);
            mapProductPricing.put(slp.Product__c, lstPriceWrap);  
     
        }

        for (SBQQ__DiscountSchedule__c sched : [SELECT id, name,
                     (SELECT id,name,Product__c,Product__r.Reference_Number__c
                     , Product__r.RecordType.Developername, RecordType.Developername, Price_Book__r.Name
                     , RegularPrice__c,toLabel(Sales_Purpose__c),Lower_Bound__c,Upper_Bound__c
                     ,Discount_Schedule__c from Service_Level_Prices__r 
                     where Product__r.RecordTypeID IN (:PACKAGE_RECTYPEID, :PRODUCT_RECTYPEID)
                     and RecordtypeId =:LISTPRICING_RECTYPEID
                     AND Product__c IN :setProdIds
                     order by Product__r.Reference_Number__c asc
                     limit 100 ),
                     (SELECT SBQQ__Number__c,SBQQ__Schedule__c,SBQQ__LowerBound__c,SBQQ__UpperBound__c 
                     ,SBQQ__Discount__c from SBQQ__DiscountTiers__r
                     ORDER BY SBQQ__Number__c ASC
                     limit 100)
                     FROM SBQQ__DiscountSchedule__c
                     limit 100]){

            if(sched.Service_Level_Prices__r.size()>0){
                for(Service_Level_Price__c price: sched.Service_Level_Prices__r){                    
                    if(sched.SBQQ__DiscountTiers__r.size()>0){
                        for(SBQQ__DiscountTier__c tier : sched.SBQQ__DiscountTiers__r){        
                            Decimal discRounded = (tier.SBQQ__Discount__c !=null ? tier.SBQQ__Discount__c.setScale(2): null);
                            PricingWrapper pricingWraps = new PricingWrapper(price.Price_Book__r.Name,  price.Sales_Purpose__c
                                , price.Lower_Bound__c, price.Upper_Bound__c,price.RegularPrice__c,
                                tier.SBQQ__LowerBound__c, tier.SBQQ__UpperBound__c,discRounded
                                );
                                                        
                            List<PricingWrapper> lstPriceWrap = mapProductPricing.containsKey(price.Product__c) ? 
                                        mapProductPricing.get(price.Product__c) : new List<PricingWrapper>();
                            lstPriceWrap.add(pricingWraps);
                            mapProductPricing.put(price.Product__c, lstPriceWrap);
                        }
                    }else{
                        //no discount tier records
                        PricingWrapper pricingWraps = new PricingWrapper(price.Price_Book__r.Name, price.Sales_Purpose__c
                            , price.Lower_Bound__c, price.Upper_Bound__c,price.RegularPrice__c,
                            null,null,null); 
                    
                            List<PricingWrapper> lstPriceWrap = mapProductPricing.containsKey(price.Product__c) ?   
                                    mapProductPricing.get(price.Product__c) : new List<PricingWrapper>();
                            lstPriceWrap.add(pricingWraps);
                            mapProductPricing.put(price.Product__c, lstPriceWrap);
                    }
                    
                }
            }
        } 
        
        return mapProductPricing;
    }


    /**
     * @author Keshav - Comforth
     * @date Creation 2020-04-22
     * @description Constructor method for visualforce controller
     */
    private void getParentProductWithoutPkg(){
        Set<Id> setotherProdWithExistingPkg = new Set<Id>();
        //requery other products linked to same packages
        for(SBQQ__ProductOption__c pOpt : [SELECT SBQQ__OptionalSKU__r.Id
                FROM SBQQ__ProductOption__c
                WHERE SBQQ__OptionalSKU__r.RecordTypeId =:PRODUCT_RECTYPEID
                AND SBQQ__OptionalSKU__c NOT IN :setParentProductIds
                AND SBQQ__ConfiguredSKU__c IN :setPackageId]){
            setOtherProdWithExistingPkg.add(pOpt.SBQQ__OptionalSKU__r.Id);      
        }
        
        //CPU time is more optimised when using existing map data compared to than querying again
        for(Id parentProdId: mapProdChargeArticle.keySet()){                        
            Product2 parentProd = mapProdChargeArticle.get(parentProdId); 
            //exclude parent product already added & linked with package and exclude excess product linked to same pkg
            if(!setParentProductIds.contains(parentProdId) && !setOtherProdWithExistingPkg.contains(parentProdId)){
                if(mapProdChargeArticle.get(parentProdId).SBQQ__Options__r.isEmpty()){
                    //adding pricing info
                    for(PricingWrapper pricingProduct : mapServiceLevelPrice.get(parentProdId)){
                        PricingWrapper prdPrice = new PricingWrapper(pricingProduct.slpPriceBook,pricingProduct.salesPurpose
                                , pricingProduct.lowerBound, pricingProduct.upperBound, pricingProduct.price
                                ,pricingProduct.discountTierLowerBound,pricingProduct.discountTierUpperBound
                                ,pricingProduct.discountTierDiscount
                                );
                        
                        productWrapper newWrapperObj = new productWrapper('', '', ''
                                        ,parentProd.Name, parentProd.Reference_Number__c, parentProd.StructureLevel2__c 
                                        ,'', '','', '',null,prdPrice);
                        
                        mapProductWrapper.put(i++,newWrapperObj); 
                    }
                }

                //show parent products with child products, but without parent package
                for(SBQQ__ProductOption__c po:mapProdChargeArticle.get(parentProdId).SBQQ__Options__r){                                                
                    //adding pricing info
                    for(PricingWrapper pricingProduct : mapServiceLevelPrice.get(parentProdId)){
                        PricingWrapper prdPrice = new PricingWrapper(pricingProduct.slpPriceBook,pricingProduct.salesPurpose
                        , pricingProduct.lowerBound, pricingProduct.upperBound, pricingProduct.price
                        ,pricingProduct.discountTierLowerBound,pricingProduct.discountTierUpperBound
                        ,pricingProduct.discountTierDiscount
                        );
                        
                        productWrapper newWrapperObj = new productWrapper('', '', '', 
                            parentProd.Name, parentProd.Reference_Number__c, parentProd.StructureLevel2__c , 
                            po.SBQQ__OptionalSKU__r.RecordType.DeveloperName, po.SBQQ__OptionalSKU__r.Name, 
                            po.SBQQ__OptionalSKU__r.SBQQ__ChargeType__c, String.valueOf(po.SBQQ__OptionalSKU__r.NoRoyalty__c)
                            ,null,prdPrice);
                        
                        mapProductWrapper.put(i++,newWrapperObj); 
                    }
                }
            }         
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
                    , String artiRTName, String artiProductName, String articCharge, String artiRoyalty
                              ,PricingWrapper packPricing, PricingWrapper prodPricing) {

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
            this.packPricing = packPricing;
            this.prodPricing = prodPricing;
        }
        
        /**
         * @description packProductName grand-parent product name
         */
        public String packProductName {get; set;}
        
        /**
         * @description packProductName grand-parent product name
         */
        public PricingWrapper packPricing {get; set;}
        public PricingWrapper prodPricing {get; set;}

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

	public class PricingWrapper{
        
        public PricingWrapper(String slpPriceBook, String salesPurpose, Decimal lowerBound, Decimal upperBound
                              ,Decimal price, Decimal discountTierLowerbound, Decimal discountTierUpperbound
                              , Decimal discountTierDiscount){
                                  
                                  this.slpPriceBook = slpPriceBook;
                                  this.salesPurpose = salesPurpose;
                                  this.lowerBound = lowerBound;
                                  this.upperBound = upperBound;
                                  this.price = price;
                                  this.discountTierLowerbound = discountTierLowerbound;
                                  this.discountTierUpperbound = discountTierUpperbound;
                                  this.discountTierDiscount = discountTierDiscount;
                                  
         }
        
        public String slpPriceBook {get; set;}
        public String salesPurpose {get; set;}
        public Decimal lowerBound {get; set;}
        public Decimal upperBound {get; set;}
        public Decimal price {get; set;}
        public Decimal discountTierLowerbound {get; set;}
        public Decimal discountTierUpperbound {get; set;}
        public Decimal discountTierDiscount {get; set;}
        
    }

}