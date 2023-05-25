import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import B2B_RESSOURCES from '@salesforce/resourceUrl/B2B_Ressources';
import updateCheckoutStatus from '@salesforce/apex/B2BCartControllerSample.updateCartStatus';
import { getRecord } from 'lightning/uiRecordApi';//VMO 20211006: Moving js code from b2bProductCalender to parent component as there was a bug where Add To Cart was not clickable on products which do not have any training session
import PRODUCT_CATEGORY_FIELD from '@salesforce/schema/Product2.Category__c';//VMO 20211006: Moving js code from b2bProductCalender to parent component as there was a bug where Add To Cart was not clickable on products which do not have any training session
import getRelatedProducts from '@salesforce/apex/B2B_AssociatedProducts.getProducts';//VMO 20211008: Moving js code from b2bProductCalender to parent component and will pass result to to the child b2bProductCalender
import getCategoryLabel from '@salesforce/apex/B2B_AssociatedProducts.getProductCategoryLabel';//VMO 20211008: Get Category Label instead of API name

/**
 * CheckOut Labels;
 */
import paymentPart1 from '@salesforce/label/c.b2bCartProcessing';
import paymentPart2 from '@salesforce/label/c.b2bCancelPayment';
import noSessionsAvailable from '@salesforce/label/c.b2b_MSG_ProductCalendar_NoSessions';//VMO 20211129
import sessionsAvailable from '@salesforce/label/c.b2b_MSG_ProductCalendar_SelectSessions';//VMO 20211129
import quantityExceeded from '@salesforce/label/c.b2b_MSG_ProductDetailsDisplay_QuanityExceedsAvailability';//VMO 20211129
import priceUnvailable from '@salesforce/label/c.b2b_MSG_ProductDetailsDisplay_PriceNotAvailable';//VMO 20211129
import totalPriceUnvailable from '@salesforce/label/c.b2b_MSG_ProductDetailsDisplay_TotalPriceNotAvailable';//VMO 20211129
import outOfStock from '@salesforce/label/c.b2b_MSG_ProductDetailsDisplay_OutOfStock';//VMO 20211129

// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

const fields = [PRODUCT_CATEGORY_FIELD];//VMO 20211006

const unitaryProductCategoryCode_1 = '301';//VMO 20211008
const unitaryProductCategoryCode_2 = '310';//VMO 20211008

/**
 * An organized display of product information.
 *
 * @fires ProductDetailsDisplay#addtocart
 * @fires ProductDetailsDisplay#createandaddtolist
 */
