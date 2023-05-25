/**
 * @author Easyfront Consulting
 * @date 2022-11-10
 * @description Service class for Special_Assignment__c object
*/
public without sharing class SM008_SpecialAssignmentService {
	/**
 	* @author Easyfront Consulting
 	* @date 2022-11-10
 	* @description Method to manage RCC approval rule & queue validator
	*/
    public static void rccApprovalSettingsCreationManagement(Set<Id> setSpecialAssignmentIds, Map<String,Group> mapPublicGroup){
        List<sbaa__Approver__c> listApproverToCreate = new List<sbaa__Approver__c>();
        List<sbaa__Approver__c> listApproverToUpdate = new List<sbaa__Approver__c>();
        List<sbaa__ApprovalRule__c> listApprovalRuleToCreate = new List<sbaa__ApprovalRule__c>();
        List<sbaa__ApprovalCondition__c> listApprovalConditionToCreate = new List<sbaa__ApprovalCondition__c>();
        Set<String> setNewAgencyNames = new Set<String>();
        Map<String, sbaa__Approver__c> mapExistingApprovers = new Map<String, sbaa__Approver__c>();
        
        List<Special_Assignment__c> listSpecialAssignment = [SELECT Id, RCC_User__c, Second_User__c, Agency__c, toLabel(Agency__c) agencyLabel FROM Special_Assignment__c WHERE Id IN : setSpecialAssignmentIds];
        if(!listSpecialAssignment.isEmpty()){
            //Get existing approvers
            for(Special_Assignment__c spa:listSpecialAssignment){
                setNewAgencyNames.add('Approval RCC - '+spa.Agency__c);
            }
            List<sbaa__Approver__c> existingApprovers = [SELECT Id, Name, SpecialAssignment__c FROM sbaa__Approver__c WHERE Name IN : setNewAgencyNames];
            if(!existingApprovers.isEmpty()){
                for(sbaa__Approver__c app:existingApprovers){
                    mapExistingApprovers.put(app.Name, app);
                }
            }
            //Create all related records
            for(Special_Assignment__c spa:listSpecialAssignment){
                //Create only if doesn't exist
                if(!mapExistingApprovers.containsKey('Approval RCC - '+spa.Agency__c)){
                    //Create Approver
                    sbaa__Approver__c app = new sbaa__Approver__c(Name= 'Approval RCC - '+spa.Agency__c, sbaa__GroupId__c = mapPublicGroup.get('Approval RCC - '+spa.Agency__c).Id, SpecialAssignment__c=spa.Id);
                    listApproverToCreate.add(app);
                    
                    //Create Approval Rule & conditions
                    sbaa__ApprovalChain__c rccChainReference = new sbaa__ApprovalChain__c(Name = 'RCC Chain');
                    sbaa__Approver__c approverReference = new sbaa__Approver__c(Name= 'Approval RCC - '+spa.Agency__c);
                    sbaa__EmailTemplate__c emailApprovalTemplate = new sbaa__EmailTemplate__c(Name = 'Approval - Approval Template');
                    sbaa__EmailTemplate__c emailRejectionTemplate = new sbaa__EmailTemplate__c(Name = 'Approval - Rejection Template');
                    sbaa__EmailTemplate__c emailRequestTemplate = new sbaa__EmailTemplate__c(Name = 'Approval - Request Template');
                    sbaa__ApprovalRule__c appRule = new sbaa__ApprovalRule__c(sbaa__ApprovalChain__r = rccChainReference, Name = 'Approval RCC - '+spa.get('agencyLabel'), ExternalID__c ='Approval RCC - '+spa.Agency__c ,sbaa__Active__c=true,sbaa__TargetObject__c='SBQQ__Quote__c', sbaa__Approver__r= approverReference,
                                                                              sbaa__ApprovalStep__c=1, sbaa__ApprovalTemplate__r =emailApprovalTemplate, sbaa__RejectionTemplate__r=emailRejectionTemplate, sbaa__RequestTemplate__r=emailRequestTemplate);
                    listApprovalRuleToCreate.add(appRule);
                    
                    //Approval Conditions
                    sbaa__ApprovalRule__c ruleReference = new sbaa__ApprovalRule__c(ExternalID__c = 'Approval RCC - '+spa.Agency__c);
                    //Create condition on RCC_Workflow_Level_1_validated__c
                    sbaa__ApprovalCondition__c approConditionRCCValidated = new sbaa__ApprovalCondition__c(sbaa__ApprovalRule__r=ruleReference, sbaa__FilterType__c='Value', sbaa__FilterValue__c='false', sbaa__Operator__c = 'equals', sbaa__TestedField__c = 'RCC_Workflow_Level_1_validated__c');
                    //Create condition on Launch_RCC_Workflow_Lv1__c
                    sbaa__ApprovalCondition__c approConditionRCCRequired = new sbaa__ApprovalCondition__c(sbaa__ApprovalRule__r=ruleReference, sbaa__FilterType__c='Value', sbaa__FilterValue__c='true', sbaa__Operator__c = 'equals', sbaa__TestedField__c = 'Launch_RCC_Workflow_Lv1__c');
                    //Create condition on Agency
                    sbaa__ApprovalCondition__c approConditionRCCAgency = new sbaa__ApprovalCondition__c(sbaa__ApprovalRule__r=ruleReference, sbaa__FilterType__c='Value', sbaa__FilterValue__c=spa.Agency__c, sbaa__Operator__c = 'equals', sbaa__TestedField__c = 'TECH_SalesRepAgency__c');
                    listApprovalConditionToCreate.add(approConditionRCCValidated);
                    listApprovalConditionToCreate.add(approConditionRCCRequired);
                    listApprovalConditionToCreate.add(approConditionRCCAgency);
                }else{ //Just update the link with new Special Assignment
                    mapExistingApprovers.get('Approval RCC - '+spa.Agency__c).SpecialAssignment__c = spa.Id;
                    listApproverToUpdate.add(mapExistingApprovers.get('Approval RCC - '+spa.Agency__c));
                }
            }
            if(!listApproverToCreate.isEmpty()){
                insert listApproverToCreate;
                insert listApprovalRuleToCreate;
                insert listApprovalConditionToCreate;  
            }
            if(!listApproverToUpdate.isEmpty()){
                update listApproverToUpdate;
            }
            
            
            //Then, add members to the group in @future because DML operation on setup object is not permitted Error
            rccApprovalSettingsUpdateGroupMembers(setSpecialAssignmentIds);
        }
    }
    
    @future
    public static void rccApprovalSettingsUpdateGroupMembers(Set<Id> setSpecialAssignmentIds){
        Map<String,Group> mapPublicGroup = new Map<String,Group>();
        List<GroupMember> listPublicGroupMembersToCreate = new List<GroupMember>();
        List<GroupMember> listPublicGroupMembersToDelete = new List<GroupMember>();
        Set<String> setGroupNames = new Set<String>();
        
        List<Special_Assignment__c> listSpecialAssignment = [SELECT Id, RCC_User__c, Second_User__c,Agency__c FROM Special_Assignment__c WHERE Id IN : setSpecialAssignmentIds];
        if(!listSpecialAssignment.isEmpty()){
            //First Loop to get Public Group
            for(Special_Assignment__c spa:listSpecialAssignment){
                setGroupNames.add('Approval RCC - '+spa.Agency__c);
            }
            
            //Loop to get existing public groups
            for(Group grp:[SELECT Name, Id, (SELECT Id FROM GroupMembers) FROM Group WHERE Name IN : setGroupNames]){
                mapPublicGroup.put(grp.Name, grp);
                listPublicGroupMembersToDelete.addAll(grp.GroupMembers);
            }
            
            //Remove existing members on groups
            if(!listPublicGroupMembersToDelete.isEmpty()){
                delete listPublicGroupMembersToDelete;
            }
            
            for(Special_Assignment__c spa:listSpecialAssignment){
                //Create Public Group members
                if(spa.RCC_User__c !=null){
                    GroupMember rccMember = new GroupMember(GroupId = mapPublicGroup.get('Approval RCC - '+spa.Agency__c).Id, UserOrGroupId=spa.RCC_User__c);
                    listPublicGroupMembersToCreate.add(rccMember);
                }
                if(spa.Second_User__c !=null){
                    GroupMember rcc2Member = new GroupMember(GroupId = mapPublicGroup.get('Approval RCC - '+spa.Agency__c).Id, UserOrGroupId=spa.Second_User__c);
                    listPublicGroupMembersToCreate.add(rcc2Member);
                }
            }
            if(!listPublicGroupMembersToCreate.isEmpty()){
                insert listPublicGroupMembersToCreate;
            }
        }
    }
    
    /**
 	* @author Easyfront Consulting
 	* @date 2022-11-10
 	* @description Method to delete RCC approval rule / condition and approver when Special Assignment is deleted
	*/
    /*public static void rccApprovalSettingsDeletionManagement(Set<Id> setSpecialAssignmentIds){
        List<sbaa__Approver__c> listApproverToDelete = new List<sbaa__Approver__c>();
        List<sbaa__ApprovalRule__c> listApprovalRuleToDelete = new List<sbaa__ApprovalRule__c>();
        List<sbaa__ApprovalCondition__c> listApprovalConditionToDelete = new List<sbaa__ApprovalCondition__c>();
        Set<String> setNames = new Set<String>();
        
        List<Special_Assignment__c> listSpecialAssignment = [SELECT Id, Agency__c, toLabel(Agency__c) agencyLabel FROM Special_Assignment__c WHERE Id IN : setSpecialAssignmentIds];
        if(!listSpecialAssignment.isEmpty()){
            //First Loop to get Name of related Records
            for(Special_Assignment__c spa:listSpecialAssignment){
                setNames.add('Approval RCC - '+spa.Agency__c);
            }
            
            listApproverToDelete = [SELECT Id FROM sbaa__Approver__c WHERE Name IN : setNames];
            listApprovalRuleToDelete = [SELECT Id FROM sbaa__ApprovalRule__c WHERE ExternalID__c IN : setNames];
            listApprovalConditionToDelete = [SELECT Id FROM sbaa__ApprovalCondition__c WHERE sbaa__ApprovalRule__r.ExternalID__c IN :setNames];
           
            //Delete all records
            delete listApproverToDelete;
            delete listApprovalConditionToDelete;
            delete listApprovalRuleToDelete;
            
        }
    }*/
}