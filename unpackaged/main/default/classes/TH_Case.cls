/**
 * @File Name          : TH_Case
 * @Description        : Update Opportunity Team Member with Case Owner  
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    01/12/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
public without sharing class TH_Case extends TriggerHandler {
    /**
* @author
* @date
* @description Constructor
* @return void
*/
    public TH_Case() {
    }
    
    /**
* @author
* @date
* @description Handler Method for before Update Event
* @return void
*/
    public override void afterUpdate() {
        system.debug('TH_Case afterUpdate');
        set<Id> setCaseId = new set<Id>();
        List<Case> listCase = new List<Case>();
        Map<Id,Id> mapCaseIdOwnerId = new Map<Id,Id>();
        
        for(Case case1:(List<Case>)Trigger.New){
            Case oldCase = (Case)Trigger.oldMap.get(case1.Id);
            system.debug('case1 after Update' + case1.Id);
            string caseOwner =case1.OwnerId;
            if(oldCase.OwnerId != case1.OwnerId && caseOwner.startsWith('005')){
                listCase.add(case1);
                mapCaseIdOwnerId.put(case1.Id,case1.OwnerId);
            }
        } 
        if(listCase.size()>0){
            SM010_Case.setOpportunityOwner(listCase,mapCaseIdOwnerId);
        }
    }
    
    public override void afterInsert() {
        system.debug('TH_Case afterInsert');
    }
}