export default class ProductDetailsDisplay extends NavigationMixin(
    LightningElement
) {
    @api recordId;//VMO 20211001

    /**
     * Get CartId
     */
     @api  cartId;
    /**Labels */
    label = {
        paymentPart1,
        paymentPart2,
        noSessionsAvailable,//VMO 20211129
        sessionsAvailable,//VMO 20211129
        quantityExceeded,//VMO 20211129
        priceUnvailable,//VMO 20211129
        totalPriceUnvailable,//VMO 20211129
        outOfStock//VMO 20211129
    }

    /**
     * Display total price * Quantity on the layout
     */
    layoutTotalPrice


    /**
     * Contains static resources for B2B Figma layout
     */
    icons = {
      messaging: B2B_RESSOURCES + '/icons/cegid--messaging.png',
      print: B2B_RESSOURCES + '/icons/cegid--print.png',
      plane: B2B_RESSOURCES + '/icons/cegid--ico-plane.png',
      add: B2B_RESSOURCES + '/icons/cegid--plus-circle.png',
    };

    /**
     * get PDP background image on right side
     */
    get getDescriptionBackgroundImage() {
        return `background-image: url(${B2B_RESSOURCES + '/images/pdp-background-cropped.png'});`;
    }

    /**
     * An event fired when the user indicates the product should be added to their cart.
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event ProductDetailsDisplay#addtocart
     * @type {CustomEvent}
     *
     * @property {string} detail.quantity
     *  The number of items to add to cart.
     *
     * @export
     */

    /**
     * An event fired when the user indicates the product should be added to a new wishlist
     *
     * Properties:
     *   - Bubbles: false
     *   - Composed: false
     *   - Cancelable: false
     *
     * @event ProductDetailsDisplay#createandaddtolist
     * @type {CustomEvent}
     *
     * @export
     */

    /**
     * A product image.
     * @typedef {object} Image
     *
     * @property {string} url
     *  The URL of an image.
     *
     * @property {string} alternativeText
     *  The alternative display text of the image.
     */

    /**
     * A product category.
     * @typedef {object} Category
     *
     * @property {string} id
     *  The unique identifier of a category.
     *
     * @property {string} name
     *  The localized display name of a category.
     */

    /**
     * A product price.
     * @typedef {object} Price
     *
     * @property {string} negotiated
     *  The negotiated price of a product.
     *
     * @property {string} currency
     *  The ISO 4217 currency code of the price.
     */

    /**
     * A product field.
     * @typedef {object} CustomField
     *
     * @property {string} name
     *  The name of the custom field.
     *
     * @property {string} value
     *  The value of the custom field.
     */

    /**
     * An iterable Field for display.
     * @typedef {CustomField} IterableField
     *
     * @property {number} id
     *  A unique identifier for the field.
     */

    /**
     * Gets or sets which custom fields should be displayed (if supplied).
     *
     * @type {CustomField[]}
     */
    @api
    customFields;

    /**
     * Gets or sets whether the cart is locked
     *
     * @type {boolean}
     */
    @api
    cartLocked = false;//VMO 20211013: Initialised to false, else it was undefined

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    @api
    description;

    /**
     * Gets or sets the product image.
     *
     * @type {Image}
     */
    @api
    image;

    /**
     * Gets or sets whether the product is "in stock."
     *
     * @type {boolean}
     */
    @api
    inStock = false;

    /**
     * Gets or sets the name of the product.
     *
     * @type {string}
     */
    @api
    name;

    /**
     * Gets or sets the price - if known - of the product.
     * If this property is specified as undefined, the price is shown as being unavailable.
     *
     * @type {Price}
     */
    @api
    price;

    /**
     * Gets or sets teh stock keeping unit (or SKU) of the product.
     *
     * @type {string}
     */
    @api
    sku;

    _invalidQuantity = false;
    @track _quantityFieldValue = 1;//VMO 20211006: Added @track
    @track totalPrice;//VMO 20211006: Added totalPrice which is calculated when quantity changes
    @track sessionCode;//VMO 20211006" ADD TO CART should be disabled if this is empty for Unitary Products
    @track sessionDate;//VMO 20211006
    @track sessionAvailability = 99;//VMO 20211008
    @track productCategoryValue;//VMO 20211008
    @track WSSessionResult;//VMO 20211008
    b2bProductCalenderTitle;//VMO 20211008
    b2bProductCalenderNoSessions = false;//VMO 20211020
    @track quantityExceedsAvailability = false;//VMO 20211012
    @track quantityNotWholeNumber = false;
    @track quantityValue;//VMO 20211012
    @track isUnitaryProduct = false;//VMO 20211012
    _categoryPath;
    categoryLabel;
    _resolvedCategoryPath = [];
    _serviceTerm;
    _duration;
    _realizationCondition;
    _category;
    storePreRequisite;
    storeEducationalObjetive;
    storeIncludedThemes;
    storeButtonLink;

    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });
    

    connectedCallback() {
        this._resolveConnected();
        //console.log('this.price.negotiated: ', this.price.negotiated);

        /* var delayInMilliseconds = 1000; //1 second

        setTimeout(function() {
            this.totalPrice = this.price.negotiated;//VMO 20211006: Set total price
        }, delayInMilliseconds); */

        this.totalPrice = this.price.negotiated;//VMO 20211006: Set total price

        this.quantityValue = 1;//VMO 20211012: Set quantity value to 1 on component initialisation

        this.getProductCategory();

        this.getSessionResult();//VMO 20211008
    }

    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }

    displaySession = false;

    //VMO 20211006: Moving js code from b2bProductCalender to parent component as there was a bug where Add To Cart was not clickable on products which do not have any training session (non-unitary)
    @wire(getRecord, { recordId : '$recordId', fields : fields })
    wiredProduct({ data, error }) {
        if(data){
            this.productCategoryValue = data.fields.Category__c.value;
            if(data.fields.Category__c.value === unitaryProductCategoryCode_1 || data.fields.Category__c.value === unitaryProductCategoryCode_2){
                this.isUnitaryProduct = true;
            }else{
                this.isUnitaryProduct = false;
            }
            if(this.inStock && this.isUnitaryProduct){
                this.displaySession = true;
            }
        }else if(error) {
            //console.log(error);
        }
    }
    //VMO 20211006: Moving js code from b2bProductCalender to parent component as there was a bug where Add To Cart was not clickable on products which do not have any training session (non-unitary)

    getProductCategory(){
        getCategoryLabel({
            productId   :   this.recordId
        })
        .then(result => {
           this.categoryLabel = result.Category__c;
            
        })
        .catch(error => {
            //c/accMassAssignmentconsole.log('error getSessionResult: ' , error);
        });
    }

    getSessionResult(){
        //if(this.productCategoryValue === unitaryProductCategoryCode_1 || this.productCategoryValue === unitaryProductCategoryCode_2){
            getRelatedProducts({
                productId   :   this.recordId,
                recType     :   null
            })
            .then(result => {
                //console.log('pdetaildisplay WS result: ', result);
                if(result){
                    if(result.relatedProductSessionInfo.Result.sessions.length == 0){
                        this.b2bProductCalenderTitle = this.label.noSessionsAvailable/* 'Nous sommes désolés mais ce produit n\'est pas ouvert à la vente en ce moment.' */;
                        this.b2bProductCalenderNoSessions = true;
                    }else{
                        this.b2bProductCalenderTitle = this.label.sessionsAvailable/* 'Merci de selectionner la date de votre session de formation' */;
                        this.WSSessionResult = result;
                        this.b2bProductCalenderNoSessions = false;
                    }
                }else{
                    this.b2bProductCalenderTitle = this.label.noSessionsAvailable;
                    this.b2bProductCalenderNoSessions = true;
                }
                
            })
            .catch(error => {
                console.log(error);
            });
        //}
    }

    /**
     * Gets or sets the ordered hierarchy of categories to which the product belongs, ordered from least to most specific.
     *
     * @type {Category[]}
     */
    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {
        this.totalPrice = this.price.negotiated;
        return ((this.price || {}).negotiated || '').length > 0;
    }

    /**
     * Gets whether add to cart button should be displabled
     *
     * Add to cart button should be disabled if quantity is invalid,
     * if the cart is locked, or if the product is not in stock
     */
    get _isAddToCartDisabled() {
        //return this._invalidQuantity || this.cartLocked || !this.inStock;//VMO 20211008: Updated flag as below to accomodate sessions

        if(this.cartLocked === undefined){//VMO 20211013
            this.cartLocked = false;//VMO 20211013
        }//VMO 20211013

        //console.log('invalidQuantity: ', this._invalidQuantity, 'cartLocked: ', this.cartLocked, 'inStock: ', !this.inStock, 'isUnitaryProduct: ', this.isUnitaryProduct, 'sessionCode: ', !this.sessionCode, 'quantityExceedsAvailability: ', this.quantityExceedsAvailability);
        return this._invalidQuantity || this.cartLocked || !this.inStock || ((this.isUnitaryProduct && !this.sessionCode) || this.quantityExceedsAvailability);
    }

    handleQuantityChange(quantityValue, isValid) {
        //var quantityInputElement = this.template.querySelector('[data-id="quantityInput"]');//VMO20211008
        //console.log('Number.isInteger(event.target.value): ', Number.isInteger(Number(quantityValue)));
        //console.log('handleQuantityChange');
        //console.log('quantityValue.validity.valid: ', quantityValue.validity.valid);
        if (Number.isInteger(Number(quantityValue)) && isValid) {
            this._invalidQuantity = false;
            this.quantityNotWholeNumber = false;
            this._quantityFieldValue = quantityValue;
            //this.totalPrice = this.price.negotiated * event.target.value;//VMO 20211006: Calculate totalPrice
        } else {
            this._invalidQuantity = true;
            this.quantityNotWholeNumber = true;
        }
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires ProductDetailsDisplay#addtocart
     * @private
     */
    notifyAddToCart() {
        let quantity = this._quantityFieldValue;
        let sessionCode = this.sessionCode;
        let sessionDate = this.sessionDate;

        this.dispatchEvent(
            new CustomEvent('addtocart', {
                detail: {
                    quantity : quantity,
                    sessionCode : sessionCode,
                    sessionDate : sessionDate
                }
            })
        );
    }

    /**
     * Emits a notification that the user wants to add the item to a new wishlist.
     *
     * @fires ProductDetailsDisplay#createandaddtolist
     * @private
     */
    notifyCreateAndAddToList() {
        this.dispatchEvent(new CustomEvent('createandaddtolist'));
    }

    /**
     * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
     *
     * @param {Category[]} newPath
     *  The new category "path" for the product.
     */
    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );

        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );

                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                this._resolvedCategoryPath = levels;
            });
    }

    /**
     * Gets the iterable fields.
     *
     * @returns {IterableField[]}
     *  The ordered sequence of fields for display.
     *
     * @private
     */
    get _displayableFields() {
        // Enhance the fields with a synthetic ID for iteration.
        //console.log('customFields prodDetailsDisplay : ', JSON.stringify(this.customFields));
        for(let i = 0; i < this.customFields.length; i++){
            if(this.customFields[i].name === 'Duration__c'){
                this._duration = this.customFields[i].value % 1 === 0 ? (this.customFields[i].value | 0) : this.customFields[i].value;//VMO 20211004: If number is whole remove decimal
            }
            if(this.customFields[i].name === 'Realization_Conditions__c'){
                this._realizationCondition = this.customFields[i].value;
            }
            if(this.customFields[i].name === 'Category__c'){
                //console.log('Category__c prodDetailsDisplay : ', JSON.stringify(this.customFields[i]));
                this._category = this.customFields[i].value;
            }
            if(this.customFields[i].name === 'Service_Term__c'){
                this._serviceTerm = this.customFields[i].value;
            }
            if(this.customFields[i].name === 'Store_Pre_requisite_public__c'){
                this.storePreRequisite = this.customFields[i].value;
            }
            if(this.customFields[i].name === 'Store_Pre_requisite_public__c'){
                this.storePreRequisite = this.customFields[i].value;
            }
            if(this.customFields[i].name === 'Store_Educational_objective__c'){
                this.storeEducationalObjetive = this.customFields[i].value;
            }
            if(this.customFields[i].name === 'Store_Included_Themes__c'){
                this.storeIncludedThemes = this.customFields[i].value;
               
            }
            if(this.customFields[i].name === 'Storelinktoeducationalobjective_file__c'){
                this.storeButtonLink = this.customFields[i].value;
                //console.log('this.storeButtonLink button link ' , this.customFields[i].value);
            }
        }
        // return (this.customFields || []).map((field, index) => ({
        //     ...field,
        //     id: index
        // }));
    }

    /* renderedCallback(){
        var value = this.template.querySelector('price');
        console.log('value: ', value);
        const priceStyle = document.createElement('style');
        priceStyle.innerText = `.price-info .slds-form-element__label {
            background-color: #fffefb;
        }`;
        this.template.querySelector('lightning-formatted-number').appendChild(priceStyle);
    } */

        /**
     * Cancel the payment of the cart based on the cartId
     */
    cancelPayment(){
        //.log('cancelPayment : ' , this.cartId);
        updateCheckoutStatus({
            cartId:this.cartId
        })
        .then(result => {
            //console.log('result : ' , result);
            location.reload();
        })
        .catch(error => {
            //console.log('error ' , error);
        });
    }

    handleEventPopulateSession(event){
        //console.log(event.detail.session);
        this.sessionCode = event.detail.sessionCode;
        this.sessionDate = event.detail.sessionDate;
        this.sessionAvailability = event.detail.sessionAvailability;

        this.handleQuantityOverQuota(this.quantityValue, this.sessionAvailability);
    }

    updateTotalvalue(event){
        //console.log('updateTotalvalue');

        this.quantityValue = event.target.value;

        let isValid = event.target.validity.valid;

        //console.log('valid: ', isValid);

        this.totalPrice = this.price.negotiated * event.target.value;

        this.handleQuantityChange(this.quantityValue, isValid);

        this.handleQuantityOverQuota(this.quantityValue, this.sessionAvailability);
    }

    get quantityClassName(){
        return this.quantityExceedsAvailability ? 'slds-has-error' : '';
    }

    handleQuantityOverQuota(quantityValue, sessionAvailability){
        //console.log('quantityValue: ', quantityValue, 'sessionAvailability', sessionAvailability);
        if(Number(quantityValue) > Number(sessionAvailability)){
            this.quantityExceedsAvailability = true;
        }else{
            this.quantityExceedsAvailability = false;
        }
    }
}