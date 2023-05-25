@isTest
public class TriggerParameters_Test {
    @isTest static void contructorTest() {
        List<SObject> olist = new List<SObject>();
        List<SObject> nlist = new List<SObject>();
        Map<Id, SObject> omap = new Map<Id, SObject>();
        Map<Id, SObject> nmap = new Map<Id, SObject>();
        Boolean isExecuting = true;

        TriggerParameters tp1 = new TriggerParameters(olist, nlist, omap, nmap, System.TriggerOperation.BEFORE_INSERT, isExecuting);

        System.assertEquals(olist, tp1.oldList, 'Trigger oldList missmatch');
        System.assertEquals(nlist, tp1.newList, 'Trigger newList missmatch');
        System.assertEquals(omap, tp1.oldMap, 'Trigger newMap missmatch');
        System.assertEquals(nmap, tp1.newMap, 'Trigger oldMap missmatch');
        System.assertEquals(System.TriggerOperation.BEFORE_INSERT, tp1.triggerEvent, 'Trigger event missmatch');
        System.assertEquals(isExecuting, tp1.isExecuting, 'trigger isExecuting missmatch');

        TriggerParameters tp2 = new TriggerParameters(olist, nlist, omap, nmap, System.TriggerOperation.BEFORE_UPDATE, isExecuting);

        System.assertEquals(olist, tp2.oldList, 'Trigger oldList missmatch');
        System.assertEquals(nlist, tp2.newList, 'Trigger newList missmatch');
        System.assertEquals(omap, tp2.oldMap, 'Trigger newMap missmatch');
        System.assertEquals(nmap, tp2.newMap, 'Trigger oldMap missmatch');
        System.assertEquals(System.TriggerOperation.BEFORE_UPDATE, tp2.triggerEvent, 'Trigger event missmatch');
        System.assertEquals(isExecuting, tp2.isExecuting, 'trigger isExecuting missmatch');

    }
}