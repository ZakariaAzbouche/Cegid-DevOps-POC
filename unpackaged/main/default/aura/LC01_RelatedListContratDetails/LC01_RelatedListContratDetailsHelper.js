({
    getData: function(component, event) {
        console.log('getData');
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
        var _getsubscriptionId = component.get("v.subscriptionId");
		component.set("v.mySpinner", true);
        var action = component.get("c.fetchData");
        action.setParams({
            recordId :component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
               
                var _setListSub;
                for(var i=0; i < result.subscriptions.length; i++){
                    //console.log('result.subscriptions[i] : ', result.subscriptions[i]);
                    var _id = result.subscriptions[i].subscriptionId;
                    //console.log('_id : ', _id);
                    //console.log('_getsubscriptionId : ', _getsubscriptionId);
                    if(_id == _getsubscriptionId){
                        //console.log('true');
                        _setListSub = result.subscriptions[i];
                        
                        result.subscriptions[i].isActive=false;
                        result.subscriptions[i].isPending=false;
                        result.subscriptions[i].isCancelled=false;
                        
                        var _status = result.subscriptions[i].status;
                        //console.log('_status: ', _status);
                        if(_status == 'Active'){
                        	result.subscriptions[i].isActive=true;
                        }
                        if(_status == 'Pending Activation'){
                            result.subscriptions[i].isPending=true;
                        }
                        if(_status == 'Cancelled'){
                            result.subscriptions[i].isCancelled=true;
                        }
                        //console.log("Status Active",_status);
                    }
                }
                
                console.log('$_setListSub: ', _setListSub);
                component.set("v.data", _setListSub);
                component.set("v.subscriptionName",_setListSub.subscriptionId);
                console.log("subscriptionName",_setListSub.subscriptionId);
                component.set("v.dataLoaded",true); 
            } else if (state === "ERROR") {
                this.handleResponseError(response.getError());
            }
            component.set("v.mySpinner", false);
        });
        $A.enqueueAction(action);
    }
})