import { LightningElement,api,track,wire } from 'lwc';

import messageChannel from '@salesforce/messageChannel/b2bMessageChannel__c';
import {publish, MessageContext} from 'lightning/messageService';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



import Participant_Object from '@salesforce/schema/Participant__c';
import CIVI from '@salesforce/schema/Participant__c.Civilite__c';
import EMAIL from '@salesforce/schema/Participant__c.EmailAddress__c';
import NameFirst from '@salesforce/schema/Participant__c.Name';
import PRENOM from '@salesforce/schema/Participant__c.Prenom__c';
import CARTITEMID from '@salesforce/schema/Participant__c.CartItemId__c';


 
export default class B2bAddParticipant extends LightningElement {
    @api getParticipants;
    @api getCartItemsIds;
    partObject = Participant_Object;
    salutation = CIVI;
    emailAdd = EMAIL;
    partName = NameFirst;
    partPrenom = PRENOM;
    cartItemsId = CARTITEMID;
    showChecked = false;
    enableDeleteButton = false
    @api getCartIds;
    @api progressValue;
    @api disabled;
    @track openModal = false;
    isSpinning = true;
    /**
     * Cart Value
     */
    _firstName;
    _lastName;
    _salutation;
    _email;
    showError;


    /*creates a MessageContext object which contains information*/
    @wire(MessageContext)
    messageContext;



    onChangeHandler(event) {
        console.log('this._salutation : ' , this._salutation);

        if(event.target.name == 'salutation'){
            this._salutation = event.detail.value;
        }
        if(event.target.name == 'name'){
            this._firstName = event.detail.value;
        }
        if(event.target.name == 'lastName'){
            this._lastName = event.detail.value;
        }
        if(event.target.name == 'email'){
            this._email = event.detail.value;
        }

        if(this._firstName !='' && this._firstName !=undefined &&
         this._lastName !='' && this._lastName !=undefined &&
         this._salutation !='' && this._salutation !=undefined && 
         this._email !='' && this._email !=undefined){
             this.isSpinning = true;
            //this.handleSave();
            clearTimeout(this.timeoutId);
            this.timeoutId = setTimeout(this.handleSave.bind(this), 1000);
        }
    }

    handleSave(){
        console.log('handleSave : ');
        this.template.querySelector('lightning-record-edit-form').submit(this.fields);
        this.isSpinning = false;
    }

    handleOnLoad(event){
        this.isSpinning = false;
        var record = event.detail.records;
        var fields = record[this.getParticipants].fields;
        this._firstName = (fields.Name.value != '')?fields.Name.value:'';
        this._lastName = (fields.Prenom__c.value != '')?fields.Prenom__c.value:'';
        this._salutation = (fields.Civilite__c.value != '')?fields.Civilite__c.value:'';
        this. _email = (fields.EmailAddress__c.value !='')?fields.EmailAddress__c.value:'';  
        
        console.log('fields : ', fields);

        this.enableDeleteButton = (this.getParticipants=='')?true:false;
        
    }

   /* handleReset(event) {
        console.log('handleReset ' ,  this.getParticipants);
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }

        this.deleterecord(this.getParticipants);
     }

     deleterecord(recordId){
        console.log('recordId ' , recordId);
        deleteRecord(recordId)
        .then(() => {
            this.dispatchEvent(
                new CustomEvent('reloadlogicpart', {
                    detail: {
                        reload : recordId
                    }
                })
            );
        })
        .catch(error => {
            console.log(error);
        });
    }*/

    handleParticipantSuccess(event){
        console.log('handleParticipantSuccess');
        this.showChecked = true;
        this.enableDeleteButton = false;
        console.log('onsuccess event recordEditForm', event.detail.id);

        this.getParticipants = event.detail.id;
        this.isSpinning = false;
        this.showError = '';

        //let message = {participantidToSend: event.detail.id};
        /*publishing event*/
        //publish(this.messageContext, messageChannel, message);

        this.dispatchEvent(
            new CustomEvent('reloadlogicpart', {
                detail: {
                    reload : event.detail.id
                }
            })
        );

    }

    handleError(event){
        this.showError = event.detail.detail;
        console.log('handleError' , event.detail.detail);
        this.showChecked = false;
        this.isSpinning = false;
    }

    showModal() {
        this.openModal = true;
    }
    closeModalRedirect() {
        var _participantId = this.getParticipants;
        deleteRecord(_participantId)
        .then(() => {
            location.reload();
        })
        .catch(error => {
            console.log(error);
        });
        this.openModal = false;
    }

    closeModal(){
        this.openModal = false;
    }

    handleChecked(event){
        var _valueCheck = event.target.checked;
        var _participantId = this.getParticipants;
        var _cartitemId = this.getCartItemsIds;
        this.dispatchEvent(
            new CustomEvent('checkboxvaluechange', {
                detail: {
                    participantvalue :_cartitemId +'-'+ _participantId,
                    checkboxvalue : _valueCheck,
                    cartItemIds : _cartitemId +'-'+_participantId
                }
            })
        );
    }


}