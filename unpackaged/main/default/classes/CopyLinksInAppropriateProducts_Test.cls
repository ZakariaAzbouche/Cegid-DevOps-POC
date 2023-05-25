@isTest
public class CopyLinksInAppropriateProducts_Test {
    @isTest 
    static void testmethodTest(){
    String test1 = 'Coucou';
    String test2 = 'Nope';
    System.assertEquals(CopyLinksInAppropriateProducts.methodTest(test1),'ok');
    System.assertEquals(CopyLinksInAppropriateProducts.methodTest(test2),'ko');
    }
}