import { LightningElement, wire, track, api } from "lwc";
import communityId from '@salesforce/community/Id';
import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedProducts from '@salesforce/apex/B2B_AssociatedProducts.getProducts';

const dateFormatOptions = {  year: '2-digit', month: 'short', day: 'numeric', weekday: "long" };

/* 
[[Weekday]]			"weekday"	"narrow", "short", "long"
[[Era]]				"era"	"narrow", "short", "long"
[[Year]]			"year"	"2-digit", "numeric"
[[Month]]			"month"	"2-digit", "numeric", "narrow", "short", "long"
[[Day]]				"day"	"2-digit", "numeric"
[[Hour]]			"hour"	"2-digit", "numeric"
[[Minute]]			"minute"	"2-digit", "numeric"
[[Second]]			"second"	"2-digit", "numeric"
[[TimeZoneName]]	"timeZoneName"	"short", "long" 
*/

const WSResponse = {
    "success": true,
    "Result": {
        "sessions": [
            {
                "Etablissement": "1002",
                "Session": "PRU117",
                "Libellé_session": "Test Session 1 Arnaud Serna",
                "Article_formation": "A0001053",
                "Libellé_formation": "Web Formation Yource",
                "Date_début_formation": "25/10/2021",
                "Heure_début_formation": "09:00",
                "Date_fin_formation": "25/10/2021",
                "Heure_fin_formation": "10:30",
                "Lieu_formation": "Web",
                "Quantité_totale_possible": 11.0,
                "Quantité_inscrits": 0.0
            },
            {
                "Etablissement": "1002",
                "Session": "PRU118",
                "Libellé_session": "Test Session 2 - Arnaud Serna",
                "Article_formation": "A0001053",
                "Libellé_formation": "Web Formation Yource",
                "Date_début_formation": "08/11/2021",
                "Heure_début_formation": "09:00",
                "Date_fin_formation": "08/11/2021",
                "Heure_fin_formation": "10:30",
                "Lieu_formation": "Web",
                "Quantité_totale_possible": 6.0,
                "Quantité_inscrits": 0.0
            },
            {
                "Etablissement": "1002",
                "Session": "PRU119",
                "Libellé_session": "Test Session 2 - Arnaud Serna",
                "Article_formation": "A0001053",
                "Libellé_formation": "Web Formation Yource",
                "Date_début_formation": "10/11/2021",
                "Heure_début_formation": "09:00",
                "Date_fin_formation": "10/11/2021",
                "Heure_fin_formation": "10:30",
                "Lieu_formation": "Web",
                "Quantité_totale_possible": 6.0,
                "Quantité_inscrits": 0.0
            }
        ]
    }
}

export default class B2bProductCalender extends LightningElement {
    @api recordId;
    @api inStock;
    _quantityFieldValue = 1;
    displaySession = false;
    rectype = 'Package';
    @api sessionResult;
    @api title;
    @track data = {};
    @track spinnerClassName;
    @api b2bProductCalenderNoSessions;

    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
     @api
     get effectiveAccountId() {
         return this._effectiveAccountId;
     }

    get titleClassName(){
        return this.b2bProductCalenderNoSessions ? 'titleNoSessions' : 'titleSessions';
    }

    handleChecked(event){
        var sessionCode =  event.target.value;
        var sessionDate =  event.currentTarget.dataset.id;
        var sessionAvailability =  event.currentTarget.dataset.availability;

        this.dispatchEvent(
            new CustomEvent('sendsession', {
                detail: {
                    sessionCode         : sessionCode,
                    sessionDate         : sessionDate,
                    sessionAvailability : sessionAvailability
                }
            })
        );
    }

    /* get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    } */

    capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    connectedCallback(){
        this.spinnerClassName = 'slds-show';
        var relatedProductInfo;
        var relatedProductSessionInfo;
        var sessionMap = {};
        var sortedSessionMap = {};

        //if(this.displaySession){
            //console.log('recordId: ', this.recordId);
            getRelatedProducts({
                productId   :   this.recordId,
                recType     :   this.rectype
            })
            .then(result => {
                //console.log('getRelatedProducts result:', result);
                if(result != null){
                    //console.log('getRelatedProducts:', result);
                     if(result){
                        relatedProductInfo = result.relatedProductInfo;
                        relatedProductSessionInfo = result.relatedProductSessionInfo;
                    }

                    let sessions = relatedProductSessionInfo.Result.sessions;

                    /* let sessions = WSResponse.Result.sessions; */

                     for(var i in sessions){

                            let key = sessions[i].Article_formation;
                            let startDateSplit = sessions[i].Date_début_formation.split('/');
                            let date = startDateSplit[0];
                            let month = startDateSplit[1];
                            let year = startDateSplit[2];
                            let formattedStartDate = year + '-' + month + '-' + date;
                            let startDate = this.capitalizeFirstLetter(new Date(formattedStartDate).toLocaleDateString('fr-FR', dateFormatOptions));
                            //let endDate = new Date(sessions[i].Date_fin_formation).toLocaleDateString('fr-FR', dateFormatOptions);;
                            let startTimeEndTime = (sessions[i].Heure_début_formation + " - " + sessions[i].Heure_fin_formation).replaceAll(':', 'h');
                            let sessionDate = date + '/' + month + '/' + year + ' ' +startTimeEndTime ;//2021-10-05T12:46:52.000+0000
                            let availability = sessions[i].Quantité_totale_possible;
                            let etablissement = sessions[i].Etablissement;
                            let sessionCode = sessions[i].Session;

                            if(!sessionMap[key]){
                                sessionMap[key] = [{ startDate : startDate, formattedStartDate : formattedStartDate, startTimeEndTime : startTimeEndTime, availability : availability, etablissement: etablissement, sessionCode : sessionCode, sessionDate : sessionDate }];
                            }else{
                                sessionMap[key].push({ startDate : startDate, formattedStartDate : formattedStartDate, startTimeEndTime : startTimeEndTime, availability : availability, etablissement: etablissement, sessionCode : sessionCode, sessionDate : sessionDate });
                            }
                        }

                    for(var i in sessionMap){
                        var sortedDates = sessionMap[i].slice().sort((a, b) => new Date(a.formattedStartDate) - new Date(b.formattedStartDate));
                        sortedSessionMap[i] = sortedDates;
                    }

                    //console.log('sessionMap: ', sessionMap);
                    //console.log('sortedSessionMap: ', sortedSessionMap);

                    var row = relatedProductInfo;
                    row.ParentProductRefenceNumber = row.SBQQ__ConfiguredSKU__r.Reference_Number__c;
                    row.Name = row.SBQQ__OptionalSKU__r.Name;
                    row.ProductId = row.SBQQ__OptionalSKU__r.Reference_Number__c;
                    row.Description = row.SBQQ__OptionalSKU__r.Description;
                    row.sessions = /* sortedSessionMap["A0001053"] */ sortedSessionMap[row.ProductId];

                    this.data = relatedProductInfo;
                    //console.log('data: ', JSON.stringify(this.data));
                    this.spinnerClassName = 'slds-hide';
                }
                this.spinnerClassName = 'slds-hide';
            })
            .catch(error => {
                console.log('error ' , error);
                this.spinnerClassName = 'slds-hide';
            });
        //}

    }
}