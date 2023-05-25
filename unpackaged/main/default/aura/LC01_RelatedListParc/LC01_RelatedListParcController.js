({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Sous contrat', fieldName: 'Sous_contrat', type: 'text', sortable: 'true'},
            {label: 'Code', fieldName: 'Code_Article_SIC', type: 'text', sortable: 'true'},
            {label: 'Nom', fieldName: 'Nom_du_produit', type: 'text', sortable: 'true'},
            {label: 'Etat', fieldName: 'etat', type: 'text', sortable: 'true'},
            {label: 'Status', fieldName: 'statut', type: 'text', sortable: 'true'},
            {label: 'Version', fieldName: 'Version_en_cours', type: 'text', sortable: 'true'},
            {label: 'Activité', fieldName: 'activitee_niveau_1', type: 'text', sortable: 'true'},
            {label: 'N° séria/Série', fieldName: 'Numero_de_serie', type: 'text', sortable: 'true'},
            {label: 'Hébergé', fieldName: 'Hebergee', type: 'text', sortable: 'true'},
            {label: 'Date début', fieldName: 'Date_debut_de_contrat', type: 'text', sortable: 'true'},
            {label: 'Date fin', fieldName: 'Date_fin_de_contrat', type: 'text', sortable: 'true'},
            {label: 'Souscription', fieldName: 'subnum', type: 'text', sortable: 'true'}

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
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.fire({
                    "recordId":  row.id
                });
                break;
                
            case 'delete':
                var page = component.get("v.page") || 1;
                helper.delete(component, page, row.Id);
                break;
                
            case 'BtnNumero':
                helper.openPopUp(component, event, row);
                break;
        }
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
            component.set("v.errorMsg", null);
        }
    }
})