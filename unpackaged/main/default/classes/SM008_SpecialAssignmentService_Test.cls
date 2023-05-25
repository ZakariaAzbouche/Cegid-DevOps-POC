/**
 * @description       : Test class for SM008_SpecialAssignmentService
 * @author            : Easyfront Consulting
 * @group             : 
 * @created on: 23-11-2022 
**/
@isTest
public with sharing class SM008_SpecialAssignmentService_Test {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();
    static final String PRIMARY_CONTACT_EMAIL = 'calcrollupcontact@email.com';

    @TestSetup 
    static void setup(){    
        //testing as admin because of issues with CPQ rights when testing as Cegid sales
        System.runAs(adminUser){      
            insert new BypassTrigger__c(SetupOwnerId = UserInfo.getOrganizationId(), Activatetrigger__c = true);
            
            Test.startTest(); //to prevent SOQL limits from SBQQ package
            
            //Create group
            Schema.DescribeFieldResult fieldResult = Special_Assignment__c.Agency__c.getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            List<Group> groupToCreate = new List<Group>();
            for( Schema.PicklistEntry pickListVal : ple){
                Group grp = new Group(Name = 'Approval RCC - '+pickListVal.getValue());
                groupToCreate.add(grp);
            } 
            upsert groupToCreate Name;
            //Create Email Template
            List<sbaa__EmailTemplate__c> tempToCreate = new List<sbaa__EmailTemplate__c>();
            sbaa__EmailTemplate__c tempRequest = new sbaa__EmailTemplate__c(Name='Approval - Request Template', sbaa__TemplateId__c='00X1t000000Moek');
            sbaa__EmailTemplate__c tempApprove = new sbaa__EmailTemplate__c(Name='Approval - Approval Template',sbaa__TemplateId__c='00X1t000000Moek');
            sbaa__EmailTemplate__c tempReject = new sbaa__EmailTemplate__c(Name='Approval - Rejection Template',sbaa__TemplateId__c='00X1t000000Moek');
            insert tempRequest;
            insert tempApprove;
            insert tempReject;
            //Create Approval Chain for RCC appro
            sbaa__ApprovalChain__c approChainRCC = new sbaa__ApprovalChain__c(Name = 'RCC Chain', sbaa__TargetObject__c='SBQQ__Quote__c');
            insert approChainRCC;
            Test.stopTest();
        }
    }
    //Test method for rccApprovalSettingsCreationManagement
    @isTest static void rccApprovalSettingsCreationManagement_test() {
        //Create Special Assignment
        Special_Assignment__c spa = new Special_Assignment__c(RCC_User__c = adminUser.Id, Agency__c='217');
        Test.startTest();                
        insert spa;
        //Test update
        spa.Second_User__c = adminUser.Id;
        update spa;
        Test.stopTest();
    }
}