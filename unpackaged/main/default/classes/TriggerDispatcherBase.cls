/**
* @author Baptiste Célérier
* @date 14/03/2022
* @description This class implements the ITriggerDispatcher and acts as an adapter to avoid implementing all the 
*				ITriggerDispatcher methods.
*/
public virtual class TriggerDispatcherBase implements ITriggerDispatcher {

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records to be inserted during a BEFORE trigger.
	*/
    public virtual void beforeInsert(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records to be updated during a BEFORE trigger.
	*/
	public virtual void beforeUpdate(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records to be deleted during a BEFORE trigger.
	*/
	public virtual void beforeDelete(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records inserted during an AFTER trigger.
	*/
	public virtual void afterInsert(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records updated during an AFTER trigger.
	*/
	public virtual void afterUpdate(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records Deleted during an AFTER trigger.
	*/
	public virtual void afterDelete(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description This method is called for records unDeleted during an AFTER trigger.
	*/
	public virtual void afterUnDelete(TriggerParameters tp) {}

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description Called by the event handlers.
	* @param ITriggerHandler The trigger handler instance. The dispatcher need to pass an instance of the trigger handler, such
	*							as AccountAfterInsertTriggerHandler if this is the first call in a given context. If it is retry,
	*							then the dispatcher will need to pass null.
	* @param TriggerParameters The trigger parameters passed by the framework.
	* @param TriggerParameters.TriggerEvent The trigger event.
	*/
    protected void execute(ITriggerHandler handlerInstance, TriggerParameters tp) {
    	if(handlerInstance != null) {
    		handlerInstance.mainEntry(tp);
    		handlerInstance.updateObjects();
    	}
    }
    
}