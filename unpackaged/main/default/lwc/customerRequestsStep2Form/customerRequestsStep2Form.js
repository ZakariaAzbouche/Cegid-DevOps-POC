/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * @last created on  : 09/06/2022
**/

import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customerRequestsFormStyle from '@salesforce/resourceUrl/customerRequestsFormStyle';
import ARROWPAGINATION from '@salesforce/resourceUrl/arrowPagination';
import ARROWDOWN from '@salesforce/resourceUrl/arrowdown';
import getInvoiceLinesData from '@salesforce/apex/CustomerRequestsFormController.getInvoiceLinesData';

/* Labels */
import CUSTOMERREQUESTFORMNODATA from '@salesforce/label/c.CustomerRequestFormNoData';
import CUSTOMERREQUESTFORMNODMOREDATA from '@salesforce/label/c.CustomerRequestFormNoMoreData';
import CUSTOMERREQUESTFORMCOLUMNINVOICELINENUM from '@salesforce/label/c.CustomerRequestFormColumnInvoiceLineNum';
import CUSTOMERREQUESTFORMCOLUMNPRODUCT from '@salesforce/label/c.CustomerRequestFormColumnProduct';
import CUSTOMERREQUESTFORMCOLUMNAMOUNT from '@salesforce/label/c.CustomerRequestFormColumnAmount';
import CUSTOMERREQUESTFORMCOLUMNDATE from '@salesforce/label/c.CustomerRequestFormColumnDate';
import CUSTOMERREQUESTFORMCOLUMNTHIRDPARTY from '@salesforce/label/c.CustomerRequestFormColumnThirdParty';
import CUSTOMERREQUESTFORMCOLUMNCALCULATEDBU from '@salesforce/label/c.CustomerRequestFormColumnCalculatedBU';
import getBUIdByExternalId from '@salesforce/apex/CustomerRequestsFormController.getBUIdByExternalId';


export default class CustomerRequestsStep2Form extends LightningElement {
    connectedCallback() {
        loadStyle(this, customerRequestsFormStyle);   
        this.getResults(false);
    }

    CustomerRequestFormNoData = CUSTOMERREQUESTFORMNODATA;
    CustomerRequestFormNoMoreData = CUSTOMERREQUESTFORMNODMOREDATA;
    CustomerRequestFormColumnInvoiceLineNum = CUSTOMERREQUESTFORMCOLUMNINVOICELINENUM;
    CustomerRequestFormColumnProduct = CUSTOMERREQUESTFORMCOLUMNPRODUCT;
    CustomerRequestFormColumnAmount = CUSTOMERREQUESTFORMCOLUMNAMOUNT;
    CustomerRequestFormColumnDate = CUSTOMERREQUESTFORMCOLUMNDATE;
    CustomerRequestFormColumnThirdParty = CUSTOMERREQUESTFORMCOLUMNTHIRDPARTY;
    CustomerRequestFormColumnCalculatedBU = CUSTOMERREQUESTFORMCOLUMNCALCULATEDBU;

    arrowPagination = ARROWPAGINATION;
    arrowdown = ARROWDOWN;
    @track warningText = '';
    @track showWarningToast = false;
    @track showLoadingSpinner = false;
    @track invoiceLines = [];
    @track mapinvoiceLines = new Map();
    @track invoiceNameSet = new Set();
    @track oldJson = [];
    @track selectedItemsNames = [];
    @track offset = 0;

    @api erpNumber;
    @api domain;
    @api origin;
    @api businessUnitExternalId;
    @api currencyIsoCode;
    @api contractNumber;
    @api invoiceNumber;
    @api minAmount;
    @api maxAmount;
    @api minDate;
    @api maxDate;

    handleParentCheckboxChange(event){
        const parent = this.template.querySelector('[data-checkboxname="' +event.currentTarget.dataset.checkboxname+ '"]');
        const items = this.template.querySelectorAll('[data-checkboxparentname="' +event.currentTarget.dataset.checkboxname+ '"]');
        parent.classList.remove('childchecked');
        if(parent.checked == true){
            items.forEach(function (item){
                item.checked = true;
            }) 
        } else{
            items.forEach(function (item){
                item.checked = false;
            }) 
        }
    }

    handleChildCheckboxChange(event){
        const child = this.template.querySelector('[data-checkboxname="' +event.currentTarget.dataset.checkboxname+ '"]');
        const parent = this.template.querySelector('[data-checkboxname="' +event.currentTarget.dataset.checkboxparentname+ '"]');
        const items = this.template.querySelectorAll('[data-checkboxparentname="' +event.currentTarget.dataset.checkboxparentname+ '"]');
        var i = 0;
        items.forEach(function(item){
            if(item.checked == true){
                i++;
            }
        }) 
        if(child.checked == true){ 
            if(parent.getAttribute('data-totallines') == i){
                parent.classList.remove('childchecked');
                parent.checked = true; 
            } else{
                parent.classList.add('childchecked');
            }
        } else{
            parent.checked = false; 
            if(i > 0){
                parent.classList.add('childchecked'); 
            } else{
                parent.classList.remove('childchecked');
            }
        }
    }

