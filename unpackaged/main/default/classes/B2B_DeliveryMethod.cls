/**
 * @description       : 
 * @author            : keshav Matabadul
 * @group             : 
 * @last modified on  : 11-30-2021
 * @last modified by  : keshav Matabadul
**/
public class B2B_DeliveryMethod {
    @InvocableMethod(label='webCartIds' description='Get active cart id')
    public static void updateDeliveryMethod(List<Id> listWebcartIds){
        // Extract cart id and start processing
        Id cartId = listWebcartIds[0];
        
        startOrderDeliveryMethod(cartId);
    }
    
    private static void startOrderDeliveryMethod(Id cartId){
        String defaultDeliveryMethodName = 'Order Delivery Method';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();
        
        // We need to get the ID of the cart delivery group in order to create the order delivery groups.
        Id cartDeliveryGroupId = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :cartId][0].Id;
        
        // On re-entry of the checkout flow delete all previous CartDeliveryGroupMethods for the given cartDeliveryGroupId
        //delete [SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId];
        
        
        OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
            Name = defaultDeliveryMethodName,
            Carrier = defaultDeliveryMethodName,
            isActive = true,
            ProductId = product2IdForThisDeliveryMethod,
            ClassOfService = defaultDeliveryMethodName
        );
        
        insert defaultOrderDeliveryMethod;
        
        
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id FROM CartDeliveryGroup WHERE Id IN (
            SELECT CartDeliveryGroupId
            FROM CartItem
            WHERE CartId =:cartId)];
        
        cartDeliveryGroup.DeliveryMethodId = defaultOrderDeliveryMethod.Id;
        
        update cartDeliveryGroup;
    }
    
    
    private static Id getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
}