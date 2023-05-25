/**
 * @description       : Controller for lwc b2bOrderRecap
 * @author            : Keshav Matabadul
 * @group             : B2B
 * @last modified on  : 11-29-2021
 * @last modified by  : keshav Matabadul
**/
public class B2B_OrderRecap {

    public class resultWrapper{
        @AuraEnabled public  List<participantObject> listParticipants;
        @AuraEnabled public ConnectApi.CartItemResult cartItemObj;
        @AuraEnabled public ConnectApi.CartSummary cartSummary;
    }

    public class participantObject{
        @AuraEnabled public  string firstName;
        @AuraEnabled public  string lastName;
        @AuraEnabled public  string cartItemId;
        @AuraEnabled public  string parId;
    }

    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(
      String communityId,
      String effectiveAccountId,
      String activeCartOrId,
      String pageParam,
      String sortParam
    ) {
      // Lookup the webstore ID associated with the community
      String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
  
      // Get the ConnectApi.CartItemSortOrder enum value from string.
      // For the list of possible values, see:
      // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
      ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(
        sortParam
      );
  
      // For more details, see:
      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
      
      System.debug('zz' + webstoreId + '|' + effectiveAccountId + '|' + activeCartOrId + '|' + pageParam + '|' + resolvedSortParam + '|' + sortParam);

      return ConnectApi.CommerceCart.getCartItems(
        webstoreId,
        effectiveAccountId,
        activeCartOrId,
        pageParam,
        resolvedSortParam
      );
    }   


    @AuraEnabled
    public static List<resultWrapper> getRecapDataV1(List<Id> listCartIds,String communityId,String effectiveAccountId,String activeCartOrId,String pageParam,String sortParam){ 

        //Declare New List Wrapper to return values 
        List<resultWrapper> listWrapper = new List<resultWrapper>();
        Set<Id> setParticipantIds = new Set<Id>();
		
        ConnectApi.CartItemCollection cartItemCollection;
        try{
            //call method getCartItems
            cartItemCollection = getCartItems(communityId, effectiveAccountId, activeCartOrId, pageParam, sortParam);
            System.debug('cartItemCollection : ' + cartItemCollection.cartSummary);
        }catch(Exception e){
            if(Test.isRunningTest()){
                cartItemCollection = new ConnectApi.CartItemCollection();
            	cartItemCollection.cartItems = new List<ConnectApi.CartItemResult>();
                
                for(CartItem ci : [SELECT Id FROM CartItem WHERE CartId = :activeCartOrId]){
                    ConnectApi.CartItemResult cartItemResult = new ConnectApi.CartItemResult();
                    cartItemResult.cartItem = new ConnectApi.CartItem();
                    cartItemResult.cartItem.cartItemId = ci.Id;
                    cartItemResult.cartItem.cartId = activeCartOrId;
                    cartItemCollection.cartItems.add(cartItemResult);
                }
            }
        }
        
        //Populate Set Id of cartItemIds
            for(Integer c = 0; c < cartItemCollection.cartItems.size(); c++){
                setParticipantIds.add(cartItemCollection.cartItems[c].cartItem.cartItemId);
            }

        System.debug('setParticipantIds : '+ setParticipantIds);

        //get Participant related to CartItems 
        List<Participant__c> listParticipants = [SELECT Id,CartItemId__c,Name,Prenom__c FROM Participant__c WHERE CartItemId__c IN:setParticipantIds];

        for(Integer c = 0; c < cartItemCollection.cartItems.size(); c++){
            resultWrapper rw = new resultWrapper();
            list<participantObject> participantsList = new list<participantObject>();
            for(Participant__c par:listParticipants){
                if(cartItemCollection.cartItems[c].cartItem.cartItemId == par.CartItemId__c){
                    System.debug('enter positive condition');
                    //Declare New Object Participant 
                    participantObject parObj = new participantObject();
                    parObj.firstName = par.Prenom__c;
                    parObj.lastName = par.Name;
                    parObj.cartItemId = par.CartItemId__c;
                    parObj.parId = par.Id;
                    participantsList.add(parObj);
                }
            }
            //return Wrapper for each line 
            rw.listParticipants = participantsList;
            rw.cartItemObj = cartItemCollection.cartItems[c];
            rw.cartSummary = cartItemCollection.cartSummary;
            listWrapper.add(rw);
        }

        System.debug('listWrapper ; ' + listWrapper);
        return listWrapper;
    }

    // @AuraEnabled
    // public static ConnectApi.CartSummary checkPromoCode(String promoInput,List<Id> listCartIds,String communityId,String effectiveAccountId,String activeCartOrId,String pageParam,String sortParam){  
    //   System.debug('checkPromoCode');
    //   string errorMessage = System.Label.b2bOrderRecapPromoMessage;
    //   string valideMessage = 'Valid';
    //   List<CartItem> listCIToUpdate = new list<CartItem>();
    //   List<CEGID_Promotion__c> listPromo = [SELECT Name,Promotion_Code__c,Discount__c FROM CEGID_Promotion__c WHERE Promotion_Code__c =:promoInput limit 1 ];

    //   if(listPromo.size()>0){
    //     decimal discPercentage = listPromo[0].Discount__c/100;
    //     List<CartItem> listCartItems = [SELECT id,ListPrice,SalesPrice,TotalAmount,TotalListPrice,TotalPrice,UnitAdjustedPrice,Cart.name,TotalLineAmount FROM CartItem WHERE CartId=:listCartIds];
    //     for(CartItem ci:listCartItems){
    //       decimal attributeDisc = ci.TotalLineAmount - (ci.TotalLineAmount * discPercentage);
    //       ci.ListPrice = 0;
    //       //ci.SalesPrice = 0;
    //       //ci.TotalAmount = 0;
    //       ci.TotalListPrice = 0;
    //       ci.TotalPrice = attributeDisc;
    //       ci.UnitAdjustedPrice = 0;
    //       listCIToUpdate.add(ci);
    //     }
    //     //update listCIToUpdate;


    //      //call method getCartItems
    //      ConnectApi.CartItemCollection cartItemCollection = getCartItems(communityId, effectiveAccountId, activeCartOrId, pageParam, sortParam);
    //      System.debug('cartItemCollection : ' + cartItemCollection.cartSummary);


    //     return cartItemCollection.cartSummary;
    //   }else{
    //     AuraHandledException auraEx = new AuraHandledException(errorMessage);
    //     auraEx.setMessage(errorMessage);
    //     throw auraEx;
    //   }
    // }

}