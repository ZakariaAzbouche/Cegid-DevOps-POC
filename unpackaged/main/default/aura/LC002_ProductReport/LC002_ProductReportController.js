({
    doInit : function(component, event, helper) {
        console.log('Enter');
        console.log('Enter' , component.get("v.getProductId"));
        console.log('Enter', component.get("v.getRecordTypeDevName"));
        
        if(component.get("v.getProductId") == '-'){
            var _pageReference = component.get("v.pageReference");
            var _productId = _pageReference.state.c__getProductId;
            var _recType = _pageReference.state.c__getRecordTypeDevName;
            component.set("v.getProductId", _pageReference.state.c__getProductId);
            component.set("v.getRecordTypeDevName", _pageReference.state.c__getRecordTypeDevName);
        }
        
        helper.getData(component,event);
        helper.getMeta(component,event);
        
    }
})