({
    onChangeCheckBox : function(component, event, helper) {
        console.log('onChangeCheckBox : ');
        var _details = component.get('v.lineDetails');
        var _subscriptionId = _details.subscriptionId;
        var _customerId = _details.customer.Id;
        var _checkbox = component.get('v.addToList');
        var _selectedId = component.get('v.subscriptionId');

        var _addToList = $A.get("e.c:LC005_AddToList");
        _addToList.setParams({
            "items": component.get('v.lineDetails'),
            "checkBoxValue" : component.get('v.addToList'),
            "subscriptionId" : _subscriptionId,
            "customerId" : _customerId
        });
        
        _addToList.fire();

    },

    doInit : function(component, event, helper) {
        console.log('doInit : Child component');
        var _checkStatus = component.get("v.disableButton");
    }
})