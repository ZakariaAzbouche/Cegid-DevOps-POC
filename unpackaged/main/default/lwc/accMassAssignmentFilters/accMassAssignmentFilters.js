import { LightningElement, track, wire, api} from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FIELD_Nature from '@salesforce/schema/Account.Nature__c';
import FIELD_RetailSeg from '@salesforce/schema/Account.Retail_Segmentation__c';
import FIELD_Expertise from '@salesforce/schema/Account_Expertise__c.Expertise__c';
import FIELD_Mode from '@salesforce/schema/Account_Expertise__c.Mode_OP_OD__c';
import FIELD_AccCoBusCoreBusiness from '@salesforce/schema/AccountCoreBusiness__c.CoreBusiness__c';
import FIELD_ProductLine from '@salesforce/schema/AccountCoreBusiness__c.ProductLine__c';
import FIELD_AccComCoreBusiness from '@salesforce/schema/Account_Competitor__c.Core_Business__c';
import FIELD_Competitor from '@salesforce/schema/Account_Competitor__c.Competitor__c';
 
export default class AccMassAssignmentFilters extends LightningElement {
    @track natureList;
    @track postalCodeList;
    @track retailSegList;
    @track expertiseList;
    @track modeList;
    @track accCoBusCoreBusinessList;
    @track productLineList;
    @track accComBusinessList;
    @track competitorList;

    @api natureValue;
    @api pcValue;
    @api retailSegValue;
    @api erpNumValue;
    @api expertiseValue;
    @api modeValue;
    @api accCoBusCoreBusinessValue;
    @api productLineValue;
    @api accComBusinessValue;
    @api competitorValue;
    @api annualRevMinValue;
    @api annualRevMaxValue;
    @api numStoresMinValue;
    @api numStoresMaxValue;
    @api employessNumMinValue;
    @api employessNumMaxValue;

    // Lookup fields   
    @api childObjectApiName = 'Target_Accounts__c';
    @api disabled = false;
    @api required = false;

    // Lookup Targeting Plan
    @api fieldTargetingPlan = 'Targeting_Plan__c';
    @api fieldTargetingPlanLabel = 'Targeting Plan';
    @api tarAccValue;

    // Lookup PAC/Account Owner
    @api fieldPacAccOwner = 'TECH_User__c';
    @api fieldPacAccOwnerLabel = 'PAC/Account Owner';
    @api pacAccOwnerValue;

    @api recordTypeId;
    @api objectName = 'Account';

    valueColPortal = [];
    error;

    /**
     * @author Jeetesh - Comforth
     * @createddate - 17/06/2020
     * @description - get Object's recordTypeId
     */
    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData({ error, data }) {
        if (data) {
            if (this.recordTypeId == null)
                this.recordTypeId = data.defaultRecordTypeId;

        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /************************ FIELD NATURE **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 17/06/2020
     * @description - getter method for Nature
     */
    get nature() {
        return this.natureList;
    }

    set nature(array) {
        this.natureList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 17/06/2020
     * @description - Retrieve picklist values for Nature__c from Account
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_Nature })
    wiredNatureValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.nature = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 17/06/2020
    * @description - Retrieve values selected from picklist Nature
    */
    handleOnItemSelectedNature(event) {
        if (event.detail) {
            this.natureValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.natureValue.push(eachItem.value);
            });
        }

        const selectedEventNature = new CustomEvent("naturevaluechange", {
            detail: this.natureValue
        });

