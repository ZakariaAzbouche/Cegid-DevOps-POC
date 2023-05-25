/**
* @File Name          : BatchLeadContactDoublons
* @Description        : Covert Lead to contact 
* @Author             : SCH  
* @Group              : Cap Gemini
* @Modification Log   : 
* Ver       Date            Author                  Modification
* ---    -----------       -------           ------------------------ 
* 1.0    23/03/2021         SCH              Initial Version
* ---    -----------       -------           ------------------------ 
**/

global class BatchLeadContactDoublons  implements Database.Batchable<sObject>, Database.stateful,Schedulable{
 
    //private static final String leadRT = 'Lead';
    static final Boolean debugMod = true;
    static List<String> statusList =new List<String> {'New','Closed - Not Converted'};
    static String recordTypeName ='Lead';    
   
    global Database.querylocator start(Database.BatchableContext BC){
        System.debug('start');
        return Database.getQueryLocator(
            [SELECT Id, Email,RecordType.name FROM Lead WHERE Status in ('New', 'Closed - Not Converted') and ConvertedContactId =null]            
        );
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope) {
        System.debug('execute' + scope.size());
        List<String> leadEmails = new List<String>();
        List<Id> leadListIds = new List<Id>();
        for(Lead lead : scope){
            leadEmails.add(lead.Email);
            leadListIds.add(lead.Id);
        }
        List<Contact> contacts = new List<Contact>([SELECT Email, Id, AccountId, Account.Industry_Code__c FROM Contact WHERE Email IN :leadEmails]); 
        System.debug('contacts '+ contacts.size());
        System.debug('leadEmails '+ leadEmails.size());
        List<Id> contactIds =new List<Id>(new Map<Id, Contact>(contacts).keySet());
        System.debug('contactIds = '+contactIds.size());
        List<Lead> leads = new List<Lead>([SELECT Email, Id, Name,Industry_Code__c,RecordType.name FROM Lead WHERE Id IN :leadListIds]); 
        
        System.debug('leads = '+leads.size());
        LeadStatus CLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();
		for (Lead lead :leads) {
           for (Contact contact : contacts) {
             if ( (lead.Email != contact.Email) || (lead.Industry_Code__c != null)||(lead.RecordType.name=='Contact Lead') ) continue ; 
             System.debug ('Lead'+lead.Email) ;
             lead.Industry_Code__c = contact.Account.Industry_Code__c ;  
           }
        }
        update (leads);
        for (Lead lead :leads) {
            for (Contact contact : contacts) {
                if (contact.Email != lead.Email )  continue ;
                 System.debug( ' Contact '+contact.Email + ' Lead '+lead.Email);
                 Database.LeadConvert Leadconvert = new Database.LeadConvert();
                 Leadconvert.setContactId(contact.id);
                 Leadconvert.setLeadId(lead.id);
                 Leadconvert.setAccountId(contact.AccountId);
                 Leadconvert.setConvertedStatus(CLeadStatus.MasterLabel);
                 leadconvert.setDoNotCreateOpportunity(TRUE); 
                 MassLeadconvert.add(Leadconvert);
            }
        }
        
        if (!MassLeadconvert.isEmpty()) {
            try {       
                 
                List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert,false); 
                   
            } catch(Exception e){
                	System.debug( e.getMessage());
                }
            	massUpdateContact(contactIds);
            }
            
    }
   public void finish(Database.BatchableContext BC){
       
   }
    
    /**
     * 
     */
    public static void massUpdateContact (List<Id> contactIds) {

        List<Contact> convertedContacts = new List<Contact>();
        List<Contact> Masscontacts = [SELECT Id
                                            ,LeadSource
                                            ,mkto71_Acquisition_Program_Id__c
                                            ,mkto71_Acquisition_Program__c
                                            ,mkto71_Acquisition_Date__c
                                            ,HasOptedOutOfEmail
                                            ,Marketo_Info__c
                                            ,Expertise__c
                                            ,External_Comment__c
                                            ,Last_AQL_Date__c
                                            ,Marketing_Campaign__c
                                            ,Mkto_email_double_opt_in__c
                                            ,Mkto_email_simple_opt_in__c
                                            ,Mkto_email_simple_opt_in_date__c
                                            ,mkto71_Lead_Score__c
                                            ,mkto71_Original_Referrer__c
                                            ,mkto71_Original_Source_Info__c
                                            ,mkto71_Original_Source_Type__c
                                            ,ATTRILTSource__c
                                            ,ATTRILTmedium__c
                                            ,AttrLTcontent__c
                                            ,mkto_si__Last_Interesting_Moment_Date__c
                                            ,mkto_si__Last_Interesting_Moment_Desc__c
                                            ,mkto_si__Last_Interesting_Moment_Source__c
                                            ,mkto_si__Last_Interesting_Moment_Type__c
                                            ,mkto_si__Last_Interesting_Moment__c
                                            ,mkto_si__Priority__c
                                            ,mkto_si__Relative_Score_Value__c
                                            ,mkto_si__Relative_Score__c
                                            ,mkto_si__Sales_Insight__c
                                            ,mkto_si__Urgency_Value__c
                                            ,mkto_si__Urgency__c 
                                            ,mkto_si__View_in_Marketo__c
                                      		, email
                                            FROM Contact WHERE Id IN :contactIds ];

        List<Lead> leadscoverts = [ SELECT  Id,ConvertedContactId,LeadSource
                                            ,mkto71_Acquisition_Program_Id__c
                                            ,mkto71_Acquisition_Program__c
                                            ,mkto71_Acquisition_Date__c
                                            ,HasOptedOutOfEmail
                                            ,Marketo_Info__c
                                            ,Expertise__c
                                            ,External_Comment__c
                                            ,Last_AQL_Date__c
                                            ,Marketing_Campaign__c
                                            ,Mkto_email_double_opt_in__c
                                            ,Mkto_email_simple_opt_in__c
                                            ,Mkto_email_simple_opt_in_date__c
                                            ,mkto71_Lead_Score__c
                                            ,mkto71_Original_Referrer__c
                                            ,mkto71_Original_Source_Info__c
                                            ,mkto71_Original_Source_Type__c
                                            ,ATTRILTSource__c
                                            ,ATTRILTmedium__c
                                            ,AttrLTcontent__c
                                            ,mkto_si__Last_Interesting_Moment_Date__c
                                            ,mkto_si__Last_Interesting_Moment_Desc__c
                                            ,mkto_si__Last_Interesting_Moment_Source__c
                                            ,mkto_si__Last_Interesting_Moment_Type__c
                                            ,mkto_si__Last_Interesting_Moment__c
                                            ,mkto_si__Priority__c
                                            ,mkto_si__Relative_Score_Value__c
                                            ,mkto_si__Relative_Score__c
                                            ,mkto_si__Sales_Insight__c
                                            ,mkto_si__Urgency_Value__c
                                            ,mkto_si__Urgency__c 
                                            ,mkto_si__View_in_Marketo__c
                                      		, email
                                            FROM Lead WHERE ConvertedContactId     IN :contactIds ];
        
        for (Contact contact : Masscontacts) {
	      for (Lead lead : leadscoverts) {
                if (lead.ConvertedContactId != contact.Id  ) continue ;
                convertedContacts.add(updateSingleContactRecord(lead,contact));
            }
        }

        if (!convertedContacts.isEmpty()) {
            try {       
                    update convertedContacts ;
                    system.debug('Contact updated');
            } catch(Exception e){
                    String body3 = 'Exception Thrown - Update Contact: ' + e.getMessage() + '\n Stack Trace: ' + e.getStackTraceString();
                	System.debug(body3);
                    
            }
        }

    }
    /**
     * 
     */
     public static Contact updateSingleContactRecord (Lead lead,Contact contact) {
		
         
        contact.LeadSource=getExpectedValueString(lead.LeadSource,contact.LeadSource,'Lead');
        contact.Marketing_Campaign__c=getExpectedValueString(lead.Marketing_Campaign__c,contact.Marketing_Campaign__c,'Lead');
        contact.mkto71_Acquisition_Program_Id__c=getExpectedValueDecimal(lead.mkto71_Acquisition_Program_Id__c,contact.mkto71_Acquisition_Program_Id__c,'Lead');
        contact.mkto71_Acquisition_Program__c=getExpectedValueString(lead.mkto71_Acquisition_Program__c,contact.mkto71_Acquisition_Program__c,'Lead');
        contact.mkto71_Acquisition_Date__c=getExpectedValueDateTime(lead.mkto71_Acquisition_Date__c,contact.mkto71_Acquisition_Date__c,'Lead');
        contact.HasOptedOutOfEmail=(lead.HasOptedOutOfEmail||contact.HasOptedOutOfEmail);
        contact.Marketo_Info__c=getExpectedValueString(lead.Marketo_Info__c,contact.Marketo_Info__c,'Lead');
        contact.Expertise__c=getExpectedValueString(lead.Expertise__c,contact.Expertise__c,'Lead');
        contact.External_Comment__c=getExpectedValueString(lead.External_Comment__c,contact.External_Comment__c,'Contact');
        contact.Last_AQL_Date__c=getExpectedValueDateTime(lead.Last_AQL_Date__c,contact.Last_AQL_Date__c,'Lead');
        contact.Mkto_email_double_opt_in__c=getBothConditionExpected(lead.Mkto_email_double_opt_in__c , contact.Mkto_email_double_opt_in__c);
        contact.Mkto_email_simple_opt_in__c=getBothConditionExpected(lead.Mkto_email_simple_opt_in__c , contact.Mkto_email_simple_opt_in__c);
        contact.Mkto_email_simple_opt_in_date__c=getExpectedValueDate(lead.Mkto_email_simple_opt_in_date__c,contact.Mkto_email_simple_opt_in_date__c,'Lead');
        contact.mkto71_Lead_Score__c=getExpectedMinValueDecimal(lead.mkto71_Lead_Score__c,contact.mkto71_Lead_Score__c);
        contact.mkto71_Original_Referrer__c=getExpectedValueString(lead.mkto71_Original_Referrer__c,contact.mkto71_Original_Referrer__c,'Lead');
        contact.mkto71_Original_Source_Info__c=getExpectedValueString(lead.mkto71_Original_Source_Info__c,contact.mkto71_Original_Source_Info__c,'Lead');
        contact.mkto71_Original_Source_Type__c=getExpectedValueString(lead.mkto71_Original_Source_Type__c,contact.mkto71_Original_Source_Type__c,'Lead');
        contact.ATTRILTSource__c=getExpectedValueString(lead.ATTRILTSource__c,contact.ATTRILTSource__c,'Lead');
        contact.ATTRILTmedium__c=getExpectedValueString(lead.ATTRILTmedium__c,contact.ATTRILTmedium__c,'Lead');
        contact.AttrLTcontent__c=getExpectedValueString(lead.AttrLTcontent__c,contact.AttrLTcontent__c,'Lead');
        contact.mkto_si__Last_Interesting_Moment_Date__c=getExpectedValueDateTime(lead.mkto_si__Last_Interesting_Moment_Date__c,contact.mkto_si__Last_Interesting_Moment_Date__c,'Lead');
        contact.mkto_si__Last_Interesting_Moment_Desc__c=getExpectedValueString(lead.mkto_si__Last_Interesting_Moment_Desc__c,contact.mkto_si__Last_Interesting_Moment_Desc__c,'Lead');
        contact.mkto_si__Last_Interesting_Moment_Source__c=getExpectedValueString(lead.mkto_si__Last_Interesting_Moment_Source__c,contact.mkto_si__Last_Interesting_Moment_Source__c,'Lead');
        contact.mkto_si__Last_Interesting_Moment_Type__c=getExpectedValueString(lead.mkto_si__Last_Interesting_Moment_Type__c,contact.mkto_si__Last_Interesting_Moment_Type__c,'Lead');
        contact.mkto_si__Priority__c=getExpectedValueDecimal(lead.mkto_si__Priority__c,contact.mkto_si__Priority__c,'Lead');
        contact.mkto_si__Relative_Score_Value__c=getExpectedValueDecimal(lead.mkto_si__Relative_Score_Value__c,contact.mkto_si__Relative_Score_Value__c,'Lead');
        contact.mkto_si__Urgency_Value__c=getExpectedValueDecimal(lead.mkto_si__Urgency_Value__c,contact.mkto_si__Urgency_Value__c,'Lead');
     
        return contact ;
    }
    
    public static Boolean getBothConditionExpected(Boolean booleanValueFromLead,Boolean booleanValueFromContact) {
        if (booleanValueFromLead ==null ||booleanValueFromContact==null ) return false;
        return (booleanValueFromLead && booleanValueFromContact) ;
    }
    /**
     * 
     */

    public static Decimal getExpectedValueDecimal(Decimal DecimalValueFromLead, Decimal DecimalValueFromContact,String preferedSobject){

        if (preferedSobject =='Contact' && DecimalValueFromContact != null)  return DecimalValueFromContact ;
		return (DecimalValueFromLead == null ? DecimalValueFromContact : DecimalValueFromLead) ; 
     
     }

     public static Decimal getExpectedMinValueDecimal(Decimal DecimalValueFromLead, Decimal DecimalValueFromContact){

        if ( DecimalValueFromContact == null)  return DecimalValueFromLead ;
        if ( DecimalValueFromLead == null)  return DecimalValueFromContact ;
		return (math.min(DecimalValueFromLead,DecimalValueFromContact)) ; 
     
     }
     /**
     * 
     */
    public static Datetime getExpectedValueDateTime(Datetime DateTimeValueFromLead, Datetime DateTimeValueFromContact,String preferedSobject){

        if (preferedSobject =='Contact' && DateTimeValueFromContact != null )  return DateTimeValueFromContact ;
     	return (DateTimeValueFromLead == null ? DateTimeValueFromContact : DateTimeValueFromLead) ;
    }
    /**
     * 
     */
    public static Date getExpectedValueDate(Date DateValueFromLead, Date DateValueFromContact,String preferedSobject){

        if (preferedSobject =='Contact' && DateValueFromContact == null)  return DateValueFromContact ;
        return (DateValueFromLead == null ? DateValueFromContact : DateValueFromLead) ;
     
    }
    
    /**
     * 
     */
    public static String getExpectedValueString(String stringValueFromLead, String stringValueFromContact,String preferedSobject){

        if (preferedSobject =='Contact' && !isEmpty(stringValueFromContact) )  return stringValueFromContact ;
        return isEmpty(stringValueFromLead) ? stringValueFromContact:stringValueFromLead;
     
    }
    /**
     * 
     */
    public static Boolean isEmpty(String stringToTest) {

        return  ( stringToTest ==null||(stringToTest.trim()).length() == 0 );
    }
    
    global void execute(SchedulableContext sc) {
        BatchLeadContactDoublons batch = new BatchLeadContactDoublons();
        Database.executeBatch(batch);
    }
    
    global static void run(){
        BatchLeadContactDoublons batch = new BatchLeadContactDoublons();
        Database.executeBatch(batch);
    }
}