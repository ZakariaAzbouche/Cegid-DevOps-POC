/**
 * @File Name          : TH_Lead
 * @Description        : Update Lead Value 
 * @Author             : SRA   
 * @Group              : Capgemini
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    20/07/2021         AZI               Initial Version
 * ---    -----------       -------           ------------------------ 
 * 1.5    21/09/2021         BCR               Refacto complete 
 * ---    -----------       -------           ------------------------ 
**/
public without sharing class TH_Lead extends TriggerHandler {
	
	/*List<String> lst = new List<String>();*/

    
    public override void beforeInsert() {   
        System.debug('TH_Lead beforeInsert');

        System.debug(Trigger.new);
        

        Group grpTelemark = [SELECT Id FROM Group WHERE DeveloperName = 'Telemarketing_Leads' LIMIT 1];
        List<User> usrs = [SELECT Id FROM User WHERE Name =: System.Label.leadOwnerFromTeleMarkLead];

        affectLeadTelemarketingGroup(Trigger.new, null, grpTelemark.Id);
        computeBufferName(Trigger.new, grpTelemark.Id);
        affectOwnerToTSLeadChange(Trigger.new, usrs[0].Id, grpTelemark.Id);


        /** AZI W-001656***/
        RecordType recordTypeLead = [SELECT Id FROM RecordType WHERE Name = 'Lead'];
        RecordType recordTypeLeadContact = [SELECT Id FROM RecordType WHERE Name = 'Contact Lead'];
        RecordType recordTypeLeadTelemarketing = [SELECT Id FROM RecordType WHERE Name = 'Lead Telemarketing'];  
        /** FIN AZI W-001656***/
        
        /****Refacto BCR B-1323/1328 W-1766**/
        Set<String> leadEmails = new Set<String>();
      
        
        for(Lead lead: (List<Lead>) Trigger.New) {
            leadEmails.add(lead.email);
        }

        List<Contact> cts = [SELECT Id,
                                    Account.Id,
                                    Phone,
                                    Email,  
                                    Direct_Phone__c,
                                    MobilePhone, 
                                    Service__c, 
                                    Function__c, 
                                    Account.Name, 
                                    Account.Type__c, 
                                    Account.Industry, 
                                    Account.Industry__c, 
                                    Account.Industry_Code__c, 
                                    Account.Industry_Label__c, 
                                    Account.Retail_Segmentation__c, 
                                    Account.National_ID__c, 
                                    Account.National_ID_Exception__c, 
                                    Account.IntercommunityVATnumber__c, 
                                    Account.ParentId, Account.Nature__c, 
                                    Account.Website, Account.AnnualRevenue, 
                                    Account.NumberOfEmployees, 
                                    Account.No_of_Stores__c, 
                                    Account.No_of_establishments__c, 
                                    Account.Payslips_per_month__c, 
                                    Account.Prescriber__c 
                                    FROM Contact WHERE Email IN: leadEmails];

        Map<String, Contact> ctsByEmail = new Map<String, Contact>();

        for(Contact ct : cts) {
            ctsByEmail.put(ct.Email, ct);
        }
        /**** End Refacto**/

        for(Lead lead: (List<Lead>) Trigger.New) {   
            /** AZI W-001656 refacto BCR***/                                
            

            if(recordTypeLeadTelemarketing.Id.equals(lead.RecordTypeId)) {
                lead.ATTRILTSource__c = lead.Last_Touch_Source_Telemarketing__c;
                
                if (!'Assigned'.equals(lead.Status) && !'New'.equals(lead.Status) && !'In Buffer'.equals(lead.Status)){
                    lead.addError(System.Label.VR_Lead_Status_Telemarketing);            ///Etrange dephasé par rapport au B-1335
                    return;
                }
            }
            /** FIN AZI W-001656***/    
        

            //Lead with Chosen Solution
            if(!String.isBlank(lead.Lead_s_Chosen_Solution__c)){
               lead.Expertise__c = switch(lead.Lead_s_Chosen_Solution__c);            
            }
            
             //IsDealRegistration ?
             if(lead.ImpartnerPRM__IsDealRegistration__c) { //=>US-1650
                //IsDealRegsitration and Partner Account (à valider avec Samir)
                if(!String.isBlank(lead.ImpartnerPRM__PartnerAccount__c) && String.isBlank(lead.Partner_Distributor__c)){ //la condition en l'état ne sert à rien car l'affectation est fait de toute façon
                    //Update Distributor Partner
                    lead.Partner_Distributor__c = lead.ImpartnerPRM__PartnerAccount__c;
                }
                //Update Distributor Partner
                lead.Partner_Distributor__c = lead.ImpartnerPRM__PartnerAccount__c;                                
                         
            }

            /** AZI W-001656***/
            if(ctsByEmail.containsKey(lead.email) == false) {  
                lead.RecordTypeId = recordTypeLead.Id;
                lead.Mkto_marketo_sync__c = true;
            } else {
                lead.RecordTypeId = recordTypeLeadContact.Id;
                lead.Contact__c= ctsByEmail.get(lead.email).Id;
                lead.Existing_Account__c = ctsByEmail.get(lead.email).Account.Id;
                lead.Direct_Phone__c = ctsByEmail.get(lead.email).Direct_Phone__c;
                lead.MobilePhone = ctsByEmail.get(lead.email).MobilePhone;
                lead.Service__c = ctsByEmail.get(lead.email).Service__c;
                lead.Function__c = ctsByEmail.get(lead.email).Function__c;
                lead.Company = ctsByEmail.get(lead.email).Account.Name;
                lead.Type__c = ctsByEmail.get(lead.email).Account.Type__c;
                lead.Industry = ctsByEmail.get(lead.email).Account.Industry;
                lead.Industry_Code__c = ctsByEmail.get(lead.email).Account.Industry_Code__c;                                
                lead.Retail_Segmentation__c = ctsByEmail.get(lead.email).Account.Retail_Segmentation__c;
                lead.National_ID__c = ctsByEmail.get(lead.email).Account.National_ID__c;
                lead.National_ID_Exception__c = ctsByEmail.get(lead.email).Account.National_ID_Exception__c;
                lead.Intercommunity_VAT_number__c = ctsByEmail.get(lead.email).Account.IntercommunityVATnumber__c;
                lead.Nature__c = ctsByEmail.get(lead.email).Account.Nature__c;
                lead.Website = ctsByEmail.get(lead.email).Account.Website;
                lead.AnnualRevenue = ctsByEmail.get(lead.email).Account.AnnualRevenue;
                lead.NumberOfEmployees = ctsByEmail.get(lead.email).Account.NumberOfEmployees;
                lead.No_of_Stores__c = ctsByEmail.get(lead.email).Account.No_of_Stores__c;
                lead.No_of_establishments__c = ctsByEmail.get(lead.email).Account.No_of_establishments__c;
                lead.Payslips_per_month__c = ctsByEmail.get(lead.email).Account.Payslips_per_month__c;
                lead.Prescriber__c = ctsByEmail.get(lead.email).Account.Prescriber__c; 
                lead.Mkto_marketo_sync__c = false;               
            }
            /**Fin AZI W-001656***/

        }
    }

    public override void afterInsert() {  
        System.debug('TH_Lead AfterInsert');

        Set<Id> leadIds = new Set<Id>();
        for(Lead lead: (List<Lead>) Trigger.New) {
            leadIds.add(lead.Id);
        }

       Map<Id, Lead> ldsMap = new Map<Id, Lead>([SELECT Partner_Distributor__r.OwnerId,
                                      ImpartnerPRM__PartnerAccount__r.OwnerId, 
                                      ImpartnerPRM__PartnerAccount__r.Name 
                                      FROM Lead 
                                      WHERE Id IN:leadIds]);
        //end refacto

        List<Lead> leads = new List<Lead>();
        for(Lead lead:(List<Lead>)Trigger.New){
            
            //Chatter Post
            if(lead.ImpartnerPRM__IsDealRegistration__c){
                String body = ' \n A new Lead was created by the Partner '+ldsMap.get(lead.Id).ImpartnerPRM__PartnerAccount__r.Name+' : '+lead.Salutation+' '+lead.FirstName+' '+lead.LastName;
                
                String userId = ldsMap.get(lead.Id).Partner_Distributor__r.OwnerId;
                if(String.isBlank(userId)) {
                    userId = UserInfo.getUserId();
                } 

               Utility.mentionTextPost(userId, lead.Name, lead.Id, body);
            }
            
        }
        System.debug('END TH_Lead AfterInsert');
    }

    //BCR B-1335 Start
    public override void beforeUpdate() {
        Map<Id, Lead> leadToBeProcess = (Map<Id, Lead>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.BEFORE_UPDATE);     
        if(leadToBeProcess.isEmpty()) {
            System.debug('No Lead to be processed');
        } else {
            Group grpTelemark = [SELECT Id FROM Group WHERE DeveloperName = 'Telemarketing_Leads' LIMIT 1];
            List<User> usrs = [SELECT Id FROM User WHERE Name = :System.Label.leadOwnerFromTeleMarkLead];
            User connectedUser = [SELECT Id, Profile.Name, SalesPRM__c, IsManager__c FROM User WHERE Id =: UserInfo.getUserId()];
            List<PermissionSetAssignment> permissions = [SELECT Id,
                                                            PermissionSet.Name,
                                                            PermissionSet.ProfileId,
                                                            PermissionSet.Profile.Name,
                                                            AssigneeId, Assignee.Profile.Name 
                                                            FROM PermissionSetAssignment
                                                            WHERE AssigneeId =: UserInfo.getUserId()];
            System.debug('permission ' +permissions);

            mergeLeadFieldForTelemark(leadToBeProcess.values(), connectedUser, permissions);
            checkUpdateValidationSDRPRM(leadToBeProcess.values(), (Map<Id, Lead>)Trigger.oldMap, connectedUser, permissions);

            affectLeadTelemarketingGroup(leadToBeProcess.values(), (Map<Id, Lead>)Trigger.oldMap, grpTelemark.Id);
            computeBufferName(leadToBeProcess.values(), grpTelemark.Id);
            affectOwnerToTSLeadChange(leadToBeProcess.values(), usrs[0].Id, grpTelemark.Id);
            manageRejectLead(leadToBeProcess.values(), (Map<Id, Lead>)Trigger.oldMap);
            
            //MAIT US 2273
            setIndustryCode(leadToBeProcess.values(), (Map<Id, Lead>)Trigger.oldMap);
            rejectCauseManagement(leadToBeProcess.values(), (Map<Id, Lead>)Trigger.oldMap);
        }
    }

    public override void beforeDelete() {
       User connectedUser = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()];
       for(Lead ld : ((Map<Id, Lead>)Trigger.oldMap).values()) {
            preventLeadDelete(connectedUser, ld);
        }
    }

    /** BCR B-2093 start */
    public void preventLeadDelete(User usr, Lead ld) {
        if(usr.profile.Name != 'System Administrator' && usr.profile.Name != 'Administrateur Système' && usr.profile.Name != 'Marketo') {
            ld.addError('You can\'t delete this Lead with your profile');
        }
    }
    /** BCR B-2093 end */ 
    
    
    
    /** BCR Start B-2044 */
    public void rejectCauseManagement(List<Lead> lds, Map<Id, Lead> oldLeads) {
        for(Lead ld : lds) {
            if(ld.Status != 'Closed - Not Converted' && oldLeads.get(ld.Id).Status == 'Closed - Not Converted') {
                ld.Reject_Cause__c = null;
            }
        }
    }
    /** BCR end B-2044 */


    /** BCR Start W-1928 */
    public void checkUpdateValidationSDRPRM(List<Lead> lds, Map<Id, Lead> oldLeads, User connectedUser, List<PermissionSetAssignment> permissions) {
        Boolean telemarkWithPRM = false;
        Boolean telemark = false;
        Boolean SDR = false;
        Boolean PRM = false;
        
        System.debug('BYPASS '+LeadVRSDRPRMTelemark.byPassVR);

        if(connectedUser.Profile.Name == 'Cegid Telemarketing' && connectedUser.SalesPRM__c) {
            telemarkWithPRM = true;
        } else if(connectedUser.Profile.Name == 'Cegid Telemarketing') {
            telemark = true;
        } else {
            for(PermissionSetAssignment perAssi : permissions) {
                if(perAssi.PermissionSet.Name == 'SDR_Lead_treatment') {
                    SDR = true;
    
                } else if(perAssi.PermissionSet.Name == 'PRMSalesUsers') {
                    PRM = true;
                }
            }
        }

        System.debug('Tele : '+telemark);
        System.debug('SDR : '+SDR);
        System.debug('PRM : '+PRM);

        if(telemarkWithPRM) {
			for(Lead ld : lds) {
                if((/*ld.Status == 'Closed - Not Converted' ||*/ oldLeads.get(ld.Id).Status == 'Closed - Not Converted')) {
                    if(LeadVRSDRPRMTelemark.byPassVR == false){
                        ld.addError('You can\'t modifiy this lead');
                        system.debug('OLD LEAD STATUS: ' + oldLeads.get(ld.Id).Status);
                        system.debug('LEAD CURRENT STATUS: ' + oldLeads.get(ld.Id).Status);
                    }
                }
            }
        } else if(telemark) {
            for(Lead ld : lds) {
                if((ld.Status == 'New' || oldLeads.get(ld.Id).Status == 'New' || oldLeads.get(ld.Id).Status == 'Closed - Not Converted')) {
                    if(LeadVRSDRPRMTelemark.byPassVR == false) {
                        ld.addError('You can\'t modifiy this lead');
                    }
                }
            }
        } else if(SDR) {
            for(Lead ld : lds) {    
                if((ld.Status != 'New' && ld.Status != 'Closed - Not Converted') || LeadVRSDRPRMTelemark.byPassVR == false) {
                    if((ld.OwnerId != connectedUser.Id && !connectedUser.IsManager__c && connectedUser.Id != oldLeads.get(ld.Id).OwnerId) || (ld.OwnerId != connectedUser.Id && connectedUser.IsManager__c && ld.OwnerId == oldLeads.get(ld.Id).OwnerId)) {
                        ld.addError(System.label.VR_Lead_PAM_NotLeadOwner);
                    } else if(ld.OwnerId != oldLeads.get(ld.Id).OwnerId) {
                        if(ld.LeadSource != 'SDR-Marketing Prospecting' && ld.LeadSource != 'SDR Lead Purchase') {
                            ld.addError(System.label.VR_Lead_SDR_NotSDRLead);
                        }
                    }
                }
            }
        } else if (PRM) {
            for(Lead ld : lds) {
                if((ld.Status != 'New' && ld.Status != 'Closed - Not Converted') || LeadVRSDRPRMTelemark.byPassVR == false) { //&& enSKiByPass 
                    if((ld.OwnerId != connectedUser.Id && !connectedUser.IsManager__c && connectedUser.Id != oldLeads.get(ld.Id).OwnerId) 
                    || (ld.OwnerId != connectedUser.Id && connectedUser.IsManager__c && ld.OwnerId == oldLeads.get(ld.Id).OwnerId)) {
                        ld.addError(System.label.VR_Lead_PAM_NotLeadOwner);
                    } else if(ld.OwnerId != oldLeads.get(ld.Id).OwnerId && oldLeads.get(ld.Id).OwnerId != connectedUser.Id) {
                        if(!ld.ImpartnerPRM__IsDealRegistration__c) {
                            ld.addError(System.label.VR_Lead_PAM_NotIsDealReg);
                        } 
                    }
                }
            }
        }
    }

    /** BCR end W-1928 */


    
    // US 2273
    // Insert Defautl IndustryCode - Lead Qualification
    @TestVisible
    private void setIndustryCode(List<Lead> lds, Map<Id, Lead> oldMap) {

        Map<String, List<Id>> mapIndustryToLeads = new Map<String, List<Id>>();

        List<Lead> ldsUpdate = new List<Lead>();

        System.debug(lds);

        for(Lead ld: lds) {
            Lead oldLd = oldMap.get(ld.Id);

            if(ld.Industry != null && ld.Industry != oldLd.Industry) {
                if(mapIndustryToLeads.containsKey(ld.Industry)) {
                    List<Id> lstTmp = mapIndustryToLeads.get(ld.Industry);
                    lstTmp.add(ld.Id);
                    mapIndustryToLeads.put(ld.Industry, lstTmp);
                } else {
                    mapIndustryToLeads.put(ld.Industry, new List<Id>{ld.Id});
                }
				ldsUpdate.add(ld);
            }
        }

        System.debug(mapIndustryToLeads);

        Map<String, Id> mapIndsNameToId = new Map<String, Id>();
        List<Industry__c> inds = [SELECT Id, Industry__c FROM Industry__c WHERE Default_NAF__c = true AND Industry__c IN :mapIndustryToLeads.keySet()];
        
        System.debug(inds);

        for(Industry__c ind: inds) {
            mapIndsNameToId.put(ind.Industry__c, ind.Id);
        }

        System.debug(mapIndsNameToId);

        for(Lead ld: ldsUpdate) {
			System.debug(mapIndsNameToId.get(ld.Industry));
			ld.Industry_Code__c = mapIndsNameToId.get(ld.Industry);

			System.debug(ld);
        }

    }

 /*  @TestVisible
    private void mergeLeadFieldForTelemark(List<Lead> leads) {
        for(Lead ld : leads) {
            if(ld.TECH_Is_Fusion__c) {
                LeadVRSDRPRMTelemark.enabledByPassVR();
                ld.ATTRILTSource__c = ld.Last_Touch_Source_Telemarketing__c;
                ld.Marketing_Status__c = ld.TECH_Marketing_Status_Tmp__c;
                ld.Marketing_Campaign__c = ld.TECH_Marketing_Campaign_Tmp__c;
                ld.TECH_Is_Fusion__c = false;
            }
        }
    }*/
