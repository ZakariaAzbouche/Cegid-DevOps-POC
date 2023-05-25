public class Customer_RefBeforeInsertTriggerHandler extends TriggerHandlerBase {
    private User connectedWithProfile;
    private Set<Id> terrUserIds;
    private Map<Id, Set<Id>> accWithTerritoriesHieriarchy;
    

    public override void mainEntry(TriggerParameters tp) {
        System.debug('BEFORE INSERT HANDLER START');
		process((List<Customer_Reference__c>)tp.newList);
        System.debug('BEFORE INSERT HANDLER END');
	}
	
	private void process(List<Customer_Reference__c> newList) {

        this.bulkbeforeProcessing(newList);

		for(Customer_Reference__c cRef : newList) {
            Customer_ReferenceHelper.checkAccPermissionInsertUpdate(cRef, this.connectedWithProfile, this.terrUserIds, this.accWithTerritoriesHieriarchy);
		}
	}
	

    private void bulkbeforeProcessing(List<Customer_Reference__c> newList) {
        this.connectedWithProfile = Customer_ReferenceHelper.getUserWithProfile(UserInfo.getUserId());
        this.terrUserIds = Customer_ReferenceHelper.getTerritoryUserIds(UserInfo.getUserId());
        Set<Id> accIds = new Set<Id>();

        for(Customer_Reference__c cRef : newList) {
            accIds.add(cRef.Account__c);
        }

        this.accWithTerritoriesHieriarchy = Customer_ReferenceHelper.extractSObjectTerritoryHierarchy(accIds);

    }
}