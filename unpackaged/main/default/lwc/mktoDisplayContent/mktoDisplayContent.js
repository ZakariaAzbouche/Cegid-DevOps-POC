/**
 * @author Shamina - Comforth Karoo
 * @date 2020-09-03
 * @description Embed marketo VF and show specific Marketo fields in LWC
 */	
import { LightningElement, api, track, wire} from 'lwc';
import { getRecord } from "lightning/uiRecordApi";

export default class MktoDisplayContent extends LightningElement {
    //@api recordId = '00Q1w0000042sWYEAY'; //UAT sample lead id used for POC
    @api recordId;
    @track objRecord;
    @api domainURL;
    @api domainVFURL;
    @api objectApiName;
    @api fieldsAPIName;
    fields = [];

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Compact'] })
    objRecord;

    connectedCallback(){
        if(this.fieldsAPIName){
            let fieldsArr = this.fieldsAPIName.split(',');
            for(let item of fieldsArr){
                let objectField = {};
                objectField.fieldApiName = item.trim();
                objectField.objectApiName = this.objectApiName;
                this.fields.push(objectField);
            }
        }    
    } 

    get fullVFUrl() { 
        //https://cegid--uat--mkto-si.visualforce.com/apex/Lead?id=00Q1w0000042sWYEAY&isdtp=p1&sfdcIFrameOrigin=https://cegid--uat.lightning.force.com
        let pageURL= this.domainVFURL + '?id='+this.recordId+'&isdtp=p1&sfdcIFrameOrigin='+this.domainURL;
        return pageURL;
    }

}