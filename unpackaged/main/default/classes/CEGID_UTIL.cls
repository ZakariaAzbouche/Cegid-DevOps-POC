/**
* @author Keshav - Comforth
* @date 2020-02
* @group Cegid
* @description Utility methods
*/
public class CEGID_UTIL {
    public static Map<String, Object> getMetadata(){ 
        // Object Level Security for product
        Map <String, Object> mapProductPermissions = new Map <String, Object>{
            'isAccessible' => Product2.sObjectType.getDescribe().isAccessible(),
                'isCreateable' => Product2.sObjectType.getDescribe().isCreateable(),
                'isUpdateable' => Product2.sObjectType.getDescribe().isUpdateable(),
                'isDeletable' => Product2.sobjectType.getDescribe().isDeletable()
                };
                    
                    Map <String, Schema.SObjectField> mapProductFields = Schema.SObjectType.Product2.fields.getMap();
        
        // Loop over all fields of product
        for (String field : mapProductFields.keySet()) {
            Map <String, Object> mapField = new Map <String, Object>{
                'isAccessible' => mapProductFields.get(field).getDescribe().isAccessible(),
                    'isCreateable' => mapProductFields.get(field).getDescribe().isCreateable(),
                    'isUpdateable' => mapProductFields.get(field).getDescribe().isUpdateable(),
                    'label'        => mapProductFields.get(field).getDescribe().getLabel()
                    };
                        
                        mapProductPermissions.put(field, mapField);
        }
        
        // Object Level Security for product option
        Map <String, Object> mapProductOptionPermissions = new Map <String, Object>{
            'isAccessible' => SBQQ__ProductOption__c.sObjectType.getDescribe().isAccessible(),
                'isCreateable' => SBQQ__ProductOption__c.sObjectType.getDescribe().isCreateable(),
                'isUpdateable' => SBQQ__ProductOption__c.sObjectType.getDescribe().isUpdateable(),
                'isDeletable' => SBQQ__ProductOption__c.sobjectType.getDescribe().isDeletable()
                };
                    
                    Map <String, Schema.SObjectField> mapProductOpptionFields = Schema.SObjectType.SBQQ__ProductOption__c.fields.getMap();
        
        // Loop over all fields of product Option 
        for (String field : mapProductOpptionFields.keySet()) {
            Map <String, Object> mapField = new Map <String, Object>{
                'isAccessible' => mapProductOpptionFields.get(field).getDescribe().isAccessible(),
                    'isCreateable' => mapProductOpptionFields.get(field).getDescribe().isCreateable(),
                    'isUpdateable' => mapProductOpptionFields.get(field).getDescribe().isUpdateable(),
                    'label'        => mapProductOpptionFields.get(field).getDescribe().getLabel()
                    };
                        
                        mapProductOptionPermissions.put(field, mapField);
        }
        
        return new Map<String, Object>{
            'Product2' 		=> mapProductPermissions,
                'SBQQ__ProductOption__c' 		=> mapProductOptionPermissions
                };
                    }
    
    
    
}