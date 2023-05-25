import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import PRODUCT_CATEGORY_FIELD from '@salesforce/schema/Product2.Store_Included_Themes__c';

const fields = [PRODUCT_CATEGORY_FIELD]

export default class B2bProductDescription extends LightningElement {

    productDetail;
    @api recordId;


    @wire(getRecord, { recordId : '$recordId', fields : fields })
    wiredProduct({ data, error }) {
        if(data){
            console.log('Field Values ; ' , data.fields.Store_Included_Themes__c.value);
            this.productDetail = data.fields.Store_Included_Themes__c.value;
        }else if(error) {
            console.log(error);
        }
    }


    // return blocks in html
    unescapeHTML(str) {
        return String(str)
            .replace(/&amp;/g,'&')
            .replace(/&lt;/g,'<')
            .replace(/&gt;/g,'>')
            .replace(/&quot;/g,'"');
    }

    @api
    get productDetailFields() {
        return this.productDetail;
    }

    set productDetailFields(value) {
        if(value) {
            this.productDetail = this.unescapeHTML(value);
        }
    }

    connectedCallback() {
        console.log('rdc: ', this.productDetail);
    }
}