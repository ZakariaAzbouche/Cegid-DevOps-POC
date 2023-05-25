({
    doInit: function(component, event, helper) {
        
        var _subscriptionName = component.get("v.subscriptionName");
        //console.log('_subscriptionName',_subscriptionName);
        component.set('v.columns', [
            //{ initialWidth: 4, type: "button", typeAttributes: {name: 'BtnNumero', title: 'Numero' }},
            {label: 'Période', fieldName:'startdate', type: 'text', sortable: 'true'},
            {label: 'Abonnement', fieldName:'subscriptionId', type: 'text', sortable: 'true'},
            //{ initialWidth: 350, type: "button",label:'Abonnement', typeAttributes: { variant:'base' ,label: { fieldName: subscriptionId },name:'BtnNumero' }},
            {label: 'Nom charge ', fieldName:'name', type: 'text', sortable: 'true'},
            {label: 'UOM', fieldName: 'uom', type: 'text', sortable: 'true'},
            {label: 'Qte', fieldName: 'quantity', type: 'number', sortable: 'true'},
            {label: 'Statut', fieldName: 'type', type: 'text', sortable: 'true'},
            {label: 'Chargé le', fieldName: 'billingPeriod', type: 'text', sortable: 'true'}

        ]); 
		helper.getData(component, page);
        var page = component.get("v.page") || 1;
        
    },
    
    openProductInfo: function(component, event, helper) {
        component.set("v.prductDetail" , true);
        //console.log('openProductInfo ');
        //helper.getProductInfo(component, helper,event);
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
        //console.log('Row.id', row.name);
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
    
        setColumns: function (component,helper) {
            
            var tableType =component.get("v.tableType");
            if(tableType=="active"){
              var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
        ];

        component.set('v.columns', [
            //{ initialWidth: 4, type: "button", typeAttributes: {name: 'BtnNumero', title: 'Numero' }},
            {label: 'Nom charge ', fieldName:'customer.name', type: 'text', sortable: 'true'},
            {label: 'Type', fieldName: 'rateplans.charges.type', type: 'text', sortable: 'true'},
            {label: 'Model', fieldName: 'rateplans.charges.model', type: 'number', sortable: 'true'},
            {label: 'UOM', fieldName: 'rateplans.charges.uom', type: 'text', sortable: 'true'},
            {label: 'Prix Unitaire', fieldName: 'rateplans.charges.unitPrice', type: 'text', sortable: 'true'},
            {label: 'Qte', fieldName: 'rateplans.charges.name', type: 'text', sortable: 'true'},
            {label: 'Total', fieldName: '', type: 'text', sortable: 'true'},
            {label: 'Facturation', fieldName: '', type: 'text', sortable: 'true'},

            { type: 'action', typeAttributes: { rowActions: actions }}
        ]);  
            }
            
        } 
})