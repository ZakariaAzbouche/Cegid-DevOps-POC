/**
* @File Name          : SM011_Contact
* @Description        : Update Lead if contact is converted from Lead
* @Author             : SRA   
* @Group              : Comforth-Karoo
* @Modification Log   : 
* Ver       Date            Author                  Modification
* ---    -----------       -------           ------------------------ 
* 1.0    03/12/2020         SRA              Initial Version
* ---    -----------       -------           ------------------------ 
**/

public class SM011_Contact {
    
    public static Set<Id> setLeadId= new set<Id>();
    private static final String leadRT = 'Lead';
    private static final String leadStatus = 'New';
    private static final String leadStatus2 = 'Closed - Not Converted';
    private static final String leadStatus3 = 'Assigned';
    private static final String leadStatus4 = 'In Buffer';
    private static final String leadStatus5 = 'In Progress';
    private static final String leadStatus6 = 'Qualified';
    private static Id leadOwner;
    
    public static void convertLeadError(List<Contact> listContact){
        
        system.debug('starting listContact'+listContact);
        set<Id> setContactId = new set<Id>();
        set<String> setContactEmail = new set<String>();
        Map<String,String> mapContactError = new Map<String,String>();
        Map<String,String> mapContactEmail = New Map<String,String>();
        
        for(Contact con:listContact){
            setContactEmail.add(con.Email);
        }
        
        system.debug('setContactEmail'+setContactEmail);
        
        For(Lead leadError:[SELECT Id,OwnerId,Email,Name
                    FROM Lead
                    WHERE Email IN :setContactEmail
                    AND (Status =:leadStatus3 OR Status=:leadStatus4 OR Status=:leadStatus5 OR Status=:leadStatus6)
                    AND RecordType.DeveloperName =: leadRT]){
                        system.debug('leadError'+leadError);
                        system.debug('leadError Email'+leadError.Email);
                        
                        if(leadError.Id!=null){
                            mapContactError.put(leadError.Email,leadError.Id);
                            
                            String s1 = String.valueof(leadError.OwnerId);
                            system.debug('s1'+s1);
                                Id owner=Label.MKT_Lead_Owner;
                                system.debug('owner'+owner);
                            	system.debug('userinfo.getUserId'+userinfo.getUserId());
                            	system.debug('leadError.Name'+leadError.Name);
                                if(s1.startsWith('00G')){
                                    system.debug('Create Chatter');
                                    //SM011_Contact.mentionTextPost(owner,userinfo.getUserId(),leadError.Name,leadError.Id);
                                }
                            }
                    }
        
        For(Contact con2:listContact){
            
            if(mapContactError.containsKey(con2.Email)){
                con2.addError('The contact you\'re trying to create had already a lead being currently processed by the telemarketing team, please contact them.');
            }
        }
    }
    
	public static void convertLead(Set<Id> setContactId, Map <Id, String> mapContactEmail){
        
        Database.LeadConvert lc = new Database.LeadConvert();
        system.debug('mapContactEmail'+mapContactEmail);
        LeadVRSDRPRMTelemark.byPassVR = true;

        //for loop to retrieve Id of Lead 
        for(Lead l:[SELECT Id,OwnerId
                    FROM Lead
                    WHERE Email IN :mapContactEmail.values()
                    AND (Status =:leadStatus OR Status=:leadStatus2)
                    AND RecordType.DeveloperName =: leadRT]){
                        
                        system.debug('l'+l);
                        
                        if(l.Id!=null) {
                            setLeadId.add(l.Id);
                            lc.setLeadId(l.Id);
                            
                            String s1 = String.valueof(l.OwnerId);
                            Id owner=Label.MKT_Lead_Owner;
                            
                            if(s1.startsWith('00G')){
                                l.OwnerId=owner;
                            }
                            l.TECH_Autoconvert_Lead__c=true;
                            //l.TECH_PB_ByPass_VR_15__c=true;
                            system.debug('lead found'+l);
                            LeadVRSDRPRMTelemark.enabledByPassVR();
                            System.debug(LeadVRSDRPRMTelemark.byPassVR);
                            update l;
                        }
                        
                    }

        
        
        //Fetching Lead from LeadStatus
        list<LeadStatus> listConvertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        list<Contact> listContacts = [SELECT Id, AccountId FROM Contact WHERE Id IN: setContactId];
        //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true AND Id IN: setLeadId];
        
        if(setLeadId.size() >0){
            lc.setConvertedStatus(listConvertStatus[0].MasterLabel);
            lc.setDoNotCreateOpportunity(True);
            lc.setContactId(listContacts[0].Id);
            lc.setAccountId(listContacts[0].AccountId);
            
            //Converting Lead, filling missing fields such as convertedContactId 
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            system.debug('lcr'+lcr);
            System.assert(lcr.isSuccess());
        }
    }
    /*
    @future
    public static void mentionTextPost(Id userId, Id userToMentionId, String leadName,Id leadId) {
        system.debug('Create Chatter2');
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
         
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
         
        mentionSegmentInput.id = userToMentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
         
        textSegmentInput.text = ' is trying to create a contact with the same email adress as the lead '+leadName+' whom you own.';
        messageBodyInput.messageSegments.add(textSegmentInput);
         
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = leadId;
         
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }*/
}