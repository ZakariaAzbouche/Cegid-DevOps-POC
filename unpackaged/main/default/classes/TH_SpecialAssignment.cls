/**
* @author Easyfront Consulting
 * @date 2022-11-21
 * @description Trigger for Special_Assignment__c
*/
public  with sharing class TH_SpecialAssignment extends TriggerHandler {
    public static final Id rccRecordTypeId = Schema.SObjectType.Special_Assignment__c.getRecordTypeInfosByName().get('RCC Assigment').getRecordTypeId();
    /**
     * @author Easyfront Consulting
     * @date 2022-11-21
	* @description afterInsert logic          
*/
    public override void afterInsert(){
        Set<Id> setSpecialAssignmentIds = new Set<Id>();
        Set<String> setGroupNames = new Set<String>();
        Map<String,Group> mapPublicGroup = new Map<String,Group>();
        
        for(Special_Assignment__c spa:(List<Special_Assignment__c>)Trigger.new){
            if(spa.RecordtypeId == rccRecordTypeId){
                setGroupNames.add('Approval RCC - '+spa.Agency__c);
            }
        }
        //Need to check if public group exist
        //Loop to get existing public groups
        for(Group grp:[SELECT Name, Id FROM Group WHERE Name IN : setGroupNames]){
            mapPublicGroup.put(grp.Name, grp);
        }
        for(Special_Assignment__c spa:(List<Special_Assignment__c>)Trigger.new){
            if(spa.RecordtypeId == rccRecordTypeId){
                //If public doesn't exist for this agency, display error messsage
                if(!mapPublicGroup.containsKey('Approval RCC - '+spa.Agency__c)){
                    spa.addError('This agency is not configured for RCC Approval. Please contact your admin.');
                }else{
                    setSpecialAssignmentIds.add(spa.Id);
                }
            }
        }
        if(!setSpecialAssignmentIds.isEmpty()){
            SM008_SpecialAssignmentService.rccApprovalSettingsCreationManagement(setSpecialAssignmentIds,mapPublicGroup);
        }
    }
    
    /**
     * @author Easyfront Consulting
     * @date 2022-11-21
     * @description afterUpdate logic          
    */
    public override void afterUpdate(){
        Set<Id> setSpecialAssignmentIds = new Set<Id>();
        
        for(Special_Assignment__c spa:(List<Special_Assignment__c>)Trigger.new){
            Special_Assignment__c oldSpa = (Special_Assignment__c)trigger.oldMap.get(spa.Id);
            
            if((spa.RCC_User__c != oldSpa.RCC_User__c || spa.Second_User__c != oldSpa.Second_User__c) && spa.RecordtypeId == rccRecordTypeId){
                setSpecialAssignmentIds.add(spa.Id);
            }
        }
        if(!setSpecialAssignmentIds.isEmpty()){
            SM008_SpecialAssignmentService.rccApprovalSettingsUpdateGroupMembers(setSpecialAssignmentIds);
        }
    }
}