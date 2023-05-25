/**
* @author Baptiste Célérier
* @date 14/03/2022
* @description Defines the interface for trigger handlers. Logic for the first time events are placed under the mainEntry 
*				method.
*/
public interface ITriggerHandler {
	/** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description Called for the first time in the execution context.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void mainEntry(TriggerParameters tp);

	/** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description Updates the objects, if any.
	*/
	void updateObjects();
}