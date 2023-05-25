trigger CampaignMemberTrigger on CampaignMember (before delete) {
    TriggerFactory.createTriggerDispatcher(CampaignMember.sObjectType);
}