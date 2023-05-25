/**
* @author Baptiste Célérier
* @date 14/03/2022
* @description This class implements the ITriggerHandler to provide abstract/virtual methods for the interface methods
*				and so that the trigger handlers need to implement only the method that they have to. The only exception
*				is the mainEntry, which is mandatory for the trigger handlers to implement.
*/
public abstract class TriggerHandlerBase implements ITriggerHandler {
    protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
	
	/** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description Called for the first time in the execution context. The trigger handlers need to implement
	*				this method.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public abstract void mainEntry(TriggerParameters tp);
	
	/** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description Updates the objects, if any.
	*/
	public virtual void updateObjects() {
		if(sObjectsToUpdate.size() > 0) {
            update sObjectsToUpdate.values();
        }		
	}
}