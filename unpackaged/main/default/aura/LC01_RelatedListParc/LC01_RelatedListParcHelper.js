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
            var result = response.getReturnValue();
            var resultError =result.error;
            console.log('resultError',resultError);
            if (state === "SUCCESS" && resultError==null) {
                console.log('SUCCESS');
                
                console.log('result',result);
                //console.log('Before set result' , JSON.stringify(result));
                component.set("v.data", result.parcList);
                component.set("v.totalRows",result.parcList.length);
                //console.log('*** result',result.parcList.numero_de_souscription);
                //console.log('v.totalRows',result.parcList.length);
                var _errorMSG =result.success;
                
                if (result.parcList){
                    for(var i = 0; i < result.parcList.length; i++){
                        //console.log('Souscription',result.parcList[i].numero_de_souscription.value);
                        result.parcList[i].subnum= result.parcList[i].numero_de_souscription.value;
                    }
                component.set("v.data", result.parcList);
                
                }else if (result.parcList == null) {
                    component.set("v.errorMsg", $A.get("$Label.c.Error_WS_Parc"));
                }else if(_errorMSG == true){
                    component.set("v.errorMsg", $A.get("$Label.c.Error_WS_Parc"));
                }else{
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message_WS"));
                }
                this.hideSpinner(component);
            } else if (state === "ERROR" && resultError!=null) {
                console.log('Error');
                this.handleResponseError(response.getError());
            }
            component.set("v.mySpinner", false);
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