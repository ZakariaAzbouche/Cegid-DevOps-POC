import { LightningElement, api } from 'lwc'
import { loadStyle } from 'lightning/platformResourceLoader';

import getAccountName from '@salesforce/apex/AP04_RelatedListSupport.getAccountName';
import fetchData from '@salesforce/apex/AP04_RelatedListSupport.fetchData'
import raiseCase from '@salesforce/apex/AP04_RelatedListSupport.raiseCase'

import css from '@salesforce/resourceUrl/LWC_RelatedListSupport_Custom';

import wsError from '@salesforce/label/c.Error_Message_WS'

const Status2Raise = [
    'New',
    'Active',
    'Awaiting Customer Info'
]

/**
 *
 *
 * @export
 * @class Lwc_RelatedListSupport
 * @extends {LightningElement}
 */
export default class Lwc_RelatedListSupport extends LightningElement {

    @api recordId;

    sending = false
    success = false
    error = false
    wait = true
    canDisplay = false
    displayPopup = false

    errorMsg
    errorMsgRaise

    title
    reason

    totalRows = 0
    data

    columns = [
        {label: 'Number', fieldName: 'case_number', type: 'button', typeAttributes: {disabled: { fieldName: 'disabled'}, label: {fieldName: 'case_number', name: "ActionName", variant: "base"}}},
        {label: 'Created Date', fieldName: 'opened_at', type: 'date', sortable: 'true'},
        {label: 'Category', fieldName: 'cate', type: 'text', sortable: 'true'},
        {label: 'Title', fieldName: 'short_description', type: 'text',clipText:true},
        {label: 'Product', fieldName: 'productCode', type: 'text'},
        {label: 'Status', fieldName: 'state', type: 'text', sortable: 'true'},
        {label: 'Criticity', fieldName: 'priority', type: 'text', sortable: 'true'},
        {label: 'Service Level', fieldName: 'description', type: 'text'},
        {label: 'Owner', fieldName: 'conName', type: 'text'},
        {label: 'Raise Date', fieldName: 'raise_date', type: 'text'},
        {label: 'PBR Number', fieldName: 'problem_number', type: 'text'}
    ]

    get displayInput() {
        return !this.sending && !this.success
    }

    /**
     *
     *
     * @memberof Lwc_RelatedListSupport
     */
    async connectedCallback() {

        Promise.all([
            loadStyle(this, css)
        ])

        try {
            let result = await fetchData({recordId: this.recordId})

            if(result.sourceList) {
                for(let i = 0; i < result.sourceList.length; i++){
                    result.sourceList[i].disabled = !Status2Raise.includes(result.sourceList[i].state)
                    result.sourceList[i].conName= result.sourceList[i].contact.name
                    result.sourceList[i].cate= result.sourceList[i].demande_type.category
                    result.sourceList[i].code= result.sourceList[i].service_level.code
                    result.sourceList[i].description= result.sourceList[i].service_level.description
                    result.sourceList[i].productCode= result.sourceList[i].asset.libele
                    result.sourceList[i].opened_at= new Date(result.sourceList[i].opened_at).toLocaleDateString('fr-FR')
                }

                this.data = result.sourceList
                this.totalRows = result.sourceList.length
                this.sortData('opened_at','desc');
            }

            if(!result.sourceList || result.error) {
                this.errorMsg = wsError
            }
        } catch(e) {
            this.errorMsg = JSON.stringify(e)
        }
        this.wait = false

    }

    /**
     *
     *
     * @memberof Lwc_RelatedListSupport
     */
    downloadCsv() {
        
        getAccountName({recordId: this.recordId})
        .then((result) => {
            this.createCsv(result.Name)
        })     

    }

    /**
     *
     *
     * @memberof Lwc_RelatedListSupport
     */
    createCsv(accName) {
        var stockData = this.data;

        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ':' + today.getMinutes() + ':' + today.getSeconds();
        var dateTime = date+' '+time;
        
        let _header = '';
        _header += 'Number'+';'+'Created Date'+';'+'Category'+';'+'Title'+';'+'Product'+';'+'Status'+';'+'Criticity'+';'+'Service Level'+';'+'Owner'+';'+'Raise Date'+';'+'PBR Number'+';';
        
        let _data = '';
        
        stockData.forEach(element => {
            _data +=
            '\n' +
            element.case_number +
            ';' +
            element.opened_at +
            ';' +
            element.cate +
            ';' +
            element.short_description +
            ';' +
            element.productCode +
            ';' +
            element.state +
            ';' +
            element.priority +
            ';' +
            element.description +
            ';' +
            element.conName +
            ';' +
            element.raise_date +
            ';' +
            element.problem_number +
            ';';
            
        });
                        
        let _csvName =accName+'_Case_'+dateTime+'.csv';
        
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,%EF%BB%BF' + encodeURI(_header + _data);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = _csvName;  // CSV file Name* you can change it.[only name not .csv] 
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }

    /**
     *
     *
     * @param {*} fieldName
     * @param {*} sortDirection
     * @memberof Lwc_RelatedListSupport
     */
    sortData(fieldName, sortDirection) {
        var reverse = sortDirection !== 'asc';
        this.data.sort(this.sortBy(fieldName, reverse));
    }

    /**
     *
     *
     * @param {*} field
     * @param {*} reverse
     * @param {*} primer
     * @return {*} 
     * @memberof Lwc_RelatedListSupport
     */
    sortBy(field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            // eslint-disable-next-line no-return-assign, no-sequences
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }

    /**
     *
     *
     * @memberof Lwc_RelatedListSupport
     */
    showDetails() {
        this.canDisplay = !this.canDisplay
    }

    /**
     *
     *
     * @param {*} event
     * @memberof Lwc_RelatedListSupport
     */
    handleRowAction(event) {
        if(Status2Raise.includes(event.detail.row.state)) {
            this.title = "Raise: Case " + event.detail.row.case_number
            this.currentCaseNumber = event.detail.row.case_number
            this.displayPopup = true
        }
    }

    /**
     *
     *
     * @param {*} event
     * @memberof Lwc_RelatedListSupport
     */
    handleTextArea(event) {
        this.reason = event.detail.value
    }

    /**
     *
     *
     * @param {*} event
     * @memberof Lwc_RelatedListSupport
     */
    handleClick(event) {
        if(event.target.name === 'cancel') {
            this.displayPopup = false;
            this.success = false
            this.error = false
            this.errorMsgRaise = undefined
            this.reason = undefined
        }

        if(event.target.name === 'send') {
            this.error = false
            if(!this.reason || this.reason.trim().length === 0) {
                this.error = true
                this.errorMsgRaise = 'Reason cannot be empty.'
                return
            }

            this.sending = true
            raiseCase({caseNumber: this.currentCaseNumber, body: JSON.stringify(this.reason)})
            .then(response => {
                this.success = response.success
                this.error = !this.success
                this.errorMsgRaise = response.error
                this.sending = false
            })
        }
    }

    closePopup() {
        this.displayPopup = false;
        this.success = false
        this.error = false
        this.errorMsgRaise = undefined
        this.reason = undefined
    }

    sortedDirection
    sortByField

    handleSorting(event) {
        this.sortByField = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortByField, this.sortDirection);
    }

}