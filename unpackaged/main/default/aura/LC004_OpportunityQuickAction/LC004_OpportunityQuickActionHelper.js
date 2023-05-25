({
    getWebservice : function(component,event) {
        //Call method from apex class
        var action = component.get("c.getWebservice");
        action.setParams({
            EntityName : '002',
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var _state = response.getState();
            var _response = response.getReturnValue();
            console.log('_response : ' , _response);
            if (_response.Statuscode == "200" &&  !$A.util.isEmpty(_response.webResponse)){
                component.set("v.ReponseFromWebService", _response.webResponse);
                console.log('Check Response ==> ', component.get("v.ReponseFromWebService"));
                $A.util.addClass(component.find("mySpinner"), "slds-hide");
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                var SuccessMsg = $A.get("$Label.c.SucessMsg");
                var _resMsg;
                if(!$A.util.isEmpty(_response.message)){
                    _resMsg = $A.get("$Label.c.LC004_OpportunityQuickAction_ErrorMessage") + ' [' +_response.message+ ']';
                }else{
                    _resMsg = 'Aucun retour n\'a été fait pour cette opportunité';
                    _response.Statuscode = '500';
                }
                toastEvent.setParams({
                /*"title": _response.Statuscode,*/
                "message": (_response.Statuscode == '200')?SuccessMsg:_resMsg,
                "type":(_response.Statuscode == '200')?"success":"error"
                });
                toastEvent.fire();
                $A.util.addClass(component.find("mySpinner"), "slds-hide");
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);  

    },

    // getSortMethod:function(arguments){
    //     var _args = Array.prototype.slice.call(arguments);
    //     return function(a, b){
    //         for(var x in _args){
    //             var ax = a[_args[x].substring(1)];
    //             var bx = b[_args[x].substring(1)];
    //             var cx;
    
    //             ax = typeof ax == "string" ? ax.toLowerCase() : ax / 1;
    //             bx = typeof bx == "string" ? bx.toLowerCase() : bx / 1;
    
    //             if(_args[x].substring(0,1) == "-"){cx = ax; ax = bx; bx = cx;}
    //             if(ax != bx){return ax < bx ? -1 : 1;}
    //         }
    //     }
    // },

    SaveRecord : function(component,event) {
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        //Call method from apex class
        var action = component.get("c.saveWebservice");
        action.setParams({
            EntityName :  component.get("v.zuraEntity"),
            subscriptionId :component.get("v.subscriptionId"),
            customerId :component.get("v.customerId"),
            recordId : component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var _response = response.getReturnValue();
            console.log('_response : ' , _response);
            
                $A.util.addClass(component.find("mySpinner"), "slds-hide");
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                console.log('window.location.origin' , window.location.origin);

            if(_response.Statuscode == '200' && _response.getContractId.contractId != null){
                console.log('Test');
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url":  window.location.origin+'/'+_response.getContractId.contractId
                });
                urlEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                var SuccessMsg = $A.get("$Label.c.SucessMsg");
                var _resMsg;
                if(!$A.util.isEmpty(_response.message)){
                    _resMsg = $A.get("$Label.c.LC004_OpportunityQuickAction_ErrorMessage") + ' [' +_response.message+ ']';
                }else{
                    _resMsg = 'Aucun retour n\'a été fait pour cette opportunité';
                    _response.Statuscode = '500';
                }
                toastEvent.setParams({
                    /*"title": _response.Statuscode,*/
                    "message": (_response.Statuscode == '200' && _response.getContractId.contractId != null)?SuccessMsg:_resMsg,
                    "type":(_response.Statuscode == '200' && _response.getContractId.contractId != null)?"success":"error"
                });
                toastEvent.fire();
                
            }
            
        });
        $A.enqueueAction(action);  

    },

})