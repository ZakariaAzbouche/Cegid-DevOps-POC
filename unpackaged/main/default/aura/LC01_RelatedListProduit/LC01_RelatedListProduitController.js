({
    doInit: function(component, event, helper) {
        
        component.set('v.columns', [
            //{ initialWidth: 4, type: "button", typeAttributes: {name: 'BtnNumero', title: 'Numero' }},
            { initialWidth: 350, type: "button",label:'Nom charge ', typeAttributes: { variant:'base' ,label: { fieldName: 'name' },name:'BtnNumero' }},
            //{label: 'Nom charge ', fieldName:'name', type: 'text', sortable: 'true'},
            {label: 'Type', fieldName: 'type', type: 'text', sortable: 'true'},
            {label: 'Model', fieldName: 'model', type: 'text', sortable: 'true'},
            {label: 'UOM', fieldName: 'uom', type: 'text', sortable: 'true'},
            {label: 'Prix Unitaire', fieldName: 'unitPrice', type: 'currency', sortable: 'true'},
            {label: 'Qte', fieldName: 'quantity', type: 'number', sortable: 'true'},
            {label: 'Total', fieldName: 'total', type: 'currency', sortable: 'true'},
            {label: 'Facturation', fieldName: 'billingPeriod', type: 'text', sortable: 'true'},

        ]); 
		helper.getData(component, page);
        var page = component.get("v.page") || 1;
        
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
        console.log('handleRowAction Row' , JSON.stringify(row));
        console.log('Row.id', row.name);
        console.log('StartDate__',row.startDate);
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
    }
})