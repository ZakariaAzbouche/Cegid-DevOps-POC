import { LightningElement, api, track  } from 'lwc';
 
export default class AccMassAssignmentMultiPicklist extends LightningElement {

    @api label = ''; //Name of the dropDown
    @api maxselected = 5; //Max selected item display
    @api options; // List of items to display
    @api showfilterinput = false; //show filterbutton
    @api showrefreshbutton = false; //show the refresh button
    @api showclearbutton = false; //show the clear button
    @api comboplaceholder = 'Select multiple values';

    @track _initializationCompleted = false;
    @track _selectedItems = 'Select a value';
    @track _filterValue;
    @track _mOptions;

    constructor() {
        super();
        this._filterValue = '';

    }

    connectedCallback() {
        this.initArray(this);
    }

  /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - Initialing picklist 
    */
    renderedCallback() {
        let self = this;
        if (!this._initializationCompleted) {
            this.template.querySelector ('.ms-input').addEventListener ('click', function (event) {
                //console.log ('multipicklist clicked');
                self.onDropDownClick(event.target);
                event.stopPropagation ();
            });
            this.template.addEventListener ('click', function (event) {
                //console.log ('multipicklist-1 clicked');
                event.stopPropagation ();
            });
            document.addEventListener ('click', function (event) {
                //console.log ('document clicked');
                self.closeAllDropDown(event.target);
            });
            this._initializationCompleted = true;
            this.setPickListName ();
        }
    }


  /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - Displaying values selected from picklist
    */
    handleItemSelected(event) {
        let self = this;
        this._mOptions.forEach(function (eachItem) {
            if (eachItem.key == event.detail.item.key) {
                eachItem.selected = event.detail.selected;
                return;
            }
        });
        this.setPickListName();
        this.onItemSelected();
    }
  /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - Enable filtering of picklist values 
    */
    filterDropDownValues(event) {
        this._filterValue = event.target.value;
        this.updateListItems(this._filterValue);
    }
  /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - closing the dropdown picklist
    */
    closeAllDropDown() {
        Array.from(this.template.querySelectorAll('.ms-picklist-dropdown')).forEach(function (node) {
            node.classList.remove('slds-is-open');
        });
    }

    /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - opening the dropdown picklist
    */
    onDropDownClick(dropDownDiv) {
        let classList = Array.from(this.template.querySelectorAll('.ms-picklist-dropdown'));
        if (!classList.includes("slds-is-open")) {
            this.closeAllDropDown();
            Array.from(this.template.querySelectorAll('.ms-picklist-dropdown')).forEach(function (node) {
                node.classList.add('slds-is-open');
            });
        } else {
            this.closeAllDropDown();
        }
    }
    /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - refreshing picklist values 
    */
    onRefreshClick(event) {
        this._filterValue = '';
        this.initArray(this);
        this.updateListItems('');
        this.onItemSelected();
    }
    /**
     * @author Jeetesh - Comforth 
     * @createddate - 05/06/2020
     * @description - clearing all picklist values selected
     */
    @api
    reset() {
        //console.log('multiSelect Reset', this._selectedItems);
        this._filterValue = '';
        this._selectedItems = this.comboplaceholder;
        
        // remove selected
        let _options = JSON.parse(JSON.stringify(this.options));
        _options.forEach(item => {
            item.selected = false;
        });
        this.options = _options;
        this.initArray(this);
        
    }

    /**
     * @author Jeetesh - Comforth 
     * @createddate - 05/06/2020
     * @description - initialising and displaying picklist values
     */
    initArray(context) {
        context._mOptions = new Array();
        context.options.forEach(function (eachItem) {
            context._mOptions.push(JSON.parse(JSON.stringify(eachItem)));
        });
    }
   /**
    * @author Jeetesh - Comforth 
    * @createddate - 05/06/2020
    * @description - method for updating list items in picklist
    */
    updateListItems(inputText) {
        Array.from(this.template.querySelectorAll('c-stf-picklist-item')).forEach(function (node) {
            if (!inputText) {
                node.style.display = "block";
            } else if (node.item.value.toString().toLowerCase().indexOf(inputText.toString().trim().toLowerCase()) != -1) {
                node.style.display = "block";
            } else {
                node.style.display = "none";
            }
        });
        this.setPickListName();
    }

  /**
   * @author Jeetesh - Comforth 
   * @createddate - 05/06/2020
   * @description - setting names and number of options selected in picklist
   */
    setPickListName() {
        let selecedItems = this.getSelectedItems();
        let selections = '';
        if (selecedItems.length < 1) {
            selections = this.comboplaceholder;
        } else if (selecedItems.length > this.maxselected) {
            selections = selecedItems.length + ' Options Selected';
        } else {
            selecedItems.forEach(option => {
                selections += option.label + ',';
            });
        }
        this._selectedItems = selections;
    }
 /**
  * @author Jeetesh - Comforth 
  * @createddate - 05/06/2020
  * @description - get selected values from picklist
  */
    @api
    getSelectedItems() {
        let resArray = new Array();
        this._mOptions.forEach(function (eachItem) {
            if (eachItem.selected) {
                resArray.push(eachItem);
            }
        });
        return resArray;
    }
 /**
  * @author Jeetesh - Comforth 
  * @createddate - 05/06/2020
  * @description - method for retrieving details on item selected
  */
    onItemSelected() {
        const evt = new CustomEvent('itemselected', { detail: this.getSelectedItems() });
        this.dispatchEvent(evt);
    }
}