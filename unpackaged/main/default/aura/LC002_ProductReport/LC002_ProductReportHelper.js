({
    
    getMeta: function(component, event) {
        var _meta = component.get("c.getObjMetadata");
        _meta.setCallback(this, function(response) {
            var _reponse = response.getReturnValue();
            console.log("**objectsPermissions :", _reponse);
            console.log("**objectsPermissions :", _reponse.Product2.metric__c.label);
            component.set("v.objectMetadata" , _reponse);
            
        });
        
        $A.enqueueAction(_meta);
    },
    
    
    getData : function(component,event) {
        var _productId = component.get("v.getProductId");
        var _recType = component.get("v.getRecordTypeDevName"); 
        
        var action = component.get("c.getProducts");
        action.setParams({
            productId : _productId,
            recType : _recType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var oRes = response.getReturnValue();
            var urlString = window.location.href;
            var baseURL = urlString.substring(0, urlString.indexOf("/s"));
            console.log('oRes : ' , oRes);
            console.log('_recType : ' , _recType);
            
            if(oRes.length > 0){
                if(_recType == 'Article'){
                    for (var i = 0; i < oRes.length; i++) {
                        var row = oRes[i];
                        row.Metric__c = row.SBQQ__OptionalSKU__r.Metric__c;
                        row.Operating_Typology__c = row.SBQQ__ConfiguredSKU__r.Operating_Typology__c;
                        row.Functional__c = row.SBQQ__ConfiguredSKU__r.Functional__c;
                        row.Functional_Level__c = row.SBQQ__ConfiguredSKU__r.Functional_Level__c;
                        row.Brand__c = row.SBQQ__ConfiguredSKU__r.Brand__c;
                        row.Offer__c = row.SBQQ__ConfiguredSKU__r.Offer__c;
                        //row.Product_Line__c = row.SBQQ__ConfiguredSKU__r.Product_Line__c;
                        row.Family = row.SBQQ__ConfiguredSKU__r.Family;
                        row.StructureLevel2__c = row.SBQQ__ConfiguredSKU__r.StructureLevel2__c;
                        row.Buying_Metric__c = row.SBQQ__OptionalSKU__r.Buying_Metric__c;
                        row.Supplier_ID__c = row.SBQQ__OptionalSKU__r.Supplier_ID__c;
                        row.Purchasing_Price__c = row.SBQQ__OptionalSKU__r.Purchasing_Price__c;
                        row.NoRoyalty__c = row.SBQQ__OptionalSKU__r.NoRoyalty__c;
                        row.NameLink = baseURL + "/" + row.SBQQ__ConfiguredSKU__r.Id , '_blank';
                        row.Name = row.SBQQ__ConfiguredSKU__r.Name;
                        row.ref = row.SBQQ__ConfiguredSKU__r.Reference_Number__c;
                        
                    }
                }else{
                    for (var i = 0; i < oRes.length; i++) {
                        var row = oRes[i];
                        row.Metric__c = row.SBQQ__ConfiguredSKU__r.Metric__c;
                        row.Operating_Typology__c = row.SBQQ__ConfiguredSKU__r.Operating_Typology__c;
                        row.Functional__c = row.SBQQ__ConfiguredSKU__r.Functional__c;
                        row.Functional_Level__c = row.SBQQ__ConfiguredSKU__r.Functional_Level__c;
                        row.Brand__c = row.SBQQ__OptionalSKU__r.Brand__c;
                        row.Offer__c = row.SBQQ__ConfiguredSKU__r.Offer__c;
                        //row.Product_Line__c = row.SBQQ__ConfiguredSKU__r.Product_Line__c;
                        row.Family = row.SBQQ__ConfiguredSKU__r.Family;
                        row.StructureLevel2__c = row.SBQQ__ConfiguredSKU__r.StructureLevel2__c;
                        row.Buying_Metric__c = row.SBQQ__OptionalSKU__r.Buying_Metric__c;
                        row.Supplier_ID__c = row.SBQQ__OptionalSKU__r.Supplier_ID__c;
                        row.Purchasing_Price__c = row.SBQQ__OptionalSKU__r.Purchasing_Price__c;
                        row.NoRoyalty__c = row.SBQQ__OptionalSKU__r.NoRoyalty__c;
                        row.NameLink = baseURL + "/" + row.SBQQ__OptionalSKU__r.Id;
                        row.Name = row.SBQQ__OptionalSKU__r.Name;
                        row.ref = row.SBQQ__OptionalSKU__r.Reference_Number__c;
                        
                    }
                }
                
                
                
                
                component.set("v.data",oRes);
                this.setTableColumns(component, _recType);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "message": "No record found !",
                    "type":"Error"
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action); 
    },
    
    setTableColumns: function(component, _recType) {
        var _meta = component.get("v.objectMetadata");
        console.log('_meta : ' , _meta);
        
        if(_recType == 'Article'){
            component.set("v.columns", [
                { label: "Name", initialWidth: 200,fieldName: "NameLink", type: "url", typeAttributes: { label: { fieldName: "Name" }, target: '_blank'  }},
                { label: "Id", initialWidth: 125,fieldName: "ref", type: "text" },
                { label: "Metric", initialWidth: 125,fieldName: "Metric__c", type: "text" },
                { label: "Operating Typology",initialWidth: 125, fieldName: "Operating_Typology__c", type: "text" },
                { label: "Functional", initialWidth: 125,fieldName: "Functional__c", type: "text" },
                { label: "Functional Level",initialWidth: 125, fieldName: "Functional_Level__c", type: "text" },
                { label: "Brand",initialWidth: 125, fieldName: "Brand__c", type: "text" },
                { label: "Offer",initialWidth: 150, fieldName: "Offer__c", type: "text" },
                //{ label: "Product Line",initialWidth: 125, fieldName: "Product_Line__c", type: "text" },
                { label: "Structure Level 1", fieldName: "Family", type: "text" },
                { label: "Structure Level 2",initialWidth: 150, fieldName: "StructureLevel2__c", type: "text" }
            ]);
            
        }else if(_recType == 'Package'){
            component.set("v.columns", [
                { label: "Name", initialWidth: 500,fieldName: "NameLink", type: "url", typeAttributes: { label: { fieldName: "Name" }, target: '_blank'  }},
                { label: "Id",initialWidth: 100, fieldName: "ref", type: "text" },
                { label: "No Royalty", initialWidth: 100, fieldName: "NoRoyalty__c", type: "boolean" },
                { label: "Brand", fieldName: "Brand__c", type: "text" },
                { label: "Buying Metric", fieldName: "Buying_Metric__c", type: "text" },
                { label: "Supplier Id", initialWidth: 150,fieldName: "Supplier_ID__c", type: "text" },
                { label: "Purchasing Price", initialWidth: 200,fieldName: "Purchasing_Price__c", type: "currency" },
            ]);
                }
                }
                })