import { LightningElement, wire, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Importing Apex Classes
import getFilteredAccs from '@salesforce/apex/LTN006_AccMassAssignment.getFilteredAccs';
import createPacAccs from '@salesforce/apex/LTN006_AccMassAssignment.createPacAccs';
 
export default class AccMassAssignmentAccountList extends LightningElement {

    @api filteredAccounts;
    @api filters;
    @api flagQueryAnd = false;
    @api flagQueryAccExpAnd = false;
    @api flagQueryAccComAnd = false;
    @api flagQueryAccCoreBusAnd = false;
    @api flagQueryComma = false;
    @api flagQueryColPortalOr = false;
    @api accIds;
    stringJSON = '';
    parsedJSON = '';
    fieldValue = '';
    strFilter = '';
    strFilterAccExp = '';
    strFilterAccCom = '';
    strFilterAccCoreBus = '';
    erpNumSplit;
    pCodeSplit;
    fieldName;

    @track accounts;
    @track data = [];
    @track errorMsg = '';
    @track showLoadingSpinner = false;

    // Datatable Columns
    @track columns = [{

        label: 'Account Name',
        fieldName: 'urlAccName',
        type: 'url',
            typeAttributes:{
                label:{
                    fieldName: 'Name'
                }, 
            target: '_blank'
        }   
    },

    {
        label: 'ERP Number',
        fieldName: 'ErpNumber',
        type: 'Text'
    },

    {
        label: 'Nature',
        fieldName: 'Nature',
        type: 'Text'
    },

    {
        label: 'Postal Code',
        fieldName: 'PostalCode',
        type: 'Text'
    },

    {
        label: 'Annual Revenue',
        fieldName: 'AnnualRevenue',
        type: 'Number'
    },

    {
        label: 'No. of Stores',
        fieldName: 'NumStores',
        type: 'Number'
    },

    {
        label: 'Retail Segmentation',
        fieldName: 'RetailSegmentation',
        type: 'Text'
    },

    {
        label: 'Collaborative Portal',
        fieldName: 'CollaborativePortal',
        type: 'boolean'
    },

    {
        label: 'Expertises',
        fieldName: 'Expertises',
        type: 'Text'
    }];

    /**
     * @author Jeetesh - Comforth
     * @createddate - 23/06/2020
     * @description - Apply filters
     */
    @api
    applyFilters(filters) {

        //console.log('##filters: ', filters);

        this.strFilter = '';
        this.strFilterAccExp = '';
        this.strFilterAccCom = '';
        this.strFilterAccCoreBus = '';

        if(filters != null){

            this.stringJSON = JSON.stringify(filters);
            //console.log('##stringJSON', this.stringJSON);
    
            this.parsedJSON = JSON.parse(this.stringJSON);
            //console.log('##parsedJSON', this.parsedJSON);

            this.flagQueryAnd = false;
            this.flagQueryAccExpAnd = false;
            this.flagQueryAccComAnd = false;
            this.flagQueryAccCoreBusAnd = false;
    
            for(var key in this.parsedJSON){

                //console.log('##key', key);
    
                // Field Nature
                if(key == 'Nature__c' && filters.Nature__c.length > 0){

                    this.constructQueryAccPicklist(key, filters.Nature__c, this.strFilter, this.fieldValue, this.flagQueryComma, this.flagQueryAnd);
                        
                }

                // Field Retail Segmentation
                if(key == 'Retail_Segmentation__c' && filters.Retail_Segmentation__c.length > 0){

                    this.constructQueryAccPicklist(key, filters.Retail_Segmentation__c, this.strFilter, this.fieldValue, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field Billing Postal Code
                if(key == 'BillingPostalCode' && filters.BillingPostalCode.length > 0){

                    this.constructQueryAccInputMulti(key, filters.BillingPostalCode, this.strFilter, this.fieldValue, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field AnnualRevMin
                if(key == 'AnnualRevMin' && filters.AnnualRevMin.length > 0){

                    this.fieldName = 'AnnualRevenue';

                    this.constructQueryAccInput(this.fieldName, filters.AnnualRevMin, this.strFilter, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field AnnualRevMax
                if(key == 'AnnualRevMax' && filters.AnnualRevMax.length > 0){

                    this.fieldName = 'AnnualRevenue';

                    this.constructQueryAccInput(this.fieldName, filters.AnnualRevMax, this.strFilter, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field NumStoresMin
                if(key == 'NumStoresMin' && filters.NumStoresMin.length > 0){

                    this.fieldName = 'No_of_Stores__c';

                    this.constructQueryAccInput(this.fieldName, filters.NumStoresMin, this.strFilter, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field NumStoresMax
                if(key == 'NumStoresMax' && filters.NumStoresMax.length > 0){

                    this.fieldName = 'No_of_Stores__c';

                    this.constructQueryAccInput(this.fieldName, filters.NumStoresMax, this.strFilter, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field EmployeesNumMin
                if(key == 'EmployeesNumMin' && filters.EmployeesNumMin.length > 0){

                    this.fieldName = 'NumberOfEmployees';

                    this.constructQueryAccInput(this.fieldName, filters.EmployeesNumMin, this.strFilter, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field EmployeesNumMax
                if(key == 'EmployeesNumMax' && filters.EmployeesNumMax.length > 0){

                    this.fieldName = 'NumberOfEmployees';

                    this.constructQueryAccInput(this.fieldName, filters.EmployeesNumMax, this.strFilter, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field ERP Number
                if(key == 'ERP_Number__c' && filters.ERP_Number__c.length > 0){

                    this.constructQueryAccInputMulti(key, filters.ERP_Number__c, this.strFilter, this.fieldValue, this.flagQueryComma, this.flagQueryAnd);

                }

                // Field Collaborative Portal
                if(key == 'Collaborative_Portal__c' && filters.Collaborative_Portal__c.length > 0){

                    if(this.flagQueryAnd){
                        this.strFilter = this.strFilter + ' AND ';
                    }

                    this.strFilter = this.strFilter + ' ( ';

                    for(var count in filters.Collaborative_Portal__c){

                        if(this.flagQueryColPortalOr){
                            this.strFilter = this.strFilter + ' OR ';
                        }

                        this.flagQueryColPortalOr = true;
                        this.fieldValue = filters.Collaborative_Portal__c[count];
                        this.strFilter = this.strFilter + key + ' = ' + this.fieldValue;
                    }

                    this.strFilter = this.strFilter + ' ) ';

                    this.flagQueryColPortalOr = false;
                    this.flagQueryAnd = true;
                }

                /********************** ACCOUNT EXPERTISE  *********************/  
                // Field Expertise
                if(key == 'Expertise__c' && filters.Expertise__c.length > 0){

                    this.constructQueryAccExpPicklist(key, filters.Expertise__c, this.strFilterAccExp, this.fieldValue, this.flagQueryComma, this.flagQueryAccExpAnd);
                    
                }

                // Field Mode
                if(key == 'Mode_OP_OD__c' && filters.Mode_OP_OD__c.length > 0){

                    this.constructQueryAccExpPicklist(key, filters.Mode_OP_OD__c, this.strFilterAccExp, this.fieldValue, this.flagQueryComma, this.flagQueryAccExpAnd);

                }

                /********************** ACCOUNT COMPETITOR  *********************/
                // Field Core Business (Account Competitor)
                if(key == 'Core_Business__c' && filters.Core_Business__c.length > 0){

                    this.constructQueryAccComPicklist(key, filters.Core_Business__c, this.strFilterAccCom, this.fieldValue, this.flagQueryComma, this.flagQueryAccComAnd);

                }

                // Field Competitor
                if(key == 'Competitor__c' && filters.Competitor__c.length > 0){

                    this.constructQueryAccComPicklist(key, filters.Competitor__c, this.strFilterAccCom, this.fieldValue, this.flagQueryComma, this.flagQueryAccComAnd);

                }

                /********************** ACCOUNT CORE BUSINESS  *********************/
                // Field Core Business (Account Core Business)
                if(key == 'CoreBusiness__c' && filters.CoreBusiness__c.length > 0){

                    this.constructQueryAccCoreBusPicklist(key, filters.CoreBusiness__c, this.strFilterAccCoreBus, this.fieldValue, this.flagQueryComma, this.flagQueryAccCoreBusAnd);

                }

                // Field Product Line
                if(key == 'ProductLine__c' && filters.ProductLine__c.length > 0){

                    this.constructQueryAccCoreBusPicklist(key, filters.ProductLine__c, this.strFilterAccCoreBus, this.fieldValue, this.flagQueryComma, this.flagQueryAccCoreBusAnd);

                }
            }
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Method to construct query for Object Account Picklist
    */
    constructQueryAccPicklist(key, field, strFilter, fieldValue, flagQueryComma, flagQueryAnd){

        if(flagQueryAnd){
            strFilter = strFilter + ' AND ';
        }

        strFilter = strFilter + '' + key + ' IN ( ';

        for(var count in field){

            if(flagQueryComma){
                strFilter = strFilter + ',';
            }

            flagQueryComma = true;
            fieldValue = field[count];

            strFilter = strFilter + '\'' + fieldValue + '\'';
        }

        strFilter = strFilter + ' ) ';
        //console.log('##strFilter', strFilter);

        flagQueryComma = false;
        flagQueryAnd = true;

        this.strFilter = strFilter;
        this.flagQueryComma = flagQueryComma;
        this.flagQueryAnd = flagQueryAnd;
    }
    
    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Method to construct query for Object Account Input seperated by comma
    */
    constructQueryAccInputMulti(key, field, strFilter, fieldValue, flagQueryComma, flagQueryAnd){

        if(flagQueryAnd){
            strFilter = strFilter + ' AND ';
        }

        strFilter = strFilter + '' + key + ' IN ( ';

        this.pCodeSplit = field.split(',');

        for(var count in this.pCodeSplit){

            if(flagQueryComma){
                strFilter = strFilter + ',';
            }

            flagQueryComma = true;

            fieldValue = this.pCodeSplit[count];

            strFilter = strFilter + '\'' + fieldValue + '\'';
        }

        strFilter = strFilter + ' ) ';
        //console.log('##strFilter', this.strFilter);

        flagQueryComma = false;
        flagQueryAnd = true;

        this.strFilter = strFilter;
        this.flagQueryComma = flagQueryComma;
        this.flagQueryAnd = flagQueryAnd;
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Method to construct query for Object Account Input
    */
    constructQueryAccInput(fieldName, field, strFilter, flagQueryComma, flagQueryAnd){

        if(flagQueryAnd){
            strFilter = strFilter + ' AND ';
        }

        strFilter = strFilter + fieldName + ' >= ' + field;
        //console.log('##strFilter', this.strFilter);

        flagQueryComma = false;
        flagQueryAnd = true;

        this.strFilter = strFilter;
        this.flagQueryComma = flagQueryComma;
        this.flagQueryAnd = flagQueryAnd;
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Method to construct query for Object Account Expertise Picklist
    */
    constructQueryAccExpPicklist(key, field, strFilterAccExp, fieldValue, flagQueryComma, flagQueryAccExpAnd){

        if(flagQueryAccExpAnd){
            strFilterAccExp = strFilterAccExp + ' AND ';
        }

        strFilterAccExp = strFilterAccExp + '' + key + ' IN ( ';

        for(var count in field){

            if(flagQueryComma){
                strFilterAccExp = strFilterAccExp + ',';
            }

            flagQueryComma = true;
            fieldValue = field[count];

            strFilterAccExp = strFilterAccExp + '\'' + fieldValue + '\'';
        }

        strFilterAccExp = strFilterAccExp + ' ) ';
        //console.log('##strFilterAccExp', strFilterAccExp);

        flagQueryComma = false;
        flagQueryAccExpAnd = true;

        this.strFilterAccExp = strFilterAccExp;
        this.flagQueryComma = flagQueryComma;
        this.flagQueryAccExpAnd = flagQueryAccExpAnd;
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Method to construct query for Object Account Competitor Picklist
    */
    constructQueryAccComPicklist(key, field, strFilterAccCom, fieldValue, flagQueryComma, flagQueryAccComAnd){
        
        if(flagQueryAccComAnd){
            strFilterAccCom = strFilterAccCom + ' AND ';
        }

        strFilterAccCom = strFilterAccCom + '' + key + ' IN ( ';

        for(var count in field){

            if(flagQueryComma){
                strFilterAccCom = strFilterAccCom + ',';
            }

            flagQueryComma = true;
            fieldValue = field[count];

            strFilterAccCom = strFilterAccCom + '\'' + fieldValue + '\'';
        }

        strFilterAccCom = strFilterAccCom + ' ) ';
        //console.log('##strFilterAccCom', strFilterAccCom);

        flagQueryComma = false;
        flagQueryAccComAnd = true;

        this.strFilterAccCom = strFilterAccCom;
        this.flagQueryComma = flagQueryComma;
        this.flagQueryAccComAnd = flagQueryAccComAnd;
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Method to construct query for Object Account Core Business Picklist
    */
    constructQueryAccCoreBusPicklist(key, field, strFilterAccCoreBus, fieldValue, flagQueryComma, flagQueryAccCoreBusAnd){
        
        if(flagQueryAccCoreBusAnd){
            strFilterAccCoreBus = strFilterAccCoreBus + ' AND ';
        }

        strFilterAccCoreBus = strFilterAccCoreBus + '' + key + ' IN ( ';

        for(var count in field){

            if(flagQueryComma){
                strFilterAccCoreBus = strFilterAccCoreBus + ',';
            }

            flagQueryComma = true;
            fieldValue = field[count];

            strFilterAccCoreBus = strFilterAccCoreBus + '\'' + fieldValue + '\'';
        }

        strFilterAccCoreBus = strFilterAccCoreBus + ' ) ';
        //console.log('##strFilterAccCoreBus', strFilterAccCoreBus);

        flagQueryComma = false;
        flagQueryAccCoreBusAnd = true;

        this.strFilterAccCoreBus = strFilterAccCoreBus;
        this.flagQueryComma = flagQueryComma;
        this.flagQueryAccCoreBusAnd = flagQueryAccCoreBusAnd;
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 30/06/2020
    * @description - Display filtered accounts in datatable
    */
    @api
    handleSearch() {

        if(this.strFilter == '' && this.strFilterAccExp == '' && this.strFilterAccCom == '' && this.strFilterAccCoreBus == ''){
            const event = new ShowToastEvent({
                title: 'Warning',
                variant: 'Warning',
                message: 'Choose at least one filter'
            });
            this.dispatchEvent(event);
        }

        else{
            this.showLoadingSpinner = true;

            // Call method getFilteredAccs()
            getFilteredAccs({
                strFilter: this.strFilter,
                strFilterAccExp: this.strFilterAccExp,
                strFilterAccCom: this.strFilterAccCom,
                strFilterAccCoreBus: this.strFilterAccCoreBus
            })
            .then(result => {

                //console.log('##result',result);
                this.showLoadingSpinner = false;

                if(result.length < 1){
                    const event = new ShowToastEvent({
                        title: 'Warning',
                        variant: 'Warning',
                        message: 'No results found'
                    });
                    this.dispatchEvent(event);

                    this.data = null;
                }

                else{
                    let currentData = [];

                    result.forEach((row) => {
                        let rowData = {};
                        let strDataExp = '';
    
                        rowData.urlAccName = '/' + row.Id;
                        rowData.Name = row.Name;
                        rowData.ErpNumber = row.ERP_Number__c;
                        rowData.Nature = row.Nature__c;
                        rowData.PostalCode = row.BillingPostalCode;
                        rowData.AnnualRevenue = row.AnnualRevenue;
                        rowData.NumStores = row.No_of_Stores__c;
                        rowData.RetailSegmentation = row.Retail_Segmentation__c;
                        rowData.CollaborativePortal = row.Collaborative_Portal__c;
    
                        if(row.Account_Expertises__r){
                            row.Account_Expertises__r.forEach((exp) => {
    
                                if(strDataExp == ''){
                                    strDataExp = exp.Expertise__c;
                                }
    
                                else{
                                    strDataExp = strDataExp + ',' + exp.Expertise__c;
                                }
                            });
                        }
    
                        rowData.Expertises = strDataExp;
    
                        currentData.push(rowData);
                    });
    
                    this.data = currentData;
                }
            })
            .catch(error => {
                //console.log('##error: ', error);

                this.showLoadingSpinner = false;

                // Display error message
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    message: error.body.message
                });
                this.dispatchEvent(event);

                this.data = null;
            });
        }
    }

    /**
    * @author Jeetesh - Comforth
    * @createddate - 29/06/2020
    * @description - Add selected accounts to Targeting Plan
    */
    @api
    handleRowAction(tPlanValue, pacAccOwnerValue){

        var rows = this.template.querySelector('lightning-datatable');
        var selectedRows = rows.getSelectedRows();

        this.accIds = [];
        let self = this;

        selectedRows.forEach(function (eachItem) {
            self.accIds.push(eachItem.urlAccName);
        });

        if(tPlanValue.length > 0 && pacAccOwnerValue.length > 0 && selectedRows.length > 0){

            this.showLoadingSpinner = true;

            // Call method createPacAccs()
            createPacAccs({
                accIds: this.accIds,
                targetingPlan: tPlanValue[0],
                pacAccOwner: pacAccOwnerValue[0]
            })
            .then(result => {

                this.showLoadingSpinner = false;

                // Display success message
                const event = new ShowToastEvent({
                    title: 'Success',
                    variant: 'Success',
                    message: 'Accounts successfully added to Targeting Plan'
                });
                this.dispatchEvent(event);
            })
            .catch(error => {

                this.showLoadingSpinner = false;

                // Display error message
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'Error',
                    message: error.body.message
                });
                this.dispatchEvent(event);
            });
        }

        else if(tPlanValue.length < 1){
            const event = new ShowToastEvent({
                title: 'Warning',
                variant: 'Warning',
                message: 'Select Targeting Plan'
            });
            this.dispatchEvent(event);
        }

        else if(pacAccOwnerValue.length < 1){
            const event = new ShowToastEvent({
                title: 'Warning',
                variant: 'Warning',
                message: 'Select Pac/Account Owner'
            });
            this.dispatchEvent(event);
        }

        else if(selectedRows.length < 1){
            const event = new ShowToastEvent({
                title: 'Warning',
                variant: 'Warning',
                message: 'Select Account(s)'
            });
            this.dispatchEvent(event);
        }
    }
}