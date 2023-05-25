({
    getData: function(component, page) {
        console.log('getData');
        this.showSpinner(component);
        var recordToDisplay = component.get("v.tableSize");
        var objectType = component.get("v.objectType");
        var parentRecordId = component.get("v.recordId");
        var parentField = component.get("v.parentFieldName");
        component.set("v.mySpinner", true);
        var action = component.get("c.fetchData");
        action.setParams({
            recordId :component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Before set result' , JSON.stringify(result));
                //component.set("v.data", result.sourceList);
                component.set("v.totalRows",result.sourceList.length);
                console.log('*** result',result.sourceList);
                //console.log('v.totalRows',result.parcList.length);
                var _errorMSG =result.success;
                
                if (result.sourceList){
                    for(var i = 0; i < result.sourceList.length; i++){
                        //component.set("v.data", result.sourceList);
                        result.sourceList[i].conName= result.sourceList[i].contact.name;
                        result.sourceList[i].cate= result.sourceList[i].demande_type.category;
                        result.sourceList[i].code= result.sourceList[i].service_level.code;
                        result.sourceList[i].description= result.sourceList[i].service_level.description;
                        result.sourceList[i].productCode= result.sourceList[i].asset.libele;
                    }
                    component.set("v.data", result.sourceList);
                }else if (result.sourceList == null) {
                    component.set("v.errorMsg", $A.get("$Label.c.Error_WS_Parc"));
                }else if(_errorMSG == true){
                    component.set("v.errorMsg", $A.get("$Label.c.Error_WS_Parc"));
                }else{
                    component.set("v.errorMsg", $A.get("$Label.c.Error_Message_WS"));
                }
                this.sortData(component,'opened_at','desc');
                this.hideSpinner(component);
            } else if (state === "ERROR") {
                component.set("v.errorMsg", $A.get("$Label.c.Error_Message_WS"));
                this.hideSpinner(component);
                //this.handleResponseError(response.getError());
            }
            component.set("v.mySpinner", false);
        });
        $A.enqueueAction(action);
    },

    showSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function (component) {
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    showToast : function(component, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Related List Message',
            message: message,
            duration:' 3000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },

    handleResponseError: function (component,helper, errors) {
        if (errors) {
            if (errors[0] && errors[0].message) {
                this.showToast(component, 'error', "Error message: " +
                    errors[0].message);
            }
        } else {
            this.showToast(component, 'error', 'Unknown error.');
            return;
        }
        this.hideSpinner(component);
    },
    createCSV: function(component,event,accName){
        
        // get the Records [contact] list from 'ListOfContact' attribute 
        var stockData = component.get("v.data");

        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ':' + today.getMinutes() + ':' + today.getSeconds();
        var dateTime = date+' '+time;
        
        let _header = '';
        _header += 'Number'+';'+'Created Date'+';'+'Category'+';'+'Title'+';'+'Product'+';'+'Status'+';'+'Criticity'+';'+'Service Level'+';'+'Owner'+';';
        
        let _data = '';
        
        stockData.forEach(element => {
            console.log('element',element);
            _data +=
            '\n' +
            element.case_number +
            ';' +
            element.opened_at +
            ';' +
            element.cate +
            ';' +
            element.short_description +
            ';' +
            element.productCode +
            ';' +
            element.state +
            ';' +
            element.priority +
            ';' +
            element.description +
            ';' +
            element.conName +
            ';';
            
            });
                        
        let _csvName =accName+'_Case_'+dateTime+'.csv';
        
        var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(_header + _data);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = _csvName;  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
    },
    sortData: function (cmp, fieldName, sortDirection) {
        var _data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        _data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.data", _data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})