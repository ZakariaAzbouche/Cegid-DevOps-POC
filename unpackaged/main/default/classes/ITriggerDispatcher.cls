public interface ITriggerDispatcher {
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions before the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting inserted.
	*/
    void beforeInsert(TriggerParameters tp);

    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions before the records are updated.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
	*/
	void beforeUpdate(TriggerParameters tp);
	
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions before the records are deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting deleted.
	*/
	void beforeDelete(TriggerParameters tp);
	
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions after the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got inserted.
	*/
	void afterInsert(TriggerParameters tp);
	
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions after the records are updated.
	* @param TriggerParameters Contains the trigger parameters which includes the records got updated.
	*/
	void afterUpdate(TriggerParameters tp);
	
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions after the records are deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got deleted.
	*/
	void afterDelete(TriggerParameters tp);
	
    /** 
	* @author Baptiste Célérier
    * @date 14/03/2022
	* @description Called by the trigger framework to carry out the actions after the records are undeleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got undeleted.
	*/
	void afterUnDelete(TriggerParameters tp);
}