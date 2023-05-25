import { LightningElement,api,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import STORE_TRAINING_CAROUSEL1 from '@salesforce/schema/Product2.Store_Training_Carousel_1__c';
import STORE_TRAINING_CAROUSEL2 from '@salesforce/schema/Product2.Store_Training_Carousel_2__c';
import STORE_TRAINING_CAROUSEL3 from '@salesforce/schema/Product2.Store_Training_Carousel_3__c';

const fields = [STORE_TRAINING_CAROUSEL1,STORE_TRAINING_CAROUSEL2,STORE_TRAINING_CAROUSEL3];

export default class B2bProductDescription extends LightningElement {

    @api recordId;
    training1;
    training2;
    training3;


    @wire(getRecord, { recordId : '$recordId', fields : fields })
    wiredProduct({ data, error }) {
        if(data){
            console.log('Field Values ; ' , data.fields);
            this.training1 = data.fields.Store_Training_Carousel_1__c.value;
            this.training2 = data.fields.Store_Training_Carousel_2__c.value;
            this.training3 = data.fields.Store_Training_Carousel_3__c.value;
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
    get training1Field() {
        return this.training1;
    }

    set training1Field(value) {
        if(value) {
            this.training1 = this.unescapeHTML(value);
        }
    }

    @api
    get training2Field() {
        return this.training2;
    }

    set training2Field(value) {
        if(value) {
            this.training2 = this.unescapeHTML(value);
        }
    }

    @api
    get training3Field() {
        return this.training1;
    }

    set training3Field(value) {
        if(value) {
            this.training3 = this.unescapeHTML(value);
        }
    }

    setClass(event){
        console.log('setClass ', event.currentTarget.dataset.id);
        if(event.currentTarget.dataset.id == '1'){
            console.log('test1');
            this.template.querySelector('[data-id="1"]').className='isActive ';
            this.template.querySelector('[data-id="2"]').className=' ';
            this.template.querySelector('[data-id="3"]').className=' ';
        }else if(event.currentTarget.dataset.id == '2'){
            this.template.querySelector('[data-id="1"]').className=' ';
            this.template.querySelector('[data-id="3"]').className=' ';
            this.template.querySelector('[data-id="2"]').className='isActive ';
        }else{
            this.template.querySelector('[data-id="1"]').className=' ';
            this.template.querySelector('[data-id="2"]').className=' ';
            this.template.querySelector('[data-id="3"]').className='isActive ';
        }

    }

}