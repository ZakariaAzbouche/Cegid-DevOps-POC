/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-30-2021
 * @last modified by  : keshav Matabadul
**/
public with sharing class B2BGetInfo {
  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductDetail getProduct(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
    return ConnectApi.CommerceCatalog.getProduct(
      webstoreId,
      productId,
      effectiveAccountID,
      null,
      false,
      null,
      false,
      true,
      false
    );
  }

  @AuraEnabled(cacheable=true)
  public static Boolean checkProductIsInStock(String productId) {
    /*
     * The following is an example of calling an external API.
     * The example API provided is extremely simple: It takes in a product id
     * and returns a true or false value for inStock based on whether the 15th char is odd or even.
     *
     * To access this endpoint on your org, go to Remote Site Settings in Setup as an admin user
     * click "New Remote Site" and provide "https://inventorymanagerdemo.herokuapp.com" for the "Remote Site URL" field
     */
    /*Http http = new Http();
    HttpRequest request = new HttpRequest();
    String endpoint =
      'https://inventorymanagerdemo.herokuapp.com/api/inventory/' + productId;
    request.setEndpoint(endpoint);
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    // If the request is successful, parse the JSON response.
    if (response.getStatusCode() == 200) {
      // Deserialize the JSON string into collections of primitive data types.
      Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      return (boolean) results.get('inStock');
    } else {
      return false;
    }*/

    List<Product2> listprod = [SELECT Id,StockKeepingUnit FROM Product2 WHERE Id =:productId LIMIT 1];
    //Integer unitSKU = integer.valueOf(listprod[0].StockKeepingUnit);
    if(listprod[0].StockKeepingUnit != null){
      return true;
    }else{
      return false;
    }
  }

  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
    //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
    String activeCartOrId = 'current';

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    return ConnectApi.CommerceCart.getCartSummary(
      webstoreId,
      effectiveAccountId,
      activeCartOrId
    );
  }

  @AuraEnabled
  public static ConnectApi.CartItem addToCart(
    String communityId,
    String productId,
    String quantity,
    String effectiveAccountId,
    String cartId,
    String sessionCode,
    String sessionDate
  ) {

    System.debug('addToCart :');

    // String defaultDeliveryMethodName = 'Order Delivery Method';
    // Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();


    // // We need to get the ID of the cart delivery group in order to create the order delivery groups.
    // Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId][0].Id;

    // // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
    // delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId];
    

    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    List<CartItem> listCartItem = [SELECT Id,TECH_SessionCode__c,Quantity FROM cartItem WHERE CartId =:cartId 
    AND TECH_SessionCode__c =:sessionCode AND Product2Id =:productId];

    system.debug('listCartItem : ' + listCartItem);
    ConnectApi.CartItemInput cartInputItems = new ConnectApi.CartItemInput();
    cartInputItems.quantity = quantity;

    if(listCartItem.size()>0){
        for(CartItem ci:listCartItem){
          return ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, 'active', ci.Id, cartInputItems);
        }
    }else{

      // OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
      //   Name = defaultDeliveryMethodName,
      //   Carrier = defaultDeliveryMethodName,
      //   isActive = true,
      //   ProductId = product2IdForThisDeliveryMethod,
      //   ClassOfService = defaultDeliveryMethodName
      // );
      
      // insert defaultOrderDeliveryMethod;

      // CartDeliveryGroup defaultCartDeliveryGroup = new CartDeliveryGroup(
      //   CartId = cartId,
      //   DeliveryMethodId = defaultOrderDeliveryMethod.Id,
      //   Name = defaultDeliveryMethodName
      // );

      // insert defaultCartDeliveryGroup;

      Id defaultOrderDeliveryMethodId = [SELECT id, /*deliveryMethodId,*/ createddate, CartId FROM CartDeliveryGroup Where CartId=:cartId].Id;
      system.debug('defaultOrderDeliveryMethodId :'+ defaultOrderDeliveryMethodId);

      //PriceBookEntry pbe =[SELECT Id,Name,Pricebook2.Name,UnitPrice,IsActive  FROM PricebookEntry WHERE Product2Id =:productId AND Pricebook2.Name ='Test Active product' AND IsActive = true];
      Product2  pro2 = [SELECT Id,Name,StockKeepingUnit FROM Product2 WHERE Id =:productId];
      CartItem ci = new CartItem(
        Name = pro2.Name,
        CartId = cartId,
        CartDeliveryGroupId = defaultOrderDeliveryMethodId,
        Product2Id = pro2.Id,
        TECH_SessionCode__c = sessionCode,
        type = 'Product',
        Sku = pro2.StockKeepingUnit
      );

      system.debug('ci : ' + ci);

      insert ci;


        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.quantity = quantity;
        return ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, 'active', ci.Id, cartInput);

      
      //   ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
      //   cartInput.productId = productId;
      //   cartInput.quantity = quantity;
      //   cartInput.type = ConnectApi.CartItemType.PRODUCT;
      //  //return ConnectApi.CommerceCart.updateCartItem(webstoreId, effectiveAccountId, 'active', ci.Id, cartInput);
      //   // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
      //   return ConnectApi.CommerceCart.addItemToCart(
      //     webstoreId,
      //     effectiveAccountId,
      //     'active',
      //     cartInput
      //   );
    }

    return null;
  }

  // private static Id getDefaultShippingChargeProduct2Id() {
  //   // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
  //   // Check to see if a Product2 with that name already exists.
  //   // If it doesn't exist, create one.
  //   String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
  //   List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name];
  //   if (shippingChargeProducts.isEmpty()) {
  //       Product2 shippingChargeProduct = new Product2(
  //           isActive = true,
  //           Name = shippingChargeProduct2Name
  //       );
  //       insert(shippingChargeProduct);
  //       return shippingChargeProduct.Id;
  //   }
  //   else {
  //       return shippingChargeProducts[0].Id;
  //   }
  // }

  @AuraEnabled
  public static ConnectApi.Wishlist createAndAddToList(
    String communityId,
    String productId,
    String wishlistName,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // Store the product in a WishlistItemInput to pass to the Wishlist
    ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
    wishlistItemInput.productId = productId;

    //Create a wishlistInput to be created
    ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
    wishlistInput.name = wishlistName;
    wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
      wishlistItemInput
    };

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
    return ConnectApi.CommerceWishlist.createWishlist(
      webstoreId,
      effectiveAccountId,
      wishlistInput
    );
  }

  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductPrice getProductPrice(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
    return ConnectApi.CommerceStorePricing.getProductPrice(
      webstoreId,
      productId,
      effectiveAccountId
    );
  }

  @AuraEnabled
  public static String saveProductSessionInCartItem(Id cartItemId, String productSessionDetail, String productSessionDate){
    CartItem cartItem = [SELECT Id, TECH_SessionCode__c, TECH_SessionDate__c FROM CartItem WHERE Id = :cartItemId];
    cartItem.TECH_SessionCode__c = productSessionDetail;
    cartItem.TECH_SessionDate__c = productSessionDate;

    try{
      update cartItem;
      return cartItem.Id;
    }catch(Exception e){
      return null;
    }
  }
}