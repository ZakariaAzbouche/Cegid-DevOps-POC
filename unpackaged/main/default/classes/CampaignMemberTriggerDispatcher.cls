public class CampaignMemberTriggerDispatcher extends TriggerDispatcherBase {

    public virtual override void beforeDelete(TriggerParameters tp) {
        System.debug('DISPATCH CAMPAIGNMEMBER BEFORE_DELETE');
        execute(new CampaignMemberBeforeDeleteTriggerHandler(), tp);
    }
}