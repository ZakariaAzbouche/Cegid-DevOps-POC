import { LightningElement, api, track } from 'lwc';
import searchLookUp from '@salesforce/apex/CustomerRequestsFormController.searchLookUp';

export default class CustomerRequestsCustomLookup extends LightningElement {

    @api classes;
    @api label;
    @api placeholder;
    @api value;

    @track options = [];
    @track mapoptions= new Map();
    @track typingTimer;
    @track isFocussed = false;
    @track isOpen = false;

    filteredOptions = [];
    domElement;

    constructor() {
        super();
        this.handleOutsideClick = this.handleOutsideClick.bind(this);
    }

    connectedCallback() {
        document.addEventListener('click', this.handleOutsideClick);
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleOutsideClick);
    }

    searchSOSL(filterText) {
        if(filterText.length > 2){
            searchLookUp({searchTerm: filterText})
            .then(result =>{
                var tempjson = JSON.parse(JSON.stringify(result)); 
                var tempOptions = [];
                var tempMapOptions = new Map();
                tempjson.forEach(function(item){
                    tempOptions.push({label:item.name,value:item.erpnumber});
                    tempMapOptions.set(item.erpnumber, item.id);
                })
                this.options = [...tempOptions];
                this.mapoptions = tempMapOptions;
                this.filteredOptions = this.options;

            })
            .catch(error =>{
                console.log(error);
            })
        } else{
            this.value = filterText;
        }
    }

    filterOptions(event) {
        const filterText = event.detail.value;
        clearTimeout(this.typingTimer);
        this.typingTimer = setTimeout(() => {
            this.searchSOSL(filterText);
        }, 300);
        
    }

    handleSelectOption(event) {
        this.value = event.currentTarget.dataset.label;
        var tempMapOptions = this.mapoptions; 
        const custEvent = new CustomEvent(
            'selectoption', {
                detail: {
                    label: event.currentTarget.dataset.value,
                    value: tempMapOptions.get(event.currentTarget.dataset.value)
                }
            }
        );
        this.dispatchEvent(custEvent);
        this.isFocussed = false;
        this.isOpen = false;
    }

    get noOptions() {
        return this.filteredOptions.length === 0;
    }

    get dropdownClasses() {
        
        let dropdownClasses = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        
        if (this.isOpen) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    handleOutsideClick(event) {

        if ((!this.isFocussed) && (this.isOpen)) { 

            let domElement = this.template.querySelector('div[data-id="resultBox"]');

            if (domElement && !domElement.contains(event.target)) {
                this.isOpen = false;
            }
        }
        if(!this.value || this.value.length < 3){
            this.filteredOptions = []; 
            this.value = null; 
            const custEvent = new CustomEvent(
                'selectoption', {
                    detail: {
                        label: null,
                        value: null
                    }
                }
            );
            this.dispatchEvent(custEvent);
        }
    }

    handleFocus() {
        this.isFocussed = true;
        this.isOpen = true;
    }

    handleBlur() {
        this.isFocussed = false;
    }
}