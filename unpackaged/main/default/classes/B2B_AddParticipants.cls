public class B2B_AddParticipants {

    // A cache which maps community Ids to WebStore Ids
  private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();

  @AuraEnabled
  public static List<Participant__c> getParticipantRow(String recordId) {
    Set<Id> setParticipantIds = new Set<Id>();
    for(CartItem ci:[SELECT Id,CartId FROM CartItem WHERE CartId =:recordId]){
      setParticipantIds.add(ci.Id);
    }
    WebCart wc = [SELECT Id,Name,status FROM WebCart WHERE Id =:recordId ];
    wc.status = 'Active';
    update wc;

    return new List<Participant__c> ([SELECT Id,CartItemId__c,Civilite__c,EmailAddress__c,Name,Prenom__c  FROM Participant__c WHERE CartItemId__c IN:setParticipantIds]);
    
  }

  @AuraEnabled
  public static WebCart resetCartStatus(String recordId) {
    WebCart wc = [SELECT Id,Name,status FROM WebCart WHERE Id =:recordId ];
    wc.status = 'Active';
    update wc;
    return wc;
  }

  @AuraEnabled
  public static Boolean deleteAllParticipant(List<Id> listCartIds) {
     List<Participant__c> listpar = [SELECT Id,CartItemId__c,Civilite__c,EmailAddress__c,Name,Prenom__c  FROM Participant__c WHERE CartItemId__c IN:listCartIds];

     if(listpar.size()>0){
      delete listpar;
      return true;
     }
     return null;
  }



  @AuraEnabled
  public static List<CartItem> deleteParticipantByIds(
      List<string> listParticipantIds , 
      String communityId,
      String effectiveAccountId,
      String activeCartOrId
    ){
    
    List<Participant__c> participantIdToDelete = new List<Participant__c>();
    set<string> cartItemsIds = new set<String>();
    Map<string, integer> mapCartItems= new Map<String, integer>();
    for(string par:listParticipantIds){

      String cartId = par.substringBefore('-');
      String participantId = par.substringAfter('-');

      if(participantId != ''){
        participantIdToDelete.add(new Participant__c(Id = participantId));
      }

      cartItemsIds.add(cartId);
    }

    for(string cartId:cartItemsIds){
      integer count = 0;
      for(String part:listParticipantIds){
        String cartIdSubString = part.substringBefore('-');
        if(cartId == cartIdSubString){
          count++;
        }
      }
      mapCartItems.put(cartId,count);
    }

    List<CartItem> listCart = [SELECT Id,Quantity,TotalLineAmount,TotalListPrice,TotalPrice,ListPrice,SalesPrice FROM CartItem WHERE Id IN:cartItemsIds];
    for(CartItem ci:listCart){
      if(ci.Quantity != null && mapCartItems.containsKey(ci.Id)){
        if(ci.Quantity>1 && (ci.Quantity - mapCartItems.get(ci.Id)) == 0){
          ci.Quantity = 1;
        }else{
          ci.Quantity = (ci.Quantity>1)?ci.Quantity - mapCartItems.get(ci.Id):1;
        }
        
      }

      ci.TotalLineAmount = ci.Quantity * ci.SalesPrice;
      ci.TotalListPrice = ci.Quantity * ci.SalesPrice;
      ci.TotalPrice = ci.Quantity * ci.SalesPrice;
    }
    

    /*for(CartItem ci:listCart){
      Integer myintval = Integer.valueOf(ci.Quantity);
      sObject obj = Schema.getGlobalDescribe().get('obj').newSObject();
      obj.put('quantity', myintval);
      B2BCartControllerSample.updateCartItem(communityId,effectiveAccountId,activeCartOrId,String.valueOf(ci.Id),obj);
    }*/
        
    update listCart;

    if(participantIdToDelete.size()>0){
      delete participantIdToDelete;
    }

    return listCart;
  }
}