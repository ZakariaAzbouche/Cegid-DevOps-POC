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

                //Retrieve data needed from WS and store in attributes
                var resultData = result.recoveryStatus;
                component.set('v.accName',resultData['Social reason']);
                component.set('v.reference',resultData['Client reference']);
                var year = resultData['Year of reference (Y)'];
                var month = resultData['Month of reference (M)'];
                component.set('v.yearMonthRef',year+'/'+month);
                component.set('v.scoring',resultData['Scoring (Aston)']);
                component.set("v.annualTurnover",resultData['Turnover of the year Y']);
                component.set("v.annualTurnoverY1",resultData['Turnover Y-1']);
                //component.set("v.sumRemainingInc",resultData[''])
                //component.set("v.sumRemainingExc",resultData[''])
                component.set("v.realOustanding",resultData['Real outstanding with VAT']);
                component.set("v.disputed",resultData['Outstanding with Dispute']);
                component.set("v.litigation",resultData['Litigation amount']);
                component.set("v.dso",resultData['DSO']);
                component.set("v.d30",resultData['Amount of delay<30 days']);
                component.set("v.d_31_60",resultData['Amount of delay 31-60 days']);
                component.set("v.d_61_90",resultData['Amount of delay 61-90 days']);
                component.set("v.d_91_120",resultData['Amount of delay 91-120 days']);
                component.set("v.d_121_150",resultData['Amount of delay 121-150 days']);
                component.set("v.d150",resultData['Amount of delay >150 days']);
                component.set("v.inv30", resultData['Number of delay <30 days']);
                component.set("v.inv_31_60",resultData['Number of delay 31-60 days']);
                component.set("v.inv150",resultData['Number of delay >150 days']);
                component.set("v.inv_61_90",resultData['Number of delay 61-90 days']);
                component.set("v.inv_91_120",resultData['Number of delay 91-120 days']);
                component.set("v.inv_121_150",resultData['Number of delay 121-150 days']);
                component.set("v.totalInv",resultData['Number of delay']);
                component.set("v.total",resultData['Amount of delay']);
                component.set("v.nChargedCredits",resultData['Non charged credits']);
                component.set("v.unpaidNumber",resultData['Unpaid number']);
                component.set("v.unpaidAmount",resultData['Unpaid amount']);
                component.set("v.colorCode",resultData['colorcode']);

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