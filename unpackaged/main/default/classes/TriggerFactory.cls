/**
* @author Baptiste Célérier
* @date 14/03/2022
* @description This factory creates the correct dispatcher and dispatches the trigger event(s) to the appropriate 
*				event handler(s). The dispatchers are automatically created using the Type API, hence dispatcher 
*				registration is not required for each dispatchers.
*/
public with sharing class TriggerFactory {
    
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Creates the appropriate dispatcher and dispatches the trigger event to the dispatcher's event handler method.
	* @param Schema.sObjectType Object type to process (SObject.sObjectType)
	*/
    public static void createTriggerDispatcher(Schema.sObjectType soType)
    {
        ITriggerDispatcher dispatcher = getTriggerDispatcher(soType);
        if(TriggerUtils.checkUserByPass()) {
            System.debug('Current User byPass Apex triggers');
        } else if (dispatcher == null) {
           System.debug('No Trigger dispatcher registered for Object Type: ' + soType);
        } else {
            execute(dispatcher);
        }
    }

    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Dispatches to the dispatcher's event handlers.
	* @param ITriggerDispatcher A Trigger dispatcher that dispatches to the appropriate handlers
	*/
    private static void execute(ITriggerDispatcher dispatcher)
    {
        if (Trigger.isBefore) { // Handle before trigger events
            if (Trigger.isDelete) {
                dispatcher.beforeDelete(new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, System.TriggerOperation.BEFORE_DELETE, Trigger.isExecuting));
            } else if(Trigger.isInsert) {
                dispatcher.beforeInsert(new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, System.TriggerOperation.BEFORE_INSERT, Trigger.isExecuting));
            } else if(Trigger.isUpdate) {
                dispatcher.beforeUpdate(new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, System.TriggerOperation.BEFORE_UPDATE, Trigger.isExecuting));
            }            
        } else if(Trigger.isAfter) { // Handle after trigger events
            if (Trigger.isDelete) {
                dispatcher.afterDelete(new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, System.TriggerOperation.AFTER_DELETE, Trigger.isExecuting));
            } else if(Trigger.isInsert) {
                dispatcher.afterInsert(new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, System.TriggerOperation.AFTER_INSERT, Trigger.isExecuting));
            } else if(Trigger.isUpdate) {
                dispatcher.afterUpdate(new TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap, System.TriggerOperation.AFTER_UPDATE, Trigger.isExecuting));
            }            
        }
        //dispatcher.andFinally();
    }

    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Gets the appropriate dispatcher based on the SObject. It constructs the instance of the dispatcher
	*				dynamically using the Type API. The name of the dispatcher has to follow this format:
	*				<ObjectName>TriggerDispatcher. For e.g. for the Feedback__c object, the dispatcher has to be named
	*				as FeedbackTriggerDispatcher.
	* @param Schema.sObjectType Object type to create the dispatcher
	* @return ITriggerDispatcher A trigger dispatcher if one exists or null.
	*/
    @TestVisible
    private static ITriggerDispatcher getTriggerDispatcher(Schema.sObjectType soType) {

    	String originalTypeName = soType.getDescribe().getName();
    	String dispatcherTypeName = null;
    	if (originalTypeName.toLowerCase().endsWith('__c')) {
    		Integer index = originalTypeName.toLowerCase().indexOf('__c');
    		dispatcherTypeName = originalTypeName.substring(0, index) + 'TriggerDispatcher';
    	} else {
            dispatcherTypeName = originalTypeName + 'TriggerDispatcher';
        }
    		
		Type obType = Type.forName(dispatcherTypeName);
        ITriggerDispatcher dispatcher;
        if(obType == null) {
            dispatcher = null;
        } else {
            dispatcher = (ITriggerDispatcher)obType.newInstance();
        }

    	return dispatcher;
    }

    
}