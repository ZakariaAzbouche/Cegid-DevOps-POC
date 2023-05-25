({

    OpenModal: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        //component.set("v.isOpen", true);
    },
   
    CloseModal: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        //component.set("v.isOpen", false);
        $A.get("e.force:closeQuickAction").fire();
    },
           
    doInit:  function(component, event, helper) {        
        var RecordId = component.get("v.recordId");
        var action = component.get("c.getData");     
        component.set("v.mySpinner", true);
        action.setParams({"RecordId" :RecordId});        
        action.setCallback(this, function(response) {    
            var state = response.getState();
            if (state === "SUCCESS") {                
                var Result=response.getReturnValue();        
                if (Result.error == null)
                {
                    component.set("v.ListtoAttach", Result.mapMandatSepas.mandates);
                }
                else
                {                  
                    component.set("v.errorMsg", Result.error);      
                }              
            } else {
                console.log("Failed with state: " + state);
            }
            component.set("v.mySpinner", false);
        });
        $A.enqueueAction(action);              
    },
        
    selectOne: function(component,event, helper){
       var slctCheck = event.getSource().get("v.value");
       var source = event.getSource();
       
       var OneManyRow = component.find('cboxRow');
       var getCheckAllId = (OneManyRow.length == null) ? [OneManyRow] : OneManyRow;       
       if (getCheckAllId !== undefined && getCheckAllId !== null) {            
            if (slctCheck == true) {
                for (var i = 0; i < getCheckAllId.length; i++) {
                    getCheckAllId[i].set("v.value", false);             
                };
                source.set("v.value", true);
            }
        }      
    },    
	
    SaveMandat : function(component, event, helper) {        
        var OneManyRow = component.find('cboxRow');
        var getCheckAllId = (OneManyRow.length == null) ? [OneManyRow] : OneManyRow;
        
        var MondatParam ;
        if (getCheckAllId !== undefined && getCheckAllId !== null &&  getCheckAllId.length >0) {          
            for (var i = 0; i < getCheckAllId.length; i++) {            
               if(getCheckAllId[i].get("v.value") == true )
               {
                    MondatParam =getCheckAllId[i].get("v.text");                       
                    var recordId = component.get("v.recordId"); 
                    var action = component.get("c.SaveMondat");  
                    action.setParams({"RecordId":recordId,"str":MondatParam }); 
                    action.setCallback(this, function(response){   
                        var state =  response.getState();
                        var returnVal = response.getReturnValue();
                        if (returnVal == "SUCCESS") {                 
                            console.log("Successfully Save..");
                            $A.get("e.force:closeQuickAction").fire();
                            $A.get('e.force:refreshView').fire();                           
                        }else {            
                           //console.log(action.getError()[0].message); 
                           //alert(action.getError()[0].message); 
                           console.log('MCU response2 : ',returnVal);
                           alert(returnVal);
                        }          
                    });    
                 	$A.enqueueAction(action);   
                 	break;
            	}                                
        	}               
    	}

    }, 
    
})