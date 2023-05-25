import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Id from '@salesforce/user/Id';

import getLeadByEmail from '@salesforce/apex/LWC_LeadController.getLeadByEmail';

import LEAD_SOBJECT from '@salesforce/schema/Lead';
import LEAD_TITLE from '@salesforce/schema/Lead.Title';
import ID_FIELD from '@salesforce/schema/Lead.Id';
import LEAD_COMPAGNY from '@salesforce/schema/Lead.Company';
import LEAD_LASTNAME from '@salesforce/schema/Lead.LastName';
import LEAD_FIRSTNAME from '@salesforce/schema/Lead.FirstName';
import LEAD_PHONE from '@salesforce/schema/Lead.Phone';
import LEAD_INTERNAL_COMMENT from '@salesforce/schema/Lead.Internal_Comment__c';
import LEAD_LEADSOURCE from '@salesforce/schema/Lead.LeadSource';
import LEAD_EXPERTISE from '@salesforce/schema/Lead.Expertise__c'
import LEAD_MARKETO_INFO from '@salesforce/schema/Lead.Marketo_Info__c';

import LEAD_LAST_TOUCH_SOURCE from '@salesforce/schema/Lead.Last_Touch_Source_Telemarketing__c';
import LEAD_STATUS from '@salesforce/schema/Lead.Status';

import LEAD_TECH_IS_FUSION from '@salesforce/schema/Lead.TECH_Is_Fusion__c';

import LEAD_TECH_MARKETING_STATUS_TMP from '@salesforce/schema/Lead.TECH_Marketing_Status_Tmp__c';
import LEAD_TECH_MARKETING_CAMPAIGN_TMP from '@salesforce/schema/Lead.TECH_Marketing_Campaign_Tmp__c';

import LEAD_REJECT_CAUSE from '@salesforce/schema/Lead.Reject_Cause__c';
import LEAD_OWNER_ID from '@salesforce/schema/Lead.OwnerId';

import form_title from '@salesforce/label/c.lds_telemarketing_form_title';
import section_1 from '@salesforce/label/c.lds_telemarketing_section_1';
import section_2 from '@salesforce/label/c.lds_telemarketing_section_2';
import section_3 from '@salesforce/label/c.lds_telemarketing_section_3';
import section_4 from '@salesforce/label/c.lds_telemarketing_section_4';
import section_5 from '@salesforce/label/c.lds_telemarketing_section_5';
import error_doublon from '@salesforce/label/c.lds_error_doublon_telemarketing';
import defaultMarketingCampaign from '@salesforce/label/c.Default_Marketing_Campaign_For_telemark';
import defaultMarketingStatus from '@salesforce/label/c.Default_Marketing_Status_For_Telemark';
import defaultFusionLeadStatusForTelemark from '@salesforce/label/c.Default_Fusion_Lead_Status_For_Telemark';

export default class LdFormTelemark extends NavigationMixin(LightningElement) {
    
    _leadEmail;
    recordId = null;
    _existingLead = [];

    _marketingStatusDefaultValue;
    _marketingCampaignDefaultValue;
    _leadStatusDefaultValue;

    _marketingCampaign;

    _marketingCampaignDisabled = true;

    

    userId = Id;

    @track openModal = true;
    _recordTypeId;

    // Expose the labels to use in the template.
    label = {
        form_title,
        section_1,
        section_2,
        section_3,
        section_4,
        section_5,
    };

    showModal() {
        this.openModal = true;
    }
    closeModal() {
        this.openModal = false;
        this.navigateToListView();
    }

    connectedCallback() {
        console.log('CONNECTED');
        this._marketingStatusDefaultValue = defaultMarketingStatus;
        this._marketingCampaignDefaultValue = defaultMarketingCampaign;
        this._leadStatusDefaultValue = defaultFusionLeadStatusForTelemark;
        this._marketingCampaign = defaultMarketingCampaign;
    }

