@isTest
public class VFC04_TargetdPrices_TEST {
    /**
    * @author MCU - Comforth
    * @date 2023-02-28
    * @group UTIL
    * @description Classe VFC04_TargetdPrices_TEST
    */
    
    
    @isTest static void VFC04_TargetdPrices() {
        
        Test.StartTest();
        PageReference testPage = Page.VFP04_TargetedPrices; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('quoteId', 'dummyId');
        
        VFC04_TargetdPrices vfc04 = new VFC04_TargetdPrices();    
        Test.StopTest();
    }
     
}