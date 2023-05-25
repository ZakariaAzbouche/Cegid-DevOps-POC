/**
 * @File Name          : TH_Contact
 * @Description        : Update Opportunity Team Member with Case Owner  
 * @Author             : SRA   
 * @Group              : Comforth-Karoo
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    01/12/2020         SRA              Initial Version
 * ---    -----------       -------           ------------------------ 
 * 1.5    09/03/2022         BCR              handle afterUpdate/delete with contact direct management
 * ---    -----------       -------           ------------------------  
**/
public without sharing class TH_Contact extends TriggerHandler {
    /**
* @author
* @date
* @description Constructor
* @return void
*/
    public TH_Contact() {
    }
    
    /**
* @author
* @date
* @description Handler Method for after Insert Event
* @return void
*/
    public override void beforeInsert() {
        system.debug('TH_Contact beforeInsert');
        List<Contact> listContact= new List<Contact>();
        computeSameEmailCustomerUser((List<Contact>)Trigger.new);
        affectTechEmail((List<Contact>)Trigger.new);

        for(Contact con:(List<Contact>)Trigger.new){
			system.debug('New con'+ con);
            
            if(!con.Contact_created_from_Lead__c){
                listContact.add(con);
        	}
        } 
        
        if(listContact.size()>0){
            system.debug('listContact'+listContact);
            
            try{
                SM011_Contact.convertLeadError(listContact);
            }
            catch(Exception e){
                System.debug('Testing Error Message');
            }finally{
                System.debug('TestFinally');
            } 
        }
    }
    
    public override void afterInsert() {
        system.debug('TH_Contact afterInsert');
        set<Id> setContactId = new set<Id>();
        Map<Id,String> mapContactEmail = New Map<Id,String>();

        
        for(Contact con:(List<Contact>)Trigger.New){
            system.debug('con after Insert' + con.Id);
            mapContactEmail.put(con.Id,con.Email);
            setContactId.add(con.Id);
            
        } 
        if(setContactId.size()>0){
            SM011_Contact.convertLead(setContactId, mapContactEmail);
        }
        computeAccountTechContactDirect((Map<Id, Contact>) Trigger.newMap, null);
        updateNbContacts((Map<Id, Contact>) Trigger.newMap, null, false);
        //checkIfcontactAlreadyExist((Map<Id, Contact>) Trigger.newMap, null);
        mergedContacts((Map<Id, Contact>) Trigger.newMap);
        convertLeadContactNonAQL((Map<Id, Contact>)Trigger.newMap);
       
    }


    public override void beforeUpdate() {
        System.debug('TH_Contact BeforeUpdate');
        Map<Id, Contact> contsToBeProcess = (Map<Id, Contact>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.BEFORE_UPDATE); 
        if(contsToBeProcess.isEmpty()) {//Control recursiv call from trigger
            System.debug('No ct to be processed');
        } else {
            affectTechEmail(contsToBeProcess.values());
        }
    }

    /**
    * @author BCR
    * @date   09/03/2022
    * @description Handler Method for after Update Event
    * @return void
    */
    public override void afterUpdate() {
        System.debug('TH_Contact afterUpdate');
        Map<Id, Contact> contsToBeProcess = (Map<Id, Contact>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.AFTER_UPDATE); 
        if(contsToBeProcess.isEmpty()) {//Control recursiv call from trigger
            System.debug('No ct to be processed');
        } else {
            computeAccountTechContactDirect(contsToBeProcess, (Map<Id, Contact>) Trigger.oldMap);
            updateNbContacts((Map<Id, Contact>) Trigger.newMap, (Map<Id, Contact>) Trigger.oldMap, false);
            //checkIfcontactAlreadyExist(contsToBeProcess, (Map<Id, Contact>) Trigger.oldMap);
        }

    }

    /**
    * @author MAIT
    * @date   12/09/2022
    * @description Handler Method for before Delete Event
    * @return void
    */
    public override void beforeDelete() {
        System.debug('TH_Contact beforeDelete');
        updateNbContacts((Map<Id, Contact>) Trigger.oldMap, null, true);
    }

    /**
    * @author BCR
    * @date   09/03/2022
    * @description Handler Method for after Delete Event
    * @return void
    */
    public override void afterDelete() {
        System.debug('TH_Contact afterDelete');
        computeAccountTechContactDirect(null, (Map<Id, Contact>) Trigger.oldMap);
        updateNbContacts((Map<Id, Contact>) Trigger.oldMap, null, true);
    }

    /**
    * @author BCR
    * @date   10/02/2023
    * @description fill TECH Email field
    * @return void
    */
    public void affectTechEmail(List<Contact> cts) {
        for(Contact ct : cts) {
            ct.TECH_Email__c = ct.email;
        }
    }

    /**BCR W-1781 start */
    public void computeSameEmailCustomerUser(List<Contact> cts) {
        Set<String> ctEmails = new Set<String>();
        Map<String, Contact> ctsByEmail = new Map<String, Contact>();

        for(Contact ct : cts) {
            ctEmails.add(ct.email);
        }

        List<Contact> ctsDouble = [SELECT Id, Email FROM Contact WHERE Email IN:ctEmails AND RecordType.DeveloperName = 'Customer_User'];

        if(cts.size() > 0) {
            for(Contact ct : ctsDouble) {
                ctsByEmail.put(ct.email, ct);
            }

            for(Contact ct : cts) {
                if(ctsByEmail.containsKey(ct.email)) {
                    ct.email = ct.email+'.tmp';
                    ct.TECH_Force_MKT_Sync_False__c = true;
                    ct.Mkto_marketo_sync__c = false;
                }
            }
        }
    }

    /**
    * @author BCR
    * @date   10/02/2023
    * @description methode to merge customer user and sales user with same email
    * @return void
    */
    public static void mergedContacts(Map<Id, Contact> ctsMap) {
        Map<String, Contact> ctsByEmail = new Map<String, Contact>();

        for(Contact ct : ctsMap.values()) {
            System.debug('mail :'+ct.email);
            if(ct.email.endsWith('.tmp')) {
                ctsByEmail.put(ct.Email.removeEnd('.tmp'), ct);
            }
        }
        System.debug('Map : '+ctsByEmail);
        List<Contact> cts = [SELECT Id, Service__c, Function__c, Email FROM Contact WHERE Email IN:ctsByEmail.keySet() AND RecordType.DeveloperName = 'Customer_User'];
        Map<String, Schema.SObjectField> fieldApiName = Schema.SObjectType.Contact.fields.getMap();
        System.debug(cts);

        if(cts.size() > 0) {
            List<merge_contact_done__e> ctsMerge = new List<merge_contact_done__e>();
            for(Contact ct : cts) {   
                for(Schema.SObjectField field : fieldApiName.values()) {
                    if(field.getDescribe().isUpdateable() && !field.getDescribe().isCalculated() && field.getDescribe().getName() != 'email' && field.getDescribe().getName() != 'Mkto_marketo_sync__c' && ctsByEmail.get(ct.email).get(field) != null) { 
                      ct.put(field, ctsByEmail.get(ct.email).get(field));
                    }
                }
                ctsMerge.add(new merge_contact_done__e(Merged_Contact_Id__c = ct.Id,
                                                       Contact_To_be_deleted__c = ctsByEmail.get(ct.email).Id,
                                                       Created_By_Id__c = ctsByEmail.get(ct.email).createdById));
            }

            ID jobID = System.enqueueJob(new AsyncUpdateAndRedirectMergedContact(cts, ctsMerge, ctsByEmail.values()));
        }
    }

/**
    * @author TMG
    * @date   08/03/2023
    * @description fill TECH Lead non AQL
    * @return void
    */
    
// US W-002334
public static void convertLeadContactNonAQL(Map<Id, Contact> conts){
    set<String> setContactEmail = new set<String>();

    for (Contact cont : conts.values() ){
        setContactEmail.add(cont.Email);
    }
    
    system.debug('FIRST DEBUG : ' + conts.values());
    
    Map<Id, Lead> leds = new Map<Id, Lead>([SELECT Id, Email, Status, Lead_non_AQL__c, RecordType.Name FROM Lead WHERE Email IN: setContactEmail AND (Status = 'New' OR Status = 'Closed - Not Converted' OR Status = 'Closed - Converted Lead')]);   
    
    system.debug('SECOND DEBUG: ' + conts.values());
    system.debug(leds.values());
    system.debug(leds.size());
    
    for (Lead led : leds.values()){
            if(!led.Lead_non_AQL__c){
            system.debug('What is this place ?');
            led.Lead_non_AQL__c = true;
        }

    }

    update leds.values();

}    
    
    
    @TestVisible
    private class AsyncUpdateAndRedirectMergedContact implements Queueable {
        private List<Contact> cts;
        private List<merge_contact_done__e> ctsMerge;
        private List<Contact> ctsToDelete;

        public AsyncUpdateAndRedirectMergedContact(List<Contact> cts, List<merge_contact_done__e> ctsMerge, List<Contact> ctsToDelete) {
            this.cts = cts;
            this.ctsMerge = ctsMerge;
            this.ctsToDelete = ctsToDelete;

        }

        public void execute(QueueableContext context) {
            update this.cts;

            List<Database.SaveResult> results = EventBus.publish(this.ctsMerge);
    
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }       
            }

            delete ctsToDelete;
        }
    }

    
    /**
    * @author BCR
    * @date   09/03/2022
    * @description methode to compute Tech_Contact_Direct__c field on contact parent Account
    * @return void
    */
    @TestVisible
    private void computeAccountTechContactDirect(Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {
        Set<Account> accToUpdate = new Set<Account>();
        List<AccountContactRelation> accContRelats;

        Set<Id> contacts = new Set<Id>();

        if(newMap != null && oldMap == null) { //check if insert 
            accContRelats = [SELECT Id, IsDirect, ContactId, AccountId, Account.Tech_Contact_Direct__c
                                                     FROM AccountContactRelation 
                                                     WHERE ContactId = :newMap.keySet()
                                                     AND IsDirect = true]; //Get all account contact relationshit link to contact with isDirect = true

            for(AccountContactRelation accContRelat : accContRelats) {
                if(accContRelat.Account.Tech_Contact_Direct__c == false) {
                    //for every account if Tech_Contact_Direct__c == false and if contacts which are inserting are direct => pass Tech_Contact_Direct__c to true
                    accToUpdate.add(new Account(Id = accContRelat.AccountId, Tech_Contact_Direct__c = true));
                }
            }
        } else if(oldMap != null) {
            Map<Id, List<Boolean>> contactByAccount = new Map<Id, List<Boolean>>();
            Set<Id> accIds = new Set<Id>();
            if(newMap == null && oldMap != null) {
                for(Contact ct : oldMap.values()) {
                    accIds.add(ct.AccountId);
                }
            } else if(newMap != null && oldMap != null) {
                for(Contact ct : newMap.values()) { 
                    if(ct.AccountId != oldMap.get(ct.Id).AccountId) {
                        accIds.add(ct.AccountId);
                        accIds.add(oldMap.get(ct.Id).AccountId);
                    }
                }
                System.debug('contact update accIDS : '+accIds);
            }
            

            Map<Id, Account> accs = new Map<Id, Account>([SELECT Id, Tech_Contact_Direct__c FROM Account WHERE Id = :accIds]);
            System.debug('acc : '+accs);

            accContRelats = [SELECT Id, IsDirect, ContactId, AccountId, Account.Tech_Contact_Direct__c
                             FROM AccountContactRelation 
                             WHERE AccountId = :accs.keySet()];

                             System.debug('acc relation : '+accContRelats);

            for(AccountContactRelation accContRelat : accContRelats) {
                if(!contactByAccount.containsKey(accContRelat.AccountId)) {
                    contactByAccount.put(accContRelat.AccountId, new List<Boolean>());
                }
                contactByAccount.get(accContRelat.AccountId).add(accContRelat.IsDirect);
            }

            System.debug('Contact by Account '+contactByAccount);

            for(Account acc : accs.values()) {
                System.debug('acc :'+acc);
                System.debug('contactByAccount :'+contactByAccount);
                System.debug(contactByAccount.containsKey(acc.Id));

                if(acc.Tech_Contact_Direct__c == true && !contactByAccount.containsKey(acc.Id)) { //Delete scenario when 0 contacts are found on the account
                    System.debug('DELETE SCENARIO');

                    accToUpdate.add(new Account(Id = acc.Id, Tech_Contact_Direct__c = false));
                } else if(contactByAccount.containsKey(acc.Id)) {
                    System.debug('NON DELETE SCENARIO');
                    if(acc.Tech_Contact_Direct__c == false && contactByAccount.get(acc.Id).contains(true)) {
                        System.debug('SCENARIO FALSE => TRUE');
                        accToUpdate.add(new Account(Id = acc.Id, Tech_Contact_Direct__c = true));
                    } else if(acc.Tech_Contact_Direct__c == true && !contactByAccount.get(acc.Id).contains(true) ) {
                        System.debug('SCENARIO TRUE => FALSE');
                        accToUpdate.add(new Account(Id = acc.Id, Tech_Contact_Direct__c = false));
                    }
                    
                }  
            }
            System.debug('Acc to update : '+accToUpdate);
        }
        if(accToUpdate.size() > 0) {
            SBQQ.TriggerControl.disable();
            update new List<Account>(accToUpdate);
            SBQQ.TriggerControl.enable();
        }
    }

    private void updateNbContacts(Map<Id, Contact> data, Map<Id, Contact> oldData, Boolean del) {

        Map<Id, List<Id>> mapAccountToContacts = new Map<Id, List<Id>>();
        Map<Id, List<Id>> mapAccountMinusOne = new Map<Id, List<Id>>();

        List<Id> contactsIds = new List<Id>(data.keySet());

        List<AccountContactRelation> lstACR = Database.query('SELECT '+String.join(new List<String>(Schema.getGlobalDescribe().get('AccountContactRelation').getDescribe().fields.getMap().keySet()), ', ')+' FROM AccountContactRelation WHERE ContactId IN :contactsIds');

        for(AccountContactRelation acr: lstACR) {
            Contact oldCt = (oldData != null) ? oldData.get(acr.ContactId) : null;
            Contact ct = data.get(acr.ContactId);
            if((ct.Active__c && ct.Compliant__c && oldCt == null) || (oldCt != null && ct.Active__c && ct.Compliant__c && (oldCt.Active__c != ct.Active__c || oldCt.Compliant__c != ct.Compliant__c))) {
                if(mapAccountToContacts.containsKey(acr.AccountId)) {
                    List<Id> tmp = mapAccountToContacts.get(acr.AccountId);
                    tmp.add(ct.Id);
                    mapAccountToContacts.put(acr.AccountId, tmp);
                } else {
                    mapAccountToContacts.put(acr.AccountId, new List<Id>{ct.Id});
                }
            } else if(oldCt != null && ((oldCt.Active__c && !ct.Active__c) || (oldCt.Compliant__c && !ct.Compliant__c))) {
                if(mapAccountMinusOne.containsKey(acr.AccountId)) {
                    List<Id> tmp = mapAccountMinusOne.get(acr.AccountId);
                    tmp.add(ct.Id);
                    mapAccountMinusOne.put(acr.AccountId, tmp);
                } else {
                    mapAccountMinusOne.put(acr.AccountId, new List<Id>{ct.Id});
                }
            }
        }

        List<Id> accsIds = new List<Id>(mapAccountToContacts.keySet());
        accsIds.addAll(new List<Id>(mapAccountMinusOne.keySet()));
        List<Account> lstAccs = Database.query('SELECT '+String.join(new List<String>(Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().keySet()), ', ')+' FROM Account WHERE Id IN :accsIds');

        List<Account> accsToUpdate = new List<Account>();

        for(Account acc: lstAccs) {
            if(acc.TECH_Nb_Contact__c == null) {
                acc.TECH_Nb_Contact__c = 0;
            }
            if(del) {
                if(mapAccountToContacts.containsKey(acc.Id))
                    acc.TECH_Nb_Contact__c -= mapAccountToContacts.get(acc.Id).size();
            } else {
                System.Debug(mapAccountMinusOne);
                if(mapAccountMinusOne.containsKey(acc.Id))
                    acc.TECH_Nb_Contact__c -= mapAccountMinusOne.get(acc.Id).size();
                
                if(mapAccountToContacts.containsKey(acc.Id))
                    acc.TECH_Nb_Contact__c += mapAccountToContacts.get(acc.Id).size();
            }
            accsToUpdate.add(acc);
        }

        if(accsToUpdate.size() > 0) {
            SBQQ.TriggerControl.disable();
            update accsToUpdate;
            SBQQ.TriggerControl.enable();
        }

    }

    
}