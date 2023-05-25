public class DependentPicklistUtils{
    
    public class MyPickListInfo{
        public String validFor;
    }
    
    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField){
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
        for(Schema.PicklistEntry currControllingValue : controllingValues){
            System.debug('ControllingField: Label:' + currControllingValue.getValue());
            controllingInfo.put(currControllingValue.getValue(), new List<String>());
        }
        
        for(Schema.PicklistEntry currDependentValue : dependentValues){
            String jsonString = JSON.serialize(currDependentValue);
            
            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);
            
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            
            System.debug('DependentField: Label:' + currDependentValue.getLabel() + ' ValidForInHex:' + hexString + ' JsonString:' + jsonString);
            
            Integer baseCount = 0;
            for(Integer curr : hexString.getChars()){
                Integer val = 0;
                
                if(curr >= 65){
                    val = curr - 65 + 10;
                }
                else{
                    val = curr - 48;
                }
                if((val & 8) == 8){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Part of ControllingField:' + controllingValues[baseCount + 0].getValue());
                    controllingInfo.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getLabel());
                }
                if((val & 4) == 4){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Part of ControllingField:' + controllingValues[baseCount + 1].getValue());
                    controllingInfo.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getLabel());                    
                }
                if((val & 2) == 2){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Part of ControllingField:' + controllingValues[baseCount + 2].getValue());
                    controllingInfo.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getLabel());                    
                }
                if((val & 1) == 1){
                    System.debug('Dependent Field: ' + currDependentValue.getLabel() + ' Part of ControllingField:' + controllingValues[baseCount + 3].getValue());
                    controllingInfo.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getLabel());                    
                }
                
                baseCount += 4;
            }            
        } 
        
        System.debug('ControllingInfo: ' + controllingInfo);       
        return controllingInfo;
    }
}