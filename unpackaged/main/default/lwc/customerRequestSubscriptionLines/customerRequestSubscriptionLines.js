/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * @last created on  : 24/05/2022
**/

import { LightningElement,track,wire,api} from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import customerRequestsFormStyle from '@salesforce/resourceUrl/customerRequestsFormStyle';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import getSubscriptionLinesByCustomerRequestId from '@salesforce/apex/CustomerRequestsFormController.getSubscriptionLinesByCustomerRequestId';
import updateSubscriptionLines from '@salesforce/apex/CustomerRequestsFormController.updateSubscriptionLines';
import deleteSubscriptionLine from '@salesforce/apex/CustomerRequestsFormController.deleteSubscriptionLine';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Labels */
import CUSTOMERREQUESTFORMERROR from '@salesforce/label/c.CustomerRequestFormError';
import CUSTOMERREQUESTLINESUPDATE from '@salesforce/label/c.CustomerRequestLinesUpdate';
import CUSTOMERREQUESTLINESDELETE from '@salesforce/label/c.CustomerRequestLinesDelete';
import CUSTOMERREQUESTLINESQUANTITYWARNING from '@salesforce/label/c.CustomerRequestLinesQuantityWarning';
import CUSTOMERREQUESTLINESDELETESUCCESS from '@salesforce/label/c.CustomerRequestLinesDeleteSuccess';
import CUSTOMERREQUESTFORMCOLUMNSUBSCRIPTIONNUM from '@salesforce/label/c.CustomerRequestFormColumnSubscriptionNum';
import CUSTOMERREQUESTFORMCOLUMNLOADNAME from '@salesforce/label/c.CustomerRequestFormColumnLoadName';
import CUSTOMERREQUESTFORMCOLUMNUNITPRICE from '@salesforce/label/c.CustomerRequestFormColumnUnitPrice';
import CUSTOMERREQUESTFORMCOLUMNQUANTITY from '@salesforce/label/c.CustomerRequestFormColumnQuantity';
import CUSTOMERREQUESTFORMCOLUMNTOTALAMOUNT from '@salesforce/label/c.CustomerRequestFormColumnTotalAmount';
import CUSTOMERREQUESTFORMCOLUMNCONTRACTENDDATE from '@salesforce/label/c.CustomerRequestFormColumnContractEndDate';
import CUSTOMERREQUESTFORMCOLUMNNEXTDATERENEWAL from '@salesforce/label/c.CustomerRequestFormColumnNextDateRenewal';
import CUSTOMERREQUESTFORMCOLUMNCANCELLATIONDATE from '@salesforce/label/c.CustomerRequestFormColumnCancellationDate';
import CUSTOMERREQUESTFORMCOLUMNQUANTITYCANCELLED from '@salesforce/label/c.CustomerRequestFormColumnQuantityCancelled';
import CUSTOMERREQUESTFORMCOLUMNNEWQUANTITY from '@salesforce/label/c.CustomerRequestFormColumnNewQuantity';
import CUSTOMERREQUESTFORMCOLUMNMRRCANCELLED from '@salesforce/label/c.CustomerRequestFormColumnMRRCancelled';
import CUSTOMERREQUESTFORMCOLUMNMRRNEW from '@salesforce/label/c.CustomerRequestFormColumnMRRNew';


export default class CustomerRequestSubscriptionLines extends LightningElement {

    connectedCallback() {
        loadStyle(this, customerRequestsFormStyle); 
    }

    CustomerRequestFormError = CUSTOMERREQUESTFORMERROR;
    CustomerRequestLinesUpdate = CUSTOMERREQUESTLINESUPDATE;
    CustomerRequestLinesDelete = CUSTOMERREQUESTLINESDELETE;
    CustomerRequestLinesQuantityWarning = CUSTOMERREQUESTLINESQUANTITYWARNING;
    CustomerRequestLinesDeleteSuccess = CUSTOMERREQUESTLINESDELETESUCCESS;
    CustomerRequestFormColumnSubscriptionNum = CUSTOMERREQUESTFORMCOLUMNSUBSCRIPTIONNUM;
    CustomerRequestFormColumnLoadName = CUSTOMERREQUESTFORMCOLUMNLOADNAME;
    CustomerRequestFormColumnUnitPrice = CUSTOMERREQUESTFORMCOLUMNUNITPRICE;
    CustomerRequestFormColumnQuantity = CUSTOMERREQUESTFORMCOLUMNQUANTITY;
    CustomerRequestFormColumnTotalAmount = CUSTOMERREQUESTFORMCOLUMNTOTALAMOUNT;
    CustomerRequestFormColumnContractEndDate = CUSTOMERREQUESTFORMCOLUMNCONTRACTENDDATE;
    CustomerRequestFormColumnNextDateRenewal = CUSTOMERREQUESTFORMCOLUMNNEXTDATERENEWAL;
    CustomerRequestFormColumnCancellationDate = CUSTOMERREQUESTFORMCOLUMNCANCELLATIONDATE;
    CustomerRequestFormColumnQuantityCancelled = CUSTOMERREQUESTFORMCOLUMNQUANTITYCANCELLED;
    CustomerRequestFormColumnNewQuantity = CUSTOMERREQUESTFORMCOLUMNNEWQUANTITY;
    CustomerRequestFormColumnMRRCancelled = CUSTOMERREQUESTFORMCOLUMNMRRCANCELLED;
    CustomerRequestFormColumnMRRNew = CUSTOMERREQUESTFORMCOLUMNMRRNEW;

    @api recordId;

