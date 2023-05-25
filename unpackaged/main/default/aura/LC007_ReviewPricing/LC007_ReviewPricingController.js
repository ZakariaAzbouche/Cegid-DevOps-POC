({
    handleOnLoad : function(component, event, helper) {
        console.log('MCU AURA recordId :' + component.get("v.recordId"))
        $A.util.addClass(component.find("mySpinner"), "slds-hide");
    },
    
    handleOnSubmit : function(component, event, helper) {
        
        var targetedPriceForGlobal = component.find("TargetedPriceForGlobal").get("v.value");
        var targetedPriceForSaas = component.find("TargetedPriceForSaas").get("v.value");
        var targetedPriceForProfessionalServices = component.find("TargetedPriceForProfessionalServices").get("v.value");
        var targetedPriceForLicense = component.find("TargetedPriceForLicense").get("v.value");
        var targetedPriceForMaintenance = component.find("TargetedPriceForMaintenance").get("v.value");
        var targetedPriceForHardware = component.find("TargetedPriceForHardware").get("v.value");
        
        console.log('MCU targetedPriceForGlobal :' + targetedPriceForGlobal);
		console.log('MCU targetedPriceForSaas :' + targetedPriceForSaas);
        console.log('MCU targetedPriceForProfessionalServices :' + targetedPriceForProfessionalServices);
        console.log('MCU targetedPriceForLicense :' + targetedPriceForLicense);
        console.log('MCU targetedPriceForMaintenance :' + targetedPriceForMaintenance);
        console.log('MCU targetedPriceForHardware :' + targetedPriceForHardware);
        
        if(targetedPriceForGlobal && (targetedPriceForSaas||
                                              targetedPriceForProfessionalServices||
                                              targetedPriceForLicense ||
                                              targetedPriceForMaintenance||
                                              targetedPriceForHardware)){
			var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "message": "Vous n'avez pas le droit de remplir le champ Global et un autre champ",
                "type":"error"
            });
            resultsToast.fire();
        	event.preventDefault();
    	}else{
            $A.util.removeClass(component.find("mySpinner"), "slds-hide");
		}
        
    },
    
    handleOnSuccess : function(component, event, helper) {
        window.open('/' + component.get("v.recordId"),"_self");  
        /*component.find("navService").navigate({
            "type": "standard__recordPage",
            "attributes": {
                "recordId": "a0q9E00000Y15sjQAB",
                "objectApiName": "SBQQ__Quote__c",
                "actionName": "view"
            }
        });*/

        console.log('MCU - handleOnSuccess - 4');
    },
    
    handleOnError : function(component, event, helper) {
        event.preventDefault();
        $A.util.addClass(component.find("mySpinner"), "slds-hide");
        var error = event.getParams();
        var errorMessage = event.getParam("detail");
        var _message = (errorMessage.includes("Targeted"))?true:false;
        
        /*if(_message){
            //event.preventDefault();
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "message": "Targeted Price too low, please review your objective !",
                "type":"error"
            });
            resultsToast.fire();
        }*/
        if(errorMessage){
            errorMessage = errorMessage.split('System.CalloutException:')[1];
            console.log('MCU errorMessage1 : ' + errorMessage);
            errorMessage = errorMessage.split('Class.')[0];
            console.log('MCU errorMessage2 : ' + errorMessage);
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Error",
                "message": errorMessage,
                "type":"error"
            });
            resultsToast.fire();

        }
    },
})