/**
 * @File Name          : SM010_Case
 * @Description        : Update Opportunity Team Member if a user is the owner of the case.
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    01/12/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
**/
public class SM010_Case {
    private static final String Presales = 'PreSales_Request';
    
    public static void setOpportunityOwner(List<Case> listCase, Map <Id, Id> mapCaseIdOwnerId){
        
        Map <Id, Id> mapOpportunity = new Map <Id, Id>();
        Map <Id, Id> mapOpportunityTeamMember = new Map <Id, Id>();
        OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
        
        set<Id> caseOwner = New Set<Id>();
        
        // Retrieve case and Opportunity where RecordType = Presales Request 
        for(Case case1 :[SELECT Id, OwnerId,Opportunity__c 
                         From Case 
                         WHERE OwnerId IN :mapCaseIdOwnerId.values()
                         AND RecordType.DeveloperName =: Presales]){
                             
			mapOpportunity.put(case1.OwnerId, case1.Opportunity__c);
                             
        }
        
        //Retrieve all OpportunityTeamMember with same userId and opportunityId
        for(OpportunityTeamMember  oppTM :[SELECT Id, UserId,OpportunityId 
                         From OpportunityTeamMember  
                         WHERE OpportunityId  IN :mapOpportunity.values()]){
                             
            mapOpportunityTeamMember.put(oppTM.UserId, oppTM.OpportunityId);
        }
        
        for(Case case2 : listCase){
            //Check if map contains case Owner
            if(mapOpportunity.containsKey(case2.OwnerId)){
                //check if map contains an Opportunity Team Member with the same user and Opportunity 
                if(!mapOpportunityTeamMember.containsKey(case2.OwnerId) && !mapOpportunityTeamMember.containsKey(case2.Opportunity__c)){
                    
                    oppTeamMember.OpportunityId=case2.Opportunity__c;
                    oppTeamMember.UserId=case2.OwnerId;
                    oppTeamMember.OpportunityAccessLevel='Read';
                    oppTeamMember.TeamMemberRole='Pre-Sales';
                }
            }
        }
        if (oppTeamMember.OpportunityId!=null){
            insert oppTeamMember;
        }
    }

}