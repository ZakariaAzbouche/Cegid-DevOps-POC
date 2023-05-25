import { LightningElement, api } from 'lwc';
import uId from '@salesforce/user/Id';
import {
    subscribe,
    unsubscribe,
    onError,
    setDebugFlag,
    isEmpEnabled,
} from 'lightning/empApi';

import { NavigationMixin } from 'lightning/navigation';

export default class MergedContactRedirection extends NavigationMixin(LightningElement) {
    channelName = '/event/merge_contact_done__e';
    subscription = {};
    @api recordId;

    // Initializes the component
    connectedCallback() { 
        console.log(uId);      
        // Register error listener       
        this.registerErrorListener();
        this.handleSubscribe(); 
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log('New message received: ', JSON.stringify(response));
            // Response contains the payload of the new message received

            let eventObj = JSON.parse(JSON.stringify(response));

            console.log('Merge success on : ' +eventObj.data.payload.Merged_Contact_Id__c); 
           
            if(uId === eventObj.data.payload.Created_By_Id__c) {
                console.log('USER MATCH');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: eventObj.data.payload.Merged_Contact_Id__c,
                        objectApiName: 'Contact',
                        actionName: 'view'
                    }
                });
            }
            
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }
}