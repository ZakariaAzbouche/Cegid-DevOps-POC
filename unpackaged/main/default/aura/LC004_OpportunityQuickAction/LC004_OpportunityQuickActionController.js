({
    doInit : function(component, event, helper) {
        
        helper.getWebservice(component, event);
    },

    buildList:function(component, event, helper) {
        var _finalList = component.get('v.listToWeb');
        //console.log('buildList');
        var _listItems = event.getParam("items");
        var _decision = event.getParam("checkBoxValue");
        var _subscriptionId = event.getParam("subscriptionId");
        var _customerId = event.getParam("customerId");

        var _breakList = _customerId.split('-');
        //console.log('_subscriptionId :' , _subscriptionId);

        if(_decision){
            _finalList.push(_listItems);
            component.set("v.subscriptionId", _subscriptionId);
            component.set("v.customerId", _breakList[0]);
            component.set("v.zuraEntity", _breakList[1]);
            //component.set("v.disableButton", true);
        }else if(!_decision){
            //console.log('Not');
            for( var i = 0; i < _finalList.length; i++){ 
                //console.log('_finalList[i] :', _finalList[i].subscriptionNumber);
                //console.log('_listItems :', _listItems.subscriptionNumber);
                if(_finalList[i].subscriptionNumber == _listItems.subscriptionNumber){
                    //console.log('Splice');
                    _finalList.splice(i,1);
                }
            }
            component.set("v.listToWeb",_finalList);
            component.set("v.subscriptionId", null);
        }
        

        //console.log('_finalList : ' ,JSON.stringify(_finalList) );
        //console.log('_finalList Length : ' ,_finalList.length );
        //console.log('listToWeb : ' ,JSON.stringify(component.get('v.listToWeb')) );
    },

    cancel:function(component, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    save:function(component, event, helper) {
        //console.log('save');
        helper.SaveRecord(component, event);
    }
})