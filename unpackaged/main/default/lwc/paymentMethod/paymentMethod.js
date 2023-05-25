import { LightningElement, api, track } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import * as Constants from './constants';

import communityId from '@salesforce/community/Id';

import getPaymentInfo from '@salesforce/apex/B2BPaymentControllerCust.getPaymentInfo';
import setPayment from '@salesforce/apex/B2BPaymentControllerCust.setPayment';

/**
 * MadatSepa Save Method 
 */

 //import saveOrders from '@salesforce/apex/B2B_QuoteGetMandatSepa.createOrderRecord';

/**
 * Allows users to choose the type of payment (eg. Purchase Order, Credit Card)
 * and to fill out the required information for the chosen type.
 *
 * @fires FlowNavigationNextEvent
 * @fires FlowNavigationBackEvent
 * @fires PaymentMethod#submitpayment
 */
export default class PaymentMethod extends LightningElement {
    // Private attributes
    _addresses;
    _creditCardErrorMessage;
    _purchaseOrderErrorMessage = '';
    _cartId;
    _purchaseOrderNumber = '1';
    _selectedBillingAddress;
    _selectedPaymentType = Constants.PaymentTypeEnum.PONUMBER;
    mandaMap = {};
    _enableButton = true;
    paymentButton = false;

    @api iban;
    @api bic;
    @api bankName;
    @api bankCity;
    @api rum;
    @api isSepaCustom;
    @api selectedPaymentTypes;
    @api userSelectedPaymentTypes;

    get disableNext() {
        if(this._selectedPaymentType == Constants.PaymentTypeEnum.PONUMBER){
            return this._enableButton;
        }else{
            //console.log('validity', this.template.querySelector("c-card-payment-method-cust").reportValidity());
            return false;
        }
    }

    /**
     * Determines if Purchase Order is a required field.
     * @type {Boolean}
     */
    @api poRequired = false;

    /**
     * Determines if Card Holder Name is a required field.
     * @type {Boolean}
     */
    @api cardHolderNameRequired = false;

    /**
     * Determines if Card Type is a required field.
     * @type {Boolean}
     */
    @api cardTypeRequired = false;

    /**
     * Determines if Expiry Month is a required field.
     * @type {Boolean}
     */
    @api expiryMonthRequired = false;

    /**
     * Determines if Expiry Year is a required field.
     * @type {Boolean}
     */
    @api expiryYearRequired = false;

    /**
     * Determines if CVV is a required field.
     * @type {Boolean}
     */
    @api cvvRequired = false;

    /**
     * Determines if Card Holder Name is a hidden field.
     * @type {Boolean}
     */
    @api hideCardHolderName = false;

    /**
     * Determines if Card Type is a hidden field.
     * @type {Boolean}
     */
    @api hideCardType = false;

    /**
     * Determines if CVV is a hidden field.
     * @type {Boolean}
     */
    @api hideCvv = false;

    /**
     * Determines if Expiry Month is a hidden field.
     * @type {Boolean}
     */
    @api hideExpiryMonth = false;

    /**
     * Determines if Expiry Year is a hidden field.
     * @type {Boolean}
     */
    @api hideExpiryYear = false;

    /**
     * Determines if Purchase Order is a hidden option.
     * @type {Boolean}
     */
    @api hidePurchaseOrder = false;

    /**
     * Determines if Credit Card is a hidden option.
     * @type {Boolean}
     */
    @api hideCreditCard = false;

    /**
     * Text to display on the Previous button. Defaults to "Previous".
     * @type {String}
     */
    @api previousButtonLabel = 'Précédent';

    /**
     * Text to display on the Next button. Defaults to "Next".
     * @type {String}
     */
    @api nextButtonLabel = 'Suivant';

    /**
     * The list of labels used in the cmp. 
     * @type {String}
     */
    get labels() {
        return Constants.labels;
    }

    /**
     * Gets or sets the currently selected payment type.
     *
     * The value of this property is updated in response to user interactions with the control.
     *
     * @type {String}
     */
    @api
    get selectedPaymentType() {
        return this._selectedPaymentType;
    }

    set selectedPaymentType(newPaymentType) {
        this._selectedPaymentType = newPaymentType;
    }

    /**
     * The purchase order number. Used to pass the purchase order to the server and to
     * display the existing purchase order when the component loads.
     *
     * The value of this property is updated in response to user interactions with the control.
     *
     * @type {string}
     */
    @api
    get purchaseOrderNumber() {
        return this._purchaseOrderNumber;
    }

    set purchaseOrderNumber(newNumber) {
        this._purchaseOrderNumber = newNumber;
    }

    /**
     * The address data. Used to pass the user's addresses to the child billing address components.
     * @type {Address[]}
     */
    @api
    get addresses() {
        return this._addresses;
    }

    set addresses(billingAddresses) {
        this._addresses = billingAddresses;
    }

