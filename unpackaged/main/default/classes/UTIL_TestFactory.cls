/**
* @author Keshav - Comforth
* @date 2020-02-04
* @group UTIL
* @description Classe utilitaire de test gérant la création de données
*/
@isTest
public with sharing class UTIL_TestFactory {
    
    private static String SYSTEM_ADMINISTRATOR_PROFILE_NAME = 'System Administrator';
    private static String SYSTEM_ADMINISTRATOR_PROFILE_NAME_FR = 'Administrateur système';
    private static String CEGID_SALES_PROFILE_NAME = 'Cegid Sales';
    private static String MARKETO_PROFILE_NAME = 'Marketo';
    private static String IM_PARTNER_PROFILE_NAME = 'IM Partner';

    
    public class UserFactory {
        public User createRunningUserAdministrator() {
            /**
            * @description Crée un utilisateur de type admin
            */
            
            User administratorUser = new User(
                alias = 'Test',
                email = 'test.magellan-admin@example.com',
                emailencodingkey = 'UTF-8',
                BypassPB__c = true,
                BypassVR__c = true,
                BypassWF__c = true,
                lastname = 'testAdmin',
                languagelocalekey = 'fr',
                localesidkey = 'fr_FR',
                profileid = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :SYSTEM_ADMINISTRATOR_PROFILE_NAME
                    OR Name = :SYSTEM_ADMINISTRATOR_PROFILE_NAME_FR
                    LIMIT 1
                ][0].Id,
                timezonesidkey = 'Europe/Paris',
                username = 'test.magellan-admin' + System.now().millisecond()
                + UserInfo.getOrganizationId() + '@example.com'
            );
            return administratorUser;
        }

        public User createUserCegidSales() {
            /**
            * @description Crée un utilisateur de Cegid sales
            */            
            User userCegidSales = new User(
                alias = 'Test',
                email = 'test.sales@example.com',
                emailencodingkey = 'UTF-8',
                BypassPB__c = true,
                BypassVR__c = true,
                BypassWF__c = true,
                lastname = 'testsales',
                languagelocalekey = 'fr',
                localesidkey = 'fr_FR',
                profileid = [
                    SELECT Id
                    FROM Profile
                    WHERE Name = :CEGID_SALES_PROFILE_NAME
                    LIMIT 1
                ][0].Id,
                timezonesidkey = 'Europe/Paris',
                username = 'test.sales' + System.now().millisecond()
                + UserInfo.getOrganizationId() + '@example.com'
            );
            return userCegidSales;
        }
        
               public User createUserMarketo() {
        /**
        * @description Crée un utilisateur de Marketo
        */            
        User userMarketo = new User(
            alias = 'Test',
            email = 'test.sales@example.com',
            emailencodingkey = 'UTF-8',
            BypassPB__c = true,
            BypassVR__c = true,
            BypassWF__c = true,
            lastname = 'testsales',
            languagelocalekey = 'fr',
            localesidkey = 'fr_FR',
            profileid = [
                SELECT Id
                FROM Profile
                WHERE Name = :MARKETO_PROFILE_NAME
                LIMIT 1
            ][0].Id,
            timezonesidkey = 'Europe/Paris',
            username = 'test.marketo' + System.now().millisecond()
            + UserInfo.getOrganizationId() + '@example.com'
        );
        return userMarketo;
    }


    public User createUserImPartner() {
        /**
        * @description Crée un utilisateur de IM Partner
        */            
        User userImPartner = new User(
            alias = 'Test',
            email = 'test.sales@example.com',
            emailencodingkey = 'UTF-8',
            BypassPB__c = true,
            BypassVR__c = true,
            BypassWF__c = true,
            lastname = 'testsales',
            languagelocalekey = 'fr',
            localesidkey = 'fr_FR',
            profileid = [
                SELECT Id
                FROM Profile
                WHERE Name = :IM_PARTNER_PROFILE_NAME
                LIMIT 1
            ][0].Id,
            timezonesidkey = 'Europe/Paris',
            username = 'test.impartner' + System.now().millisecond()
            + UserInfo.getOrganizationId() + '@example.com'
        );
        return userImPartner;
    }
    }
    
    public class AccountFactory {
        public Account createAccount(){
            Account acc = new Account();
            acc.Name = 'test Comforth' + System.now().millisecond();
            acc.Siren_Siret__c = '1545';
            acc.BillingCountry='France';
            return acc;
        } 
        
        public Account createAccountWithNature(Integer idx){
            String natureType = (idx>3)?'CLI':'PRO';
            Account acc = new Account();
            acc.Name = 'test Comforth' + System.now().millisecond() + idx;
            acc.Siren_Siret__c = '1545'+ System.now().millisecond()+ idx;
            acc.BillingCountry='France';
            acc.Nature__c = natureType;
            acc.Risk_Level__c = 'Risque moyen';
            acc.Amount_of_delay_30_days__c = 2;
            acc.Amount_of_delay_over_24_months__c = 0;
            acc.Collection_Status__c = 'Black';
            return acc;
        }  

        public Account createAccountPartner(){
            //003 => Partner
            //004 => RESELLER
            Account acc = new Account();
            acc.Name = 'test partner' + System.now().millisecond();
            acc.Siren_Siret__c = '1547';
            acc.BillingCountry='France';
            acc.Type__c = '003';
            acc.Partnership__c = '004';
            return acc; 
        }
    }
    
    public class ContactFactory {
        public Contact createContact(Id accountId) {
            
            Contact c = new Contact();
            c.LastName = 'LName';
            c.FirstName = 'FName';
            c.email = 'lname@email.com';
            c.AccountId = accountId;
            c.Service__c = 'IT';
            c.Function__c = 'IT Dir.';          
            return c;
        }
    }
    
    public class ProductFactory {
       
        public Product2 createProduct(String RecordType, String PricingMethod) {
            Product2 pro2 = new Product2();
            if(RecordType == 'Charge'){
               
                pro2.recordtypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Package').getRecordTypeId();
                pro2.Name = 'VFC02Product' + RecordType;
                pro2.Marketing_Status__c = 'Non_Marketable';
                pro2.Service_Levels__c = 'C30';
                pro2.IsActive = true;
                pro2.Possible_Billing_Modes__c = 'Consumption';
                pro2.InternalDescription__c = 'Test DESC';
                pro2.SBQQ__ChargeType__c = 'One-Time';
                pro2.Metric__c='445';
                //pro2.BU_Offer__c ='200';
                insert pro2;
            }
            
            Product2 pro = new Product2();
            pro.recordtypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();
            pro.Name = 'Product' + RecordType;
            pro.Marketing_Status__c = 'Marketable';
            pro.Service_Levels__c = 'C30';
            pro.SBQQ__PricingMethod__c = PricingMethod;
            pro.Purchasing_Price__c = 122;
            pro.IsActive = true;
            pro.Metric__c='445';
            
            
            if(RecordType == 'Package' || RecordType == 'Product'){
                pro.Possible_Billing_Modes__c = 'Consumption';
                pro.InternalDescription__c = 'Test DESC';
                pro.SBQQ__ChargeType__c = 'One-Time';
            }else if(RecordType == 'Article'){
                pro.NoRoyalty__c = true;
                pro.Purchasing_Price__c = 200;
            }else if(RecordType == 'Charge'){
                pro.Main_Charge_Product__c= pro2.Id;
                pro.Excess_Pricing_Method__c = 'Fixed Unit Price';
                pro.SBQQ__ChargeType__c = 'One-Time';
            }
            
            return pro;
        }
    }

    public class ProductFactoryV1 {
       
        public Product2 createProduct(String RecordType, String PricingMethod, String FamilySet) {
            // String familyAPI;
            // if(FamilySet == 1){
            //     familyAPI = '130';
            // }else if(FamilySet == 2){
            //     familyAPI = '140';
            // }else if(FamilySet == 3){
            //     familyAPI = '120';
            // }else if(FamilySet == 4){
            //     familyAPI = '110';
            // }else if(FamilySet == 0){
            //     familyAPI = '190';
            // }else if(FamilySet == 5){
            //     familyAPI = '190';
            // }

            Product2 pro2 = new Product2();
            if(RecordType == 'Charge'){
               
                pro2.recordtypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Package').getRecordTypeId();
                pro2.Name = 'VFC02Product' + RecordType;
                pro2.Marketing_Status__c = 'Non_Marketable';
                pro2.Service_Levels__c = 'C30';
                pro2.IsActive = true;
                pro2.Possible_Billing_Modes__c = 'Consumption';
                pro2.InternalDescription__c = 'Test DESC';
                pro2.SBQQ__ChargeType__c = 'One-Time';
                pro2.Metric__c='445';
                //pro2.BU_Offer__c ='200';
                insert pro2;
            }
            
            Product2 pro = new Product2();
            pro.recordtypeid = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(RecordType).getRecordTypeId();
            pro.Name = 'Product' + RecordType;
            pro.Marketing_Status__c = 'Marketable';
            pro.Service_Levels__c = 'C30';
            pro.SBQQ__PricingMethod__c = PricingMethod;
            pro.Purchasing_Price__c = 122;
            pro.Family = FamilySet;
            pro.IsActive = true;
            pro.Metric__c='445';
            
            
            if(RecordType == 'Package' || RecordType == 'Product'){
                pro.Possible_Billing_Modes__c = 'Consumption';
                pro.InternalDescription__c = 'Test DESC';
                pro.SBQQ__ChargeType__c = 'One-Time';
            }else if(RecordType == 'Article'){
                pro.NoRoyalty__c = true;
                pro.Purchasing_Price__c = 200;
            }else if(RecordType == 'Charge'){
                pro.Main_Charge_Product__c= pro2.Id;
                pro.Excess_Pricing_Method__c = 'Fixed Unit Price';
                pro.SBQQ__ChargeType__c = 'One-Time';
            }
            
            return pro;
        }
    }

  
    
    public class ProductOptionFactory {
      
        public SBQQ__ProductOption__c createProductOption(Id Optional, Id Configured) {
            
            SBQQ__ProductOption__c proOption = new SBQQ__ProductOption__c();
            proOption.SBQQ__OptionalSKU__c = Optional;
            proOption.SBQQ__ConfiguredSKU__c = Configured;
            proOption.SBQQ__Number__c = 1;
            return proOption;
        }
    }
    
    public class OpportunityFactory {
      
        public Opportunity createOpportunity(Id AccountId, Boolean ConvertedFromLead, Boolean AutoCreated) {
            Opportunity opp = new Opportunity();
            opp.Name = 'Opportunity';
            opp.CloseDate = System.today().addDays(10);
            opp.StageName = 'Prospecting';
            opp.AccountId = AccountId;
            opp.Expertise__c = '200';
            opp.Product_Line__c = '307';
            opp.Sales_Purpose__c = '111';
            Opp.Oppy_converted_from_Lead__c = ConvertedFromLead;
            opp.Oppy_AutoCreated__c = AutoCreated;
            return Opp;
        }

        public OpportunityLineItem createOppLineItem(Id opportunityId, Id pbEntryId) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opportunityId;
            oli.pricebookentryid=pbEntryId;
            oli.quantity = 1;
            oli.unitPrice = 50;            
            return oli;
        }
    }

    public class LeadFactory{

        public Lead createLead(String title){
            Lead lead = new Lead();
            lead.Title = 'Test' + title;
            lead.FirstName = 'Test' + title;
            lead.LastName = 'Test' + title;
            lead.email = title+'@'+title+'.com';
            lead.Service__c = 'HR';
            lead.Function__c = 'HR Assistant';
            lead.Company = 'Test ' + title;
            lead.Country = 'France';
            lead.Expertise__c = '200';//200 = Retail
            return lead;
        }
    }

    public class PricebookFactory {
        public Pricebook2 activateStdPriceBook(){
            Entity__c entity = new Entity__c();
            entity.Active__c = true;
            entity.name ='CEGID SA';
            entity.ICS__c = 'FR14ZZZ497659';
            entity.Street__c = '52, quai Sedallian';
            entity.City__c = 'Lyon';
            entity.Postal_Code__c = '69009';
            entity.Country__c = 'France';
            entity.Allowed_currency__c = 'AUD;CAD;EUR;GBP;USD';
            insert entity;

            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                Cegid_Entity__c = entity.Id,
                IsActive = true
            );
            update standardPricebook;

            return standardPricebook;
        }
        
        public PricebookEntry createPriceBookEntry(Id priceBook2Id, Id product2Id) {
            PricebookEntry pbe = new PricebookEntry( 
                Product2Id=product2Id, 
                UnitPrice=10, 
                PriceBook2Id=PriceBook2Id,
                IsActive = true);
            return pbe;
        }
    }

    public class RCC_ConditionFactory {
        public RCC_Condition__c createRccCondition(String nature,String riskLevel, Decimal oneTime, Decimal astonAmount, String astonDelay, Decimal recuringMonthly, String workflowLevel){
            RCC_Condition__c rcc = new RCC_Condition__c();
            //String workflowLevel = (i>1)?'RCC Team Leader':'RCC Validator';
            rcc.Account_Nature__c = nature;
            rcc.Account_Risk_Level__c = riskLevel;
            rcc.One_Time_Total__c = oneTime;
            rcc.Account_Aston_Amount__c = astonAmount;
            rcc.Account_Aston_Delay__c = astonDelay;
            rcc.Recurring_Total_Monthly__c = recuringMonthly;
            rcc.RCC_Workflow_Level__c = workflowLevel;
            return rcc;
        }

        public RCC_Condition__c createRccConditionv1(String nature,String riskLevel, Decimal oneTime, Decimal astonAmount, String astonDelay, Decimal recuringMonthly, Integer Idx){
            RCC_Condition__c rcc = new RCC_Condition__c();
            String workflowLevel = (Idx>3)?'RCC Team Leader':'RCC Validator';
            rcc.Account_Nature__c = nature;
            rcc.Account_Risk_Level__c = riskLevel;
            rcc.One_Time_Total__c = oneTime;
            rcc.Account_Aston_Amount__c = astonAmount;
            rcc.Account_Aston_Delay__c = astonDelay;
            rcc.Recurring_Total_Monthly__c = recuringMonthly;
            rcc.RCC_Workflow_Level__c = workflowLevel;
            return rcc;
        }
    }

    public class SBQQ_QuoteFactory {
      
        public SBQQ__Quote__c createSBQQ_Quote(Id opportunityId, Id accountId, Id contactId) {
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accountId;
            quote.SBQQ__Opportunity2__c = opportunityId;
            quote.SBQQ__PrimaryContact__c = contactId;
            return quote;
        }

        public SBQQ__Quote__c createSBQQ_QuoteV2(Id opportunityId, Id accountId, Id contactId,Id billingAcc) {
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = accountId;
            quote.SBQQ__Opportunity2__c = opportunityId;
            quote.SBQQ__PrimaryContact__c = contactId;
            quote.Billing_Account__c = billingAcc;
            quote.One_Time_Licenses_Amount__c  = 1;
            quote.One_Time_Maintenance_Amount__c  = 2;
            quote.One_Time_SaaS_Amount__c  = 3;
            quote.One_Time_Services_Amount__c  = 5;
            quote.One_Time_Training_Amount__c = 6;
            quote.Recurring_Licenses_Amount__c  = 10;
            quote.SBQQ__SubscriptionTerm__c  = 22;
            quote.SBQQ__Status__c = 'Draft';
            quote.TargetedPriceForHardware__c = 2;
            quote.Tech_CollectionStatus_Approved__c =true;
            quote.SBQQ__DocumentStatus__c = 'Signed';
            return quote;
        }

        public SBQQ__QuoteLine__c createSBQQ_QuoteLine(Id quoteId, Id product2Id) {
            SBQQ__QuoteLine__c quoLine = new SBQQ__QuoteLine__c();
            quoLine.SBQQ__Quote__c = quoteId;
            quoLine.SBQQ__Product__c = product2Id;
            quoLine.SBQQ__Quantity__c = 1;
            return quoLine;
        }

        public SBQQ__QuoteLine__c createSBQQ_QuoteLineV1(Id quoteId, Id product2Id) {
            SBQQ__QuoteLine__c quoLine = new SBQQ__QuoteLine__c();
            quoLine.SBQQ__Quote__c = quoteId;
            quoLine.SBQQ__Product__c = product2Id;
            quoLine.SBQQ__Quantity__c = 1;
            quoLine.Purchasing_Price__c = 120;
            quoLine.Waterfall_Gross_Unit_Price__c = 1000;
            return quoLine;
        }

        //CPQ 
        public SBQQ__QuoteLine__c createSBQQ_QuoteLineCPQ(Id quoteId, Id product2Id, Boolean bundle) {
            SBQQ__QuoteLine__c quoLineInsert = new SBQQ__QuoteLine__c();
            quoLineInsert.SBQQ__Quote__c = quoteId;
            quoLineInsert.SBQQ__Product__c = product2Id;
            quoLineInsert.SBQQ__Quantity__c = 1;
            quoLineInsert.SBQQ__Bundle__c = false;
            insert quoLineInsert;
            SBQQ__QuoteLine__c quoLine = new SBQQ__QuoteLine__c();
            quoLine.SBQQ__Quote__c = quoteId;
            quoLine.SBQQ__Product__c = product2Id;
            quoLine.SBQQ__Quantity__c = 1;
            quoLine.SBQQ__Bundle__c = bundle;
            quoLine.SBQQ__SegmentLabel__c  = 'TEst';
            quoLine.SBQQ__RequiredBy__c = null;
            return quoLine;
        }

        public SBQQ__QuoteLineGroup__c createQuoteLineGroupCPQ(Id quoteId, String Name, Integer position){
            SBQQ__QuoteLineGroup__c  QLG = new SBQQ__QuoteLineGroup__c();
            QLG.SBQQ__Quote__c  = quoteId;
            QLG.Name =  Name;
            QLG.SBQQ__Number__c = position;
            return QLG;
        }
    }
    
    //Method to create qualification on Quotes
    public static List<Qualification_Sheet__c> createQualificationSheetOnQuote(List<SBQQ__Quote__c> listQuo){
            List<Qualification_Sheet__c> listQS = new List<Qualification_Sheet__c>();
            For(SBQQ__Quote__c q:listQuo){
                Qualification_Sheet__c qs = new Qualification_Sheet__c(Quote__c = q.Id, Name = 'QS - '+String.valueOf(q.Id));
                listQS.add(qs);
            }
            return listQS;
        }

    public class ObjectTerritory2AssociationFactory {
      
        public ObjectTerritory2Association createObjectTerritory2Association(Id account, Id model) {
            ObjectTerritory2Association ota = new ObjectTerritory2Association();
            ota.ObjectId = account;
            ota.Territory2Id = model;
            ota.AssociationCause = 'Territory2Manual';

            return ota;
        }
        
        public Territory2Model  createObjectTerritory2Model()
        {
            Territory2Model  TerrModel= new Territory2Model();
            TerrModel.Name='Cegid';
            return TerrModel;
        }
    } 
    
    public class EntityFactory{
        public Entity__c createEntity(){  
            Entity__c CegidEntity= new Entity__c();
            CegidEntity.City__c='Paris';
            CegidEntity.Country__c='FR';
            CegidEntity.Postal_Code__c='60100';
            CegidEntity.Street__c='Henry Dunant';
            CegidEntity.ICS__c='1';
            CegidEntity.Active__c=true;
            CegidEntity.Entity_code__c='1123';               
            return  CegidEntity;
        }
    }
    
    public class DiscountSchFactory {
        public SBQQ__DiscountSchedule__c createDiscountSch(String type, String discount) {
            // type can be Range  or Stab
            // discount unit can be percentage /amount / price
            SBQQ__DiscountSchedule__c dSch = new SBQQ__DiscountSchedule__c();
            dSch.Name = 'comforth Discount';
            dSch.SBQQ__Type__c = type;
            dSch.SBQQ__DiscountUnit__c = discount;

            return dSch; 
        }
    }  
    
    public class DiscountTierFactory {
        public SBQQ__DiscountTier__c createDiscountSch(Id discount) {
           
            SBQQ__DiscountTier__c discountTier = new SBQQ__DiscountTier__c();
            discountTier.Name = '1';
            discountTier.SBQQ__Schedule__c = discount;
            discountTier.SBQQ__LowerBound__c= 1;
            discountTier.SBQQ__UpperBound__c = 2;
            return discountTier; 
        }
    }
    
    public class ProductLineFactory {
        public Product_Line__c createProductLinePrice( String name, String api) {
            Product_Line__c pl = new Product_Line__c();
            pl.Name = name;
            pl.API_Code__c = api;
            pl.Active__c = true;
            pl.Expertise__c = '200';
            pl.Marketing_Status__c = 'Marketable';
            pl.Global_Pricing_Management__c = true;
            return pl;  
        }
    }   
        
    public class ServiceLevelPriceFactory {
        public Service_Level_Price__c createServiceLevelPrice( Id product, Id priceBook,String recType, Id discount) {
            Service_Level_Price__c slp = new Service_Level_Price__c();
            slp.recordtypeid = Schema.SObjectType.Service_Level_Price__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
            slp.Service_Level__c = 'C30';
            slp.Product__c = product;
            slp.Price_Book__c = priceBook;
            slp.Sales_Purposes__c = '612';
            slp.Discount_Schedule__c = discount;
            slp.RegularPrice__c= 10;

            return slp; 
        }
    } 
    
    public class CompanyLabel {
        public Company_Labels__c createCompanyLabel(Id entity, String payMethod, String PayFrequency, String payTerm) {
            Company_Labels__c companyLabel = new Company_Labels__c();
            companyLabel.Default_Entity__c = entity;
            companyLabel.Payment_Method__c = payMethod;
            companyLabel.Default_Billing_Frequency__c = PayFrequency;
            companyLabel.Payment_Term__c = payTerm;
            return companyLabel; 
        }
    }

    public class ContractFactory {
        public Contract createContract(Id Accountid, Date dateToday,Integer intContractTerm) {
            Contract con = new Contract();
            con.AccountId = Accountid;
            con.StartDate = dateToday;
            con.ContractTerm = intContractTerm;
            return con; 
        }
    }

    
    public class AttachedDocumentsFactory {
        public Attached_Document__c createAttachedDocument( String name, String struc1 ,String struc2, String docLink, String serviceLevel, Id productLine, String recType) {
            Attached_Document__c aDoc = new Attached_Document__c();
            aDoc.recordtypeid = Schema.SObjectType.Attached_Document__c.getRecordTypeInfosByDeveloperName().get(recType).getRecordTypeId();

            if(recType == 'General_Terms_And_Conditions'){
                aDoc.Name = name;
                aDOc.StructureLevel1__c = struc1;
                aDoc.StructureLevel2__c = struc2;
                aDoc.Document_Link__c = docLink;
            }else if(recType == 'Service_Book'){
                aDoc.Product_Line__c = productLine;
                aDoc.Name = name;
                aDOc.StructureLevel1__c = struc1;
                aDoc.Service_Level__c = serviceLevel;
                aDoc.Document_Link__c = docLink;
            }

            return aDoc; 
        }
    }      
        
    public class ContentDocumentFactory{
        public ContentVersion createContentVersion(String title, String filePath) {
           
            ContentVersion contentVersion= new ContentVersion(
                Title = title,
                PathOnClient = filePath,
                VersionData = Blob.valueOf('Test Content Data'),
                IsMajorVersion = true
            );
            return contentVersion;
        }

        public ContentDocumentLink createContentDocLink(Id linkedEntityId, Id contDocId) {
           
            ContentDocumentLink contDocLink= new ContentDocumentLink(
                LinkedEntityId = linkedEntityId,
                ContentDocumentId = contDocId
            );
            return contDocLink;
        }
    }

     public class TaskFactory {
        public Task createTask(Id AccountId, Id productId,Id createby) {
            Task tsk = new Task();
            tsk.WhatId = AccountId;
            tsk.Product_Line__c = productId;
            tsk.CreatedById = createby;
            tsk.Generates_Order_Influence__c = true;
            return tsk; 
        }
    }
    
    public class OrderInfluenceFactory {
        public Order_Influence__c createOrderInfluence(Id AccountId, Id productId) {
            Order_Influence__c oi = new Order_Influence__c();
            oi.Account__c = AccountId;
            oi.Product_Line__c = productId;
            oi.Active__c = true;
            return oi; 
        }
    }

    public class WebCartFactory {
        public WebCart createWebCart(Id accountIds, Id storeId) {
            WebCart wc = new WebCart();
            wc.Name = 'Cart1';
            //Status='Closed',
            wc.Status='Active';
            wc.AccountId=accountIds;
            wc.WebStoreId=storeId;
            return wc; 
        }
    }

    public class CartItemFactory {

        public CartItem createCartItem(Id cartId) {

            // Insert cartDeliveryGroup
            CartDeliveryGroup cartDeliveryGroup1 = new CartDeliveryGroup();
            cartDeliveryGroup1.Name='Default Delivery';
            cartDeliveryGroup1.CartId=cartId;
            insert cartDeliveryGroup1;


            CartItem ci = new CartItem();
            ci.CartId=cartId; 
            ci.Sku='SKU_Test1'; 
            ci.Quantity=3.0;
            ci.Type='Product'; 
            ci.Name='TestProduct';
            ci.CartDeliveryGroupId=cartDeliveryGroup1.Id;
            return ci; 
        }
    }

    public class ParticipantFactory {
        public Participant__c createParticipant(Id cartItemId) {
            Participant__c part = new Participant__c();
            part.Name='testP1';
            part.Civilite__c ='Mr';
            part.Prenom__c = 'Test';
            part.EmailAddress__c='test1@test.test';
            part.CartItemId__c=cartItemId;
            return part; 
        }
    }

    public class StoreFactory {
        public WebStore createStore() {
            WebStore store = new WebStore();
            store.Name='testwebstore';
            return store; 
        }
    }

    // public class BuyerAccountFactory {
    //     public BuyerAccount createBuyerAccount(Id accountId) {
    //         BuyerAccount buyerAcc = new BuyerAccount();
    //         buyerAcc.BuyerId = accountId;
    //         buyerAcc.Name = 'Test Buyer Account (BA-AJ)';
    //         buyerAcc.IsActive = true; 
    //         return buyerAcc;
    //     }
    // }
}