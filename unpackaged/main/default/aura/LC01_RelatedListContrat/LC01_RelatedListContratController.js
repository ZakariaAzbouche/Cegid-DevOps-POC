({
    doInit: function(component, event, helper) {
        var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        component.set('v.columns', [
            { initialWidth: 4, type: "button", typeAttributes: {name: 'BtnNumero', title: 'Numero' }},
            //{label: 'Numero ', fieldName:'subscriptionId', type: 'text', sortable: 'true'},
            {label: 'Ref Client', fieldName: 'status', type: 'text', sortable: 'true'},
            {label: 'MRR', fieldName: 'meanRecurringRevenue', type: 'number', sortable: 'true'},
            {label: 'Date Debut', fieldName: 'subscriptionActivationDate', type: 'text', sortable: 'true'},
            {label: 'Date fin engagement', fieldName: 'currentTermEndDate', type: 'text', sortable: 'true'},
            {label: 'Date realisation prevue', fieldName: '', type: 'text', sortable: 'true'},

            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);

        var page = component.get("v.page") || 1;
        helper.getData(component, page);
    },

    navigate: function(component, event, helper) {
        var page = component.get("v.page") || 1;
        var direction = event.getSource().get("v.label");
        page = direction === "Previous Page" ? (page - 1) : (page + 1);

        helper.getData(component, page);
    },

    onSelectChange: function(component, event, helper) {
        var page = 1;
        helper.getData(component, page);
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        //console.log('handleRowAction Row' , JSON.stringify(row));
        console.log('Row.subscriptionId', row.id);
        switch (action.name) {
                
            case 'BtnNumero':
                helper.openPopUp(component, event, row);
                break;
        }
    },

    createRecord : function (component) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var objectType = component.get("v.objectType");

        createRecordEvent.fire({
            "entityApiName": objectType
        });
    },

    handleApplicationEvent: function (component, event, helper) {
        var page = component.get("v.page") || 1;
        helper.getData(component, page);
    },

    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },
    
    showDetails: function (component, event, helper) {
        var _btnEvent = component.get("v.canDisplay");
        
        if(_btnEvent){
            component.set("v.canDisplay", false);
        }else{
            component.set("v.canDisplay", true);
        }
    }
})