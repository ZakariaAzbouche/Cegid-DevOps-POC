import { LightningElement, api,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { resolve } from 'c/cmsResourceResolver';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/cartUtils';
import deleteAllRelatedParticipant from '@salesforce/apex/B2B_AddParticipants.deleteAllParticipant';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { deleteRecord } from 'lightning/uiRecordApi';

import messageChannel from '@salesforce/messageChannel/b2bMessageChannel__c';
import {publish, MessageContext} from 'lightning/messageService'

const QUANTITY_CHANGED_EVT = 'quantitychanged';
const SINGLE_CART_ITEM_DELETE = 'singlecartitemdelete';

/**
 * A non-exposed component to display cart items.
 *
 * @fires Items#quantitychanged
 * @fires Items#singlecartitemdelete
 */
export default class Items extends NavigationMixin(LightningElement) {
    /*creates a MessageContext object which contains information*/
    @wire(MessageContext)
    messageContext;

    @track itemsIds = [];
    @track cartItemsIds = [];
    participantIds = [];
    rendertab = false;
    /**
     * An event fired when the quantity of an item has been changed.
     *
     * Properties:
     *   - Bubbles: true
     *   - Cancelable: false
     *   - Composed: true
     *
     * @event Items#quantitychanged
     * @type {CustomEvent}
     *
     * @property {string} detail.itemId
     *   The unique identifier of an item.
     *
     * @property {number} detail.quantity
     *   The new quantity of the item.
     *
     * @export
     */

    /**
     * An event fired when the user triggers the removal of an item from the cart.
     *
     * Properties:
     *   - Bubbles: true
     *   - Cancelable: false
     *   - Composed: true
     *
     * @event Items#singlecartitemdelete
     * @type {CustomEvent}
     *
     * @property {string} detail.cartItemId
     *   The unique identifier of the item to remove from the cart.
     *
     * @export
     */

    /**
     * A cart line item.
     *
     * @typedef {Object} CartItem
     *
     * @property {ProductDetails} productDetails
     *   Representation of the product details.
     *
     * @property {string} originalPrice
     *   The original price of a cart item.
     *
     * @property {number} quantity
     *   The quantity of the cart item.
     *
     * @property {string} totalPrice
     *   The total sales price of a cart item.
     *
     * @property {string} totalListPrice
     *   The total original (list) price of a cart item.
     *
     * @property {string} unitAdjustedPrice
     *   The cart item price per unit based on tiered adjustments.
     */

    /**
     * Details for a product containing product information
     *
     * @typedef {Object} ProductDetails
     *
     * @property {string} productId
     *   The unique identifier of the item.
     *
     * @property {string} sku
     *  Product SKU number.
     *
     * @property {string} name
     *   The name of the item.
     *
     * @property {ThumbnailImage} thumbnailImage
     *   The image of the cart line item
     *
     */

    /**
     * Image information for a product.
     *
     * @typedef {Object} ThumbnailImage
     *
     * @property {string} alternateText
     *  Alternate text for an image.
     *
     * @property {string} title
     *   The title of the image.
     *
     * @property {string} url
     *   The url of the image.
     */

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {string}
     */
    @api
    currencyCode;

    

    /**
     * Whether or not the cart is in a locked state
     *
     * @type {Boolean}
     */
    @api
    isCartDisabled = false;

    /**
     * A list of CartItems
     *
     * @type {CartItem[]}
     */
    @api
    get cartItems() {
        return this._providedItems;
    }

    set cartItems(items) {
        this._providedItems = items;
        const generatedUrls = [];
        this._items = (items || []).map((item) => {
            // Create a copy of the item that we can safely mutate.
            const newItem = { ...item };
            // Set default value for productUrl
            newItem.productUrl = '';
            // Get URL of the product image.
            newItem.productImageUrl = resolve(
                item.cartItem.productDetails.thumbnailImage.url
            );

            


            // Set the alternative text of the image(if provided).
            // If not, set the null all text (alt='') for images.
            newItem.productImageAlternativeText =
                item.cartItem.productDetails.thumbnailImage.alternateText || '';

            // Get URL for the product, which is asynchronous and can only happen after the component is connected to the DOM (NavigationMixin dependency).
            const urlGenerated = this._canResolveUrls
                .then(() =>
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: newItem.cartItem.productId,
                            objectApiName: 'Product2',
                            actionName: 'view'
                        }
                    })
                )
                .then((url) => {
                    newItem.productUrl = url;
                });
            generatedUrls.push(urlGenerated);
            return newItem;
        });

        // When we've generated all our navigation item URLs, update the list once more.
        Promise.all(generatedUrls).then(() => {
            this._items = Array.from(this._items);
        });
       
    }

    /**
     * A normalized collection of items suitable for display.
     *
     * @private
     */
    @track _items = [];

    /**
     * A list of provided cart items
     *
     * @private
     */
    _providedItems;

    /**
     * A Promise-resolver to invoke when the component is a part of the DOM.
     *
     * @type {Function}
     * @private
     */
    _connectedResolver;

    /**
     * A Promise that is resolved when the component is connected to the DOM.
     *
     * @type {Promise}
     * @private
     */
    _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     */
    connectedCallback() {
        // Once connected, resolve the associated Promise.
        this._connectedResolver();
    }

    /**
     * This lifecycle hook fires when this component is removed from the DOM.
     */
    disconnectedCallback() {
        // We've beeen disconnected, so reset our Promise that reflects this state.
        this._canResolveUrls = new Promise((resolved) => {
            this._connectedResolver = resolved;
        });
    }


    /**
     * Gets the sequence of cart items for display.
     * This getter allows us to incorporate properties that are dependent upon
     * other component properties, like price displays.
     *
     * @private
     */
    get displayItems() {
        //var existingParticipant = [];
        console.log('DisplayItems CartItems: ' );
        var sumOdAllQuantity = 0;
        var participantDataFilled = 0;
        //var linesToDelete = [];
        return this._items.map((item) => {
            // Create a copy of the item that we can safely mutate.
            const newItem = { ...item };

            sumOdAllQuantity = sumOdAllQuantity + parseInt(newItem.cartItem.quantity);

            //Calculate difference between lines
            var count = 0
            var subtract = 0
            var linesToDelete = []
            var existingParticipant = newItem.participantIdsFromParent;
            if(newItem.cartItem.quantity > newItem.participantIdsFromParent.length){
                for(var i=1; i<=newItem.cartItem.quantity-newItem.participantIdsFromParent.length;i++){
                    count++;
                }
            }else if(newItem.participantIdsFromParent.length > newItem.cartItem.quantity){
                for(var i=1; i<=newItem.participantIdsFromParent.length-newItem.cartItem.quantity;i++){
                    subtract++;
                }
            }

            //Check wheather to add lines or remove lines 
            //Input empty lines if count is > 0
            if(count > 0){
                var list = [];
                for (var i = 0; i <count; i++) {
                    list.push('');
                }
                //console.log('List Size () ' , list.length);
                newItem.participantIdsFromParent = existingParticipant.concat(list);
            }
            
            //Remove Lines if subtract > 0
            if(subtract > 0){
                //console.log('subtract : ' , subtract);

                const valuesToKeep = [];
                for (var i = 0; i < existingParticipant.length; i++){
                    if(existingParticipant[i] != undefined)
                    valuesToKeep.push(existingParticipant[i]);
                }
                linesToDelete = valuesToKeep.splice(-subtract);
                newItem.participantIdsFromParent = valuesToKeep;

                //Delete Record Testing 

                
                /*if(linesToDelete.length>0){
                    deleteparticipant({
                        listParticipantIds:linesToDelete
                    })
                    .then(result => {
                        //console.log('deleted Lines : ' , result);
                        this.dispatchEvent(
                            new CustomEvent('reloadlogic', {
                                detail: {
                                    reload : result
                                }
                            })
                        );
                    })
                    .catch(error => {
                        console.log('error ' , error);
                    });
                }*/
                
                for (var i = 0; i < linesToDelete.length; i++){
                    if(linesToDelete[i] != '' ){
                        console.log('recordId ' , linesToDelete[i]);
                        deleteRecord(linesToDelete[i])
                        .then((result) => {
                            this.dispatchEvent(
                                new CustomEvent('reloadlogic', {
                                    detail: {
                                        reload : result
                                    }
                                })
                            );
                        })
                        .catch(error => {
                            console.log(error);
                        });
                    }
                }
                
            }

            //To enable Commade Button 

            for (var i = 0; i <newItem.participantIdsFromParent.length; i++){
                
                if( newItem.participantIdsFromParent[i] != '' ){
                    participantDataFilled++
                }
            }

            console.log('sumOdAllQuantity : ' , sumOdAllQuantity);
            console.log('participantDataFilled : ' , participantDataFilled);

            let message = {remaningCount: sumOdAllQuantity, CountToSubstract: participantDataFilled};

            /*publishing event*/
            publish(this.messageContext, messageChannel, message);

           
            
            // Set whether or not to display negotiated price
            newItem.showNegotiatedPrice =
                this.showNegotiatedPrice &&
                (newItem.cartItem.totalPrice || '').length > 0;

            // Set whether or not to display original price
            newItem.showOriginalPrice = displayOriginalPrice(
                this.showNegotiatedPrice,
                this.showOriginalPrice,
                newItem.cartItem.totalPrice,
                newItem.cartItem.totalListPrice
            );
            // get the label for original price to provide to the aria-label attr for screen readers
            newItem.originalPriceLabel = getLabelForOriginalPrice(
                this.currencyCode,
                newItem.cartItem.totalListPrice
            );
                //console.log('newItem child ###### : ', newItem);
            return newItem;
        });
    }

    /**
     * Gets the available labels.
     *
     * @type {Object}
     *
     * @readonly
     * @private
     */
    get labels() {
        return {
            quantity: 'QTY',
            originalPriceCrossedOut: 'Prix ​​d\'origine (crossed out):'
        };
    }

    /**
     * Handler for the 'click' event fired from 'contents'
     *
     * @param {Object} evt the event object
     */
    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                actionName: 'view'
            }
        });
    }

    /**
     * Fires an event to delete a single cart item
     * @private
     * @param {ClickEvent} clickEvt A click event.
     * @fires Items#singlecartitemdelete
     */
    handleDeleteCartItem(clickEvt) {
        const cartItemId = clickEvt.target.dataset.cartitemid;
        this.dispatchEvent(
            new CustomEvent(SINGLE_CART_ITEM_DELETE, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId
                }
            })
        );
        this.deleteParticipant(cartItemId);
    }

    //Delete Participant 
    deleteParticipant(cartItemId) {

        deleteAllRelatedParticipant({
            listCartIds:cartItemId
        })
        .then(result => {
        })
        .catch(error => {
            console.log('error ' , error);
        });
    }

    /**
     * Fires an event to update the cart item quantity
     * @private
     * @param {FocusEvent} blurEvent A blur event.
     * @fires Items#quantitychanged
     */
    handleQuantitySelectorBlur(blurEvent) {
        //Stop the original event since we're replacing it.
        blurEvent.stopPropagation();

        // Get the item ID off this item so that we can add it to a new event.
        const cartItemId = blurEvent.target.dataset.itemId;
        // Get the quantity off the control, which exposes it.
        const quantity = blurEvent.target.value;

        // Fire a new event with extra data.
        this.dispatchEvent(
            new CustomEvent(QUANTITY_CHANGED_EVT, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId,
                    quantity
                }
            })
        );
    }

    /**
     * Handles a click event on the input element.
     *
     * @param {ClickEvent} clickEvent
     *  A click event.
     */
    handleQuantitySelectorClick(clickEvent) {
        /*
      Firefox is an oddity in that if the user clicks the "spin" dial on the number
      control, the input control does not gain focus. This means that users clicking the
      up or down arrows won't trigger our change events.

      To keep the user interactions smooth and prevent a notification on every up / down arrow click
      we simply pull the focus explicitly to the input control so that our normal event handling takes care of things properly.
    */
        clickEvent.target.focus();
    }

    handleActive(){
        console.log('Handle Active ');
        this.rendertab = true;
    }

    executeReload(){
        var _tab = this.rendertab
        this.dispatchEvent(
            new CustomEvent('reloadlogic', {
                detail: {
                    _tab
                }
            })
        );
    }

    sendDeleteListToParent(event){
        //console.log('Parent ' ,event.detail.participantvalue);
        this.dispatchEvent(
            new CustomEvent('sendtoparent', {
                detail: {
                    participantvalue : event.detail.participantvalue,
                    checkboxvalue : event.detail.checkboxvalue,
                    cartItemIds : event.detail.cartItemIds
                }
            })
        );
    }
}