    /**
     * Gets or sets the selected billing address.
     * @type {String}
     */
    @api
    get selectedBillingAddress() {
        return this._selectedBillingAddress;
    }

    set selectedBillingAddress(address) {
        this._selectedBillingAddress = address;
    }

    /**
     * Determines if Billing Address is a hidden field.
     * @type {Boolean}
     */
    @api hideBillingAddress = false;

    /**
     * Determines if the billing address field should be marked required.
     * @type {Boolean}
     */
    @api billingAddressRequired = false;

    /**
     * The error message string if there is an error with displaying billing addresses.
     * Errors that are possible are no access to web cart/ no access to CPA/ or no billing addresses in the list.
     *
     * @type {String}
     */
    @api billingAddressErrorMessage;

    /**
     * The cartId for the current webCart.
     * @return {String} the webCartID
     */
    @api
    get cartId() {
        return this._cartId;
    }

    /**
     * Sets the cartId of the current webCart.
     * @param {String} cartId
     */
    set cartId(cartId) {
        this._cartId = cartId;
        if (cartId) {
            this.initializePaymentData(cartId);
        }
    }

    /**
     * Gets the payment types
     * PO Number or Card Payment
     */
    get paymentTypes() {
        return {
            poNumber: Constants.PaymentTypeEnum.PONUMBER,
            cardPayment: Constants.PaymentTypeEnum.CARDPAYMENT
        };
    }

    /**
     * Get state of selected payment type
     * @return {boolean} true if selected payment type is Card Payment
     */
    get isCardPaymentSelected() {
        return (
            this.actualSelectedPaymentType ===
                Constants.PaymentTypeEnum.CARDPAYMENT && !this.hideCreditCard
        );
    }

    /**
     * Get state of selected payment type
     * @return {boolean} true if selected payment type is PO number
     */
    get isPoNumberSelected() {
        return (
            this.actualSelectedPaymentType ===
            Constants.PaymentTypeEnum.PONUMBER && !this.hidePurchaseOrder
        );
    }

    /**
     * Get the selected payment type.
     * If hidePurchaseOrder is true, default to cardPayment.
     * if hideCreditCard is true, default to PurchaseOrderNumber.
     * @private
     */
    get actualSelectedPaymentType() {
        return this.hidePurchaseOrder
        ? Constants.PaymentTypeEnum.CARDPAYMENT
        : (this.hideCreditCard ? Constants.PaymentTypeEnum.PONUMBER : this._selectedPaymentType);
    }

    /**
     * Handler to initialize the payment component
     * @param {String} cartId - the current webCart ID
     */
    initializePaymentData(cartId) {
        // If we don't have those values yet
        getPaymentInfo({ communityId: communityId,cartId: cartId })
            .then((data) => {
                this._purchaseOrderNumber = '1';//data.purchaseOrderNumber;
                this._addresses = data.addresses;
            })
            .catch((error) => {
                //do nothing, continue as normal
                console.log(error.body.message);
            });
    }

    /**
     * Handler for the 'blur' event fired from the purchase order input.
     */
    handleUpdate() {
        const poComponent = this.getComponent('[data-po-number]');
        const poData = (poComponent.value || '').trim();
        this._purchaseOrderNumber = poData;
    }

    /**
     * Handler for the 'click' event fired from the payment type radio buttons.
     * @param {event} event - The selected payment type
     */
    handlePaymentTypeSelected(event) {
        this._selectedPaymentType = event.currentTarget.value;
    }

