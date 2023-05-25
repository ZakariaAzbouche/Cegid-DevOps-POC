import { LightningElement, wire, track, api} from 'lwc';

export default class AccMassAssignment extends LightningElement {

    error;
    pcValue;
    natureValue;
    retailSegValue;
    erpNumValue;
    tPlanValue = '';
    pacAccOwnerValue = '';
    expertiseValue;
    modeValue;
    accCoBusCoreBusinessValue;
    productLineValue;
    accComBusinessValue;
    competitorValue;
    annualRevMinValue;
    annualRevMaxValue;
    numStoresMinValue;
    numStoresMaxValue;
    employeesNumMinValue;
    employeesNumMaxValue;
    colPortalValue;
    accountsFiltered;
    filters = {};

    /**
     * @author Jeetesh - Comforth
     * @createddate - 18/06/2020
     * @description - Retrieve Nature selected
     */
    handleNatureChange(event) {
        this.natureValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 18/06/2020
     * @description - Retrieve Postal Code selected from child component stfPicklist
     */

    handlePostalCodeChange(event) {
        this.pcValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 18/06/2020
     * @description - Retrieve Retail Segmentation selected
     */
    handleRetailSegChange(event) {
        this.retailSegValue = event.detail;
        this.applyFilters();
    }

    handleTargetingPlanChange(event) {
        this.tPlanValue = event.detail;
    }

    handlePacAccOwnerChange(event) {
        this.pacAccOwnerValue = event.detail;
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Expertise selected
     */
    handleExpertiseChange(event) {
        this.expertiseValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Mode selected
     */
    handleModeChange(event) {
        this.modeValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Core Business (Account Core Business) selected
     */
    handleAccCoBusCoreBusinessChange(event) {
        this.accCoBusCoreBusinessValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Product Line selected
     */
    handleProductLineChange(event) {
        this.productLineValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Core Business (Account Competitor) selected
     */
    handleAccComCoreBusinessChange(event) {
        this.accComBusinessValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Competitor selected
     */
    handleCompetitorChange(event) {
        this.competitorValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Annual Revenue Min
     */
    handleAnnualRevenueMinChange(event) {
        this.annualRevMinValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Annual Revenue Max
     */
    handleAnnualRevenueMaxChange(event) {
        this.annualRevMaxValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve No. of Stores Min
     */
    handleNumStoresMinChange(event) {
        this.numStoresMinValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve No. of Stores Max
     */
    handleNumStoresMaxChange(event) {
        this.numStoresMaxValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Employees Num Min
     */
    handleEmployeesNumMinChange(event) {
        this.employeesNumMinValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve Employees Num Max
     */
    handleEmployeesNumMaxChange(event) {
        this.employeesNumMaxValue = event.detail;
        this.applyFilters();
    }
    
    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve ERP Number
     */

    handleErpNumChange(event) {
        this.erpNumValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 19/06/2020
     * @description - Retrieve ERP Number
     */

    handleColPortalChange(event) {
        this.colPortalValue = event.detail;
        this.applyFilters();
    }

    /**
     * @author Jeetesh - Comforth
     * @createddate - 18/06/2020
     * @description - Apply filters in table data
     */
    applyFilters() {
        let filters = {};

        if(this.natureValue){
            filters["Nature__c"] = this.natureValue;
        }

        if(this.pcValue){
            filters["BillingPostalCode"] = this.pcValue;
        }

        if(this.retailSegValue){
            filters["Retail_Segmentation__c"] = this.retailSegValue;
        }

        if(this.expertiseValue){
            filters["Expertise__c"] = this.expertiseValue;
        }

        if(this.accCoBusCoreBusinessValue){
            filters["CoreBusiness__c"] = this.accCoBusCoreBusinessValue;
        }

        if(this.modeValue){
            filters["Mode_OP_OD__c"] = this.modeValue;
        }

        if(this.productLineValue){
            filters["ProductLine__c"] = this.productLineValue;
        }

        if(this.accComBusinessValue){
            filters["Core_Business__c"] = this.accComBusinessValue;
        }

        if(this.competitorValue){
            filters["Competitor__c"] = this.competitorValue;
        }

        if(this.annualRevMinValue){
            filters["AnnualRevMin"] = this.annualRevMinValue;
        }

        if(this.annualRevMaxValue){
            filters["AnnualRevMax"] = this.annualRevMaxValue;
        }

        if(this.numStoresMinValue){
            filters["NumStoresMin"] = this.numStoresMinValue;
        }

        if(this.numStoresMaxValue){
            filters["NumStoresMax"] = this.numStoresMaxValue;
        }

        if(this.employeesNumMinValue){
            filters["EmployeesNumMin"] = this.employeesNumMinValue;
        }

        if(this.employeesNumMaxValue){
            filters["EmployeesNumMax"] = this.employeesNumMaxValue;
        }

        if(this.erpNumValue){
            filters["ERP_Number__c"] = this.erpNumValue;
        }

        if(this.colPortalValue){
            filters["Collaborative_Portal__c"] = this.colPortalValue;
        }

        //console.log('##filters: ' + JSON.stringify(filters));
        this.filters = filters;
        this.template.querySelector("c-acc-mass-assignment-account-list").applyFilters(filters);
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 18/06/2020
    * @description - Handle accounts after filter
    */
    accountsFilteredHandler(e){
        this.accountsFiltered = e.detail;
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 22/06/2020
    * @description - Handle Search button
    */
    handleSearchBtn(){
        this.template.querySelector("c-acc-mass-assignment-account-list").handleSearch();
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 22/06/2020
    * @description - Handle create PAC/Account button
    */
    handleCreatePacAccountBtn(){
        this.template.querySelector("c-acc-mass-assignment-account-list").handleRowAction(this.tPlanValue, this.pacAccOwnerValue);
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 02/07/2020
    * @description - Handle Reset filters button
    */
   handleResetFiltersBtn(){

        this.pcValue = [];
        this.natureValue = [];
        this.retailSegValue = [];
        this.erpNumValue = [];
        this.expertiseValue = [];
        this.modeValue = [];
        this.accCoBusCoreBusinessValue = [];
        this.productLineValue = [];
        this.accComBusinessValue = [];
        this.competitorValue = [];
        this.annualRevMinValue = [];
        this.annualRevMaxValue = [];
        this.numStoresMinValue = [];
        this.numStoresMaxValue = [];
        this.employeesNumMinValue = [];
        this.employeesNumMaxValue = [];
        this.colPortalValue = [];

        this.filters = {};
        this.template.querySelector("c-acc-mass-assignment-account-list").applyFilters({});
   }
}