@TestVisible
 private void mergeLeadFieldForTelemark(List<Lead> leads, User usr, List<PermissionSetAssignment> perms) {
        Boolean isInPermSet = false;
     
 		for (PermissionSetAssignment perm : perms ) {
            System.debug(perm.PermissionSet.Name);
            if(perm.PermissionSet.Name == 'Marketing_Lead_and_Opportunity_Creators'){
                isInPermSet = true;
            }
        }

     system.debug(isInPermSet);
     
        for(Lead ld : leads) {
            if(ld.TECH_Is_Fusion__c && (isInPermSet || usr.Profile.Name == 'System Administrator' || usr.Profile.Name == 'Administrateur Système' || usr.Profile.Name == 'Marketo')) {
                LeadVRSDRPRMTelemark.enabledByPassVR();
                ld.ATTRILTSource__c = ld.Last_Touch_Source_Telemarketing__c;
                ld.Marketing_Status__c = ld.TECH_Marketing_Status_Tmp__c;
                ld.Marketing_Campaign__c = ld.TECH_Marketing_Campaign_Tmp__c;
                ld.TECH_Is_Fusion__c = false;
                system.debug('LEAD 1 : '+ ld);
            } else if (ld.TECH_Is_Fusion__c){
				system.debug('You can\'t merged this lead');
                ld.addError('You can\'t merge this lead');
			                
                
            }
        }
        }    
   

    
     //BCR B-1335 END

    //BCR B-1529 Start
    public override void afterUpdate() {
        Map<Id, Lead> leadToBeProcess = (Map<Id, Lead>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.AFTER_UPDATE);
        
        if(leadToBeProcess.isEmpty()) {
            System.debug('No Lead to be processed');
        } else {
            Map<Id, Lead> newConvertedLead = new Map<Id, Lead>();
            for(Lead ld : leadToBeProcess.values()) {
                if(ld.IsConverted && Trigger.oldMap.get(ld.Id).get('IsConverted') == false && ld.ConvertedOpportunityId != null && ld.TECH_Autoconvert_Lead__c == false) {
                    newConvertedLead.put(ld.Id, ld);
                }
                affectNoOfVehiclesOnAccount(leadToBeProcess);
            }
            if(!newConvertedLead.isEmpty()) {
                leadOppyMergeTraitement(newConvertedLead);
                
            }
        }
    }

    @TestVisible
    private void leadOppyMergeTraitement(Map<Id, Lead> newLead) {
        Set<Id> oppIds = new Set<Id>();
        
        for(Lead ld : newLead.values()) {
            oppIds.add(ld.ConvertedOpportunityId);
        }
        System.debug(oppIds);
        if(!oppIds.isEmpty()) {
            Map<Id, Opportunity> opps = new Map<Id, Opportunity>([SELECT Id, Description, TECH_New_oppy_From_Lead__c, ownerId FROM Opportunity WHERE Id IN: oppIds]);
            List<Opportunity> oppToUpdate = new List<Opportunity>();
        
            String message;
            for(Lead ld : newLead.values()) {
                message = '';
                if(ld.Amount__c != null) {
                    message += 'The Lead\'s  Budget is: ' + ld.Amount__c + '\n\n';
                }
                message +='Project Description (Lead\'s internal comment from the Telemarketing) : ' + ld.Internal_Comment__c  + '\n';

                if(!String.isBlank(ld.Project_s_associated_contact_1__c)) {
                    message += 'Associated contacts: \n 1 - ' + ld.Project_s_associated_contact_1__c;

                    if(ld.Role_in_decision_1__c != null) {
                        message += ' who is the '+ ld.Role_in_decision_1__c;
                    }

                    if(ld.Availability1__c != null){
                        message += ' available ' + ld.Availability1__c + '.';
                    } 

                } else {
                    //message += ld.Project_s_associated_contact_1__c + '\n';
            
                    if(!String.isBlank(ld.Project_s_associated_contact_2__c)) {
                        message += 'Associated contacts: \n 2 - ' + ld.Project_s_associated_contact_2__c;

                        if(ld.Role_in_decision_2__c != null) {
                            message += ' who is the '+ ld.Role_in_decision_2__c;
                        }

                        if(ld.Availability2__c != null){
                            message += ' available ' + ld.Availability2__c + '.';
                        } 
                        
                    } else {
                        //message += ld.Project_s_associated_contact_2__c + '\n';
                    
                    }
                }

                if(opps.get(ld.ConvertedOpportunityId).TECH_New_oppy_From_Lead__c) {
                    opps.get(ld.ConvertedOpportunityId).Description = 'Lead\'s external comment : '+ld.External_Comment__c + '\n\nCreated from Lead  ' + ld.FirstName  + ' ' + ld.LastName + ' : \n \n' + message;
                    opps.get(ld.ConvertedOpportunityId).TECH_New_oppy_From_Lead__c = false;
                    oppToUpdate.add(opps.get(ld.ConvertedOpportunityId));
                } else {
                    String bodyMessage = 'The lead ' + ld.FirstName + ' ' + ld.LastName  + ' has been  merged with your opportunity. \n' +  message;
                    Utility.mentionTextPost(opps.get(ld.ConvertedOpportunityId).OwnerId, null, ld.ConvertedOpportunityId, bodyMessage);
                }
                
            }

        
            if(!oppToUpdate.isEmpty()) {
                update oppToUpdate;
            }
        }
    }

    //BCR B-1529 END 

    //BCR W-001839 Start

    @TestVisible
    private void affectLeadTelemarketingGroup(List<Lead> lds, Map<Id, Lead> ldOldMap, Id idgrpTelemark) {
        System.debug('affectLeadTelemarketingGroup');
        for(Lead ld : lds) {

            if(ld.Marketing_Status__c == 'AQL' && (ldOldMap == null || ldOldMap.get(ld.Id).Marketing_Status__c != 'AQL')) {
                if(ld.Status != 'Qualified' &&
                   ld.Status != 'Closed - Converted Lead' &&
                   ld.Status != 'Assigned' &&
                   ld.Status != 'In Progress') {
                    ld.OwnerId = idgrpTelemark;
                    ld.Status = 'In buffer';
                }
            }
        }
    }

    @TestVisible
    private void computeBufferName(List<Lead> lds, Id idgrpTelemark) {
        System.debug('computeBufferName');
        for(Lead ld : lds) {
            System.debug('OWNER ID : '+ld.OwnerId);
            system.debug(ld.OwnerId + '  ' + idgrpTelemark);
            if(ld.OwnerId == idgrpTelemark) { //If OwnerId isn't the group telemark ID => no buffer calculation
                system.debug(ld.OwnerId + '  ' + idgrpTelemark);
                system.debug(ld.LeadSource);
                system.debug(ld.Expertise__c);
/*modif TMG*/  if((ld.LeadSource == 'SDR-Marketing Prospecting' || ld.LeadSource == 'SDR Lead Purchase')) {
    				system.debug('!!!!SDR MARKETING PROSPECTING!!!!');
                    if(ld.Expertise__c == '110'){

                        ld.Buffer_Name__c = 'SDR CPA France	';
                        }
                        if(ld.Expertise__c == '350' || ld.Expertise__c == '310' || ld.Expertise__c == '370' || ld.Expertise__c == '360'){
                            
                            ld.Buffer_Name__c = 'SDR Finance France';
                        }
                        if(ld.Expertise__c == '340' && ld.Core_Business__c == '124'){
                            
                            ld.Buffer_Name__c = 'SDR Notilus';
                        }
                        if(ld.Expertise__c == '340' && ld.Core_Business__c != '124'){

                            ld.Buffer_Name__c = 'SDR Finance France';
                        }
                        if(ld.Expertise__c == '200' && ld.Core_Business__c == '251'){

                            ld.Buffer_Name__c = 'SDR StorIQ';
                        }
                        if(ld.Expertise__c == '200' && ld.Core_Business__c != '251'){

                            ld.Buffer_Name__c = 'SDR Retail France';
                        }
                        if(ld.Expertise__c == '320' || ld.Expertise__c == '380'){
                            
                            if(ld.CountryCode == 'FR' || ld.CountryCode == null){
                                ld.Buffer_Name__c = 'SDR HCM France';
                            } if(ld.CountryCode != 'FR' && ld.CountryCode != null) {
                                ld.Buffer_Name__c = 'SDR HCM International';
                            }
 /*fin modif TMG*/   }

                } else {
                    switch on ld.Expertise__c {
                        when null, '110', '350', '100', '999', '370', '360'{
                            ld.Buffer_Name__c = 'Telemarketing France';
                        }
                        when '320' {
                            system.debug('HCM');
                            if(ld.Marketing_Campaign__c != null && ld.Marketing_Campaign__c.containsIgnoreCase('VAR')) {
                                ld.Buffer_Name__c = 'Partner Marketing leads – HCM';
                            } else if(ld.Core_Business__c == '126') {
                                system.debug('Time management');

                                if(ld.CountryCode == null ||
                                   ld.CountryCode == 'ES'||
                                   ld.CountryCode == 'PT'||
                                   ld.CountryCode == 'AR'||
                                   ld.CountryCode == 'CL'||
                                   ld.CountryCode == 'CO'||
                                   ld.CountryCode == 'MX'||
                                   ld.CountryCode == 'PE'||
                                   ld.CountryCode == 'BR'||
                                   ld.CountryCode == 'BO'||
                                   ld.CountryCode == 'CR'||
                                   ld.CountryCode == 'CU'||
                                   ld.CountryCode == 'EC'||
                                   ld.CountryCode == 'SV'||
                                   ld.CountryCode == 'GY'||
                                   ld.CountryCode == 'GT'||
                                   ld.CountryCode == 'HT'||
                                   ld.CountryCode == 'HN'||
                                   ld.CountryCode == 'JM'||
                                   ld.CountryCode == 'NI'||
                                   ld.CountryCode == 'PY'||
                                   ld.CountryCode == 'PA'||
                                   ld.CountryCode == 'SR'||
                                   ld.CountryCode == 'UY'||
                                   ld.CountryCode == 'VE'||
                                   ld.CountryCode == 'DO') {

                                    ld.Buffer_Name__c = 'HCM Visual Time';

                                   } else {

                                    ld.Buffer_Name__c = 'HCM Time Management Rest of the world';

                                   }
                            } else {

                                if(ld.CountryCode == null) {

                                    ld.Buffer_Name__c = 'Telemarketing France';

                                } else if(ld.CountryCode != 'AD' && 
                                          ld.CountryCode != 'AG' && 
                                          ld.CountryCode != 'AR' && 
                                          ld.CountryCode != 'BS' && 
                                          ld.CountryCode != 'BB' && 
                                          ld.CountryCode != 'BZ' && 
                                          ld.CountryCode != 'BO' && 
                                          ld.CountryCode != 'BR' && 
                                          ld.CountryCode != 'CL' && 
                                          ld.CountryCode != 'CO' && 
                                          ld.CountryCode != 'CR' && 
                                          ld.CountryCode != 'CU' && 
                                          ld.CountryCode != 'DM' && 
                                          ld.CountryCode != 'DO' && 
                                          ld.CountryCode != 'EC' && 
                                          ld.CountryCode != 'SV' && 
                                          ld.CountryCode != 'GD' && 
                                          ld.CountryCode != 'GT' && 
                                          ld.CountryCode != 'HT' && 
                                          ld.CountryCode != 'HN' && 
                                          ld.CountryCode != 'JM' && 
                                          ld.CountryCode != 'MX' && 
                                          ld.CountryCode != 'NI' && 
                                          ld.CountryCode != 'PA' && 
                                          ld.CountryCode != 'PY' && 
                                          ld.CountryCode != 'PE' && 
                                          ld.CountryCode != 'PT' && 
                                          ld.CountryCode != 'LC' &&  
                                          ld.CountryCode != 'ES' && 
                                          ld.CountryCode != 'SR' && 
                                          ld.CountryCode != 'UY' && 
                                          ld.CountryCode != 'VE' && 
                                          ld.CountryCode != 'CA' && 
                                          ld.CountryCode != 'US') {

                                            ld.Buffer_Name__c = 'Telemarketing France';

                                } else if(ld.CountryCode == 'AD' ||
                                          ld.CountryCode == 'ES' ||
                                          ld.CountryCode == 'PT') {

                                            ld.Buffer_Name__c = 'HCM Iberia';

                                } else if(ld.CountryCode == 'AG' || 
                                          ld.CountryCode == 'AR' || 
                                          ld.CountryCode == 'BS' || 
                                          ld.CountryCode == 'BB' || 
                                          ld.CountryCode == 'BZ' || 
                                          ld.CountryCode == 'BO' || 
                                          ld.CountryCode == 'BR' || 
                                          ld.CountryCode == 'CL' || 
                                          ld.CountryCode == 'CO' || 
                                          ld.CountryCode == 'CR' || 
                                          ld.CountryCode == 'CU' || 
                                          ld.CountryCode == 'DM' || 
                                          ld.CountryCode == 'DO' || 
                                          ld.CountryCode == 'EC' || 
                                          ld.CountryCode == 'SV' || 
                                          ld.CountryCode == 'GD' || 
                                          ld.CountryCode == 'GT' || 
                                          ld.CountryCode == 'HT' || 
                                          ld.CountryCode == 'HN' || 
                                          ld.CountryCode == 'JM' || 
                                          ld.CountryCode == 'MX' || 
                                          ld.CountryCode == 'NI' || 
                                          ld.CountryCode == 'PA' || 
                                          ld.CountryCode == 'PY' || 
                                          ld.CountryCode == 'PE' || 
                                          ld.CountryCode == 'LC' ||  
                                          ld.CountryCode == 'SR' || 
                                          ld.CountryCode == 'UY' || 
                                          ld.CountryCode == 'VE') {

                                            ld.Buffer_Name__c = 'HCM Latam';

                                          } else if(ld.CountryCode == 'CA' || 
                                                    ld.CountryCode == 'US') {

                                                ld.Buffer_Name__c = 'HCM Canada - USA';
                                        }
                                
                            }
                            
                            /*if(ld.CountryCode == null) {
    
                                ld.Buffer_Name__c = 'Telemarketing France';
    
                            } else if(ld.CountryCode != 'AD' && 
                                      ld.CountryCode != 'AG' && 
                                      ld.CountryCode != 'AR' && 
                                      ld.CountryCode != 'BS' && 
                                      ld.CountryCode != 'BB' && 
                                      ld.CountryCode != 'BZ' && 
                                      ld.CountryCode != 'BO' && 
                                      ld.CountryCode != 'BR' && 
                                      ld.CountryCode != 'CL' && 
                                      ld.CountryCode != 'CO' && 
                                      ld.CountryCode != 'CR' && 
                                      ld.CountryCode != 'CU' && 
                                      ld.CountryCode != 'DM' && 
                                      ld.CountryCode != 'DO' && 
                                      ld.CountryCode != 'EC' && 
                                      ld.CountryCode != 'SV' && 
                                      ld.CountryCode != 'GF' && 
                                      ld.CountryCode != 'GD' && 
                                      ld.CountryCode != 'GT' && 
                                      ld.CountryCode != 'GY' && 
                                      ld.CountryCode != 'HT' && 
                                      ld.CountryCode != 'HN' && 
                                      ld.CountryCode != 'JM' && 
                                      ld.CountryCode != 'MX' && 
                                      ld.CountryCode != 'NI' && 
                                      ld.CountryCode != 'PA' && 
                                      ld.CountryCode != 'PY' && 
                                      ld.CountryCode != 'PE' && 
                                      ld.CountryCode != 'PT' && 
                                      ld.CountryCode != 'BL' && 
                                      ld.CountryCode != 'LC' && 
                                      ld.CountryCode != 'MF' && 
                                      ld.CountryCode != 'ES' && 
                                      ld.CountryCode != 'SR' && 
                                      ld.CountryCode != 'UY' && 
                                      ld.CountryCode != 'VE' && 
                                      ld.CountryCode != 'CA' && 
                                      ld.CountryCode != 'US') {
                                          
                                        ld.Buffer_Name__c = 'Telemarketing France';  
    
                            } else if(ld.CountryCode == 'AD' ||
                                      ld.CountryCode == 'AG' ||
                                      ld.CountryCode == 'AR' || 
                                      ld.CountryCode == 'BS' || 
                                      ld.CountryCode == 'BB' || 
                                      ld.CountryCode == 'BZ' || 
                                      ld.CountryCode == 'BO' || 
                                      ld.CountryCode == 'BR' || 
                                      ld.CountryCode == 'CL' || 
                                      ld.CountryCode == 'CO' || 
                                      ld.CountryCode == 'CR' || 
                                      ld.CountryCode == 'CU' || 
                                      ld.CountryCode == 'DM' || 
                                      ld.CountryCode == 'DO' || 
                                      ld.CountryCode == 'EC' || 
                                      ld.CountryCode == 'SV' || 
                                      ld.CountryCode == 'GF' || 
                                      ld.CountryCode == 'GD' || 
                                      ld.CountryCode == 'GT' || 
                                      ld.CountryCode == 'GY' || 
                                      ld.CountryCode == 'HT' || 
                                      ld.CountryCode == 'HN' || 
                                      ld.CountryCode == 'JM' || 
                                      ld.CountryCode == 'MX' || 
                                      ld.CountryCode == 'NI' || 
                                      ld.CountryCode == 'PA' || 
                                      ld.CountryCode == 'PY' || 
                                      ld.CountryCode == 'PE' || 
                                      ld.CountryCode == 'PT' || 
                                      ld.CountryCode == 'BL' || 
                                      ld.CountryCode == 'LC' || 
                                      ld.CountryCode == 'MF' || 
                                      ld.CountryCode == 'ES' || 
                                      ld.CountryCode == 'SR' || 
                                      ld.CountryCode == 'UY' || 
                                      ld.CountryCode == 'VE') {
                                          
                                        ld.Buffer_Name__c = 'HCM Iberia - Latam';
    
                            } else if(ld.CountryCode == 'CA' ||
                                      ld.CountryCode == 'US') {
                                          
                                        ld.Buffer_Name__c = 'HCM Canada - USA';
                            }*/
                        }
                        when '310' {
                            if(ld.CountryCode == null) {
    
                                ld.Buffer_Name__c = 'Telemarketing France';
                                
                            } else if(ld.CountryCode != 'ES') {
    
                                ld.Buffer_Name__c = 'Telemarketing France';
    
                            } else if(ld.CountryCode == 'ES') {
    
                                ld.Buffer_Name__c = 'TAX Spain';
                            }
                        }
                        when '200' {
                            if(ld.Marketing_Campaign__c != null && ld.Marketing_Campaign__c.containsIgnoreCase('VAR')) {
    
                                ld.Buffer_Name__c = 'Partner Marketing leads - Retail';
    
                            } else {
                                if(ld.CountryCode == null ||
                                   ld.CountryCode == 'DZ' || 
                                   ld.CountryCode == 'AD' || 
                                   ld.CountryCode == 'BE' || 
                                   ld.CountryCode == 'FR' || 
                                   ld.CountryCode == 'GF' || 
                                   ld.CountryCode == 'PF' || 
                                   ld.CountryCode == 'TF' || 
                                   ld.CountryCode == 'GP' || 
                                   ld.CountryCode == 'MG' || 
                                   ld.CountryCode == 'MQ' || 
                                   ld.CountryCode == 'MU' || 
                                   ld.CountryCode == 'MC' || 
                                   ld.CountryCode == 'MA' || 
                                   ld.CountryCode == 'RE' || 
                                   ld.CountryCode == 'BL' || 
                                   ld.CountryCode == 'LC' || 
                                   ld.CountryCode == 'MF' || 
                                   ld.CountryCode == 'TN') {
    
                                    ld.Buffer_Name__c = 'Telemarketing France';
    
                                } else if(ld.CountryCode != 'DZ' && 
                                          ld.CountryCode != 'AD' && 
                                          ld.CountryCode != 'BE' && 
                                          ld.CountryCode != 'FR' && 
                                          ld.CountryCode != 'GF' && 
                                          ld.CountryCode != 'PF' && 
                                          ld.CountryCode != 'TF' && 
                                          ld.CountryCode != 'GP' && 
                                          ld.CountryCode != 'MG' && 
                                          ld.CountryCode != 'MQ' && 
                                          ld.CountryCode != 'MU' && 
                                          ld.CountryCode != 'MC' && 
                                          ld.CountryCode != 'MA' && 
                                          ld.CountryCode != 'RE' && 
                                          ld.CountryCode != 'BL' && 
                                          ld.CountryCode != 'LC' && 
                                          ld.CountryCode != 'MF' &&
                                          ld.CountryCode != 'TN') {
    
                                            ld.Buffer_Name__c = 'Retail International';
                                }
                            }
                        }
                        when '340' {
                            if(ld.Marketing_Campaign__c != null && ld.Marketing_Campaign__c.containsIgnoreCase('VAR')) {
    
                                ld.Buffer_Name__c = 'Partner Marketing leads - ERP';
    
                            } else {
    
                                ld.Buffer_Name__c = 'Telemarketing France';
                            }
                        }
                        when '380' {
                            switch on ld.CountryCode {
                                when 'FR', 'BE' {
    
                                    ld.Buffer_Name__c = 'Telemarketing France';
                                }
                                when 'AD', 'ES', 'PT'{

                                    ld.Buffer_Name__c = 'HCM Iberia';
                                }
                                when  'AG', 'AR', 'BS', 'BB', 'BZ', 'BO', 'BR', 'CL', 'CO', 'CR', 'CU', 'DM', 'DO', 'EC', 'SV', 
                                      'GF', 'GD', 'GT', 'GY', 'HT', 'HN', 'JM', 'MX', 'NI', 'PA', 'PY', 'PE', 'BL', 'LC', 'MF',
                                      'SR', 'UY', 'VE' {
    
                                        ld.Buffer_Name__c = 'HCM Latam';
                                }
                                when 'CA', 'US' {
    
                                    ld.Buffer_Name__c = 'HCM Canada - USA';
                                }
                                when 'DE', 'CH', 'AT'{
    
                                    ld.Buffer_Name__c = 'Talentsoft DACH';
                                }
                                when 'NL', 'LU'{
    
                                    ld.Buffer_Name__c = 'Talentsoft Benelux';
                                }
                                when 'DK', 'SE', 'NO', 'FI' {
    
                                    ld.Buffer_Name__c = 'Talentsoft Nordics';
                                }
                            }
                        }
                    }
                } 
            } 
            System.debug(ld.Buffer_Name__c);
        }
    }
    //BCR W-001839 END
     

    @TestVisible //A refactoriser => enlever les regles de l'APEX => prévoir une table de transcodage (objet custo)
    private static String switch(String key){

        Map<String, String> m = new Map<String, String>();
        m.put('CPA','110');
        m.put('Retail','200');
        m.put('HR','320');
        m.put('Finance','315');
        m.put('Manufacturing Industry','340');
        m.put('TPE & Association','100');
        
        if(m.containsKey(key)){
            return m.get(key);
        }
        
        return null;
 }

 private void affectOwnerToTSLeadChange(List<Lead> lds, Id userId, Id idgrpTelemark) {
    for(Lead ld : lds) {
        System.debug(ld.Lead_TS__c);
        if(ld.Lead_TS__c && ld.ownerId == idgrpTelemark) {
            ld.OwnerId = userId;
        }
    }
 }

 //BCR W-1827 start
 private void manageRejectLead(List<Lead> lds, Map<Id, Lead> oldMap) {
     for(Lead ld : lds) {
         if(ld.Status == 'Closed - Not Converted' && oldMap.get(ld.Id).Status != 'Closed - Not Converted') {
            ld.ImpartnerPRM__PartnerLeadAcceptance__c = 'Rejected';
         }
     }
 }
 //BCR W-1827 end

 // TMG 30/03/2023
