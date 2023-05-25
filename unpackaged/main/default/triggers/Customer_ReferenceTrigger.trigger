trigger Customer_ReferenceTrigger on Customer_Reference__c (before insert, before update, before delete, after delete) {
    TriggerFactory.createTriggerDispatcher(Customer_Reference__c.sObjectType);
}