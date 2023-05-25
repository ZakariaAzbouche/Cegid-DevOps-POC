import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { resolve } from 'c/cmsResourceResolver';
import communityId from '@salesforce/community/Id';
import getCartItemsDetails from '@salesforce/apex/B2B_OrderRecap.getRecapDataV1';
//import isPromoCodeValide from '@salesforce/apex/B2B_OrderRecap.checkPromoCode';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

// Import custom labels
import cgvurl from '@salesforce/label/c.b2bCGVUrl';

export default class B2bOrderRecap extends NavigationMixin(LightningElement) {
    @api getCartIds;
    @api recordId;
    @api effectiveAccountId;
    pageParam = null;
    sortParam = 'CreatedDateDesc';
    displayItems = [];
    @track cartSummary = {};
    promoCode;
    buttoncheck = true;
    _connectedResolver;
    displayErrorMsg;
   

    @api
    proceedtoNext() {
        //console.log('Next');
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    /**
     * This lifecycle hook fires when this component is inserted into the DOM.
     */
    connectedCallback(){
        // Initialize 'displayItems' list as soon as the component is inserted in the DOM.
        this.getCartItemsWrapper();
        this._connectedResolver();
    }

    // Expose the labels to use in the template.
    label = {
        cgvurl
    };

    getCartItemsWrapper(){
        getCartItemsDetails({
            listCartIds:this.getCartIds,
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam
        })
        .then(result => {
           
            this.displayItems = result;
            this.cartSummary = result[0].cartSummary;
            console.log(' this.cartSummary   : ' ,  this.cartSummary);
            //console.log(' this.displayItems   : ' ,  this.displayItems);
            const generatedUrls = [];
            //console.log('this.displayItems : ' , this.displayItems);
            for (var i = 0; i <this.displayItems.length; i++) {
                this.displayItems[i].productImageUrl = resolve(
                    this.displayItems[i].cartItemObj.cartItem.productDetails.thumbnailImage.url
                );
            }

            for(var i = 0; i <this.displayItems.length; i++){
                for(var j = 0; j <this.displayItems[i].listParticipants.length; j++){
                    this.displayItems[i].listParticipants[j].fullname = this.displayItems[i].listParticipants[j].firstName + ' '+
                    this.displayItems[i].listParticipants[j].lastName;
                    //console.log(' this.displayItems  part  : ' );
                }
                
            }

            console.log(' this.displayItems  part  : ' ,  this.displayItems);

        })
        .catch(error => {
           // console.log('error ' , error);
        });
    }

    PopulateCode(event){
        //console.log('promoCode : ', event.target.value);
        this.promoCode = event.target.value;
        if(this.promoCode == null || this.promoCode ==''){
            this.displayErrorMsg = '';
        }
    }

    validateCode(){

        if(this.promoCode != null && this.promoCode !=''){
            this.displayErrorMsg = 'Code promotionnel invalide';
        }else{
            this.displayErrorMsg = '';
        }
        // isPromoCodeValide({
        //     promoInput:this.promoCode,
        //     listCartIds:this.getCartIds,
        //     communityId: communityId,
        //     effectiveAccountId: this.resolvedEffectiveAccountId,
        //     activeCartOrId: this.recordId,
        //     pageParam: this.pageParam,
        //     sortParam: this.sortParam
        // })
        // .then(result => {
        //    //console.log('result Promo Code : ' , result);
        //    this.cartSummary = result;
        // })
        // .catch(error => {
        //     //console.log('this.promoCode :', this.promoCode);
        //     if(this.promoCode != null && this.promoCode !=''){
        //         this.displayErrorMsg = 'Code promotionnel invalide';
        //     }else{
        //         this.displayErrorMsg = '';
        //     }
           
        //     //let inputdiscount=this.template.querySelector(".discount"); 
        //     //inputdiscount.setCustomValidity(error.body.message);
        //     //console.log('error : ' , error.body.message);
        // });
    }

    verifycheckbox(event){
        //console.log('verifycheckbox : ' , event.target.checked);
        if(event.target.checked){
            this.buttoncheck = false;
        }else{
            this.buttoncheck = true;
        }
    }

        /**
     * Handler for the 'click' event fired from 'contents'
     *
     * @param {Object} evt the event object
     */
    handleProductDetailNavigation(evt) {
        console.log('Test');
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
     * A Promise that is resolved when the component is connected to the DOM.
     *
     * @type {Promise}
     * @private
     */
     _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

}