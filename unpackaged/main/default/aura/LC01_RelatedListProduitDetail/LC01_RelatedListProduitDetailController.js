({
    doInit: function(component, event, helper) {
        /*
        console.log('PopProduct : ' , component.get("v.data"));
        var _getData = component.get("v.data");
         console.log('PopProduct : ' , _getData);
        var _setProduct  = _getData[0].product;
        var _setCustomer  = _getData[0].customer;
        var _setRatePlans  = _getData[0].rateplans;
        var _setPlannedCancellation  = _getData[0]._setPlannedCancellation;
        
       component.set("v.product",_setProduct);
       component.set("v.customer",_setCustomer);
       component.set("v.ratePlans",_setRatePlans);
        component.set("v.plannedCancellation",_setPlannedCancellation);*/
        
        var rateplanList = component.get('v.rateplanList');
        var index = component.get('v.index');
        var rateplanListFilter = rateplanList[index].rateplans;
        var today = new Date();
        var endDate = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0');
        var yyyy = today.getFullYear();
        
        today = yyyy + '-' + mm + '-' + dd;
        //console.log('rateplanListFilter',rateplanListFilter);
        /*
        rateplanListFilter.forEach(function (element) {
                        element.charges.forEach(function(charge){
                            endDate = charge.endDate;
                            console.log('endDate',endDate);
                            if (endDate >= today) {
                                //chargeListFinal.push(element);
                            } 
                        });
                    });*/
        
        //console.log('charges',rateplanList[index].rateplans);
        
        component.set("v.ratePlans",rateplanList[index].rateplans);
    },
    
    closePop : function(component, event, helper) {
        var cmpTarget = component.find('pop');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
        component.set("v.prductDetail" , false);
        
    },
    
    openProductInfo: function(component, event, helper) {
        console.log('openProductInfo 1');
        component.set("v.prductDetail" , true);
        console.log('openProductInfo ');
        //helper.getProductInfo(component, helper,event);
    },
    
})