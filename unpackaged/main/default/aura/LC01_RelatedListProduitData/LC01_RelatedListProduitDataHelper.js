({
    openPopUp: function (component,helper, row){
        console.log('openPopUp');
        
        var _name = row.name;
        var _startDate= row.startDate;
        var _endDate= row.endDate;  
        var _lastInvoiceDate= row.lastInvoiceDate;
        var _nextInvoiceDate= row.nextInvoiceDate;
        var _mRR= row.monthlyRecurringRevenue;
        var _codeUsade= row.codeUsade;
        var _totalContactValue = row.totalContactValue;
        var _pricingSummary = row.pricingSummary;
        console.log('_name',_name );
        
        console.log('onhandleRowAction');
        $A.createComponent(
            "c:LC01_RelatedListProduitCharges", {
                name:_name,
                startDate:_startDate,
                endDate: _endDate,
                //nextInvoiceDate: _nextInvoiceDate,
                //lastInvoiceDate: _lastInvoiceDate,
                mRR:_mRR,
                codeUsage:_codeUsade,
                valeurTotal:_totalContactValue,
                pricingSummary:_pricingSummary
            },
            function(content, status) {
                if(status === "SUCCESS") {
                    component.find("overlayLib").showCustomModal({
                        body: content,
                        showCloseButton: true,
                        //cssClass: "slds-modal_medium",
                        closeCallback: function() {}
                    });
                    //component.find("overlayLib").notifyClose();
                }
                else {
                    console.log("Error while opening the component ",status);
                    console.log("Error while opening the component ",content);
                }
            }
        );
        
    },
})