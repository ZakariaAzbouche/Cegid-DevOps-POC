import { LightningElement, api } from 'lwc';
 
export default class AccMassAssignmentPicklistItem extends LightningElement {

    @api item;

    constructor () {
        super();
    }
    connectedCallback () {
        this._item =  JSON.parse(JSON.stringify (this.item));
    }
    /**
     * @author Jeetesh - Comforth 
     * @createddate - 05/06/2020
     * @description - get class from css Picklist html
     */    
    get itemClass () {
        return 'slds-listbox__item ms-list-item' + (this.item.selected ? ' slds-is-selected' : '');
    }

    /**
     * @author Jeetesh - Comforth 
     * @createddate - 05/06/2020
     * @description - retrieving values selected from picklist
     */    
    onItemSelected (event) {
        const evt = new CustomEvent ('items', { detail : {'item' :this.item, 'selected' : !this.item.selected }});
        this.dispatchEvent (evt);
        event.stopPropagation();
    }
}