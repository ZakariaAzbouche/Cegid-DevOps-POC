import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
 
export default class B2bProductObjectifpedagogique extends NavigationMixin (LightningElement) {
    productDetail;
    @api buttonLink;

    // return blocks in html
    unescapeHTML(str) {
        return String(str)
            .replace(/&amp;/g,'&')
            .replace(/&lt;/g,'<')
            .replace(/&gt;/g,'>')
            .replace(/&quot;/g,'"');
    }

    @api
    get productDetailFields() {
        return this.productDetail;
    }

    set productDetailFields(value) {
        if(value) {
            this.productDetail = this.unescapeHTML(value);
        }
    }

    connectedCallback() {
        console.log('rdc: ', this.productDetail);
    }
    
    handleURL(){
        console.log('handleUrltest : ' ,this.buttonLink);
        let finalUrl;
        const substring = "https://";

        if(this.buttonLink.includes(substring)){
           finalUrl =this.buttonLink;
        }else{
            finalUrl ="https://"+this.buttonLink;
        }
        
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": finalUrl
            }
        });
    }

}