    @wire(getObjectInfo, { objectApiName: LEAD_SOBJECT })
    objectInfo({error, data}) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this._recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Lead Telemarketing');
            console.log(this._recordTypeId);
        } else if (error) {
            console.log(error);
        }
    }
    

    handleLoad(event) {
        this._leadEmail = event.details.fields.Email;
        console.log(this.leads);
    }

    handleLeadSourceChange(event) {
        console.log(event.detail.value);
        if(event.detail.value === 'leadpurchase' && this._marketingCampaign === this._marketingCampaignDefaultValue) {
            this._marketingCampaignDisabled = false;
            this._marketingCampaign = null;
        } else {
            this._marketingCampaignDisabled = true;
            this._marketingCampaign = this._marketingCampaignDefaultValue;
        }

        console.log(this._marketingCampaign);
    }

    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        this._leadEmail = fields.Email;
        this.processLeadByEmail(fields);
    }

    handleError(event) {
        console.log('ERROR');
        console.log(event.detail.output.errors[0].errorCode);
        console.log(event.detail);
        
        let errorMessage = 'Details : '+event.detail.detail;

        if(event.detail.output.errors[0].errorCode === 'DUPLICATES_DETECTED') {
            errorMessage += '\n Object concerned : ' + event.detail.output.errors[0].duplicateRecordError.matchResults[0].apiName;
        }
        const evt = new ShowToastEvent({
            title: "ERROR : " + event.detail.output.errors[0].errorCode,
            message: errorMessage,
            variant: "error",
            mode: "sticky"
        });

        this.dispatchEvent(evt);
    }

    async processLeadByEmail(fields) {
        this._existingLead = await getLeadByEmail({ email: this._leadEmail});
        console.log(this._existingLead);
        if(this._existingLead.length === 0) { 
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } else {
            this.recordId = this._existingLead[0].Id;
            if(this._existingLead[0].Status === 'Assigned' || this._existingLead[0].Status === 'In Progress' || this._existingLead[0].Status === 'Qualified' || this._existingLead[0].Status === 'In Buffer') {
                //error Message
                console.log(`ERROR existing lead with ${this._existingLead[0].Status}`);

                this.openModal = false;

                const evt = new ShowToastEvent({
                    title: "Error",
                    message: error_doublon,
                    variant: "error",
                    mode: "sticky"
                });
        
                this.dispatchEvent(evt);
                this.navigateToRecord(this.recordId);
                
            } else if(this._existingLead[0].Status === 'New' || this._existingLead[0].Status === 'Closed - Not Converted') {
               
                console.log('LEAD FUSION');
                
                this.updateLead(fields);
            }
        }
        
    }

    
    updateLead(newFields) {
            console.log(JSON.stringify(newFields));
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.recordId;
            if(newFields.Title !== null) {
                fields[LEAD_TITLE.fieldApiName] = newFields.Title;
            }
            fields[LEAD_COMPAGNY.fieldApiName] = newFields.Company;
            fields[LEAD_LASTNAME.fieldApiName] = newFields.LastName;
            fields[LEAD_FIRSTNAME.fieldApiName] = newFields.FirstName;
            fields[LEAD_PHONE.fieldApiName] = newFields.Phone;
            fields[LEAD_LEADSOURCE.fieldApiName] = newFields.LeadSource;
            fields[LEAD_EXPERTISE.fieldApiName] = newFields.Expertise__c;
            fields[LEAD_MARKETO_INFO.fieldApiName] = newFields.Marketo_Info__c;
            fields[LEAD_TECH_MARKETING_CAMPAIGN_TMP.fieldApiName] = this._marketingCampaign;
            fields[LEAD_LAST_TOUCH_SOURCE.fieldApiName] = newFields.Last_Touch_Source_Telemarketing__c;
            fields[LEAD_INTERNAL_COMMENT.fieldApiName] = newFields.Internal_Comment__c;
            fields[LEAD_STATUS.fieldApiName] = this._leadStatusDefaultValue;
            fields[LEAD_TECH_MARKETING_STATUS_TMP.fieldApiName] = this._marketingStatusDefaultValue;
            fields[LEAD_TECH_IS_FUSION.fieldApiName] = true;
            if(this._existingLead[0].Status === 'Closed - Not Converted') {
                fields[LEAD_REJECT_CAUSE.fieldApiName] = ''; 
            }
            fields[LEAD_OWNER_ID.fieldApiName] = this.userId;

            const recordInput = { fields };

            console.log(recordInput);

            updateRecord(recordInput)
                .then(() => {
                    this.openModal = false;
                    /*this.dispatchEvent(
                        new ShowToastEvent({
                            title: fusion_title,
                            message: fusion_body,
                            variant: 'success'
                        })
                    );*/
                    // Display fresh data in the form
                    this.navigateToRecord(this.recordId); 
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error updating record',
                            message: 'You can\'t merge this lead',//error.body.message,
                            variant: 'error'
                        })
                    );
                });
    }

    
    handleSucess(event) {
        this.openModal = false;
        const evt = new ShowToastEvent({
            title: "Lead created",
            message: "Record ID: "+ event.detail.id,
            variant: "success"
        });

        this.dispatchEvent(evt);
        console.log(`LEAD CREATION ${event.detail.id}`);
        this.navigateToRecord(event.detail.id);
        

     }

     navigateToRecord(id) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                actionName: 'view',
            }
        });
     }

     navigateToListView() {
        // Navigate to the Lead object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    get recordTypeId() {
        return this._recordTypeId;
    }

    get marketingStatusDefaultValue() {
        return this._marketingStatusDefaultValue;
    }

    get leadStatusDefaultValue() {
        return this._leadStatusDefaultValue;
    }

    get marketingCampaignDisabled() {
        return this._marketingCampaignDisabled;
    }

    get marketingCampaign() {
        return this._marketingCampaign;
    }
}