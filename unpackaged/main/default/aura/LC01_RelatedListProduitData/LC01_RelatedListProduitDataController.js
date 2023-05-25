({
    doInit: function(component, event, helper) {
        
        component.set('v.columns', [
            { initialWidth: 350, type: "button",label:'Nom charge ', typeAttributes: { variant:'base' ,label: { fieldName: 'name' },name:'BtnNumero' }},
            {label: 'Type', fieldName: 'type', type: 'text', sortable: 'true'},
            {label: 'Model', fieldName: 'model', type: 'text', sortable: 'true'},
            {label: 'UOM', fieldName: 'uom', type: 'text', sortable: 'true'},
            {label: 'Prix Unitaire', fieldName: 'unitPrice', type: 'currency', sortable: 'true'},
            {label: 'Qte', fieldName: 'quantity', type: 'number', sortable: 'true'},
            {label: 'Total', fieldName: 'total', type: 'currency', sortable: 'true'},
            {label: 'Facturation', fieldName: 'billingPeriod', type: 'text', sortable: 'true'}

        ]); 
        var chargeList = component.get('v.chargeList');
        
        var index = component.get('v.index');
        var chargeListFin =chargeList[index].rateplans.charges;
		var chargeListFinal = [];
        var today = new Date();
        var endDate = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy + '-' + mm + '-' + dd;
        
        chargeListFin.forEach(function (element) {
            //console.log('Element',JSON.stringify(element));
            endDate = element.endDate;
            //console.log('endDate',endDate);
            //console.log('today',today);
            if (endDate >= today) {
                chargeListFinal.push(element);
                    } 
        });
        
        //console.log('chargeListFin',chargeListFin);
        //console.log('chargeListFinal',chargeListFinal);
        //console.log('chargeListFin.size',chargeListFinal.length);
        //console.log('charges',chargeList[index].rateplans.charges);
        //console.log('rateplans',chargeList[index].rateplans);
        //component.set("v.data",chargeList[index]);
        component.set("v.data",chargeListFinal);
        
        if(chargeListFinal.length >0){
            component.set("v.containCharges",true);
        }
        //component.set("v.data",chargeList[index].rateplans.charges);
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
                
            case 'BtnNumero':
                helper.openPopUp(component, event, row);
                break;
        }
    },
    
})