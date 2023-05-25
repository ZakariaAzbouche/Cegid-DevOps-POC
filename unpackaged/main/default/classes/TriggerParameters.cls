/**
* @author Baptiste
* @date 14/03/2022
* @description This class holds the trigger parameters.
*/
public class TriggerParameters {

    public System.TriggerOperation triggerEvent { get; private set; }
	public List<SObject> oldList { get; private set; }
	public List<SObject> newList { get; private set; }
	public Map<Id, SObject> oldMap { get; private set; }
	public Map<Id, SObject> newMap { get; private set; }
    public String triggerObject { get; private set; }
    public Boolean isExecuting { get; private set; }
     

    /** 
	* @author Baptiste Célérier
	* @date 14/03/2022
	* @description Constructs the TriggerParameter object.
	* @param List<SObject> A list of records with the state of 'before' event.
	* @param List<SObject> A list of records with the state of 'after' event.
	* @param Map<Id, SObject> A map of records with the state of 'before' event.
	* @param Map<Id, SObject> A map of records with the state of 'after' event.
	* @param Boolean A flag to indicate 'isExecuting'.
	*/
    public TriggerParameters(List<SObject> olist, List<SObject> nlist, Map<Id, SObject> omap, Map<Id, SObject> nmap, System.TriggerOperation triggerEvent, Boolean isExecuting) { 
        this.triggerEvent = triggerEvent;
        if(triggerEvent == System.TriggerOperation.BEFORE_UPDATE || triggerEvent == System.TriggerOperation.AFTER_UPDATE) {
            this.newMap = CheckRecursivCall.checkRunOnce(nmap, triggerEvent);
            this.newList = this.newMap.values();
        } else {
            this.newList = nlist;
            this.newMap = nmap;
        }
        //this.triggerObject = UtilityClass.getSObjectTypeName((this.oldList != null && this.oldList.size() > 0) ? this.oldList[0] : this.newList[0]);
        this.oldList = olist;
        this.oldMap = omap;
        this.isExecuting = isExecuting;
    }
}