    handleToggle(event){
        const parent = this.template.querySelector('[data-togglename="' +event.currentTarget.dataset.togglename+ '"]');
        const items = this.template.querySelectorAll('[data-parent="' +event.currentTarget.dataset.togglename+ '"]');
        if(event.currentTarget.dataset.collapse == 'true'){
            parent.setAttribute('data-collapse', 'false');
            parent.style.transform = 'rotate(180deg)';
            items.forEach(function (item){
                item.style.display = 'table-row';
            })  
        } else{
            parent.setAttribute('data-collapse', 'true');
            parent.style.transform = 'rotate(0deg)';
            items.forEach(function (item){
                item.style.display = 'none';
            }) 
        }
    }


    getSelectedIputs(){
        var items = this.template.querySelectorAll('.linecheckbox'); 
        var tempSelectedItemsNames = []; 
        for (var i = 0; i < items.length; i++) {
            if(items[i].checked == true){
                tempSelectedItemsNames.push(items[i].getAttribute('data-checkboxname'));
            }   
        }
        this.selectedItemsNames = tempSelectedItemsNames
        items = this.template.querySelectorAll('.parentcheckbox'); 
        tempSelectedItemsNames = []; 
        for (var i = 0; i < items.length; i++) {
            if(items[i].checked == true || items[i].classList.contains('childchecked')){
                var parentdata = items[i].getAttribute('data-checkboxname') + "##" + items[i].getAttribute('data-totallines');
                if(items[i].classList.contains('childchecked')){
                    parentdata += '&&childchecked';
                } else{
                    parentdata += '&&none';
                }
                tempSelectedItemsNames.push(parentdata);
            }   
        }
        this.selectedParents = tempSelectedItemsNames;
    }

    setSelectedIputs(){
        var items = this.template.querySelectorAll('.linecheckbox'); 
        for (var i = 0; i < items.length; i++) {  
            this.selectedItemsNames.forEach(function(selectedItem){
                if(items[i].getAttribute('data-checkboxname') == selectedItem){
                    items[i].checked = true;
                } 
            })
        }

        items = this.template.querySelectorAll('.parentcheckbox'); 
        for (var i = 0; i < items.length; i++) {  
            this.selectedParents.forEach(function(selectedItem){
                if(String(items[i].getAttribute('data-checkboxname')) == String(selectedItem.split('##')[0]) && String(items[i].getAttribute('data-totallines')) == String(selectedItem.split('##').pop().split('&&')[0]) && String(selectedItem.split('&&')[1]) != 'childchecked'){
                    items[i].checked = true;
                    items[i].classList.remove('childchecked');
                } else if(items[i].getAttribute('data-checkboxname') == selectedItem.split('##')[0] || (items[i].getAttribute('data-checkboxname') == selectedItem.split('##')[0] && selectedItem.split('&&')[1] == 'childchecked')){
                    items[i].checked = false;
                    items[i].classList.add('childchecked');
                }
            })
        }
    }


    parseJsonResult(result, isPagination){
        var tempjson = JSON.parse(JSON.stringify(result).split('items').join('_children')); 
        if(tempjson[0].name == "ERROR"){
            this.showLoadingSpinner = false;
            this.showWarningToast = true;
            this.warningText = this.CustomerRequestFormWSError;
            setTimeout(() => {
                this.showWarningToast = false; this.warningText = '';
            }, 2500 );
        } else{
            var i = 0;
            var oldJson = this.oldJson;
            var tempinvoiceLines = this.invoiceLines; 
            var tempinvoiceNameSet = new Set(); 
            var tempMapinvoiceLines = this.mapinvoiceLines;
            tempjson.forEach(function(record){
                oldJson.push(record);
            })
            oldJson.sort((a, b) => a.lineNumber.toLowerCase().localeCompare(b.lineNumber.toLowerCase()));
            oldJson.forEach(function(record){
                if(record.amount == null && tempinvoiceNameSet.has(record.name) == false){
                    tempinvoiceLines.push({"totalLines" : record.totalLines, "name" : record.name, "totalAmount" : record.totalAmount, "lineNumber" : record.lineNumber});
                    tempinvoiceNameSet.add(record.name);
                } else if(record.amount == null){
                    for(i=0; i < tempinvoiceLines.length; i++){
                        if(tempinvoiceLines[i].name == record.name){
                            tempinvoiceLines[i].totalLines = String(parseFloat(tempinvoiceLines[i].totalLines) + parseFloat(record.totalLines));
                            tempinvoiceLines[i].totalAmount = String(parseFloat(tempinvoiceLines[i].totalAmount) + parseFloat(record.totalAmount));
                        }
                    }

                }
                record._children.forEach(function(item){
                    tempMapinvoiceLines.set(item.lineName, item);
                    tempinvoiceLines.push(item);
                })
            })

            this.mapinvoiceLines = tempMapinvoiceLines;
            this.invoiceLines = tempinvoiceLines; 
            this.invoiceNameSet = tempinvoiceNameSet;
            this.showLoadingSpinner = false;
    
            if(isPagination){
                setTimeout(() => {
                    this.setSelectedIputs();
                }, 500 );
            }
        }
    }

