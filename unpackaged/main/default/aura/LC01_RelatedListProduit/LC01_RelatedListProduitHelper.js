({
    getData: function(component, page) {
        //console.log('getData');
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
		component.set("v.mySpinner", true);
        var action = component.get("c.fetchData");
        action.setParams({
            recordId :component.get("v.recordId"),
            subName : component.get("v.subscriptionName")
        });
         $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('result',result);
                //console.log('Result Produit ***', result.subscriptionItems.product);
                
                var _errorMSG =result.success;
                if (_errorMSG == false && result.error == null) {
                    //console.log('_errorMSG',_errorMSG);
                    component.set("v.errorMsg", $A.get("$Label.c.NoProduct"));
                }else if(_errorMSG == true && result.error == null){
                
                    var subscriptionItemsList = [];
                    var rateplansList = [];
                    var chargesList = [];
                    var chargesDetailsList = [];
                    var productNameList = [];
                    var chargeList = [];
                    var final =[];
                    var arr = [];
                    var chargeFinal =[];
                    
                    //console.log('result.length',result.subscriptionItems[0].product.rateplans.charges.endDate);
                    for (var i in result.subscriptionItems) {
                        subscriptionItemsList.push(result.subscriptionItems[i]);
                    }
                    //console.log('subscriptionItemsList',subscriptionItemsList);
                    
                    for (var i in subscriptionItemsList) {
                        //console.log('charges',subscriptionItemsList[i].rateplans.charges);
                        productNameList.push(subscriptionItemsList[i].product);
                    }
                    //console.log('productNameList',productNameList);
                    
                    for (var i in subscriptionItemsList) {
                        rateplansList.push(subscriptionItemsList[i].rateplans);
                    }
                    //console.log('rateplansList',rateplansList);
                    
                    for (var i in rateplansList) {
                        chargesList.push(rateplansList[i].charges);
                    }
                    subscriptionItemsList.forEach(function (element) {
                        //console.log('element',element.rateplans);
                        element.rateplans.charges.forEach(function(charge){
                        //charge.startDate=element.rateplans.startDate; 
                        //charge.endDate=element.rateplans.endDate; 
                        charge.lastInvoiceDate=element.rateplans.lastInvoiceDate; 
                        charge.nextInvoiceDate=element.rateplans.nextInvoiceDate; 
                        //console.log('element.rateplans.startDate',element.rateplans.startDate);
                        //console.log('charge.startDate',charge.startDate);
                        });
                    });
                    //console.log('subscriptionItemsList',subscriptionItemsList);
                    
                    component.set("v.chargeList",subscriptionItemsList);
                    component.set("v.productList",productNameList);
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

    handleResponseError: function (helper, errors) {
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
    
    getProductInfo: function (component,event) {
        console.log('Helper getProductInfo');
        var _setData = component.get("v.data");
        console.log('produit OpenPopUp');
        /*
        $A.createComponent(
            "c:LC01_RelatedListProduitDetail", {
                data: _setData
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
        );*/
    }
    
})