    /**
     * Navigates to the previous page. Doesn't save any information, so that information is lost on clicking
     * Previous.
     */
    handlePreviousButton() {
        const navigatePreviousEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigatePreviousEvent);
    }

    /**
     * Handler for the 'click' event fired from the payment button.
     * If PO Number is selected, make an apex call to set the new values.
     * If Credit Card is selected, check to see that all required fields are filled in first,
     * then makes an apex call which in turns makes a call to Payment.tokenize endpoint
     */
    get disableButton() {
        if(this.submissionInProgress) {
            return this.submissionInProgress;
        }
        return false;
    }
    submissionInProgress = false;

    handlePaymentButton() {
        this.paymentButton = true;
        const selectedAddressResult = this.getBillingAddress();

        // Mandat SEPA
        if (this.selectedPaymentType !== Constants.PaymentTypeEnum.CARDPAYMENT) {
            this.userSelectedPaymentTypes = 'SEPA';
            if (selectedAddressResult.error) {
                this._purchaseOrderErrorMessage = selectedAddressResult.error;
                return;
            }

            const poInput = this.getComponent('[data-po-number]');            
            // Make sure that PO input is valid first
            if (
                poInput != null &&
                !poInput.reportValidity()
            ) {
                
                return;
            }

            const paymentInfo = {
                poNumber: this.purchaseOrderNumber
            };

            setPayment({
                paymentType: this.selectedPaymentType,
                cartId: this.cartId,
                billingAddress: selectedAddressResult.address,
                paymentInfo: paymentInfo
            }).then(() => {
               // this.handleUpdateSepa();
                // After making the server calls, navigate NEXT in the flow
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }).catch((error) => {
                this._purchaseOrderErrorMessage = error.body.message;
            });
        } else {// Card Payment
            // First let's get the cc data
            const creditPaymentComponent = this.getComponent(
                '[data-credit-payment-method]'
            );
                this.userSelectedPaymentTypes = 'CB';
            console.log("submitting request to child lwc");

            //JD (Custom) - Trigger method in Child LWC to initialize iFrame request (inside the VF Page)
            creditPaymentComponent.handleSubmitPayment();
        }
    }

    /**
     * Save Mandat SEPA 
     */
    // handleUpdateSepa(){
    //     saveOrders({
    //         listCartIds:this.cartId,
    //         mapMandatSepa : this.mandaMap
    //     })
    //     .then(result => {
    //        console.log('result Manda' , result);
    //     })
    //     .catch(error => {
    //         console.log('error ' , error);
    //     });
    // }

    /**
     * @returns The selected billing address in an object { address: <the selected billing address> } or
     *          { error: <the error message> } if the field is required but missing. It can return an empty
     *          object if there is no billing address and it's not a required field.
     */
    getBillingAddress() {
        if (!Array.isArray(this._addresses) || !this._addresses.length) {
            if (this.billingAddressRequired) {
                return { error: 'Adresse de facturation obligatoire' };
            }
        } else {
            return { address: this._addresses.filter(add => add.id === this.selectedBillingAddress)[0] };
        }

        return {};
    }

    getCreditCardFromComponent(creditPaymentComponent) {
        const cardPaymentData = {};
        [
            'cardHolderName',
            'cardNumber',
            'cvv',
            'expiryYear',
            'expiryMonth',
            'expiryYear',
            'cardType'
        ].forEach((property) => {
            cardPaymentData[property] = creditPaymentComponent[property];
        });
        return cardPaymentData;
    }

    /**
     * Set the address selected
     */
    handleChangeSelectedAddress(event) {
        const address = event.detail.address;
        if (address.id !== null && (address.id).startsWith('8lW')) {
            this._selectedBillingAddress = address.id;
        } else {
            this._selectedBillingAddress = '';
        }
    }

    /**
     * Simple function to query the passed element locator
     * @param {*} locator The HTML element identifier
     * @private
     */
    getComponent(locator) {
        return this.template.querySelector(locator);
    }

    dispatchCustomEvent(eventName, detail) {
        this.dispatchEvent(
            new CustomEvent(eventName, {
                bubbles: false,
                composed: false,
                cancelable: false,
                detail
            })
        );
    }

    getMandaSepaInfo(event){
        console.log('Mandat : ' , event.detail.isCustom);
         this.mandaMap = {iban:event.detail.iban, bic:event.detail.bic, rum:event.detail.rum, 
            bankCity:event.detail.bankCity, bankName:event.detail.bankName,isSepaCustom:event.detail.isCustom};
        
         this._enableButton = event.detail.enableButton;

         this.bic = event.detail.bic;
         this.iban = event.detail.iban;
         this.bankName = event.detail.bankName;
         this.bankCity = event.detail.bankCity;
         this.rum = event.detail.rum;
         this.isSepaCustom = event.detail.isCustom;

         console.log('this.mandaMap : ' , this.mandaMap);
    }

    //JD (Custom) - Triggered via an event from the cardPaymentMethodCust LWC to submit a Credit Card Payment
    handleSubmitCreditCard(event) {
        console.log('handleSubmitCreditCard', JSON.parse(JSON.stringify(event.detail)));
        //Took existing logic from the initial paymentMethod LWC and copy/pasted here
        const selectedAddress = this._addresses.filter(add => add.id === this.selectedBillingAddress)[0];

        setPayment({
            paymentType: this.selectedPaymentType,
            cartId: this.cartId,
            billingAddress: selectedAddress,
            paymentInfo: event.detail
        }).then(() => {
            // After making the server calls, navigate NEXT in the flow
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);

            //If successful, no need to re-enable
            //this.submissionInProgress = false;
        }).catch((error) => {
            console.log('handleSubmitCreditCard', error);
            try{
                let _error =  JSON.parse(error.body.message);
                console.log('handleSubmitCreditCard error', _error);
                if(_error && _error.output && _error.output.gatewayResponse && _error.output.gatewayResponse.gatewayMessage){
                    this._creditCardErrorMessage = _error.output.gatewayResponse.gatewayMessage;
                }else{
                    this._creditCardErrorMessage = error.body.message;
                }
            }catch(e){
                this._creditCardErrorMessage = error.body.message;
            }
            
            this.submissionInProgress = false;
        });
    }

    handlePaymentError(event) {
        console.log("ERROR RECEIVED IN LWC");
        this.submissionInProgress = false;
        this.disableButton = false;
    }
}