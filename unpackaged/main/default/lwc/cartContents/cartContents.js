import { api, wire, LightningElement,track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

import communityId from '@salesforce/community/Id';
import getCartItems from '@salesforce/apex/B2BCartControllerSample.getCartItems';
import updateCartItem from '@salesforce/apex/B2BCartControllerSample.updateCartItem';
import updateCheckoutStatus from '@salesforce/apex/B2BCartControllerSample.updateCartStatus';
import deleteCartItem from '@salesforce/apex/B2BCartControllerSample.deleteCartItem';
import deleteCart from '@salesforce/apex/B2BCartControllerSample.deleteCart';
import createCart from '@salesforce/apex/B2BCartControllerSample.createCart';
import getParticipants from '@salesforce/apex/B2B_AddParticipants.getParticipantRow';
import deleteParticipant from '@salesforce/apex/B2B_AddParticipants.deleteParticipantByIds';
import resetStatus from '@salesforce/apex/B2B_AddParticipants.resetCartStatus';


import messageChannel from '@salesforce/messageChannel/b2bMessageChannel__c';
import {publish, MessageContext} from 'lightning/messageService'

import { fireEvent } from 'c/pubsub';
import { isCartClosed } from 'c/cartUtils';

/**
 * CheckOut Labels;
 */

 import paymentPart1 from '@salesforce/label/c.b2bCartProcessing';
 import paymentPart2 from '@salesforce/label/c.b2bCancelPayment';
 import deleteParticipantsButtonLabel from '@salesforce/label/c.b2b_MSG_CartItems_DeleteParticipants';//VMO 20211008

// Event name constants
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

// Locked Cart Status
const LOCKED_CART_STATUSES = new Set(['Processing', 'Checkout']);

/**
 * A sample cart contents component.
 * This component shows the contents of a buyer's cart on a cart detail page.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Sample Cart Contents Component'
 *
 * @fires CartContents#cartchanged
 * @fires CartContents#cartitemsupdated
 */

export default class CartContents extends NavigationMixin(LightningElement) {

    /**Labels */
    label = {
        paymentPart1,
        paymentPart2,
        deleteParticipantsButtonLabel//VMO 20211008
    }

    /*creates a MessageContext object which contains information*/
    @wire(MessageContext)
    messageContext;

    /**
     * Delete participant ids
     */

    @api deleteparticipantIds = [];
    @api cartItemIds = [];
    @api cartitemsObject= [];
    participantList = [];
    emptyList = true;
    /**
     * An event fired when the cart changes.
     * This event is a short term resolution to update the cart badge based on updates to the cart.
     *
     * @event CartContents#cartchanged
     *
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * An event fired when the cart items change.
     * This event is a short term resolution to update any sibling component that may want to update their state based
     * on updates in the cart items.
     *
     * In future, if LMS channels are supported on communities, the LMS should be the preferred solution over pub-sub implementation of this example.
     * For more details, please see: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_message_channel_considerations
     *
     * @event CartContents#cartitemsupdated
     * @type {CustomEvent}
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
     * @property {number} quantity
     *   The quantity of the cart item.
     *
     * @property {string} originalPrice
     *   The original price of a cart item.
     *
     * @property {string} salesPrice
     *   The sales price of a cart item.
     *
     * @property {string} totalPrice
     *   The total sales price of a cart item, without tax (if any).
     *
     * @property {string} totalListPrice
     *   The total original (list) price of a cart item.
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
     *   The quantity of the item.
     */

    /**
     * Image information for a product.
     *
     * @typedef {Object} ThumbnailImage
     *
     * @property {string} alternateText
     *  Alternate text for an image.
     *
     * @property {string} id
     *  The image's id.
     *
     * @property {string} title
     *   The title of the image.
     *
     * @property {string} url
     *   The url of the image.
     */

    /**
     * Representation of a sort option.
     *
     * @typedef {Object} SortOption
     *
     * @property {string} value
     * The value for the sort option.
     *
     * @property {string} label
     * The label for the sort option.
     */

    /**
     * The recordId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    recordId;

    /**
     * The effectiveAccountId provided by the cart detail flexipage.
     *
     * @type {string}
     */
    @api
    effectiveAccountId;

    /**
     * An object with the current PageReference.
     * This is needed for the pubsub library.
     *
     * @type {PageReference}
     */
    @wire(CurrentPageReference)
    pageRef;

    /**
     * Total number of items in the cart
     * @private
     * @type {Number}
     */
    _cartItemCount = 0;

    /**
     * A list of cartItems.
     *
     * @type {CartItem[]}
     */
    @track cartItems;

    /**
     * A list of sortoptions useful for displaying sort menu
     *
     * @type {SortOption[]}
     */
    sortOptions = [
        { value: 'CreatedDateDesc', label: this.labels.CreatedDateDesc },
        { value: 'CreatedDateAsc', label: this.labels.CreatedDateAsc },
        { value: 'NameAsc', label: this.labels.NameAsc },
        { value: 'NameDesc', label: this.labels.NameDesc }
    ];

    /**
     * Specifies the page token to be used to view a page of cart information.
     * If the pageParam is null, the first page is returned.
     * @type {null|string}
     */
    pageParam = null;

    /**
     * Sort order for items in a cart.
     * The default sortOrder is 'CreatedDateDesc'
     *    - CreatedDateAsc—Sorts by oldest creation date
     *    - CreatedDateDesc—Sorts by most recent creation date.
     *    - NameAsc—Sorts by name in ascending alphabetical order (A–Z).
     *    - NameDesc—Sorts by name in descending alphabetical order (Z–A).
     * @type {string}
     */
    sortParam = 'CreatedDateDesc';

    /**
     * Is the cart currently disabled.
     * This is useful to prevent any cart operation for certain cases -
     * For example when checkout is in progress.
     * @type {boolean}
     */
    isCartClosed = false;

    /**
     * The ISO 4217 currency code for the cart page
     *
     * @type {string}
     */
    currencyCode;

    /**
     * Gets whether the cart item list is empty.
     *
     * @type {boolean}
     * @readonly
     */
    get isCartEmpty() {
        // If the items are an empty array (not undefined or null), we know we're empty.
        return Array.isArray(this.cartItems) && this.cartItems.length === 0;
    }

    /**
     * The labels used in the template.
     * To support localization, these should be stored as custom labels.
     *
     * To import labels in an LWC use the @salesforce/label scoped module.
     * https://developer.salesforce.com/docs/component-library/documentation/en/lwc/create_labels
     *
     * @type {Object}
     * @private
     * @readonly
     */
    get labels() {
        return {
            loadingCartItems: 'Chargement des articles du panier',
            clearCartButton: 'Vider le panier',
            sortBy: 'Trier par',
            cartHeader: 'Panier',
            emptyCartHeaderLabel: 'Votre panier est vide',
            emptyCartBodyLabel:
                'Recherchez ou parcourez les produits et ajoutez-les à votre panier. Vos sélections apparaissent ici.',
            closedCartLabel: "Le panier que vous avez demandé n'est pas disponible.",
            CreatedDateDesc: 'Date d\'ajout - Le plus récent en premier',
            CreatedDateAsc: 'Date d\'ajout - Le plus ancien en premier',
            NameAsc: 'Nom - A à Z',
            NameDesc: 'Nom - Z à A'
        };
    }

    /**
     * Gets the cart header along with the current number of cart items
     *
     * @type {string}
     * @readonly
     * @example
     * 'Cart (3)'
     */
    get cartHeader() {
        return `${this.labels.cartHeader} (${this._cartItemCount})`;
    }

    /**
     * Gets whether the item list state is indeterminate (e.g. in the process of being determined).
     *
     * @returns {boolean}
     * @readonly
     */
    get isCartItemListIndeterminate() {
        return !Array.isArray(this.cartItems);
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     */
    connectedCallback() {
        // Initialize 'cartItems' list as soon as the component is inserted in the DOM.
        this.getCreatedParticipantList();
        //this.updateCartItems();
    }

    /**
     * Get Participant
     */

     getCreatedParticipantList(){
        console.log('getCreatedParticipantList');
        getParticipants({
            recordId:this.recordId
        })
        .then(result => {
            this.participantList = result;
            this.updateCartItems();

        })
        .catch(error => {
            console.log('error ' , error);
        });
    }

    resetCartStatus(){
        resetStatus({
            recordId:this.recordId
        })
        .then(result => {

        })
        .catch(error => {
            console.log('error ' , error);
        });
    }

    convertHTML(str) {
        str = str.replace("&lt;", "<");
        str = str.replace("&gt;", ">");
        str = str.replace("&amp;", "&");
        return str;
    }

    /**
     * Get a list of cart items from the server via imperative apex call
     */
    updateCartItems() {
        // Call the 'getCartItems' apex method imperatively
        getCartItems({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam
        })
            .then((result) => {
                resetStatus({
                    recordId:this.recordId
                })
                .then(result => {
                    console.log('Reset status ' , result);
                })
                .catch(error => {
                    console.log('error ' , error);
                });
                console.log('result Parent : ' , result);

                var cartIds = [];
                result.cartItems.forEach(function(res){
                    cartIds.push(res.cartItem.cartItemId);
                });
                
                this.cartItemIds = cartIds;
                this.cartItems = result.cartItems;
                var countPopulatedFields= 0;
                var totalQuantity=0;
                for (let i = 0; i < this.cartItems.length; i++) {
                    //check if there is participant 
                   
                   this.cartItems[i].cartItem.name =  this.convertHTML(this.cartItems[i].cartItem.name); 
                   this.cartItems[i].cartItem.productDetails.name =  this.convertHTML(this.cartItems[i].cartItem.productDetails.name); 



                    if(this.participantList.length>0){
                        var _participantIds =[];
                        // loop on Result
                        for(let j = 0; j < this.participantList.length; j++){
                            if(this.cartItems[i].cartItem.cartItemId == this.participantList[j].CartItemId__c){
                                countPopulatedFields++;
                                _participantIds.push(this.participantList[j].Id);
                            }
                        }

                        if( this.cartItems[i].cartItem.quantity > _participantIds.length){
                            for(let q = 0; q < this.cartItems[i].cartItem.quantity; q++){
                                if(this.cartItems[i].cartItem.quantity > _participantIds.length){
                                    _participantIds.push('');
                                }
                            }
                        }


                    }else if(this.participantList.length == 0){
                        var _participantIds =[];
                        for(let k = 0; k < this.cartItems[i].cartItem.quantity; k++){
                            _participantIds.push('');
                            totalQuantity++;
                        }
                    }
                    this.cartItems[i].participantIdsFromParent = _participantIds;
                    this.cartItems[i].CartItemId__c = this.cartItems[i].cartItem.cartItemId;
                }

                //let message = {remaningCount: totalQuantity, CountToSubstract: 0};

                /*publishing event*/
               // publish(this.messageContext, messageChannel, message);

                this._cartItemCount = Number(
                    result.cartSummary.totalProductCount
                );

                

                this.currencyCode = result.cartSummary.currencyIsoCode;
                this.isCartDisabled = LOCKED_CART_STATUSES.has(
                    result.cartSummary.status
                );
                
                if(this.isCartDisabled){
                    
                }
                //console.log('this.cartItems : ', this.cartItems);
            })
            .catch((error) => {
                const errorMessage = error.body.message;
                this.cartItems = undefined;
                this.isCartClosed = isCartClosed(errorMessage);
            });
    }

    /**
     * Handles a "click" event on the sort menu.
     *
     * @param {Event} event the click event
     * @private
     */
    handleChangeSortSelection(event) {
        this.sortParam = event.target.value;
        // After the sort order has changed, we get a refreshed list
        this.updateCartItems();
    }

    /**
     * Helper method to handle updates to cart contents by firing
     *  'cartchanged' - To update the cart badge
     *  'cartitemsupdated' - To notify any listeners for cart item updates (Eg. Cart Totals)
     *
     * As of the Winter 21 release, Lightning Message Service (LMS) is not available in B2B Commerce for Lightning.
     * These samples make use of the [pubsub module](https://github.com/developerforce/pubsub).
     * In the future, when LMS is supported in the B2B Commerce for Lightning, we will update these samples to make use of LMS.
     *
     * @fires CartContents#cartchanged
     * @fires CartContents#cartitemsupdated
     *
     * @private
     */
    handleCartUpdate() {
        // Update Cart Badge
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
        // Notify any other listeners that the cart items have updated
        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
    }

    /**
     * Handler for the 'quantitychanged' event fired from cartItems component.
     *
     * @param {Event} evt
     *  A 'quanitychanged' event fire from the Cart Items component
     *
     * @private
     */
    handleQuantityChanged(evt) {
        const { cartItemId, quantity } = evt.detail;
        updateCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId,
            cartItem: { quantity }
        })
            .then((cartItem) => {
                this.updateCartItemInformation(cartItem);
            })
            .catch((e) => {
                // Handle quantity update error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    /**
     * Handler for the 'singlecartitemdelete' event fired from cartItems component.
     *
     * @param {Event} evt
     *  A 'singlecartitemdelete' event fire from the Cart Items component
     *
     * @private
     */
    handleCartItemDelete(evt) {
        const { cartItemId } = evt.detail;
        deleteCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId
        })
            .then(() => {
                this.removeCartItem(cartItemId);
            })
            .catch((e) => {
                // Handle cart item delete error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    /**
     * Handler for the 'click' event fired from 'Clear Cart' button
     * We want to delete the current cart, create a new one,
     * and navigate to the newly created cart.
     *
     * @private
     */
    handleClearCartButtonClicked() {
        // Step 1: Delete the current cart
        deleteCart({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId
        })
            .then(() => {
                // Step 2: If the delete operation was successful,
                // set cartItems to undefined and update the cart header
                this.cartItems = undefined;
                this._cartItemCount = 0;
            })
            .then(() => {
                // Step 3: Create a new cart
                return createCart({
                    communityId,
                    effectiveAccountId: this.effectiveAccountId
                });
            })
            .then((result) => {
                // Step 4: If create cart was successful, navigate to the new cart
                this.navigateToCart(result.cartId);
                this.handleCartUpdate();
            })
            .catch((e) => {
                // Handle quantity any errors properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    /**
     * Given a cart id, navigate to the record page
     *
     * @private
     * @param{string} cartId - The id of the cart we want to navigate to
     */
    navigateToCart(cartId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: cartId,
                objectApiName: 'WebCart',
                actionName: 'view'
            }
        });
    }

    /**
     * Given a cartItem id, remove it from the current list of cart items.
     *
     * @private
     * @param{string} cartItemId - The id of the cart we want to navigate to
     */
    removeCartItem(cartItemId) {
        const removedItem = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId === cartItemId
        )[0];
        const quantityOfRemovedItem = removedItem
            ? removedItem.cartItem.quantity
            : 0;
        const updatedCartItems = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId !== cartItemId
        );
        // Update the cartItems with the change
        this.cartItems = updatedCartItems;
        // Update the Cart Header with the new count
        this._cartItemCount -= Number(quantityOfRemovedItem);
        // Update the cart badge and notify any other components interested in this change
        this.handleCartUpdate();
    }

    /**
     * Given a cartItem id, remove it from the current list of cart items.
     *
     * @private
     * @param{CartItem} cartItem - An updated cart item
     */
    updateCartItemInformation(cartItem) {
        // Get the item to update the product quantity correctly.
        let count = 0;
        const updatedCartItems = (this.cartItems || []).map((item) => {
            // Make a copy of the cart item so that we can mutate it
            let updatedItem = { ...item };
            if (updatedItem.cartItem.cartItemId === cartItem.cartItemId) {
                updatedItem.cartItem = cartItem;
            }
            count += Number(updatedItem.cartItem.quantity);
            return updatedItem;
        });
        // Update the cartItems List with the change
        this.cartItems = updatedCartItems;
        // Update the Cart Header with the new count
        this._cartItemCount = count;
        // Update the cart badge and notify any components interested with this change
        this.handleCartUpdate();
        //this.getCreatedParticipantList();
    }

    /**
     * Cancel the payment of the cart based on the cartId
     */
    cancelPayment(){
        console.log('cancelPayment : ' , this.recordId);
        updateCheckoutStatus({
            cartId:this.recordId
        })
        .then(result => {
            console.log('result : ' , result);
            location.reload();
        })
        .catch(error => {
            console.log('error ' , error);
        });
    }

    deleteParticipantIds(event){
        console.log(' event.detail.cartItemIds : ' ,  event.detail.cartItemIds);
        
        if(event.detail.checkboxvalue){
            this.deleteparticipantIds.push(event.detail.participantvalue);
            
        }else if(!event.detail.checkboxvalue){
            for(var i = 0; i <this.deleteparticipantIds.length; i++){
                if(event.detail.participantvalue == this.deleteparticipantIds[i]){
                    this.deleteparticipantIds.splice(i, 1);
                }
            }
        }

        this.emptyList = (this.deleteparticipantIds!='')?false:true;
        console.log(' this.deleteparticipantIds : ' ,  this.deleteparticipantIds);
    }

    deleteParticipants(event){
        console.log('cancelPayment : ' , this.recordId);
        deleteParticipant({
            listParticipantIds:this.deleteparticipantIds
        })
        .then(result => {
            console.log('result : ' , result);
            location.reload();
        })
        .catch(error => {
            console.log('error ' , error);
        });
    }
}