    @track  columns = [
        { label: this.CustomerRequestFormColumnSubscriptionNum, fieldName: 'SubscriptionUrl' ,type: 'url',typeAttributes: {label: { fieldName: 'SubscriptionNumber' },target: '_blank'},editable: false,initialWidth: 180},
        { label: this.CustomerRequestFormColumnLoadName, fieldName: 'SubscriptionLineUrl',type: 'url',typeAttributes: {label: { fieldName: 'LoadName' },target: '_blank'},editable: false,initialWidth: 360},
        { label: this.CustomerRequestFormColumnUnitPrice, fieldName: 'UnitPrice' ,type: 'currency',editable: false,cellAttributes: { alignment: 'left' },initialWidth: 110},
        { label: this.CustomerRequestFormColumnQuantity, fieldName: 'Quantity' ,type: 'number',editable: false,cellAttributes: { alignment: 'center' },initialWidth: 100},
        { label: this.CustomerRequestFormColumnTotalAmount, fieldName: 'TotalAmount' ,type: 'currency',editable: false,cellAttributes: { alignment: 'left' },initialWidth: 130},
        { label: this.CustomerRequestFormColumnContractEndDate, fieldName: 'ContractEndDate' ,type: 'date-local',typeAttributes: { day: "2-digit", month: "2-digit"},editable: false,initialWidth: 160},
        { label: this.CustomerRequestFormColumnNextDateRenewal, fieldName: 'NextDateRenewal' ,type: 'date-local',typeAttributes: { day: "2-digit", month: "2-digit"},editable: false,initialWidth: 160},
        { label: this.CustomerRequestFormColumnCancellationDate, fieldName: 'CancellationDate' ,type: 'date-local',typeAttributes: { day: "2-digit", month: "2-digit"},editable: true,initialWidth: 160},
        { label: this.CustomerRequestFormColumnQuantityCancelled, fieldName: 'QuantityCancelled' ,type: 'number',editable: true,cellAttributes: { alignment: 'center' },initialWidth: 170},
        { label: this.CustomerRequestFormColumnNewQuantity, fieldName: 'NewQuantity' ,type: 'text',editable: false,cellAttributes: { alignment: 'center' },initialWidth: 130},
        { label: this.CustomerRequestFormColumnMRRCancelled, fieldName: 'MRR_Cancelled' ,type: 'text',editable: false,initialWidth: 150},
        { label: this.CustomerRequestFormColumnMRRNew, fieldName: 'MRR_New' ,type: 'text',editable: false,initialWidth: 110},
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

    @track subscriptionLinesData;
    @track subscriptionLinesDataLength ;
    @track deletedSubscriptionLinesId;
    @track isModalOpen = false;
    @track showLoadingSpinner = false;
    draftValues
    _datatableresp
    mapsubscriptionLinesQuantity
    @wire(getSubscriptionLinesByCustomerRequestId, { customerRequestId: '$recordId' })
    wiredAccount(result) {
        this.showLoadingSpinner = true;
        this._datatableresp = result
        if (result.data) {
            this.subscriptionLinesData = result.data;
            this.subscriptionLinesDataLength = result.data.length;
            this.setsubscriptionLinesQuantityMap();
            this.showLoadingSpinner = false;
        } else {
            console.log(result.error)
            this.showLoadingSpinner = false;
        }
    }

    setsubscriptionLinesQuantityMap(){
        var tempMapsubscriptionLinesQuantity = new Map();
        var i = 1;
        this.subscriptionLinesData.forEach(function (record){
            tempMapsubscriptionLinesQuantity.set(record.SubscriptionLineId, {Quantity:record.Quantity,index:i});
            i++;
        })
        this.mapsubscriptionLinesQuantity = tempMapsubscriptionLinesQuantity;
    }

    handleSave(event){
        var i = 0; 
        this.showLoadingSpinner = true;
        this.draftValues = event.detail.draftValues;
        var quantityWarningTxt = this.CustomerRequestLinesQuantityWarning;
        var tempMapsubscriptionLinesQuantity = this.mapsubscriptionLinesQuantity;
        this.draftValues.forEach(function (record){
            if(record.QuantityCancelled > tempMapsubscriptionLinesQuantity.get(record.SubscriptionLineId).Quantity){
                i++;
                quantityWarningTxt = quantityWarningTxt + '\n ' + 'Ligne N°' + tempMapsubscriptionLinesQuantity.get(record.SubscriptionLineId).index;
            }
        })
        if(i > 0){
            this.showLoadingSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    message: quantityWarningTxt,
                    variant: 'warning'
                })

            );
        } else{
            updateSubscriptionLines({subscriptionLinesStr: JSON.stringify(this.draftValues)})
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
        this.deletedSubscriptionLinesId = event.detail.row.SubscriptionLineId;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    deleteSubscriptionLine() {
        this.isModalOpen = false;
        this.showLoadingSpinner = true;
        const deletedSubscriptionLinesId = this.deletedSubscriptionLinesId; 
        var rows = [];
        for(let i=0; i<this.subscriptionLinesData.length; i++){
            if(this.subscriptionLinesData[i].SubscriptionLineId != deletedSubscriptionLinesId){
                rows.push(this.subscriptionLinesData[i]);
            }
        }
        deleteSubscriptionLine({subscriptionLineId: deletedSubscriptionLinesId})
        .then( result => {
            if(result === 'Success'){
                this.mapsubscriptionLinesQuantity.delete(deletedSubscriptionLinesId);
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: this.CustomerRequestLinesDeleteSuccess,
                        variant: 'success'
                    })

                );
                this.subscriptionLinesData = rows;
                this.subscriptionLinesDataLength = rows.length;
                this.setsubscriptionLinesQuantityMap();
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