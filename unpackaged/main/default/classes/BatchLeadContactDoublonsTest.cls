@isTest
public with sharing class BatchLeadContactDoublonsTest {
    
       
    Static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();  
    //adminUser.BypassVR__c = true;
	
    
	static List<String> listMail = new List<String> {'schibout@yopmail.com'};
    @IsTest
    static void methodName(){
        Test.startTest();
	        System.runAs(adminUser){
            RecordType recType =[select id from RecordType where Name ='Lead' Limit 1];  
            System.debug('recType '+recType);    
            Database.DMLOptions dml = new Database.DMLOptions(); 
			dml.DuplicateRuleHeader.allowSave = true;
            Industry__c  industryCode = new Industry__c( Name = '0163Z',CurrencyIsoCode='EUR',Industry__c='Agriculture / Aquaculture and Fishing');   
            Database.insert(industryCode, dml);
            Account acct = new Account();
    		acct.Name='LA POSTE2';
            acct.BillingStreet='5053 RTE DE LA VALLEE';
            acct.BillingCity='CHESSY';
            acct.BillingPostalCode='69380';
            acct.BillingCountry='France';
            acct.BillingCountryCode='FR';
            acct.Phone='33155445000';
            acct.Website='https://www.laposte.fr/';
            acct.Industry='Transportation';
            acct.NumberOfEmployees=182183;
            acct.CurrencyIsoCode='EUR';
            acct.SBQQ__AssetQuantitiesCombined__c=FALSE;
            acct.SBQQ__CoTermedContractsCombined__c=FALSE;
            acct.SBQQ__ContractCoTermination__c='Never';
            acct.SBQQ__IgnoreParentContractedPrices__c=FALSE;
            acct.SBQQ__PreserveBundle__c=TRUE;
            acct.SBQQ__RenewalModel__c='Contract Based';
            acct.SBQQ__RenewalPricingMethod__c='Same';
            acct.SBQQ__TaxExempt__c='No';
            acct.DGE_Group__c=FALSE;
            acct.ERP_Number__c='904540150';
            acct.Order_Number__c=FALSE;
            acct.Industry_Code__c = industryCode.Id;    
            acct.Infolegale_conn__TECH_InfoLegaleExternalKey__c='35600120023317';
            acct.Headquarter__c=FALSE;
            acct.National_ID_Active__c=FALSE;
            acct.National_ID__c='35600000123318';
            acct.Nature__c='PRO';
            acct.Advanced_portal_customization__c=FALSE;
            acct.Risk_Level__c='Risque très faible';
            acct.IntercommunityVATnumber__c='FR39355550000';
            //acct.Reasonforclosing__c='Invalid National Id';
            acct.RegisteredwiththeOrderofCharteredA__c=FALSE;
            acct.Industry_Code_External__c='5310Z';
            acct.Account_in_Dispute__c=FALSE;
            acct.PO_Mandatory__c=FALSE;
            acct.TECH_Converted_From_Lead__c=FALSE;
            acct.POMandatory__c='Unknown';
            acct.Tech_Contact_Direct__c=TRUE;
            //insert acct;
     		Database.insert(acct, dml);
			List<Account> act = [SELECT Id FROM ACCOUNT WHERE NAME ='LA POSTE2'];
            System.debug('act =' + act);
            System.assert(act.size() > 0, 'Account inserted')    ;
                
            //insert acct;
            String MailString =listMail[0];
          	System.debug('Load Contact');
            Contact contact = new Contact();
            contact.accountId = acct.Id ;
            contact.LastName='lkekzak';
            contact.FirstName='lkekzak';
            contact.Salutation='Mr.';
            contact.MailingStreet='4 BIS RUE ROBERT SCHUMAN';
            contact.MailingCity='PLERIN';
            contact.MailingState='Bretagne';
            contact.MailingPostalCode='22190';
            contact.MailingCountry='France';
            contact.MailingStateCode='FRBRE';
            contact.MailingCountryCode='FR';
            contact.Phone='33296553030';
            contact.MobilePhone='725718214';
            contact.Email=MailString;
            contact.CurrencyIsoCode='EUR';
            contact.HasOptedOutOfEmail=FALSE;
            contact.Active__c=TRUE;
            contact.BuyerPersonaCPA__c='EC associe';
            contact.BuyerPersonaERPHigh__c='DG';
            contact.BuyerPersonaERPMiddle__c='DG';
            contact.BuyerPersonaEducation__c='Responsable';
            contact.BuyerPersonaHCM__c='DG';
            contact.BuyerPersonaPortailTPE__c='Gerant';
            contact.BuyerPersonaRetail__c='CEO';
            contact.BuyerPersonaSMB__c='Gerant';
            contact.BuyerPersonaTAX__c='DG';
            contact.Expertise__c='110';
            contact.Function__c='Director';
            contact.LeadOrigin__c='Sales';
            contact.Marketing_Campaign__c='PORT-fr-1-collaborateursvalorises';
            contact.Marketing_Status__c='Cold';
            contact.Mkto_Unsync_Requested__c=FALSE;
            contact.Mkto_marketo_sync__c=False;
            contact.Service__c='Management';
            contact.Mkto_email_invalid__c=FALSE;
            contact.FunctionId__c='D10';
            contact.Mkto_email_double_opt_in__c=FALSE;
            contact.Mkto_email_simple_opt_in__c=FALSE;
            contact.Mkto_marketing_suspended__c=FALSE;
            contact.mkto71_Original_Source_Info__c='Contact';
            contact.mkto71_Original_Source_Type__c='salesforce.com';
            contact.ATTRILTmedium__c='email';
            contact.TECH_Email__c=MailString;
            contact.Marketo_Info__c='PORTAIL_2021_Event_Inscrits Cegid Flow';
            contact.mkto_si__Last_Interesting_Moment_Desc__c='Opens Email : Votre interlocutrice Cegid en 2021';
            contact.mkto_si__Last_Interesting_Moment_Source__c='Lead action';
            contact.mkto_si__Last_Interesting_Moment_Type__c='Email';
            contact.Contact_created_from_Lead__c=FALSE;
            contact.Sync_to_PRM__c=FALSE;
            //insert contact ;
            Database.insert(contact, dml);
            List<Contact> ct = [SELECT Id,Email FROM contact WHERE Email = :MailString ];
            System.debug('contact ='+ct);   
            System.assert(ct.size() > 0, 'Contact not inserted') ;        
            Lead ld = new Lead ();
            ld.recordTypeId ='0123Y000000LDV6QAO';    
            ld.LastName='vvvvv';
            ld.FirstName='vvvvv';
            ld.Company='LA POSTE';
            ld.Email=MailString;
            ld.Status='New';
            ld.CurrencyIsoCode='EUR';
            ld.Industry   ='Education';
            ld.HasOptedOutOfEmail=FALSE;
            ld.IsConverted=FALSE;
            ld.IsUnreadByOwner=FALSE;
            ld.Oppy_converted_from_Lead__c=TRUE;
            ld.Call_result__c='Not yet treated';
            ld.Expertise__c='110';
            ld.Last_Call__c=FALSE;
            ld.Marketing_Campaign__c='PORT-fr-1-collaborateursvalorises';
            ld.Marketing_Status__c='Warm';
            ld.Mkto_Unsync_Requested__c=FALSE;
            ld.Mkto_email_double_opt_in__c=FALSE;
            ld.Mkto_email_invalid__c=FALSE;
            ld.Mkto_email_simple_opt_in__c=FALSE;
            ld.Mkto_marketing_suspended__c=FALSE;
            ld.Mkto_marketo_sync__c=TRUE;
            ld.Nature__c='PRO';
            ld.mkto71_Acquisition_Program__c='IBM_2002_Contract_tiering_erreur_mandarine';
            ld.mkto71_Lead_Score__c=4;
            ld.mkto71_Original_Source_Type__c='List import';
            ld.Lead_Origin__c='Marketing';
            ld.ATTRILTmedium__c='email';
            ld.Marketo_Info__c='PORTAIL_2021_Event_Inscrits Cegid Flow';
            ld.mkto_si__Last_Interesting_Moment_Type__c='Email';
            ld.mkto_si__Priority__c=70;
            ld.mkto_si__Relative_Score_Value__c=1;
            ld.mkto_si__Urgency_Value__c=1;
            ld.ImpartnerPRM__DealRegistrationDenied__c=FALSE;
            ld.ImpartnerPRM__IsDealRegistration__c=FALSE;
            ld.ImpartnerPRM__NotifyPartner__c=FALSE;
            ld.TECH_Autoconvert_Lead__c=FALSE;
            ld.Mkto_marketo_sync__c = false ;
            insert ld ;
            //Database.insert(ld, dml);
            System.debug('ldLead ='+ld.RecordType.DeveloperName);     
            List<Lead> ldR = [SELECT Id,Email, Status FROM Lead WHERE Email = :MailString ];
            System.debug('ldR ='+ldR[0].status);  
            System.assert(ldR.size() > 0, 'Lead not inserted') ;    
            System.debug('Running a batch');											
            BatchLeadContactDoublons.run();         
            List<Lead> leadResultList =  [SELECT Id,Email, Status FROM Lead WHERE Email = :MailString ];
            LeadStatus CLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true Limit 1];    
           // System.assert(leadResultList[0].status ==CLeadStatus.MasterLabel,'Lead not converted');
            
        }
        Test.stopTest();
        
    }


}