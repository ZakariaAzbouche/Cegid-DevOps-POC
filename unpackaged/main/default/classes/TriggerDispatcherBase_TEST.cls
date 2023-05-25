@isTest
public class TriggerDispatcherBase_TEST {
     
    @isTest static void beforeInsertTest() {
        new TriggerDispatcherBase().beforeInsert(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.BEFORE_INSERT,
                 false));
    }

	@isTest static void beforeUpdateTest() {
        new TriggerDispatcherBase().beforeUpdate(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.BEFORE_UPDATE,
                 false));
    }

   
	@isTest static void beforeDeleteTest() {
        new TriggerDispatcherBase().beforeDelete(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.BEFORE_DELETE,
                 false));
    }

    
	@isTest static void afterInsertTest() {
        new TriggerDispatcherBase().afterInsert(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.AFTER_INSERT,
                 false));
    }

    
	@isTest static void afterUpdateTest() {
        new TriggerDispatcherBase().afterUpdate(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.AFTER_UPDATE,
                 false));
    }

    
	@isTest static void afterDeleteTest() {
        new TriggerDispatcherBase().afterDelete(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.AFTER_DELETE,
                 false));
    }

    
	@isTest static void afterUnDeleteTest() {
        new TriggerDispatcherBase().afterUnDelete(new TriggerParameters(
            new List<SObject>(),
            new List<SObject>(),
            new Map<Id, SObject>(),
            new Map<Id, SObject>(),
            System.TriggerOperation.AFTER_UNDELETE,
                 false));
    }
}