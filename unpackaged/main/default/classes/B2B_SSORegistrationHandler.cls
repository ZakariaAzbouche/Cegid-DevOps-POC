/**
 * @author Gulshan DOORGAH ~ Comforth Karoo
 * @description This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
 */
global without sharing class B2B_SSORegistrationHandler implements Auth.SamlJitHandler {
	private class JitException extends Exception{}
	private static final String ROLES = 'Roles';
	private static final String EXTENDED_ROLES = 'ExtendedRoles';
	@TestVisible private static final String EMAIL_PATH = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
	@TestVisible private static final String PHONE_PATH = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/otherphone';
	@TestVisible private static final String FIRSTNAME_PATH = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname';
	@TestVisible private static final String LASTNAME_PATH = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname';
	@TestVisible private static final String TITLE_PATH = 'http://passeport.cegid.com/ProfessionCode';
	@TestVisible private static final String SALUTATION_PATH = 'http://passeport.cegid.com/TitleCode';
	@TestVisible private static final String COMPANY_PATH = 'http://passeport.cegid.com/AccountName';
	@TestVisible private static final String EMPLOYEE_NUMBER_PATH = 'http://passeport.cegid.com/SicId';
	@TestVisible private static final String ACCOUNTID_PATH = 'http://passeport.cegid.com/AccountId';
    @TestVisible private static final String MOBILEPHONE_PATH = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone';
	//private static final Id CONTACT_CUSTOMER_USER_RTID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CustomerUser').getRecordTypeId();
	@TestVisible private static final B2B_Settings__c B2B_SETTINGS = B2B_Settings__c.getOrgDefaults();

	private void handleUser(boolean create, User u, Map<String, String> attributes,
		String federationIdentifier, boolean isStandard, Id communityId) {
		
		if(create && attributes.containsKey(EMAIL_PATH)) {
			u.Username = attributes.get(EMAIL_PATH);
		}
		if(create) {
			u.FederationIdentifier = federationIdentifier;
		}
		if(attributes.containsKey(PHONE_PATH)) {
			u.Phone = attributes.get(PHONE_PATH);
		}
		if(attributes.containsKey(EMAIL_PATH)) {
			u.Email = attributes.get(EMAIL_PATH);
		}
		if(attributes.containsKey(FIRSTNAME_PATH)) {
			u.FirstName = attributes.get(FIRSTNAME_PATH);
		}
		if(attributes.containsKey(LASTNAME_PATH)) {
			u.LastName = attributes.get(LASTNAME_PATH);
		}
		if(attributes.containsKey(TITLE_PATH)) {
			u.Title = attributes.get(TITLE_PATH);
		}
		if(attributes.containsKey(COMPANY_PATH)) {
			u.CompanyName = attributes.get(COMPANY_PATH);
		}
		if(attributes.containsKey(EMPLOYEE_NUMBER_PATH)) {
			u.EmployeeNumber = attributes.get(EMPLOYEE_NUMBER_PATH);
		}
		String uid = UserInfo.getUserId();
		User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey 
							FROM User 
							WHERE Id = :uid
							LIMIT 1];

		if(create) {
			u.LocaleSidKey = currentUser.LocaleSidKey;
			u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
			String alias = '';
			if(u.FirstName == null) {
				alias = u.LastName;
			} else {
				alias = u.FirstName.charAt(0) + u.LastName;
			}
			if(alias.length() > 5) {
				alias = alias.substring(0, 5);
			}
			u.Alias = alias;
			u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
			u.EmailEncodingKey = currentUser.EmailEncodingKey;
		}

		if(communityId == B2B_SETTINGS.CommunityId__c || Test.isRunningTest()){
			u.BypassPB__c = true;
			u.BypassWF__c = true;
		}

		/*
		 * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
		 * If your identity provider sends these User fields as attributes along with Contact 
		 * or Account fields, you must modify the logic in this class to update either these 
		 * User fields or the Contact and Account fields.
		 */
		if(create){
			u.IsActive = true;
		}
		//Handle custom fields here

		if(!create) {
			update(u);
		}
	}

	/**
	 * @description handleContact handles Contact creation/update
	 * @param  create     true if creation / false if update
	 * @param  accountId  accountId
	 * @param  u          user
	 * @param  attributes attributes from SAML assertion
	 */
	private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
		System.debug('handleContact create : ' + create);
		System.debug('handleContact u : ' + u);
		System.debug('handleContact attributes : ' + attributes);
		System.debug('handleContact accountId : ' + accountId);
		Contact c;
		boolean newContact = false;
		boolean isRelated = false;

		if(create) {
			if(attributes.containsKey(EMAIL_PATH)) {
				String contactEmail = attributes.get(EMAIL_PATH);

				// check if Contact with the email exists on the Account
				for(Contact existingContact : [SELECT Id, AccountId 
												FROM Contact 
												WHERE Email = :contactEmail
												AND AccountId = :accountId
												WITH SECURITY_ENFORCED
												LIMIT 1]){
                    System.debug('Contact with the email exists on the Account');
					u.ContactId = existingContact.Id;
                    c = existingContact;
				}

				// check if Contact with the email exists on another Account
				if(String.isBlank(u.ContactId)){
					for(Contact existingContact : [SELECT Id, AccountId 
													FROM Contact 
													WHERE Email = :contactEmail
													WITH SECURITY_ENFORCED
													LIMIT 1]){
                        System.debug('Contact with the email exists on another Account'); 
						u.ContactId = existingContact.Id;
                        c = existingContact;
						// TODO : associate Contact with Account ?
					}
					if(c != null && accountId != null){
						for(AccountContactRelation acr:[SELECT Id,AccountId from AccountContactRelation where ContactId =:c.Id AND AccountId =:accountId LIMIT 1]){
							isRelated = true;
						}
					}
					
				}

				// check if Lead with the email exists
				if(String.isBlank(u.ContactId)){
					for(Lead existingLead : [SELECT Id 
													FROM Lead 
													WHERE Email = :contactEmail
													WITH SECURITY_ENFORCED
													LIMIT 1]){
                        System.debug('Lead with the email exists'); 
						Database.LeadConvert lc = new Database.LeadConvert();
						lc.setLeadId(existingLead.id);
						lc.setAccountId(accountId);
						lc.setDoNotCreateOpportunity(true);
						
						// GDH : note that the query below will run only once in this loop as we have limited the above SOQL to 1
						LeadStatus convertStatus = [SELECT Id, MasterLabel 
													FROM LeadStatus 
													WHERE IsConverted = true 
													LIMIT 1];
						lc.setConvertedStatus(convertStatus.MasterLabel);
						
						Database.LeadConvertResult lcr = Database.convertLead(lc);
						
						if(lcr.isSuccess()){
							u.ContactId = lcr.getContactId();
							c = [SELECT Id, AccountId 
									FROM Contact 
									WHERE Email = :contactEmail 
									WITH SECURITY_ENFORCED
									LIMIT 1];
							// TODO c.RecordTypeId = CONTACT_CUSTOMER_USER_RTID;
						}else{
							throw new JitException('Lead conversion unsuccessful!');
						}
					}
				}

				// create new Contact
				if(String.isBlank(u.ContactId)){
					c = new Contact();
					newContact = true;
				}
			}
		} else {// update
			if(attributes.containsKey(EMAIL_PATH)) {
				// ensure that a contact with the same email exists
				String contactEmail = attributes.get(EMAIL_PATH);
				for(Contact existingContact : [SELECT Id, AccountId 
												FROM Contact 
												WHERE Email = :contactEmail 
												WITH SECURITY_ENFORCED
												LIMIT 1]){
					c = existingContact;
				}
				system.debug('Contact Id : ' + c.Id);
				system.debug('accountId Id : ' + accountId);
				for(AccountContactRelation acr:[SELECT Id,AccountId from AccountContactRelation where ContactId =:c.Id AND AccountId =:accountId LIMIT 1]){
					isRelated = true;
				}
				if(c == null) {
					throw new JitException('Contact not found');
				}else if(u.ContactId != c.Id) {
					throw new JitException('Cannot change User.ContactId');
				}
			}
		}
		system.debug('isRelated : ' + isRelated);
		system.debug('newContact : ' + newContact);
		system.debug('c.AccountId != accountId : ' + c.AccountId != accountId);
		if(!newContact && c.AccountId != accountId && !isRelated) {
			throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
		}

		if(attributes.containsKey(EMAIL_PATH)) {
			c.Email = attributes.get(EMAIL_PATH);
		}
		if(attributes.containsKey(FIRSTNAME_PATH)) {
			c.FirstName = attributes.get(FIRSTNAME_PATH);
		}
		if(attributes.containsKey(LASTNAME_PATH)) {
			c.LastName = attributes.get(LASTNAME_PATH);
		}
		if(attributes.containsKey(PHONE_PATH)) {
			c.Phone = attributes.get(PHONE_PATH);
		}
		if(attributes.containsKey(MOBILEPHONE_PATH)) {
			c.MobilePhone = attributes.get(MOBILEPHONE_PATH);
		}
		if(attributes.containsKey(SALUTATION_PATH)){
			if(attributes.get(SALUTATION_PATH) == 'M' || attributes.get(SALUTATION_PATH) == 'autre'){
				c.Salutation = 'Mr.';
			}else if(attributes.get(SALUTATION_PATH) == 'MLE'){
				c.Salutation = 'Ms.';
			}
		}

		if(newContact) {
			c.AccountId = accountId;
			if (Schema.sObjectType.Contact.isCreateable()) {
				insert(c);
			}
			u.ContactId = c.Id;
		} else {
			if (Schema.sObjectType.Contact.isUpdateable()) {
				update(c);
			}
		}
	}

	/**
	 * @description handleAccount handles account logic after SSO
	 * @param  create     is new user
	 * @param  u          user instance
	 * @param  attributes saml sso attributes
	 * @return            return account id
	 */
	private String handleAccount(boolean create, User u, Map<String, String> attributes, Id communityId) {
		Account a;
		if(attributes.containsKey(ACCOUNTID_PATH)) {
			String accountId = attributes.get(ACCOUNTID_PATH);
			System.debug('ERP_Number : ' + accountId);

			// query Account using ERP Number
			// Note that the below loop will occur only once
			for(Account acc : [SELECT Id, Name 
								FROM Account 
								WHERE ERP_Number__c = :accountId 
								WITH SECURITY_ENFORCED 
								LIMIT 1]){
				a = acc;
			}
            
            System.debug('communityId ' + communityId);
            System.debug('B2B_SETTINGS.CommunityId__c ' + B2B_SETTINGS.CommunityId__c);
            
			if(a == null){
				throw new JitException('Account with ERPNumber ' + accountId + ' not found!');
			}else if(communityId == B2B_SETTINGS.CommunityId__c){// check if B2B community before logic below
				
				// enable account as Buyer Account
				BuyerAccount buyerAccount = new BuyerAccount(
					BuyerId = a.Id,
					Name = a.Name,
					IsActive = true
				);
				// check if Buyer Account does not already exists
				for(BuyerAccount buyerAcc : [SELECT Id 
												FROM BuyerAccount
												WHERE BuyerId = :a.Id]){
					buyerAccount.Id = buyerAcc.Id;
				}
				
				upsert buyerAccount;

				// Add Buyer Account to Buyer Group
				// https://help.salesforce.com/s/articleView?id=b2b_comm_lex_add_buyer_accounts_to_buyer_group.htm&type=5&language=en_US
				
				// get Buyer Group for B2B Store
				BuyerGroup b2bBuyerGroup;
				for(BuyerGroup bg : [SELECT Id
										FROM BuyerGroup
										WHERE Name = :B2B_SETTINGS.DefaultBuyerGroup__c
										LIMIT 1]){
					b2bBuyerGroup = bg;
				}

				if(b2bBuyerGroup == null){
					throw new JitException('Buyer Group ' + B2B_SETTINGS.DefaultBuyerGroup__c + ' not found!');
				}else{
					// upsert BuyerGroupMember
					BuyerGroupMember buyerGroupMember = new BuyerGroupMember(
						BuyerId = a.Id,
						BuyerGroupId = b2bBuyerGroup.Id
					);

					for(BuyerGroupMember bgm : [SELECT Id
												FROM BuyerGroupMember
												WHERE BuyerId = :a.Id
												AND BuyerGroupId = :b2bBuyerGroup.Id]){
						buyerGroupMember.Id = bgm.Id;
					}

					upsert buyerGroupMember;
				}

				// TODO Create Contact Point Address

				
			}
			
		}else{
			throw new JitException('Account ERP Number not provided.');
		}
		
		return a.Id;
	}

	@TestVisible
	private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		System.debug('handleJit create : ' + create);
		System.debug('handleJit u : ' + u);
		System.debug('handleJit attributes : ' + attributes);
		System.debug('handleJit samlSsoProviderId : ' + samlSsoProviderId);
		System.debug('handleJit communityId : ' + communityId);
		System.debug('handleJit portalId : ' + portalId);
		System.debug('handleJit federationIdentifier : ' + federationIdentifier);
		if(communityId != null || portalId != null) {
			String account = handleAccount(create, u, attributes, communityId);
			handleContact(create, account, u, attributes);
			setAuthorisations(create, u, assertion);	// sets Profile to user
			handleUser(create, u, attributes, federationIdentifier, false, communityId);
		} else {
			handleUser(create, u, attributes, federationIdentifier, true, communityId);
		}

		System.debug('u: ' + u);
	}

	global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		System.debug('createUser ');
		User u = new User();
		
		handleJit(true, u, samlSsoProviderId, communityId, portalId,
			federationIdentifier, attributes, assertion);
		
		return u;
	}

	global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
		String federationIdentifier, Map<String, String> attributes, String assertion) {
		System.debug('updateUser attributes : ' + attributes);
	
		User u = [SELECT Id, FirstName, ContactId, ProfileId, Profile.Name 
					FROM User 
					WHERE Id = :userId
					WITH SECURITY_ENFORCED];

		handleJit(false, u, samlSsoProviderId, communityId, portalId,
			federationIdentifier, attributes, assertion);
	}

	/**
	 * @description setAuthorisations sets Profile and Permission sets to user
	 * @author Gulshan DOORGAH ~ Comforth Karoo
	 * @param  create    if new user
	 * @param  u         user object
	 * @param  assertion SAML assertion
	 */
	private void setAuthorisations(Boolean create, User u, String assertion){
		Map<String, Object> mapAssertionAtributes = getAssertionAttributes(assertion);
		System.debug(mapAssertionAtributes.get(ROLES));
        Set<String> setRoles = (Set<String>) mapAssertionAtributes.get(ROLES);

		// determine Profile to user based on Custom Metadata 'SSO Passeport Setting'
		String profileName = '';
        Boolean roleFound = false;

		// get configured services from SSOPasseportSetting Custom Metadata
		for(SSOPasseportSetting__mdt setting : [SELECT DeveloperName, 								
														Profile__c
													FROM SSOPasseportSetting__mdt
													WHERE Active__c = true
                                                    AND DeveloperName IN :setRoles
													WITH SECURITY_ENFORCED
													ORDER BY Priority__c ASC]){
            roleFound = true;
			// if new User
			if(create && String.isBlank(profileName)){
				profileName = setting.Profile__c;	// store the profile name; to be queried later
			}
		}
        
        if(!roleFound){
            throw new JitException('Vous n\'avez pas le bon service. Merci de contacter votre admin.');
        }

		// if new user or change of profile
		if(create || u.Profile.Name != profileName){
			for(Profile p : [SELECT Id 
								FROM Profile 
								WHERE Name = :profileName 
								WITH SECURITY_ENFORCED 
								LIMIT 1]){
				u.ProfileId = p.Id;
			}
		}

		String userId = u.Id;
		
	}

	/**
	 * @description getAssertionAttributes get assertion attributes that are needed for further processing like Roles
	 * @author Gulshan DOORGAH ~ Comforth Karoo
	 * @param  assertion assertion in base64 format
	 * @return           return a map of attributes with their values as in the assertion
	 */
	private static Map <String, Object> getAssertionAttributes(String assertion){
		// Encode Base 64 Decode assertion value for getting saml
		Blob blobXML = EncodingUtil.base64Decode(assertion);
		String ns = 'urn:oasis:names:tc:SAML:2.0:assertion';

		Dom.document doc = new Dom.Document();    
        doc.load(blobXML.toString());
        dom.XmlNode xroot = doc.getRootElement();

		List<dom.XmlNode> xnAttributeList = xroot.getChildElement('Assertion', ns).getChildElement('AttributeStatement',ns).getChildElements(); 

		List<DOM.XmlNode> xnAttributeValList = new List<DOM.XmlNode>();
		Set <String> setExtendedRoles = new Set <String>();
		Set <String> setRoles = new Set <String>();
		for(Dom.XmlNode xn : xnAttributeList){
           
            //Check Name attribute matches Extended Role        
            if(xn.getAttribute('Name','') == 'http://passeport.cegid.com/ExtendedRole'){
                xnAttributeValList = xn.getChildElements();
                for(Dom.XmlNode xnv : xnAttributeValList){
					//System.debug(xnv.getText());
					setExtendedRoles.add(xnv.getText().replaceAll('\\s+', ''));	// remove any space and add to set
                }
            }

			//Check Name attribute matches Role        
            if(xn.getAttribute('Name','') == 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'){
                xnAttributeValList = xn.getChildElements();
                for(Dom.XmlNode xnv : xnAttributeValList){
					//System.debug(xnv.getText());
					setRoles.add(xnv.getText().replaceAll('\\s+', ''));	// remove any space and add to set
                }
            }
        }

		return new Map <String, Object>{
			EXTENDED_ROLES 	=> setExtendedRoles,
			ROLES			=> setRoles
		};
	}
}