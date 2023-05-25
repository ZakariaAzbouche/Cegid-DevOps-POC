public class Customer_ReferenceTriggerDispatcher extends TriggerDispatcherBase {
    public virtual override void beforeInsert(TriggerParameters tp) {
        System.debug('DISPATCH Customer_Reference BEFORE_INSERT');
        execute(new Customer_RefBeforeInsertTriggerHandler(), tp);
    }

    public virtual override void beforeUpdate(TriggerParameters tp) {
        System.debug('DISPATCH Customer_Reference BEFORE_UPDATE');
        execute(new Customer_RefBeforeUpdateTriggerHandler(), tp);
    }
    
    public virtual override void beforeDelete(TriggerParameters tp) {
        System.debug('DISPATCH Customer_Reference BEFORE_DELETE');
        execute(new Customer_RefBeforeDeleteTriggerHandler(), tp);
    }

    public virtual override void afterDelete(TriggerParameters tp) {
        System.debug('DISPATCH Customer_Reference AFTER_DELETE');
        execute(new Customer_RefAfterDeleteTriggerHandler(), tp);
    }
}