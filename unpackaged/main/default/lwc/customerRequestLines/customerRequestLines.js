/**
 * @author           : Soufiane LOGDALI soufiane.logdali@comforth-karoo.eu
 * @last created on  : 19/05/2022
**/

import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import TYPE from '@salesforce/schema/CustomerRequest__c.Type__c';

const fields = [TYPE];

export default class CustomerRequestLines extends LightningElement {
    @api recordId;

    showInvoiceLines = false;
    showSubscriptionLines = false;

    @wire(getRecord, { recordId: '$recordId', fields })
    customerRequest;

    get type() {
        if(getFieldValue(this.customerRequest.data, TYPE) == 'Credit Note' || getFieldValue(this.customerRequest.data, TYPE) == 'Cancellation with Credit Note'){
            this.showInvoiceLines = true;
        }
        if(getFieldValue(this.customerRequest.data, TYPE) == 'Cancellation' || getFieldValue(this.customerRequest.data, TYPE) == 'Cancellation with Credit Note'){
            this.showSubscriptionLines = true;
        }
        return getFieldValue(this.customerRequest.data, TYPE);
    }
}