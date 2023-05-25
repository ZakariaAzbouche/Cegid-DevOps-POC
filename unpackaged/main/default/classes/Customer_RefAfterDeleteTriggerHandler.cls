public class Customer_RefAfterDeleteTriggerHandler extends TriggerHandlerBase {
    private Map<Id, List<Customer_Reference__c>> customerRefsByAcc;
    

    public override void mainEntry(TriggerParameters tp) {
        System.debug('AFTER DELETE HANDLER START');
		process((Map<Id, Customer_Reference__c>)tp.oldMap);
        System.debug('AFTER DELETE HANDLER END');
	}
	
	private void process(Map<Id, Customer_Reference__c> oldMap) {

        this.bulkbeforeProcessing(oldMap);

		for(Customer_Reference__c cRef : oldMap.values()) {
            Customer_ReferenceHelper.updateCustomerReferalOnAcc(cRef, this.customerRefsByAcc, this.sObjectsToUpdate);
		}

        this.updateObjects();
	}
	

    private void bulkbeforeProcessing(Map<Id, Customer_Reference__c> oldMap) {
       Set<Id> accIds = new Set<Id>();
       this.customerRefsByAcc = new Map<Id, List<Customer_Reference__c>>();

       for(Customer_Reference__c cRef : oldMap.values()) {
        accIds.add(cRef.Account__c);
        if(!this.customerRefsByAcc.containsKey(cRef.Account__c)) {
            this.customerRefsByAcc.put(cRef.Account__c, new List<Customer_Reference__c>());
        }
        
       }
       System.debug(accIds);

       for(Customer_Reference__c cRef : [SELECT Id FROM Customer_Reference__c WHERE Account__r.Referral_Customer__c =: true  AND Id != :oldMap.keySet() AND Account__c =: accIds]) {
        
        this.customerRefsByAcc.get(cRef.Account__c).add(cRef);
       }
       System.debug(this.customerRefsByAcc);

    }
}