import { LightningElement,api,track } from 'lwc';
 
import getMandaSEPAFROMWS from '@salesforce/apex/B2B_QuoteGetMandatSepa.getData';
//import saveOrders from '@salesforce/apex/B2B_QuoteGetMandatSepa.createOrderRecord';
export default class B2bSepaPayment extends LightningElement {
    @api getCartIds;
    @track error;
    listToAttach = [];
    WsSepa = true;
    iban = '';
    bic = '';
    rum = '';
    bankCity = '';
    bankName = '';
    selectCheckBox;
    radiobutton;
    enableButton = false;
    isSpinning = true;
    errorMsg = '';
    displayErrormsg = false;
    ibanCheck = "^(?:(?:IT|SM)\\d{2}[A-Z]\\d{22}|CY\\d{2}[A-Z]\\d{23}|NL\\d{2}[A-Z]{4}\\d{10}|LV\\d{2}[A-Z]{4}\\d{13}|(?:BG|BH|GB|IE)\\d{2}[A-Z]{4}\\d{14}|GI\\d{2}[A-Z]{4}\\d{15}|RO\\d{2}[A-Z]{4}\\d{16}|KW\\d{2}[A-Z]{4}\\d{22}|MT\\d{2}[A-Z]{4}\\d{23}|NO\\d{13}|(?:DK|FI|GL|FO)\\d{16}|MK\\d{17}|(?:AT|EE|KZ|LU|XK)\\d{18}|(?:BA|HR|LI|CH|CR)\\d{19}|(?:GE|DE|LT|ME|RS)\\d{20}|IL\\d{21}|(?:AD|CZ|ES|MD|SA)\\d{22}|PT\\d{23}|(?:BE|IS)\\d{24}|(?:FR|MR|MC)\\d{25}|(?:AL|DO|LB|PL)\\d{26}|(?:AZ|HU)\\d{27}|(?:GR|MU)\\d{28})$";
    //ibanCheck = "^(?:(?:IT|SM)\d{2}[A-Z]\d{22}|CY\d{2}[A-Z]\d{23}|NL\d{2}[A-Z]{4}\d{10}|LV\d{2}[A-Z]{4}\d{13}|(?:BG|BH|GB|IE)\d{2}[A-Z]{4}\d{14}|GI\d{2}[A-Z]{4}\d{15}|RO\d{2}[A-Z]{4}\d{16}|KW\d{2}[A-Z]{4}\d{22}|MT\d{2}[A-Z]{4}\d{23}|NO\d{13}|(?:DK|FI|GL|FO)\d{16}|MK\d{17}|(?:AT|EE|KZ|LU|XK)\d{18}|(?:BA|HR|LI|CH|CR)\d{19}|(?:GE|DE|LT|ME|RS)\d{20}|IL\d{21}|(?:AD|CZ|ES|MD|SA)\d{22}|PT\d{23}|(?:BE|IS)\d{24}|(?:FR|MR|MC)\d{25}|(?:AL|DO|LB|PL)\d{26}|(?:AZ|HU)\d{27}|(?:GR|MU)\d{28})$";

    bicCheck = "[A-Z]{6,6}[A-Z2-9][A-NP-Z0-9]([A-Z0-9]{3,3}){0,1}";

    connectedCallback(){
        getMandaSEPAFROMWS({
            listCartIds:this.getCartIds
        })
        .then(result => {
           console.log('result ' , result.error != '');
           console.log('result ' , result.error != '');
           
           this.WsSepa = true;

        //    if(result.error != ''){
        //     this.errorMsg = result.error;
        //     this.displayErrormsg = true;
        //    }else{
                this.listToAttach = result.mapMandatSepas.mandates;
                this.displayErrormsg = false;
                for(var i = 0; i < this.listToAttach.length; i++){
                    console.log('for Loop');
                    this.listToAttach[i].hiddenIban = this.listToAttach[i].IBAN.replace(/\d(?=\d{3})/g, "*");
                    this.listToAttach[i].hiddenBic= this.listToAttach[i].BIC.replace(/\w(?=\w{2})/g, "*");
                    this.listToAttach[i].complyInformation = this.listToAttach[i].IBAN +'-'+ this.listToAttach[i].BIC +'-'+ this.listToAttach[i].RUM +'-'+ this.listToAttach[i].bankCity +'-'+ this.listToAttach[i].bankName;
                    //(.{0,8})$
                //}
                console.log('listToAttach : ' , this.listToAttach);
           }
           
           this.isSpinning = false;
        })
        .catch(error => {
            this.isSpinning = false;
            console.log('error ' , error);
        });
    }

