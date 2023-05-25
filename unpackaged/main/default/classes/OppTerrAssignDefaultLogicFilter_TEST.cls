/* 
----------------------------------------------------------------------
-- - Name          : OppTerrAssignDefaultLogicFilter
-- - Author        : Comforth
-- - Description   : Set Account territory
-- - Maintenance History: 
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------------------
-- 17 Jan-2020  KMM    1.0     Initial version - 
----------------------------------------------------------------------
***********************************************************************/
@istest
public class OppTerrAssignDefaultLogicFilter_TEST {
    @isTest
    static void unitTest() {
        List<Opportunity> listOppConverted = new List<Opportunity>();
        List<Opportunity> listOppAutoCreate = new List<Opportunity>();
        List<Account> listAcc = new List<Account>();
        List<ObjectTerritory2Association> listOTA = new List<ObjectTerritory2Association>();
        Test.startTest();
        list<ObjectTerritory2Association> listOA= [Select ObjectId, Territory2Id, Territory2.Expertise__c from ObjectTerritory2Association ];
        List<Territory2> listTerritory = [Select Id , Expertise__c from Territory2 where  Expertise__c='200'];  
        
        

        listAcc.add(new UTIL_TestFactory.AccountFactory().createAccount());
        insert listAcc;
        
        listOppConverted.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[0].Id,True,false));
        Insert listOppConverted;
        
        listOppAutoCreate.add(new UTIL_TestFactory.OpportunityFactory().createOpportunity(listAcc[0].Id,false,true));
        Insert listOppAutoCreate;
      
        listOppConverted[0].name = 'Territory';
        update listOppConverted;


        listOTA.add(new UTIL_TestFactory.ObjectTerritory2AssociationFactory().createObjectTerritory2Association(listAcc[0].Id,listTerritory[0].Id));
        Insert listOTA;
        
        
        OppTerrAssignDefaultLogicFilter filter = new OppTerrAssignDefaultLogicFilter();
        
        
        Map<Id, Id> resultMap = filter.getOpportunityTerritory2Assignments(new List<Id> {listOppConverted[0].Id});
        OppTerrAssignDefaultLogicFilter.territory2Expertise tp = new OppTerrAssignDefaultLogicFilter.territory2Expertise(listOppConverted[0].Id, '200');
        
        Test.stopTest();
        
        System.assertEquals(1, resultMap.size());
        System.assertEquals(tp.territory2Id, listOppConverted[0].Id);
    }
}