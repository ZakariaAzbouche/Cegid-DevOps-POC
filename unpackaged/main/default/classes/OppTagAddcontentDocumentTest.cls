@istest
public class OppTagAddcontentDocumentTest {
    @isTest
    static void unitTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='IM Partner']; 
        /*User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id,List_of_VR_to_By_Pass__c	='VR007_NationalId_Exception', 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduserimpartnet@testorg.com');
*/
        
        
         User userImPartner= new User(
                alias = 'Test',
                email = 'test.sales@example.com',
                emailencodingkey = 'UTF-8',
                BypassPB__c = true,
                BypassVR__c = true,
                BypassWF__c = true,
                lastname = 'testsales',
                languagelocalekey = 'fr',
                localesidkey = 'fr_FR',
                profileid = p.id,
                timezonesidkey = 'Europe/Paris',
                username = 'test.sales' + System.now().millisecond()
                + UserInfo.getOrganizationId() + '@example.com'
            );
        insert userImPartner;
        System.runAs(userImPartner) {        
        
        
        List<Opportunity> listOppConverted = new List<Opportunity>(); 
        List<Opportunity> listOppAutoCreate = new List<Opportunity>();
        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
                insert acc;
         Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, false, false);
                insert opp;
 
ContentVersion conVer = new ContentVersion();
conVer.ContentLocation = 'S'; 
conVer.PathOnClient = 'testing.txt'; 
conVer.Title = 'Testing Files'; 
conVer.VersionData = Blob.valueOf('Test Content');
insert conVer;    
        
Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
ContentDocumentLink conDocLink = New ContentDocumentLink();
conDocLink.LinkedEntityId = opp.Id; 
conDocLink.ContentDocumentId = conDoc;  
conDocLink.shareType = 'V';
insert conDocLink;
        }      
        
    }
}