    getResults(isPagination){
        var tempinvoiceLines = this.invoiceLines;
        this.invoiceLines = [];
        this.showLoadingSpinner = true;
        if(isPagination != true){
            this.offset = 0;
            this.selectedItemsNames = [];
            this.mapinvoiceLines = new Map();
        }
        getInvoiceLinesData({erpNumber: this.erpNumber, domain: this.domain, origin: this.origin, businessUnitExternalId: this.businessUnitExternalId, currencyIsoCode: this.currencyIsoCode, contractNumber: this.contractNumber, invoiceNumber: this.invoiceNumber, minAmount: this.minAmount, maxAmount: this.maxAmount, minDate: this.minDate?this.minDate.replaceAll("-", ""):'', maxDate: this.maxDate?this.maxDate.replaceAll("-", ""):'', offset: this.offset})
            .then(result =>{
                if(result.length > 0){
                    this.warningText = '';
                    this.parseJsonResult(result, isPagination);
                    this.template.querySelector('[data-id="nextimg"]').style.display = "block";
                } else{
                    this.showLoadingSpinner = false;
                    this.showWarningToast = true;
                    if(isPagination != true){
                        this.warningText = this.CustomerRequestFormNoData;
                        setTimeout(() => {
                            this.showWarningToast = false; this.warningText = '';
                        }, 2500 );
                        this.offset = 0;
                    } else{
                        this.showWarningToast = true;
                        this.warningText = this.CustomerRequestFormNoMoreData;
                        setTimeout(() => {
                            this.showWarningToast = false; this.warningText = '';
                        }, 2500 );
                        this.invoiceLines = tempinvoiceLines;
                        setTimeout(() => {
                            this.setSelectedIputs();
                        }, 500 );
                    }
                    this.template.querySelector('[data-id="nextimg"]').style.display = "none";
                }                   
            })
            .catch(error =>{
                console.log(error);
            })
    }

    getCheckedLines() {
        this.showLoadingSpinner = true;
        var tempInvoiceLinesNames = [];
        var items = this.template.querySelectorAll('.linecheckbox');   
        for (var i = 0; i < items.length; i++) {
            if(items[i].checked == true){
                tempInvoiceLinesNames.push(items[i].getAttribute('data-checkboxname'));
            }   
        }
        var linesToSave = [];
        var currentItem;
        var tempMapinvoiceLines = this.mapinvoiceLines;
        var tempMapBU = new Map();
        tempInvoiceLinesNames.forEach(function (item){
            currentItem = tempMapinvoiceLines.get(item);
            linesToSave.push(currentItem);
            if(tempMapBU.get(currentItem.buOffer)){
                tempMapBU.set(currentItem.buOffer, parseFloat(tempMapBU.get(currentItem.buOffer)) + parseFloat(currentItem.amount));
            } else{
                tempMapBU.set(currentItem.buOffer, parseFloat(currentItem.amount));
            }
        })
        


        tempMapBU = new Map([...tempMapBU.entries()].sort((a, b) => b[1] - a[1]));
        let mapKeys =[ ...tempMapBU.keys() ];

        var businessUnit1 = '';
        var businessUnit2 = '';
        var businessUnit3 = '';
        var businessUnit4 = '';
        var businessUnit5 = '';
        var buOfferMultiple = false;

        getBUIdByExternalId({ ExternalIds: mapKeys })
        .then((result) => { 
            let mapResult = Object.values(result);
            let buArray = ['','','','','']
            mapResult.forEach(function(externalBU){
                let i=0;
                tempMapBU.forEach((key, value) => {
                    if(value == externalBU.API_Code__c){
                        buArray[i] = externalBU.Id;
                    }
                    i += 1;
                });
            });
            
            if(buArray[0] != ''){
                businessUnit1 = buArray[0];
            }         
            if(buArray[1] != ''){
                businessUnit2 =  buArray[1];
                buOfferMultiple = true;
            } 
            if(buArray[2] != ''){
                businessUnit3 = buArray[2];
            } 
            if(buArray[3] != ''){
                businessUnit4 = buArray[3];
            } 
            if(buArray[4] != ''){
                businessUnit5 = buArray[4];
            } 

            const getCheckedLinesStep2Event = new CustomEvent("getcheckedlinesstep2", {
                detail: {
                    linestosave: linesToSave,
                    buoffermultiple: buOfferMultiple, 
                    businessunit1: businessUnit1,
                    businessunit2: businessUnit2,
                    businessunit3: businessUnit3,
                    businessunit4: businessUnit4,
                    businessunit5: businessUnit5
                } 
            });
            this.dispatchEvent(getCheckedLinesStep2Event);
            this.showLoadingSpinner = false;
        })
        .catch((error) => {
            console.log(error);
            this.showLoadingSpinner = false;
            this.showErrorToast = true;
            setTimeout(() => {
                this.showErrorToast = false;
            }, 3000 );
        });

    }

    cancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    next(){
        this.getSelectedIputs();
        this.offset += 25;
        this.getResults(true);
    }
}