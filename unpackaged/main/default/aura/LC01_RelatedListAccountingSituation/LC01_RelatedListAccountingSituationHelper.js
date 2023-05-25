({
    getData: function(component, event, helper) {
        console.log('getData');
        this.showSpinner(component);
        component.set("v.mySpinner", true);
        var action = component.get("c.fetchData");
        action.setParams({
            recordId :component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //component.set("v.data", result.recoveryStatus);
                const data = Object.entries(result);
                component.set("v.totalRows", data.length -1);
                
                 if (result.recoveryStatus == null) {
                    component.set("v.errorMsg", $A.get("$Label.c.Error_WS_Aston"));
                }else{
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message_WS"));
                }
            } else if (state === "ERROR") {
                this.handleResponseError(response.getError());
            }
            this.hideSpinner(component);
            component.set("v.mySpinner", false);
        });
        $A.enqueueAction(action);
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
    }    
})