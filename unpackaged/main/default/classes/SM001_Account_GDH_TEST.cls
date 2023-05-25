@isTest
public class SM001_Account_GDH_TEST {
/**
 * @File Name          : SM001_Account_GDH_TEST
 * @Description        : Update fileds when owner is changed in account and territories are added or removed
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Last Modified By   : SRA
 * @Last Modified On   : 30/10/2020
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    30/10/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static User adminUser2 = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static Territory2 t = new Territory2();
    
    @testSetup static void setup(){
        System.runAs(adminUser){       
            
            Territory2Model territoryModel = [select Id,Name From Territory2Model];

            Territory2Type territoryType = [select Id,MasterLabel From Territory2Type where MasterLabel='Hierarchy Territory'];
            
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = True);
                
            Test.startTest();
            List<Account> listAcc = new List<Account>();
            List<Contact> listCon = new List<Contact>();
            List<Opportunity> listOppConverted = new List<Opportunity>();
            List<Opportunity> listOppAutoCreate = new List<Opportunity>();
            List<ObjectTerritory2Association> listOTA = new List<ObjectTerritory2Association>();
            List<Territory2> listTerritory = [Select Id , Expertise__c from Territory2 where  Expertise__c='200']; 
            
            t.Name = 'Cegid Test';
            t.TerritoryCode__c ='3441';
            t.DeveloperName= 'Cegid_Test';
            t.Territory2ModelId=territoryModel.Id;
            t.BU__c='302';
            t.Channel__c='001';
            t.Territory2TypeId=territoryType.Id;

            insert t;
            system.System.debug('t'+t);
            
            listAcc.add(new UTIL_TestFactory.AccountFactory().createAccount());
            listAcc[0].National_ID_Exception__c ='Empty on loading';
            listAcc[0].BillingPostalCode ='75008';
            listAcc[0].BillingCountry ='France';
            listAcc[0].BillingCity ='Paris';
            listAcc[0].No_of_Employees_Group__c =12;
            listAcc[0].No_of_Stores__c =2;
            listAcc[0].NumberOfEmployees =12;
            insert listAcc;
            
            Account acc = new Account();
            acc.Name= 'Test';
            acc.National_ID_Exception__c ='Empty on loading';
            acc.BillingPostalCode ='75009';
            acc.BillingCountry ='France';
            acc.BillingCity ='Paris';
            acc.No_of_Employees_Group__c =15;
            acc.No_of_Stores__c =7;
            acc.NumberOfEmployees =14;
            acc.OwnerId=adminUser.Id;

            insert acc;
            
            Account_Expertise__c accShare = new Account_Expertise__c();
            accShare.Account__c=listAcc[0].Id;
            accShare.Expertise__c='200';
            accShare.Cegid_solution__c=true;
            insert accShare;
            
            
            listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[0].Id,listTerritory[0].Id));
            listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(acc.Id,t.Id));
            listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[0].Id,listTerritory[1].Id));
            listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[0].Id,listTerritory[2].Id));
            listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[0].Id,listTerritory[3].Id));
            Insert listOTA;
            
            Test.stopTest();
        }
    }
    
    static testMethod void testPackage() {
        
        List<Account> listAcc = [SELECT id from Account];
        listAcc[0].TECHFollowedByCodeToBeCalculated__c=true;
        
        System.runAs(adminUser) {
            Test.startTest();
            update listAcc;
            Test.stopTest();
        }
    }
    
        //Owner avec un territoire et compte sans territoire
    static testMethod void testing_AccNoTerritory() {
        system.debug('testing_AccNoTerritory');

        List<Account> listAcc = [SELECT id,TECHFollowedByCodeToBeCalculated__c,OwnerId,ReferentCode__c,SedentaryCode__c,CodeFollowedBy__c from Account where Name LIKE '%Test%'];
        User accountOwner=[select id,Name from User where Name LIKE '%Willy Bocquet%'];
        system.debug('listAcc ***'+listAcc[0].TECHFollowedByCodeToBeCalculated__c);
        system.debug('listAcc ***'+listAcc[0].OwnerId);
        system.debug('accountOwnerId'+accountOwner);
        listAcc[0].TECHFollowedByCodeToBeCalculated__c = True;
        listAcc[0].OwnerId=accountOwner.Id;
        
        system.debug('listAcc2 ***'+listAcc[0].TECHFollowedByCodeToBeCalculated__c);
        system.debug('listAcc2 ***'+listAcc[0].OwnerId);

        UserTerritory2Association uts3 = [SELECT Id, RoleInTerritory2, Territory2Id, UserId FROM UserTerritory2Association where UserId=:accountOwner.Id];
        
        System.runAs(adminUser) {
            Test.startTest();
            update listAcc;
            Test.stopTest();
        }
        
        Territory2 territory = [SELECT Id,TerritoryCode__c FROM Territory2 WHERE Id=:uts3.Territory2Id];
        List<Account> listAcc2 = [SELECT id,TECHFollowedByCodeToBeCalculated__c,OwnerId,ReferentCode__c,SedentaryCode__c,CodeFollowedBy__c from Account where Name LIKE '%Test%'];
        

        system.debug('listAcc'+listAcc2[0].TECHFollowedByCodeToBeCalculated__c);
        system.debug('listAcc ReferentCode'+listAcc2[0].ReferentCode__c);

        System.assertEquals(territory.TerritoryCode__c,listAcc2[0].ReferentCode__c);
        System.assertEquals(null,listAcc2[0].SedentaryCode__c);
        System.assertEquals(territory.TerritoryCode__c,listAcc2[0].CodeFollowedBy__c);
    }
}