({    
    doInit: function(component, event, helper) {
        helper.getData(component, helper);
    },
   // open LC01_RelatedListAccSituationDetails 
    openPopUp: function (component,helper, event) {
        var _recId = component.get("v.recordId")
        
        $A.createComponent(
                "c:LC01_RelatedListAccSituationDetails", {
                    recordId : _recId
                },
                function(content, status) {
                    if(status === "SUCCESS") {
                        component.find("overlayLib").showCustomModal({
                            body: content,
                            showCloseButton: true,
                            cssClass: "slds-modal_large",
                            closeCallback: function() {}
                        });
                    }
                    else {
                        console.log("Error while opening the component");
                    }
                }
            )
    },

    showInfo : function(component,helper,event){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Related List Message' ,
                message: $A.get("$Label.c.Error_WS_Aston"),
                duration:' 3000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire();
    }
})