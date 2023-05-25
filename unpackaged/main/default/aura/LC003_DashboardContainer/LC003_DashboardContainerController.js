({
    doInit : function(component, event, helper) {
        var _pageReference = component.get("v.pageReference");
        if(!$A.util.isUndefinedOrNull(_pageReference.state.c__getProductId)){
            var _productId = _pageReference.state.c__getProductId; 
            component.set("v.getProductId", _productId);
            console.log('_productId', _productId);
        }
        
        if(!$A.util.isUndefinedOrNull(_pageReference.state.c__getRecordTypeDevName)){
            var _recType = _pageReference.state.c__getRecordTypeDevName;
            component.set("v.getRecordTypeDevName", _recType);
            console.log('_recType', _recType);
        }
        
        if(!$A.util.isUndefinedOrNull(_pageReference.state.c__displayCustom)){
            var _customReport = _pageReference.state.c__displayCustom;
            component.set("v.displayCustom", _customReport);
        }
        
        if(!$A.util.isUndefinedOrNull(_pageReference.state.c__getIds)){
            var _getReportIds = _pageReference.state.c__getIds;
            console.log('_getReportIds', _getReportIds);
            if(_getReportIds != ''){
                var _reportIds = _getReportIds.split(';');
                if(_reportIds.length == 1){
                    component.set("v.colSize", 'slds-col slds-size_6-of-6');
                }else if(_reportIds.length >= 2){
                    component.set("v.colSize", 'slds-col slds-size_2-of-6');
                }else if(_reportIds.length == 0){
                    helper.setError(component,event,helper);
                }
                component.set("v.reportIds", _reportIds);
            }
            
        }
        
        
    },
    
    Reload : function(component, event, helper) {
        console.log('Reload');
        $A.get('e.force:refreshView').fire();
    }
    
    
})