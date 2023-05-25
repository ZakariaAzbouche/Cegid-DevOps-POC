/**
 * @author Varun Molla - Comforth Karoo
 * @date Creation 2021-11-11
 * @description Test class for apex class B2B_MandatSEPA
 *              
*/
@isTest
private class B2B_MandatSEPA_TEST {

    static User adminUser = new UTIL_TestFactory.UserFactory().createRunningUserAdministrator();

    @isTest static void decryptData_Test(){ 
        System.runAs(adminUser){ 
            Account acct = new Account(Name='tAccount');
            insert acct;

            Order od = new Order();
            od.Name = '14TPE000001';
            od.AccountId = acct.Id;
            od.EffectiveDate = Date.Today();
            od.Status = 'Draft';
            od.BIC__c = 'CDEFGHIJ';
            od.IBAN__c = 'CDEFGHIJABCDEFGHIJABCDEFG';
            insert od;

            Test.startTest();
                PageReference vfPage = Page.B2B_MandatSEPA; // VF_PageName: replace with your vfpage
                Test.setCurrentPage(vfPage);

                ApexPages.StandardController sc = new ApexPages.StandardController(od);
                ApexPages.currentPage().getParameters().put('Id', od.id);

                B2B_MandatSEPA sepa = new B2B_MandatSEPA(sc);
            Test.stopTest();
        }   
    }

    @isTest static void decryptData_Test_2(){ 
        System.runAs(adminUser){ 
            Account acct = new Account(Name='tAccount');
            insert acct;

            Order od = new Order();
            od.Name = '14TPE000001';
            od.AccountId = acct.Id;
            od.EffectiveDate = Date.Today();
            od.Status = 'Draft';
            od.New_BIC__c = 'CDEFGHIJ';
            od.New_IBAN__c = 'CDEFGHIJABCDEFGHIJABCDEFG';
            insert od;

            Test.startTest();
                PageReference vfPage = Page.B2B_MandatSEPA; // VF_PageName: replace with your vfpage
                Test.setCurrentPage(vfPage);

                ApexPages.StandardController sc = new ApexPages.StandardController(od);
                ApexPages.currentPage().getParameters().put('Id', od.id);

                B2B_MandatSEPA sepa = new B2B_MandatSEPA(sc);
            Test.stopTest();
        }   
    }
}