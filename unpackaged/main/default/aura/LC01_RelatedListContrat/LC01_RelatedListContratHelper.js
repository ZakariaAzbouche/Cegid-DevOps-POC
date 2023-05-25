({
    getData: function(component, page) {
        console.log('getData');
        this.showSpinner(component);
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
        component.set("v.mySpinner", true);
        var action = component.get("c.fetchData");
        action.setParams({
            recordId :component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('result.error',result.success);
                console.log('Before set result' , result);
                component.set("v.data", result.subscriptions);
                
                var _errorMSG =result.success;
                if (_errorMSG == false && result.error == null) {
                    console.log('_errorMSG',_errorMSG);
                    component.set("v.errorMsg", $A.get("$Label.c.NoSubscriptions"));
                }else if (_errorMSG == true && result.subscriptions == null){
                    console.log('_errorMSG',_errorMSG);
                    component.set("v.errorMsg", $A.get("$Label.c.NoSubscriptions"));
                }else if(_errorMSG == true && result.error == null){
                    var _getStatus = result.subscriptions;
                    var _active;
                    var _pending;
                    var _cancelled;
                    //console.log('result.subscriptions : ' ,result.subscriptions );
                    
                    for(var i=0; i < _getStatus.length; i++){
                        var _status = _getStatus[i].status;
                        if(_status == "Active"){
                            //console.log("Active");
                            _active= component.get("v.statusActive");
                            _active.push(_getStatus[i]);
                        }else if(_status == "Pending Activation"){
                            //console.log("Pending Activation");
                            _pending= component.get("v.statusPending");
                            _pending.push(_getStatus[i]);
                        }else if(_status == "Cancelled"){
                            //console.log("Cancelled");
                            _cancelled= component.get("v.statusCancelled");
                            _cancelled.push(_getStatus[i]);
                        }
                        
                    }
                    component.set("v.statusActive",_active);
                    //console.log('result.Active',JSON.stringify(_active));
                    component.set("v.statusPending",_pending);
                    component.set("v.statusCancelled",_cancelled);
                    //console.log('result.Subscriptions',result.subscriptions);
                    //console.log('result.Subscriptions',result.subscriptions.length);
                    component.set("v.totalRows",result.subscriptions.length);
                }else{
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message_WS"));
                }
                this.hideSpinner(component);
            } else if (state === "ERROR") {
                this.handleResponseError(response.getError());
            }
            component.set("v.mySpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    openPopUp: function (component,helper, row) {
        var _row = row.id;
        console.log('_row helper : ' , _row);
        
        console.log('OpenPopUp');
        $A.createComponent(
                "c:LC01_RelatedListContratDetails", {
                    subscriptionId: _row
                },
                function(content, status) {
                    if(status === "SUCCESS") {
                        component.find("overlayLib").showCustomModal({
                            body: content,
                            showCloseButton: true,
                            cssClass: "slds-modal_large",
                            closeCallback: function() {}
                        });
                        component.find("overlayLib").notifyClose();
                    }
                    else {
                        console.log("Error while opening the component");
                    }
                }
            );
    },

    delete: function (component, page, recordId) {
        this.showSpinner(component);
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
        var action = component.get("c.deleteRecord");
        action.setParams({
            infoJSON : JSON.stringify({
                "pageNumber": page,
                "recordToDisplay": recordToDisplay,
                "objectType" : objectType,
                "parentRecordId": parentRecordId,
                "parentField": parentField,
                "recordId": recordId
            })
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.data", result.data);
                component.set("v.page", result.page);
                component.set("v.total", result.total);
                component.set("v.pages", Math.ceil(result.total / recordToDisplay));
                this.hideSpinner(component);
                this.showToast(component, 'success', 'Object was deleted.');
            } else if (state === "ERROR") {
                this.handleResponseError(response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    sortData: function (component, fieldName, sortDirection) {
        this.showSpinner(component);
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
        this.hideSpinner(component);
    },

    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    showSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    showToast : function(component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Related List Message',
            message: message,
            duration:' 3000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },

    handleResponseError: function (component,helper, errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showToast(component, 'error', "Error message: " +
                    errors[0].message);
            }
        } else {
            this.showToast(component, 'error', 'Unknown error.');
        }
        this.hideSpinner(component);
    },
})