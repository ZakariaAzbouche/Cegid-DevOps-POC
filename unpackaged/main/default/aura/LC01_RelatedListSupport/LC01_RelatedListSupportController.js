({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Number', fieldName: 'case_number', type: 'text'},
            {label: 'Created Date', fieldName: 'opened_at', type: 'date', sortable: 'true'},
            {label: 'Category', fieldName: 'cate', type: 'text', sortable: 'true'},
            {label: 'Title', fieldName: 'short_description', type: 'text',clipText:true},
            {label: 'Product', fieldName: 'productCode', type: 'text'},
            {label: 'Status', fieldName: 'state', type: 'text', sortable: 'true'},
            {label: 'Criticity', fieldName: 'priority', type: 'text', sortable: 'true'},
            {label: 'Service Level', fieldName: 'description', type: 'text'},
            {label: 'Owner', fieldName: 'conName', type: 'text'}

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

    handleApplicationEvent: function (component, event, helper) {
        var page = component.get("v.page") || 1;
        helper.getData(component, page);
    },
    
    showDetails: function (component, event, helper) {
        var _btnEvent = component.get("v.canDisplay");
        
        if(_btnEvent){
            component.set("v.canDisplay", false);
        }else{
            component.set("v.canDisplay", true);
            component.set("v.errorMsg", null);
        }
    },
    downloadCsv : function(component,event,helper){
        
        var action = component.get("c.getAccountName"); 
        action.setParams({
            recordId :component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) { 
            var state = response.getState(); 
            if (state === "SUCCESS") { 
                console.log("SUCCESS");
                var result = response.getReturnValue();
                console.log("result",result.Name);
                helper.createCSV(component,event,result.Name);
            } 
            else { 
                console.log("FAILED");
            } 
        }); 
        $A.enqueueAction(action); 
        

    },
    updateColumnSorting: function (cmp, event, helper) {
        console.log('updateColumnSorting');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    }
})