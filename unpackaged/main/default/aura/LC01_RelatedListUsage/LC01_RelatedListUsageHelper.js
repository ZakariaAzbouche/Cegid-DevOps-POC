({
    getData: function(component, page) {
        console.log('getData');
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
                //component.set("v.data", result.subscriptionItems);
                //component.set("v.productName", 'Produit : ' + result.subscriptionItems.product.name);
                
                var _errorMSG =result.success;
                if (_errorMSG == false && result.error == null) {
                    //console.log('_errorMSG',_errorMSG);
                    component.set("v.errorMsg", $A.get("$Label.c.NoProduct"));
                }else if(_errorMSG == true && result.error == null){
                
                    var subscriptionItemsList = [];
                    var rateplansList = [];
                    var chargesList = [];
                    var final =[];
                    var arr = [];
                    var chargeFinal =[];
                    var _subscriptionId= component.get("v.subscriptionName");
                    var today = new Date();
                    var endDate = new Date();
                    var dd = String(today.getDate()).padStart(2, '0');
                    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
                    var yyyy = today.getFullYear();
                    
                    today = yyyy + '-' + mm + '-' + dd;
                    //console.log('_subscriptionId',_subscriptionId);
                    //
                    for (var i in result.subscriptionItems) {
                        subscriptionItemsList.push(result.subscriptionItems[i]);
                    }
                    //console.log('subscriptionItemsList',subscriptionItemsList);

                    for (var i in subscriptionItemsList) {
                        rateplansList.push(subscriptionItemsList[i].rateplans);
                    }
                    /*
                    for (var i in rateplansList) {
                        chargesList.push(rateplansList[i].charges);
                    }
                    console.log('chargesList',chargesList);
                    
                    console.log('result.length',result.subscriptionItems[0].customer);
                    for (var i = 0; i < result.subscriptionItems.rateplans.length; i++) {
                        rateplansList.push(result.subscriptionItems.rateplans[i]);
                    }
                    //console.log('rateplansList',rateplansList);
                    */
                    for(var i in rateplansList){
                        //console.log('Start Date',rateplansList[i].startDate);
                        for (var j in rateplansList[i]["charges"]){
                            chargesList.push({
                                chargesx:rateplansList[i]["charges"][j]
                                //startdatex:rateplansList[i]["startDate"]
                            });
                        }
                    }
                    //console.log('$$$$ chargesList',chargesList);
                    
                    for(var i in chargesList){
                        endDate = chargesList[i]["chargesx"]["endDate"];
                        //console.log('endDate',endDate);
                        //console.log('today',today);
                        if(endDate >= today){
                            chargeFinal.push({
                                name:chargesList[i]["chargesx"]["name"],
                                type:chargesList[i]["chargesx"]["type"],
                                model:chargesList[i]["chargesx"]["model"],
                                billingPeriod:chargesList[i]["chargesx"]["billingPeriod"],
                                uom:chargesList[i]["chargesx"]["uom"],
                                unitPrice:chargesList[i]["chargesx"]["unitPrice"],
                                quantity:chargesList[i]["chargesx"]["quantity"],
                                startdate:chargesList[i]["chargesx"]["startDate"],
                                enddate:chargesList[i]["chargesx"]["endDate"],
                                subscriptionId:_subscriptionId
                                
                            });
                        }
                    }
                    //console.log('$$$$ chargeFinal',chargeFinal);
                    component.set("v.dataRatePlans",chargeFinal);
                    //component.set("v.productList",result.subscriptionItems.product);
                    //console.log("productList",result.subscriptionItems.product);
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
        var _name = row.name;
        var _startDate= row.startDate;
        var _endDate= row.endDate;   
        var _lastInvoiceDate= row.lastInvoiceDate;
        var _nextInvoiceDate= row.nextInvoiceDate;
        //console.log('_startDate : ' , _startDate);
        
        //console.log('OpenPopUp');
        $A.createComponent(
                "c:LC01_RelatedListProduitCharges", {
                    name:_name,
                    startDate:_startDate,
                    endDate: _endDate,
                    nextInvoiceDate: _nextInvoiceDate,
                    lastInvoiceDate: _lastInvoiceDate
                    
                },
                function(content, status) {
                    if(status === "SUCCESS") {
                        component.find("overlayLib").showCustomModal({
                            body: content,
                            showCloseButton: true,
                            //cssClass: "slds-modal_medium",
                            closeCallback: function() {}
                        });
                        //component.find("overlayLib").notifyClose();
                    }
                    else {
                        console.log("Error while opening the component");
                    }
                }
            );
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
        //console.log('Helper getProductInfo');
        var _setData = component.get("v.data");
        console.log('produit OpenPopUp');
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
        );
    }
    
})