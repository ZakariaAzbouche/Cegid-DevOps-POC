// Determines the taxes for the cart
public class B2BSyncTax {
    // This invocable method only expects one ID
    @InvocableMethod(callout=true label='Prepare the taxes' description='Runs a synchronous version of taxes' category='B2B Commerce')
    public static void syncTax(List<ID> cartIds) {
        // Validate the input
        if (cartIds == null || cartIds.size() != 1) {
            String errorMessage = 'A cart id must be included to B2BSyncTax'; // Get wording from doc!!!
           // saveCartValidationOutputError(errorMessage, '');
            throw new CalloutException (errorMessage);
        }
        
        // Extract cart id and start processing
        Id cartId = cartIds[0];
       startCalculateTax(cartId);
    }

    private static void startCalculateTax(Id cartId){

        List<CartTax> listCartTax = new List<CartTax>();
        set<Id> setCartIds = new set<Id>();
        set<Id> setAccountIds = new set<Id>();

        List<B2B_Settings__c> listCustomSetting = [SELECT Id,Dom__c,Tom__c FROM B2B_Settings__c LIMIT 1];

        List<String> listDom = listCustomSetting[0].Dom__c.split(';');
        List<String> listTom = listCustomSetting[0].Tom__c.split(';');

        Set<String> franceDOM = new Set<String>(listDom);
        Set<String> franceTOM = new Set<String>(listTom);

        //Set<String> franceDOM = new Set<String>{'971','972','974'};
        //Set<String> franceTOM = new Set<String>{'970','973','975','976','977','978','987','988'};


        set<String> setBillingCountry = new set<String>();
        String postalCode;
        String taxType;

        for(WebCart wc:[SELECT Id,AccountId FROM WebCart WHERE Id =:cartId]){
            setAccountIds.add(wc.AccountId);
        }

        for(Account acc:[SELECT Id, BillingCountry,BillingPostalCode FROM Account WHERE Id IN:setAccountIds LIMIT 1]){
            
            if(acc.BillingCountry =='France'){
                //masterLabel = 'Normal for France';
                setBillingCountry.add(acc.BillingCountry);
                postalCode = acc.BillingPostalCode;
            }else{
                setBillingCountry.add('International');
            }
        }

        //differenciate between type of tax France DOM AND TOM
        //DOM 
        if(setBillingCountry.contains('France')){
            if (franceDOM.contains(postalCode.left(3))) {
                taxType = 'Dom';
            }else if(franceTOM.contains(postalCode.left(3))) {
                taxType = 'Tom';
            }else{
                taxType = 'Normal';
            }
        }else{
            taxType = 'Normal';
        }
        

        //Get Metadata type related to country and postalcode
        List<Tax_Type__mdt> listTax = [SELECT id,Label,Domiciliation__c,Tax_Percent__c,Type__c,MasterLabel 
                                      FROM Tax_Type__mdt where Domiciliation__c IN:setBillingCountry AND Type__c =:taxType LIMIT 1];

        //Get CartItems 
        List<CartItem> listCI = [SELECT Id,TotalPrice, Type FROM CartItem WHERE CartId =:cartId];
        
        for(CartItem ci:listCI){
            setCartIds.add(ci.Id);
        }

        //Exisiting Cart type 
        Map<Id,CartTax> mapCart = new Map<Id,cartTax>();//[SELECT Id FROM CartTax WHERE CartItemId IN:setCartIds];
        for(CartTax ct:[SELECT Id,CartItemId FROM CartTax WHERE CartItemId IN:setCartIds]){
            mapCart.put(ct.CartItemId,ct);
        }



        //Get CartItems based on CartIds
        for (CartItem cartItem : listCI){
            for(Tax_Type__mdt taxValue:listTax){
                if (cartItem.Type == 'Product') {
                    System.debug('zz' + taxValue.Tax_Percent__c);
                    System.debug('zz' + cartItem.TotalPrice);
                    CartTax tax = new CartTax( 
                        Amount = (taxValue.Tax_Percent__c/100)* cartItem.TotalPrice,
                        CartItemId = cartItem.Id,
                        Id =(mapCart.containsKey(cartItem.Id))?mapCart.get(cartItem.Id).Id:null,
                        Name = taxValue.MasterLabel,
                        TaxCalculationDate = Date.today(),
                        TaxRate = 0,
                        TaxType = 'Actual'
                    );
                    listCartTax.add(tax);
                }
            }
            
        }

        if(listCartTax.size()>0){
            upsert listCartTax;
        }
    }
    
}