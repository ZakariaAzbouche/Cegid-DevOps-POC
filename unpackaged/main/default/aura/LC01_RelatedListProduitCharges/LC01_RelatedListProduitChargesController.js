({
    doInit: function(component, event, helper) {
        /*
        console.log('PopProduct : ' , component.get("v.data"));
        var _getData = component.get("v.data");
         console.log('PopProduct : ' , _getData);
        
        var _setProduct  = _getData[0].product;
        var _setCustomer  = _getData[0].customer;
        var _setRatePlans  = _getData[0].rateplans;
        var _setRatePlansName  = _getData[0].rateplans.name;
        
       component.set("v.product",_setProduct);
       component.set("v.customer",_setCustomer);
       component.set("v.ratePlans",_setRatePlans);
       component.set("v.chargeName",_setRatePlansName);*/
        
        
    },
    
    closePop : function(component, event, helper) {
        var cmpTarget = component.find('pop');
        $A.util.addClass(cmpTarget, 'slds-hide');
        $A.util.removeClass(cmpTarget, 'slds-show');
        
    },
    
})