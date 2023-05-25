/**
* @author Keshav - Comforth
* @date 2020-02-04
* @group UTIL
* @description Classe utilitaire de test gérant la création de données
*/
@isTest
public class UTIL_TestFactory_TEST {
	static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User userSales = new UTIL_TestFactory.UserFactory().createUserCegidSales();
    public static TestMethod void testAllMethod(){
        System.runAs(adminUser){
            Test.startTest();
               Account Acc= new UTIL_TestFactory.AccountFactory().createAccount();
               Contact C=   new UTIL_TestFactory.ContactFactory().createContact(Acc.id);
               Product2 pro0=   new UTIL_TestFactory.ProductFactory().createProduct('Charge','List');
               Product2 pro1=   new UTIL_TestFactory.ProductFactory().createProduct('Package','List');
               Product2 pro2=   new UTIL_TestFactory.ProductFactory().createProduct('Article','List');
               SBQQ__ProductOption__c proOptio= new UTIL_TestFactory.ProductOptionFactory().createProductOption(pro0.id,pro1.id) ;
               Lead Ld= new UTIL_TestFactory.LeadFactory().createLead('AAAA');            
               Pricebook2  Prbook=   new UTIL_TestFactory.PricebookFactory().activateStdPriceBook();          
               PricebookEntry PrbookEntry=  new UTIL_TestFactory.PricebookFactory().createPriceBookEntry(Prbook.id, pro0.id);
               Opportunity Opp   =new UTIL_TestFactory.OpportunityFactory().createOpportunity(Acc.id,true, true);
               OpportunityLineItem   OppLineItem = new UTIL_TestFactory.OpportunityFactory().createOppLineItem(Opp.id, Prbook.id);  
               SBQQ__Quote__c   Quot = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_Quote(Opp.Id,Acc.id, C.id);             
               SBQQ__QuoteLine__c   QuotLn = new UTIL_TestFactory.SBQQ_QuoteFactory().createSBQQ_QuoteLine(Quot.Id,pro0.id);                 
               Territory2Model TerrModel=new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Model();                
               ObjectTerritory2Association OnjTerr=new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(Acc.id, TerrModel.id)   ;
               Entity__c Entity=new UTIL_TestFactory.EntityFactory().createEntity();  
               SBQQ__DiscountSchedule__c Discount=new   UTIL_TestFactory.DiscountSchFactory().createDiscountSch('Range', 'DiscountRondan');    
               SBQQ__DiscountTier__c DiscountTier=  new UTIL_TestFactory.DiscountTierFactory().createDiscountSch(Discount.id);            
               Product_Line__c  ProdLine=  new UTIL_TestFactory.ProductLineFactory().createProductLinePrice('name', 'api');  
            
               Attached_Document__c AttDoc01= new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('name', 'struc1','struc2', 'docLink', 'serviceLevel',ProdLine.id , 'Service_Book');
               Attached_Document__c AttDoc02= new UTIL_TestFactory.AttachedDocumentsFactory().createAttachedDocument('name', 'struc1','struc2', 'docLink', 'serviceLevel',ProdLine.id, 'General_Terms_And_Conditions');
               ContentVersion  ContVers=new UTIL_TestFactory.ContentDocumentFactory().createContentVersion('title', 'filePath'); 
               ContentDocumentLink  ContDocLink=new UTIL_TestFactory.ContentDocumentFactory().createContentDocLink(AttDoc01.id, AttDoc01.id);
               Service_Level_Price__c  SLevel= new  UTIL_TestFactory.ServiceLevelPriceFactory().createServiceLevelPrice( pro0.id,Prbook.id,'List Pricing',Discount.id);
            Test.stopTest();
        }
    }
}