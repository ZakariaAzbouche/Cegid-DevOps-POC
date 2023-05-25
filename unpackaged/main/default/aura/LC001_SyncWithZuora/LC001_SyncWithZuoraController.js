({
	doInit : function(component, event, helper) {
        var recTempId = component.get("v.recordId");
		console.log('##### INIT  '+recTempId);
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
           "type": "success",
            "title": "Success!",
            "message": "Synchronized with love <3 by Mulesoft!"
         });
         toastEvent.fire();
        
        var action = component.get("c.makeCallout");
        action.setParams({recordId : recTempId}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //alert("From server: " + response.getReturnValue());
                if (response.getReturnValue() != ''){
                    console.log('## Success');
                } else {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "error",
                        "title": "error!",
                        "message": "Something went wrong :("
                    });
                    toastEvent.fire();
                }
                
            }
            else if (state === "INCOMPLETE") {
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
   	},
    
    hideSpinner : function(component,event,helper){
       component.set("v.Spinner", false);
    }
})