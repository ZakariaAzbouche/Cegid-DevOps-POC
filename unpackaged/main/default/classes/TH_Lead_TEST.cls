@isTest
public with sharing class TH_Lead_TEST {
    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();        
    private static final String TELEMARKETING_PROFILE_NAME = 'Cegid Telemarketing';

    @isTest static void createLeadTest() {
        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
        Account acc = new Account(Name='Test');
        
        List<Contact> cts = new List<Contact>();
        List<Lead> lds = new List<Lead>();
        
        for(Integer i = 0; i < 21; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('Test'));
        }

        lds[0].Lead_s_Chosen_Solution__c = 'CPA';
        lds[1].Lead_s_Chosen_Solution__c = 'Retail'; 
        lds[2].Lead_s_Chosen_Solution__c = 'HR'; 
        lds[3].Lead_s_Chosen_Solution__c = 'HR'; 
        lds[4].Lead_s_Chosen_Solution__c = 'Manufacturing Industry'; 
        lds[5].Lead_s_Chosen_Solution__c = 'TPE & Association';  
        lds[6].Lead_s_Chosen_Solution__c = 'HR';

        lds[7].ImpartnerPRM__IsDealRegistration__c = true;
        lds[8].ImpartnerPRM__IsDealRegistration__c = true;
        lds[9].ImpartnerPRM__IsDealRegistration__c = true;
        lds[10].ImpartnerPRM__IsDealRegistration__c = true;

        lds[11].Email = 'test1@test1.fr';
        lds[12].Email = 'test2@test2.fr';
        lds[13].Email = 'test3@test3.fr';
        lds[14].Email = 'test4@test4.fr'; 
        lds[15].Email = 'test5@test5.fr';
                
        System.runAs(adminUser) {
            insert acc;
        }

        lds[16].ImpartnerPRM__IsDealRegistration__c = true;
        lds[16].ImpartnerPRM__PartnerAccount__c = acc.Id;
        lds[17].ImpartnerPRM__PartnerAccount__c = acc.Id;
        lds[18].ImpartnerPRM__PartnerAccount__c = acc.Id;
        lds[19].ImpartnerPRM__PartnerAccount__c = acc.Id;
        lds[20].ImpartnerPRM__PartnerAccount__c = acc.Id;

        for(Integer i = 0; i < 5; i++) {
            cts.add(new UTIL_TestFactory.ContactFactory().createContact(acc.Id));
            cts[i].Email = 'test'+i+'@test'+i+'.fr';
        }

        System.runAs(adminUser) {
            insert cts;
            insert bypass;
        }

        List<Lead> contactLeads;
        List<Lead> leads;
        Test.startTest();
        System.runAs(adminUser) {
            List<Database.SaveResult> results = Database.insert(lds, false);
        }
        Test.stopTest();
    }

    @isTest static void updateLeadTest() {
        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
    
        List<Lead> lds = new List<Lead>();
        
        for(Integer i = 0; i < 17; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('Test'));
        }

        lds[0].Lead_s_Chosen_Solution__c = 'CPA';
        lds[1].Lead_s_Chosen_Solution__c = 'Retail'; 
        lds[2].Lead_s_Chosen_Solution__c = 'HR'; 
        lds[3].Lead_s_Chosen_Solution__c = 'HR'; 
        lds[4].Lead_s_Chosen_Solution__c = 'Manufacturing Industry'; 
        lds[5].Lead_s_Chosen_Solution__c = 'TPE & Association';  
        lds[6].Lead_s_Chosen_Solution__c = 'HR';

        lds[7].ImpartnerPRM__IsDealRegistration__c = true;
        lds[8].ImpartnerPRM__IsDealRegistration__c = true;
        lds[9].ImpartnerPRM__IsDealRegistration__c = true;
        lds[10].ImpartnerPRM__IsDealRegistration__c = true;

        lds[11].Email = 'test1@test1.fr';
        lds[12].Email = 'test2@test2.fr';
        lds[13].Email = 'test3@test3.fr';
        lds[14].Email = 'test4@test4.fr';
        lds[15].Email = 'test5@test5.fr';
                
        lds[16].ImpartnerPRM__IsDealRegistration__c = true;
    
        System.runAs(adminUser) {
            insert bypass;
        }

        insert lds;

        for(Integer i = 0 ; i < lds.size() ; i++) {
            lds[i].LastName = 'TestN'+i;
        }
        
        List<Lead> leads;
        Test.startTest();
        
        List<Database.SaveResult> results = Database.update(lds, false);
        
        Test.stopTest();
    }

    @isTest static void createTelemarkLeadTest() {
        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
        List<Lead> lds = new List<Lead>();
        
        for(Integer i = 0; i < 2; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('Test'));
            lds[i].ImpartnerPRM__IsDealRegistration__c = true;
        }

        lds[0].Status = 'New';
        lds[1].Status = 'Closed - Not Converted';

        System.runAs(adminUser) {
            insert bypass;
        }

        User telemarkUser = createUserTelemarketing();

        Test.startTest();
        System.runAs(telemarkUser) {
            List<Database.SaveResult> results = Database.insert(lds, false);
            System.debug(results);
        }
        Test.stopTest();

    }

   

    private static User createUserTelemarketing() {
        /**
        * @description Crée un utilisateur de Telemarketeur
        */     
        User userUsrTelemark = new User(
            alias = 'TestTele',
            email = 'testTele.sales@example.com',
            emailencodingkey = 'UTF-8',
            BypassPB__c = true,
            BypassVR__c = true,
            BypassWF__c = true,
            lastname = 'testsales',
            languagelocalekey = 'fr',
            localesidkey = 'fr_FR',
            profileid = [
                SELECT Id
                FROM Profile
                WHERE Name = :TELEMARKETING_PROFILE_NAME
                LIMIT 1
            ][0].Id,
            timezonesidkey = 'Europe/Paris',
            username = 'test.telemarketing' + System.now().millisecond()
            + UserInfo.getOrganizationId() + '@example.com'
        );
        return userUsrTelemark;
    }

    @isTest static void switchTest() {
        
        Test.startTest();
            String result1 = TH_Lead.switch('CPA');
            String result2 = TH_Lead.switch('Retail');
            String result3 = TH_Lead.switch('HR');
            String result4 = TH_Lead.switch('Finance');
            String result5 = TH_Lead.switch('Manufacturing Industry');
            String result6 = TH_Lead.switch('TPE & Association');
            String result7 = TH_Lead.switch('Key null');
        Test.stopTest();
        System.assertEquals('110', result1, 'result should be 110');
        System.assertEquals('200', result2, 'result should be 200');
        System.assertEquals('320', result3, 'result should be 320');
        System.assertEquals('315', result4, 'result should be 315');
        System.assertEquals('340', result5, 'result should be 340');
        System.assertEquals('100', result6, 'result should be 100');
        System.assertEquals(null, result7, 'result should be null');
        
    }


    @isTest static void mergeLeadFieldForTelemarkTest() {
        List<Lead> lds = new List<Lead>();

        for(Integer i = 0;i < 4;i++) {
            if(math.mod(i,2) == 0) {
                lds.add(new Lead(TECH_Is_Fusion__c = true,
                                 Last_Touch_Source_Telemarketing__c = 'IBD',
                                 TECH_Marketing_Status_Tmp__c = 'AQL',
                                 TECH_Marketing_Campaign_Tmp__c = 'TEST MKT' +i));
            } else {
                lds.add(new Lead(TECH_Is_Fusion__c = false));
            }
            
        }

        Test.startTest();
            TH_Lead th = new TH_Lead();

            System.runAs(adminUser) {
                System.debug(UserInfo.getProfileId());
                List<PermissionSetAssignment> permissions = [SELECT Id,
                                                            PermissionSet.Name,
                                                            PermissionSet.ProfileId,
                                                            PermissionSet.Profile.Name,
                                                            AssigneeId, Assignee.Profile.Name 
                                                            FROM PermissionSetAssignment
                                                            WHERE AssigneeId =: UserInfo.getUserId()];
                User us = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
                th.mergeLeadFieldForTelemark(lds, us, permissions);
            }
        Test.stopTest();

        System.assertEquals(false, lds[0].TECH_Is_Fusion__c);
        System.assertEquals('AQL', lds[0].Marketing_Status__c);
        System.assertEquals('TEST MKT0', lds[0].Marketing_Campaign__c);
        System.assertEquals('IBD', lds[0].ATTRILTSource__c);

        System.assertEquals(false, lds[1].TECH_Is_Fusion__c);
        System.assertEquals(null, lds[1].Marketing_Status__c);
        System.assertEquals(null, lds[1].Marketing_Campaign__c);
        System.assertEquals(null, lds[1].ATTRILTSource__c);
    }

    @isTest static void beforeUpdate() {
        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
        List<Lead> lds = new List<Lead>();
        
        for(Integer i = 0; i < 3; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('Test'));
            lds[i].ImpartnerPRM__IsDealRegistration__c = true;
        }

        lds[1].Status = 'New';
        lds[2].Status = 'Closed - Not Converted';

        System.runAs(adminUser) {
            insert bypass;
            insert lds;
        }

        User telemarkUser = createUserTelemarketing();

        for(Lead ld : lds) {
            ld.TECH_Is_Fusion__c = true;
            ld.Last_Touch_Source_Telemarketing__c = 'IBD';
            ld.TECH_Marketing_Status_Tmp__c = 'AQL';
            ld.TECH_Marketing_Campaign_Tmp__c = 'TEST MKT';
        }

        Test.startTest();
        System.runAs(telemarkUser) {
            List<Database.SaveResult> results = Database.update(lds, false);
            System.debug(results);
        }
        Test.stopTest();
    }

    @isTest static void leadOppyMergeTraitementTest() {
        BypassTrigger__c bypass = new BypassTrigger__c(Activatetrigger__c = true);
        List<Lead> lds = new List<Lead>();
        Account acc = new UTIL_TestFactory.AccountFactory().createAccount();
        acc.ERP_Number__c = 'TESTERP';
        acc.Phone = '0143434543';
        acc.BillingStreet = 'Rue du Test';
        acc.BillingPostalCode = '69007';
        acc.BillingCity = 'LYON';
        acc.Status__c = 'Validated';
        acc.National_Id__c = '32345545656767';
        acc.IntercommunityVATnumber__c = 'Test';
        acc.Tech_Contact_Direct__c = true;

        insert acc;

        List<Opportunity> opps = new List<Opportunity>();
        
        for(Integer i = 0; i < 5; i++) {
            Opportunity opp = new UTIL_TestFactory.OpportunityFactory().createOpportunity(acc.Id, true, false);
            opp.Sales_Purpose__c = '111';
            opp.Expertise__c = '110';
            opp.Product_Line__c = '292';

            if(math.mod(i,2) == 0) {
                opp.TECH_New_oppy_From_Lead__c = true;
            }
            opps.add(opp);
        }

        System.debug(adminUser);
        System.runAs(adminUser) {
            insert opps;
        }
        

        
        for(Integer i = 0; i < 5; i++) {
            Lead ld = new UTIL_TestFactory.LeadFactory().createLead('Test');
            
            
            ld.IsConverted = true;
            ld.ConvertedAccountId = acc.Id;
            ld.ConvertedOpportunityId = opps[i].Id;
            ld.Amount__c = 235698;

            if(math.mod(i,2) == 0) {
                ld.Project_s_associated_contact_2__c = 'Test assoc contact 2';
                ld.Role_in_decision_2__c = 'partner';
                ld.Availability2__c = 'Test availability contact 2';
            } else {
                ld.Project_s_associated_contact_1__c = 'Test assoc contact 1';
                ld.Role_in_decision_1__c = 'partner';
                ld.Availability1__c = 'Test availability contact 1';
            }

            
               
            lds.add(ld);

        }

        System.runAs(adminUser) {
            insert bypass;
            insert lds;
        }
        Map<Id, Lead> mapLds = new Map<Id, Lead>(lds);
        TH_Lead th = new TH_Lead();

        Test.startTest();
        
        System.runAs(adminUser) {
            th.leadOppyMergeTraitement(mapLds);
        } 
        
        Test.stopTest();
        List<Opportunity> newOpps = [SELECT Id, Description, TECH_New_oppy_From_Lead__c FROM Opportunity];

        List<Opportunity> oppNewDescription = new List<Opportunity>();
        List<Opportunity> oppNoDescription = new List<Opportunity>();

        for(Opportunity opp : newOpps) {
            if(opp.Description != null) {
                oppNewDescription.add(opp);
            } else {
                oppNoDescription.add(opp);
            }
        }

        System.assertEquals(3, oppNewDescription.size(), '3 oppys should have description field');
        System.assertEquals(2, oppNoDescription.size(), '2 oppys should have description field');
    }


    @isTest static void affectLeadTelemarketingGroupTest() {
        List<Lead> lds = new List<Lead>();
        for(Integer i = 0; i < 10; i++) {
            lds.add(new UTIL_TestFactory.LeadFactory().createLead('Test'));
        }

        Group grpTelemark = new Group(Name = 'Telemarketing Leads', DeveloperName = 'Telemarketing_Leads');

        System.runAs(adminUser) {
            insert grpTelemark;
            insert lds;
        }

        List<Lead> ldsTest = [SELECT Id, Marketing_Status__c, Status, OwnerId FROM Lead];

        
        Map<Id, Lead> ldsMapTest = new Map<Id, Lead>(ldsTest.clone());
        Integer i = 0;
        for(Lead ld : ldsTest) {
            ld.Marketing_Status__c = 'AQL';
            if(Math.mod(i, 2) == 0) {
                ld.Marketing_Status__c = 'AQL';
                ld.Status = 'New';   
            } else {
                ld.Status = 'In Progress'; 
            }
            i++;
        }

        TH_Lead th = new TH_Lead();

        Test.startTest();

        th.affectLeadTelemarketingGroup(ldsTest, null, grpTelemark.Id);

        Test.stopTest();

        Integer nbChange = 0;

        Integer nbNoChange = 0;

        for(Lead ld : ldsTest) {
            System.debug(ld.Status);
            System.debug(ld.OwnerId);
            if(ld.Status == 'In buffer' && ld.OwnerId == grpTelemark.Id) {
                nbChange++;
            } else {
                nbNoChange++;
            }
        }
        System.assertEquals(5, nbChange, '5 lead should changed by method');
        System.assertEquals(5, nbNoChange, '5 lead should not changed by method');

    }

   @isTest static void computeBufferNameTest() {
       
       Group grpTelemark = new Group(Name = 'Telemarketing Leads', DeveloperName = 'Telemarketing_Leads');

        System.runAs(adminUser) {
            insert grpTelemark;
        }

        List<Lead> lds = new List<Lead>();

        Lead ld;
        for(Integer i = 0 ; i < 150 ; i++) {

            if(i < 100) {
                ld = new Lead(OwnerId = grpTelemark.Id);
            } else {
                ld = new Lead();
            }
            switch on i {
                when 0,1,2,3,4,5,6,7,8,9 {
                    if(Math.mod(i, 9) == 0) {
                        ld.Expertise__c = '110';
                    } else if (Math.mod(i, 8) == 0) {
                        ld.Expertise__c = '350';
                    } else if (Math.mod(i, 7) == 0) {
                        ld.Expertise__c = '100';
                    } else if (Math.mod(i, 6) == 0) {
                        ld.Expertise__c = '999';
                    } else if (Math.mod(i, 5) == 0) {
                        ld.Expertise__c = '370';
                    } else if (Math.mod(i, 4) == 0) {
                        ld.Expertise__c = '360';
                    } else {
                        ld.Expertise__c = null;
                    }
                }
                when 10,11,12,13,14,15,16,17,18,19 {
                    ld.Expertise__c = '320';

                    if(Math.mod(i, 5) == 0) {
                        ld.CountryCode = 'FR';
                    } else if (Math.mod(i, 4) == 0) {
                        ld.CountryCode = 'VE';
                    } else if (Math.mod(i, 3) == 0) {
                        ld.CountryCode = 'CA';
                    } else if (Math.mod(i, 2) == 0) {
                        ld.CountryCode = 'US';
                    } else {
                        ld.CountryCode = null;
                    }
                }
                when 20,21,22,23,24,25,26,27,28,29 {
                    ld.Expertise__c = '310';

                    if(Math.mod(i, 3) == 0) {
                        ld.CountryCode = 'ES';
                    } else if (Math.mod(i, 2) == 0) {
                        ld.CountryCode = 'FR';
                    } else {
                        ld.CountryCode = null;
                    }
                    
                }
                when 30,31,32,33,34,35,36,37,38,39 {
                    ld.Expertise__c = '200';
                    ld.Marketing_Campaign__c = 'testVRtest';

                    if(Math.mod(i, 3) == 0) {
                        ld.Marketing_Campaign__c = 'testVaRtest';
                    } else if (Math.mod(i, 2) == 0) {
                        ld.CountryCode = 'TN';
                    } else {
                        ld.CountryCode = 'CA';
                    }
                    
                }
                when 40,41,42,43,44,45,46,47,48,49 {
                    ld.Expertise__c = '340';
                    ld.Marketing_Campaign__c = 'testVRtest';

                    if(Math.mod(i, 3) == 0) {
                        ld.Marketing_Campaign__c = 'testVaRtest';
                    }
                    
                }
                when 50,51,52,53,54,55,56,57,58,59 {
                    ld.Expertise__c = '380';

                    if(Math.mod(i, 9) == 0) {
                        ld.CountryCode = 'FR';
                    } else if (Math.mod(i, 8) == 0) {
                        ld.CountryCode = 'JM';
                    } else if (Math.mod(i, 6) == 0) {
                        ld.CountryCode = 'US';
                    } else if (Math.mod(i, 5) == 0) {
                        ld.CountryCode = 'CH';
                    } else if (Math.mod(i, 4) == 0) {
                        ld.CountryCode = 'LU';
                    } else {
                        ld.CountryCode = 'NO';
                    }  
                }
            }

            lds.add(ld);
        }

        TH_Lead th = new TH_Lead();

        Test.startTest();
        th.computeBufferName(lds, grpTelemark.Id);
        Test.stopTest();

        Map<String, Integer> mapNbBuffer = new Map<String, Integer>();

        for(Lead led : lds) {
            if(mapNbBuffer.containsKey(led.Buffer_Name__c)) {
                mapNbBuffer.put(led.Buffer_Name__c, mapNbBuffer.get(led.Buffer_Name__c) + 1);
            } else {
                mapNbBuffer.put(led.Buffer_Name__c, 1);
            }
        }

        System.assertEquals(50, mapNbBuffer.get(null), '50 leads should not have buffer name');
        System.assertEquals(2, mapNbBuffer.get('HCM Canada - USA'), '2 leads should be HCM Canada - USA');
        //System.assertEquals(3, mapNbBuffer.get('HCM Iberia - Latam'), '3 leads should be HCM Iberia - Latam');
        System.assertEquals(3, mapNbBuffer.get('Partner Marketing leads - ERP'), '3 leads should be Partner Marketing leads - ERP');
        System.assertEquals(4, mapNbBuffer.get('Partner Marketing leads - Retail'), '3 leads should be Partner Marketing leads - Retail');
        System.assertEquals(3, mapNbBuffer.get('Retail International'), '3 leads should be Retail International');
        System.assertEquals(3, mapNbBuffer.get('TAX Spain'), '3 leads should be TAX Spain');
        System.assertEquals(1, mapNbBuffer.get('Talentsoft Benelux'), '3 leads should be Talentsoft Benelux');
        System.assertEquals(2, mapNbBuffer.get('Talentsoft DACH'), '3 leads should be Talentsoft DACH');
        System.assertEquals(5, mapNbBuffer.get('Talentsoft Nordics'), '3 leads should be Talentsoft Nordics');
        System.assertEquals(74, mapNbBuffer.get('Telemarketing France'), '74 leads should be Telemarketing France');

   }
}