({
    openPopUp: function (component,helper, row) {
        var _row = row.subscriptionId;
        var _recId = component.get("v.recordId")
        console.log('_row : ' , _row);
        
        console.log('OpenPopUp');
        $A.createComponent(
                "c:LC01_RelatedListContratDetails", {
                    subscriptionId: _row,
                    recordId : _recId
                },
                function(content, status) {
                    if(status === "SUCCESS") {
                        component.find("overlayLib").showCustomModal({
                            body: content,
                            showCloseButton: true,
                            cssClass: "slds-modal_large",
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
        setColumns: function (component,helper) {
            var tableType =component.get("v.tableType");
            if(tableType=="active"){
              var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        component.set('v.columns', [
            { initialWidth: 250, type: "button",label:'Numero', typeAttributes: { variant:'base' ,label: { fieldName: 'subscriptionId' },name:'BtnNumero' }},
            //{label: 'Numero ', fieldName:'subscriptionId', type: 'text', sortable: 'true'},
            {label: 'Réf Client', fieldName: 'purchaseOrder', type: 'text', sortable: 'true'},
            {label: 'MRR', fieldName: 'meanRecurringRevenue', type: 'currency', sortable: 'true'},
            {label: 'Date début', fieldName: 'subscriptionActivationDate', type: 'text', sortable: 'true'},
            {label: 'Date fin engagement', fieldName: 'currentTermEndDate', type: 'text', sortable: 'true'},
            {label: 'Date réalisation prevue', fieldName: 'plannedCancelationDate', type: 'text', sortable: 'true'},

            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);  
                component.set("v.lightningIcon",'action:new_opportunity');
                component.set("v.lightningTitle",'Abonnements - Actifs');
            }else if(tableType=="pending"){
               var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        component.set('v.columns', [
            { initialWidth: 250, type: "button", label:'Numero', typeAttributes: {variant:'base' , label: { fieldName: 'subscriptionId' },name:'BtnNumero' }},
            //{label: 'Numero ', fieldName:'subscriptionId', type: 'text', sortable: 'true'},
            {label: 'Réf Client', fieldName: 'purchaseOrder', type: 'text', sortable: 'true'},
            {label: 'Durée initiale', fieldName: 'initialTerm', type: 'text', sortable: 'true'},
            {label: 'Durée renouvellement', fieldName: 'currentTermEndDate', type: 'text', sortable: 'true'},
            {label: 'Date début souhaitée', fieldName: 'targetDeliveryDate', type: 'text', sortable: 'true'},
            {label: 'Date début prévue', fieldName: 'plannedDeliveryDate', type: 'text', sortable: 'true'},

            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);  
                component.set("v.lightningIcon",'custom:custom18');
                component.set("v.lightningTitle",'Abonnements - A activer');
            }else if(tableType=="cancel"){
               var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        component.set('v.columns', [
            { initialWidth: 250, type: "button",label:'Numero', typeAttributes: {variant:'base' , label: { fieldName: 'subscriptionId' },name:'BtnNumero' }},
            //{label: 'Numero ', fieldName:'subscriptionId', type: 'text', sortable: 'true'},
            {label: 'Réf Client', fieldName: 'purchaseorder', type: 'text', sortable: 'true'},
            {label: 'MRR', fieldName: 'meanRecurringRevenue', type: 'currency', sortable: 'true'},
            {label: 'Date début', fieldName: 'subscriptionActivationDate', type: 'text', sortable: 'true'},
            {label: 'Date fermeture', fieldName: 'subscriptionEndDate', type: 'text', sortable: 'true'},
            {label: 'Motif', fieldName: 'reasoncancellation', type: 'text', sortable: 'true'},

            { type: 'action', typeAttributes: { rowActions: actions }}
        ]); 
                component.set("v.lightningIcon",'custom:custom18');
                component.set("v.lightningTitle",'Abonnements - Fermer');
            }
            
        } 
    
})