        this.dispatchEvent(selectedEventNature);
    }  


    /********************* FIELD POSTAL CODE **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 17/06/2020
     * @description - Retrieve values from Postal Code
     */
    handleOnChangePostalCode(event) {
        this.pcValue = event.target.value;

        const selectedEventPostalCodeValue = new CustomEvent("postalcodevaluechange", {
            detail: this.pcValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventPostalCodeValue);
    }


   /********************* FIELD RETAIL SEGMENTATION **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 18/06/2020
     * @description - getter method for Retail Segmentation
     */
   get retailSeg() {
        return this.retailSegList;
    }

    set retailSeg(array) {
        this.retailSegList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 08/06/2020
     * @description - Retrieve picklist values for Retail_Segmentation__c from Account
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_RetailSeg })
    wiredRetailSegValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.retailSeg = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 18/06/2020
    * @description - Retrieve values selected from picklist Retail Segmentation
    */
    handleOnItemSelectedRetailSeg(event) {
        if (event.detail) {
            this.retailSegValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.retailSegValue.push(eachItem.value);
            });
        }

        const selectedEventRetailSeg = new CustomEvent("retailsegvaluechange", {
            detail: this.retailSegValue
        });

        this.dispatchEvent(selectedEventRetailSeg);
    }


    /********************* FIELD COLLABORATIVE PORTAL **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 17/06/2020
     * @description - Change handler for Collaborative Portal checkbox
     */
    get optionsColPortal() {
        return [
            { label: 'Yes', value: 'true' },
            { label: 'No', value: 'false' },
        ];
    }

    get selectedValues() {
        return this.value.join(',');
    }

    handleChangeColPortal(event) {
        this.valueColPortal = event.detail.value;
        
        const selectedEventColPortal = new CustomEvent("colportalvaluechange", {
            detail: this.valueColPortal
        });

        this.dispatchEvent(selectedEventColPortal);
    }


    /********************* FIELD TARGETING PLAN **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 18/06/2020
     * @description - Handle change in Targeting plan
     */
    handleChangeTargetingPlan(event) {
        // Create the event
        const selectedEventTargetingPlan = new CustomEvent('targetingplanchange', {
            detail: event.detail.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEventTargetingPlan);
    }

    @api isValidTargetingPlan() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }

    /********************* FIELD PAC/ACCOUNT OWNER **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Handle change in PAC/Account Owner
     */
    handleChangePacAccOwner(event) {
        // Create the event
        const selectedEventPacAccOwner = new CustomEvent('pacaccownerchange', {
            detail: event.detail.value
        });
        //dispatching the custom event
        this.dispatchEvent(selectedEventPacAccOwner);
    }

    @api isValidPacAccOwner() {
        if (this.required) {
            this.template.querySelector('lightning-input-field').reportValidity();
        }
    }

    /************************ FIELD EXPERTISE **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - getter method for Expertise
     */
    get expertise() {
        return this.expertiseList;
    }

    set expertise(array) {
        this.expertiseList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve picklist values for Expertise__c from Account_Expertise__c
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_Expertise })
    wiredExpertiseValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.expertise = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from picklist Expertise
    */
    handleOnItemSelectedExpertise(event) {
        if (event.detail) {
            this.expertiseValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.expertiseValue.push(eachItem.value);
            });
        }

        const selectedEventExpertise = new CustomEvent("expertisevaluechange", {
            detail: this.expertiseValue
        });

        this.dispatchEvent(selectedEventExpertise);
    }  

    /************************ FIELD MODE (OP/OD) **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - getter method for Mode
     */
    get mode() {
        return this.modeList;
    }

    set mode(array) {
        this.modeList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve picklist values for Mode_OP_OD__c from Account_Expertise__c
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_Mode })
    wiredModeValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.mode = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from picklist Mode
    */
    handleOnItemSelectedMode(event) {
        if (event.detail) {
            this.modeValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.modeValue.push(eachItem.value);
            });
        }

        const selectedEventMode = new CustomEvent("modevaluechange", {
            detail: this.modeValue
        });

        this.dispatchEvent(selectedEventMode);
    }


    /************************ FIELD CORE BUSINESS (ACCOUNT CORE BUSINESS) **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - getter method for Core Business
     */
    get accCoBusCoreBusiness() {
        return this.accCoBusCoreBusinessList;
    }

    set accCoBusCoreBusiness(array) {
        this.accCoBusCoreBusinessList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve picklist values for CoreBusiness__c from AccountCoreBusiness__c
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_AccCoBusCoreBusiness })
    wiredAccCoBusCoreBusinessValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.accCoBusCoreBusiness = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from picklist Core Business (AccountCoreBusiness__c)
    */
    handleOnItemSelectedAccCoBusCoreBusiness(event) {
        if (event.detail) {
            this.accCoBusCoreBusinessValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.accCoBusCoreBusinessValue.push(eachItem.value);
            });
        }

        const selectedEventAccCoBusCoreBusiness = new CustomEvent("acccobuscorebusinessvaluechange", {
            detail: this.accCoBusCoreBusinessValue
        });

        this.dispatchEvent(selectedEventAccCoBusCoreBusiness);
    } 
    
    
    /************************ FIELD PRODUCT LINE **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - getter method for Product Line
     */
    get productLine() {
        return this.productLineList;
    }

    set productLine(array) {
        this.productLineList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve picklist values for ProductLine__c from AccountCoreBusiness__c
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_ProductLine })
    wiredProductLineValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.productLine = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from picklist Product Line
    */
    handleOnItemSelectedProductLine(event) {
        if (event.detail) {
            this.productLineValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.productLineValue.push(eachItem.value);
            });
        }

        const selectedEventproductLine = new CustomEvent("productlinevaluechange", {
            detail: this.productLineValue
        });

        this.dispatchEvent(selectedEventproductLine);
    }
    
    /************************ FIELD CORE BUSINESS (ACCOUNT COMPETITOR) **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - getter method for Core Business
     */
    get accComCoreBusiness() {
        return this.accComBusinessList;
    }

    set accComCoreBusiness(array) {
        this.accComBusinessList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve picklist values for Core_Business__c from Account_Competitor__c
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_AccComCoreBusiness })
    wiredAccComBusinessValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.accComCoreBusiness = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from picklist Core Business (Account_Competitor__c)
    */
    handleOnItemSelectedAccComCoreBusiness(event) {
        if (event.detail) {
            this.accComBusinessValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.accComBusinessValue.push(eachItem.value);
            });
        }

        const selectedEventAccComBusiness = new CustomEvent("acccombusinessvaluechange", {
            detail: this.accComBusinessValue
        });

        this.dispatchEvent(selectedEventAccComBusiness);
    }

    /************************ FIELD COMPETITOR **********************/
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - getter method for Competitor
     */
    get competitor() {
        return this.competitorList;
    }

    set competitor(array) {
        this.competitorList = array;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve picklist values for Competitor__c from Account_Competitor__c
     */
    @wire(getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: FIELD_Competitor })
    wiredCompetitorValues
        ({ error, data }) {
        if (data) {
            // Map picklist values
            this.competitor = data.values.map((item, index) => ({ key: index, value: item.value, label : item.label}));
        }
        else if (error) {
            // Handle error
            console.log(error);
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from picklist Competitor
    */
    handleOnItemSelectedCompetitor(event) {
        if (event.detail) {
            this.competitorValue = [];
            let self = this;

            event.detail.forEach(function (eachItem) {
                self.competitorValue.push(eachItem.value);
            });
        }

        const selectedEventCompetitor = new CustomEvent("competitorvaluechange", {
            detail: this.competitorValue
        });

        this.dispatchEvent(selectedEventCompetitor);
    }

    /************************ FIELD ANNUAL REVENUE MIN **********************/

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from Annual Revenue min
    */
    handleOnChangeAnnualRevMin(event){
        this.annualRevMinValue = event.target.value;

        const selectedEventAnnualRevMinValue = new CustomEvent("annualrevminvaluechange", {
            detail: this.annualRevMinValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventAnnualRevMinValue);
    }

    /************************ FIELD ANNUAL REVENUE MAX **********************/

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from Annual Revenue max
    */
    handleOnChangeAnnualRevMax(event){
        this.annualRevMaxValue = event.target.value;

        const selectedEventAnnualRevMaxValue = new CustomEvent("annualrevmaxvaluechange", {
            detail: this.annualRevMaxValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventAnnualRevMaxValue);
    }

    /************************ FIELD NUM STORES MIN **********************/

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from Num Stores min
    */
    handleOnChangeNumStoresMin(event){
        this.numStoresMinValue = event.target.value;

        const selectedEventNumStoresMinValue = new CustomEvent("numstoresminvaluechange", {
            detail: this.numStoresMinValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventNumStoresMinValue);
    }

    /************************ FIELD NUM STORES MAX **********************/

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from Num Stores max
    */
    handleOnChangeNumStoresMax(event){
        this.numStoresMaxValue = event.target.value;

        const selectedEventNumStoresMaxValue = new CustomEvent("numstoresmaxvaluechange", {
            detail: this.numStoresMaxValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventNumStoresMaxValue);
    }

    /************************ FIELD EMPLOYEES NUM MIN **********************/

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from Employees Num min
    */
    handleOnChangeEmployeesNumMin(event){
        this.employessNumMinValue = event.target.value;

        const selectedEventEmployeesNumMinValue = new CustomEvent("employeesnumminvaluechange", {
            detail: this.employessNumMinValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventEmployeesNumMinValue);
    }

    /************************ FIELD EMPLOYEES NUM MAX **********************/

    /**
    * @author Jeetesh - Comforth
    * @createddate - 19/06/2020
    * @description - Retrieve values selected from Employees Num max
    */
    handleOnChangeEmployeesNumMax(event){
        this.employessNumMaxValue = event.target.value;

        const selectedEventEmployeesNumMaxValue = new CustomEvent("employeesnummaxvaluechange", {
            detail: this.employessNumMaxValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventEmployeesNumMaxValue);
    }

    
    /********************* FIELD ERP NUMBER **********************/
    /**
    * @author Jeetesh - Comforth
    * @createddate - 18/06/2020
    * @description - Retrieve values from ERP Number
    */
    handleOnChangeErpNum(event) {
        this.erpNumValue = event.target.value;

        const selectedEventErpNumValue = new CustomEvent("erpnumvaluechange", {
            detail: this.erpNumValue
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEventErpNumValue);
    }

    /************************ BUTTON SEARCH **********************/
    /**
    * @author Jeetesh - Comforth
    * @createddate - 18/06/2020
    * @description - Handle Search button
    */
    handleSearch() {
        const handleSearch = new CustomEvent("handlesearch");
        this.dispatchEvent(handleSearch);
    }

    /************************ BUTTON ADD SELECTED ACCOUNTS TO TARGETING PLAN **********************/
    /**
    * @author Jeetesh - Comforth
    * @createddate - 18/06/2020
    * @description - Handle Add selected accounts to Tagerting Plan button
    */
    handleCreatePacAccount() {
        const handleCreatePacAccount = new CustomEvent("handlecreatepacaccount");
        this.dispatchEvent(handleCreatePacAccount);
    }

    /************************ BUTTON RESET FILTERS **********************/
    /**
    * @author Jeetesh - Comforth
    * @createddate - 02/07/2020
    * @description - Handle Reset filters button
    */
    handleResetFilters(){

        this.template.querySelectorAll('c-acc-mass-assignment-multi-picklist').forEach(element => {
            element.reset();
        });

        this.template.querySelectorAll('lightning-input').forEach(element => {
            element.value = null;
        });

        this.template.querySelectorAll('lightning-checkbox-group').forEach(element => {
            element.value = [];
        });

        const handleResetFilters = new CustomEvent("handleresetfilters");
        this.dispatchEvent(handleResetFilters);
    }
}