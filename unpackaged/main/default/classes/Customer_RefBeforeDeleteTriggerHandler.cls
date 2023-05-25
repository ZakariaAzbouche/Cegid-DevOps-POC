public class Customer_RefBeforeDeleteTriggerHandler extends TriggerHandlerBase {
    private User connectedWithProfile;
    private Set<Id> terrUserIds;
    private Map<Id, Set<Id>> accWithTerritoriesHieriarchy;
    

    public override void mainEntry(TriggerParameters tp) {
        System.debug('BEFORE DELETE HANDLER START');
		process((Map<Id, Customer_Reference__c>)tp.oldMap);
        System.debug('BEFORE DELETE HANDLER END');
	}
	
	private void process(Map<Id, Customer_Reference__c> oldMap) {

        this.bulkbeforeProcessing(oldMap);

		for(Customer_Reference__c cRef : oldMap.values()) {
            Customer_ReferenceHelper.checkAccPermissionInsertUpdate(cRef, this.connectedWithProfile, this.terrUserIds, this.accWithTerritoriesHieriarchy);
		}
	}
	

    private void bulkbeforeProcessing(Map<Id, Customer_Reference__c> newMap) {
        this.connectedWithProfile = Customer_ReferenceHelper.getUserWithProfile(UserInfo.getUserId());
        this.terrUserIds = Customer_ReferenceHelper.getTerritoryUserIds(UserInfo.getUserId());
        Set<Id> accIds = new Set<Id>();

        for(Customer_Reference__c cRef : newMap.values()) {
            accIds.add(cRef.Account__c);
        }

        this.accWithTerritoriesHieriarchy = Customer_ReferenceHelper.extractSObjectTerritoryHierarchy(accIds);

    }
}