public void affectNoOfVehiclesOnAccount(Map<Id, Lead> leds) {
    if (leds.isEmpty()) {
        return; 
    }
    
    set<Id> setLeadId= new Set<Id>();

    for (Lead led : leds.values()){
        setLeadId.add(led.Id);
        setLeadId.add(led.Existing_Account__r.Id);
        setLeadId.add(led.Existing_Account__c);
    }
    
    system.debug('BUG DEBUG: ' + setLeadId);
    
    List<Lead> listLead = [SELECT Id, Number_of_vehicles__c, ConvertedAccountId FROM Lead WHERE Id IN: setLeadId];
    List<Id> accIds = new List<Id>();

    Map<Id, Lead> ledByAccId = new Map<Id, Lead>();

    for(Lead led: listLead) {
        accIds.add(led.ConvertedAccountId);
        ledByAccId.put(led.ConvertedAccountId, led);
    }
   
    system.debug('BUG DEBUG 2 (listLead): '+ listLead + 'BUG DEBUG accIds: ' + accIds + 'BUG DEBUG ledByAccId: ' + ledByAccId);
    List<Account> accountToUpdate = [SELECT Id, Number_of_vehicles__c, TECH_Converted_From_Lead__c FROM Account WHERE Id IN :accIds /*AND TECH_Converted_From_Lead__c = true*/];
    system.debug('BUG DEBUG 3: '+ accountToUpdate);
    
    for (Account acct : accountToUpdate) {
        Lead led = ledByAccId.get(acct.Id);
        if (led.Number_of_vehicles__c != null) {
            acct.Number_of_vehicles__c = led.Number_of_vehicles__c;
        } 
    }
    
    if (accountToUpdate != null && accountToUpdate.size() > 0) {
        update accountToUpdate;
    }

    
}   
    
    
}