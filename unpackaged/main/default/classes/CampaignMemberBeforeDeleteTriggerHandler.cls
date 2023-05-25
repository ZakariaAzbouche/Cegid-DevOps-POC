public class CampaignMemberBeforeDeleteTriggerHandler extends TriggerHandlerBase {
    private User connectedUser;

    public override void mainEntry(TriggerParameters tp) {
        System.debug('BEFORE DELETE HANDLER START');
		process((Map<Id, CampaignMember>)tp.oldMap);
        System.debug('BEFORE DELETE HANDLER END');
	}
	
	private void process(Map<Id, CampaignMember> oldMap) {

        this.bulkbeforeProcessing(oldMap);

		for(CampaignMember caMember : oldMap.values()) {
            CampaignMemberHelper.preventCMemberDelete(this.connectedUser, caMember);
		}
	}

    private void bulkbeforeProcessing(Map<Id, CampaignMember> oldMap) {
        connectedUser = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
    }
}