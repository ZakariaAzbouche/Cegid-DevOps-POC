/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * @last created on  : 19/05/2022
**/

import { LightningElement,track,wire,api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customerRequestsFormStyle from '@salesforce/resourceUrl/customerRequestsFormStyle';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getInvoiceLinesByCustomerRequestId from '@salesforce/apex/CustomerRequestsFormController.getInvoiceLinesByCustomerRequestId';
import updateInvoiceLines from '@salesforce/apex/CustomerRequestsFormController.updateInvoiceLines';
import deleteInvoiceLine from '@salesforce/apex/CustomerRequestsFormController.deleteInvoiceLine';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Labels */
import CUSTOMERREQUESTFORMERROR from '@salesforce/label/c.CustomerRequestFormError';
import CUSTOMERREQUESTLINESUPDATE from '@salesforce/label/c.CustomerRequestLinesUpdate';
import CUSTOMERREQUESTLINESDELETE from '@salesforce/label/c.CustomerRequestLinesDelete';
import CUSTOMERREQUESTLINESAMOUNTWARNING from '@salesforce/label/c.CustomerRequestLinesAmountWarning';
import CUSTOMERREQUESTLINESDELETESUCCESS from '@salesforce/label/c.CustomerRequestLinesDeleteSuccess';
import CUSTOMERREQUESTFORMCOLUMNINVOICENUM from '@salesforce/label/c.CustomerRequestFormColumnInvoiceNum';
import CUSTOMERREQUESTFORMCOLUMNPRODUCT from '@salesforce/label/c.CustomerRequestFormColumnProduct';
import CUSTOMERREQUESTFORMCOLUMNAMOUNT from '@salesforce/label/c.CustomerRequestFormColumnAmount';
import CUSTOMERREQUESTFORMCOLUMNCNAMOUNT from '@salesforce/label/c.CustomerRequestFormColumnCNAmount';
import CUSTOMERREQUESTFORMCOLUMNDISCOUNT from '@salesforce/label/c.CustomerRequestFormColumnDiscount';


export default class CustomerRequestInvoiceLines extends LightningElement {

    connectedCallback() {
        loadStyle(this, customerRequestsFormStyle); 
    }

    CustomerRequestFormError = CUSTOMERREQUESTFORMERROR;
    CustomerRequestLinesUpdate = CUSTOMERREQUESTLINESUPDATE;
    CustomerRequestLinesDelete = CUSTOMERREQUESTLINESDELETE;
    CustomerRequestLinesAmountWarning = CUSTOMERREQUESTLINESAMOUNTWARNING;
    CustomerRequestLinesDeleteSuccess = CUSTOMERREQUESTLINESDELETESUCCESS;
    CustomerRequestFormColumnInvoiceNum = CUSTOMERREQUESTFORMCOLUMNINVOICENUM;
    CustomerRequestFormColumnProduct = CUSTOMERREQUESTFORMCOLUMNPRODUCT;
    CustomerRequestFormColumnAmount = CUSTOMERREQUESTFORMCOLUMNAMOUNT;
    CustomerRequestFormColumnCNAmount = CUSTOMERREQUESTFORMCOLUMNCNAMOUNT;
    CustomerRequestFormColumnDiscount = CUSTOMERREQUESTFORMCOLUMNDISCOUNT;

    @api recordId;

    @track  columns = [
        { label: this.CustomerRequestFormColumnInvoiceNum, fieldName: 'InvoiceUrl' ,type: 'url',typeAttributes: {label: { fieldName: 'InvoiceName' },target: '_blank'},editable: false},
        { label: this.CustomerRequestFormColumnProduct, fieldName: 'LoadName' ,type: 'text',editable: false, initialWidth: 380},
        { label: this.CustomerRequestFormColumnAmount, fieldName: 'Amount' ,type: 'currency',editable: false,cellAttributes: { alignment: 'left' }},
        { label: this.CustomerRequestFormColumnCNAmount, fieldName: 'CreditNoteAmount' ,type: 'currency',editable: true,cellAttributes: { alignment: 'left' }, initialWidth: 180},
        { label: this.CustomerRequestFormColumnDiscount, fieldName: 'Discount' ,type: 'text',editable: false},
        {
            type: 'button-icon',
            typeAttributes:
            {
                iconName: 'utility:delete',
                name: 'Delete',
                value: 'delete',  
                iconClass: 'slds-icon-text-error'
            }
        }
    ];

    @track invoiceLinesData;
    @track invoiceLinesDataLength ;
    @track deletedInvoiceLinesId;
    @track isModalOpen = false;
    @track showLoadingSpinner = false;
    draftValues
    _datatableresp
    mapinvoiceLinesAmount
    @wire(getInvoiceLinesByCustomerRequestId, { customerRequestId: '$recordId' })
    wiredAccount(result) {
        this.showLoadingSpinner = true;
        this._datatableresp = result
        if (result.data) {
            this.invoiceLinesData = result.data;
            this.invoiceLinesDataLength = result.data.length;
            var tempMapinvoiceLinesAmount = new Map();
            var i = 1;
            this.invoiceLinesData.forEach(function (record){
                tempMapinvoiceLinesAmount.set(record.InvoiceLineId, {Amount:record.Amount,index:i});
                i++;
            })
            this.mapinvoiceLinesAmount = tempMapinvoiceLinesAmount;
            this.showLoadingSpinner = false;
        } else {
            console.log(result.error);
            this.showLoadingSpinner = false;
        }
    }

    handleSave(event){
        var i = 0; 
        this.showLoadingSpinner = true;
        this.draftValues = event.detail.draftValues;
        var amountWarningTxt = this.CustomerRequestLinesAmountWarning;
        var tempmapinvoiceLinesAmount = this.mapinvoiceLinesAmount;
        this.draftValues.forEach(function (record){
            if(record.CreditNoteAmount > tempmapinvoiceLinesAmount.get(record.InvoiceLineId).Amount){
                i++;
                amountWarningTxt = amountWarningTxt + '\n ' + 'Ligne N°' + tempmapinvoiceLinesAmount.get(record.InvoiceLineId).index;
            }
        })
        if(i > 0){
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    message: amountWarningTxt,
                    variant: 'warning'
                })

            );
        } else{
            updateInvoiceLines({invoiceLineListStr: JSON.stringify(this.draftValues)})
            .then( result => {
               if(result === 'Success'){
                this.showLoadingSpinner = false;
                   this.dispatchEvent(
                       new ShowToastEvent({
                           message: this.CustomerRequestLinesUpdate,
                           variant: 'success'
                       })
   
                   );
                   this.draftValues = []
                   getRecordNotifyChange([{recordId: this.recordId}]);
                   return refreshApex(this._datatableresp);
               } else {
                    this.showLoadingSpinner = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: this.CustomerRequestFormError + '\n ' + result,
                            variant: 'error'
                        })
                    );
               }
            })
        }
    }

    handleRowAction( event ) {  
        this.isModalOpen = true;
        this.deletedInvoiceLinesId = event.detail.row.InvoiceLineId;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    deleteInvoiceLine() {
        this.isModalOpen = false;
        this.showLoadingSpinner = true;
        const invoiceLineId =  this.deletedInvoiceLinesId;  
        var rows = [];
        for(let i=0; i<this.invoiceLinesData.length; i++){
            if(this.invoiceLinesData[i].InvoiceLineId != invoiceLineId){
                rows.push(this.invoiceLinesData[i]);
            }
        }
        deleteInvoiceLine({invoiceLineId: invoiceLineId})
        .then( result => {
            if(result === 'Success'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: this.CustomerRequestLinesDeleteSuccess,
                        variant: 'success'
                    })

                );
                this.invoiceLinesData = rows;
                this.invoiceLinesDataLength = rows.length;
                this.showLoadingSpinner = false;
            } else {
                this.showLoadingSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: this.CustomerRequestFormError,
                        variant: 'error'
                    })
                );
                this.isModalOpen = false;
            }
        })
    }

}