    handleClick(){
        this.WsSepa = false;
    }
    // handleSave(){
    //     console.log(this.getCartIds);
    //     this.WsSepa = false;
    //     var map = {iban: this.iban, bic: this.bic, rum: this.rum, bankCity: this.bankCity, bankName: this.bankName};

    //     saveOrders({
    //         listCartIds:this.getCartIds,
    //         mapMandatSepa : map
    //     })
    //     .then(result => {
    //        console.log('result ' , result);
    //     })
    //     .catch(error => {
    //         console.log('error ' , error);
    //     });
    // }
    handleCancel(){
        this.WsSepa = true;
    }

    handleIbanChange(event){
        console.log('handleIbanChange');
        this.iban = event.target.value;
        this.sendmanda();
    }

    handleBicChange(event){
        this.bic = event.target.value;
        this.sendmanda();
    }

    handleRumChange(event){
        this.rum = event.target.value.trim().substr(0, 26);
        this.sendmanda();
    }

    handleBankCityChange(event){
        this.bankCity = event.target.value;
        this.sendmanda();
    }

    handleBankNameChange(event){
        this.bankName = event.target.value;
        this.sendmanda();
    }

    sendmanda(){
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputField) => {
            inputField.reportValidity();
            return validSoFar && inputField.checkValidity();
        }, true);
        if (isInputsCorrect) {
                //perform success logic
                if( this.iban !=null && this.iban !='' && this.bic !=null && this.bic !=''
                && this.bankCity !=null && this.bankCity !='' && this.bankName !=null && this.bankName !=''){
                //var _map = {iban: this.iban, bic: this.bic, rum: this.rum, bankCity: this.bankCity, bankName: this.bankName};
                this.dispatchEvent(
                    new CustomEvent('sendinfomandasepa', {
                        detail: {
                            iban: this.iban, 
                            bic: this.bic, 
                            rum: this.rum, 
                            bankCity: this.bankCity, 
                            bankName: this.bankName,
                            enableButton : false,
                            isCustom : this.WsSepa
                        }
                    })
                );
            }else{
                this.dispatchEvent(
                    new CustomEvent('sendinfomandasepa', {
                        detail: {
                            iban: '', 
                            bic: '', 
                            rum: '', 
                            bankCity: '', 
                            bankName: '',
                            enableButton : true,
                            isCustom : this.WsSepa
                        }
                    })
                );
            }
        }else{
            this.dispatchEvent(
                new CustomEvent('sendinfomandasepa', {
                    detail: {
                        iban: '', 
                        bic: '', 
                        rum: '', 
                        bankCity: '', 
                        bankName: '',
                        enableButton : true,
                        isCustom : this.WsSepa
                    }
                })
            );
        }
        console.log('isInputsCorrect : ' , isInputsCorrect);

       
        
    }
    

    handleChecked(event){
        if(event.target.checked){
            console.log('handleChecked');
            this.selectCheckBox =  event.target.value;
            const myArr = this.selectCheckBox.split("-");
            this.iban = myArr[0];
            this.bic = myArr[1];
            this.rum = myArr[2];
            this.bankCity = myArr[3];
            this.bankName = myArr[4];
            console.log('myArr : ', myArr[3]);
            this.enableButton = true;
            this.sendmanda();
        }else{
            this.enableButton = false;
            this.dispatchEvent(
                new CustomEvent('sendinfomandasepa', {
                    detail: {
                        iban: this.iban, 
                        bic: this.bic, 
                        rum: this.rum, 
                        bankCity: this.bankCity, 
                        bankName: this.bankName,
                        enableButton : true
                    }
                })
            );
        }
    }

    handleResetClick() {
        this.radiobutton = undefined;
    }

}