public class OrderHelper {

    /**
     * @name AfterUpdate
     * @description 
     * @param List<Order> newList
     * @param List<Order> oldList
     * @return void
    **/
    public static void AfterUpdate(List<Order> newList, List<Order> oldList){
        Set<Id> orderIds = new Set<Id>();
        for ( Integer i=0; i<newList.size(); i++ ){
            if ( newList[i].Status == Constants.ACTIVATED_ORDER_STATUS
                && oldList[i].Status == Constants.DRAFT_ORDER_STATUS
                && newList[i].ActivatedDate != null) {
                orderIds.add(newList[i].Id);
            }
        }

        RollUpOrderItems(orderIds);
    }

    /**
     * @name RollUpOrderItems
     * @description Given a set of Activated Order ids, query the child Order Items and related Products to calculate Inventory levels
     * @param Set<Id> activatedOrderIds
     * @return void
    **/
    public static void RollUpOrderItems(Set<Id> activatedOrderIds){
        //ToDo: Declare a Map named "productMap" of Ids to Product2 records
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        Set<Id> product2Ids = new Set<Id>();

        //ToDo: Loop through a query of OrderItems related to the activatedOrderIds
        for (OrderItem var : [SELECT Id, Product2Id FROM OrderItem WHERE OrderId IN :activatedOrderIds]) {
            product2Ids.add(var.Product2Id);
        }  

        //ToDo: Populate the map with the Id of the related Product2 as the key and Product2 record as the value
        productMap = new Map<Id, Product2>([SELECT id, Quantity_Ordered__c FROM Product2 WHERE id in :product2Ids]);

        //ToDo: Loop through a query that aggregates the OrderItems related to the Products in the ProductMap keyset
        
        for (AggregateResult var : [SELECT Product2Id, sum(Quantity) Quantity FROM OrderItem WHERE Product2Id IN :productMap.keyset() GROUP BY Product2Id]) {
            productMap.get((String)var.get('Product2Id')).Quantity_Ordered__c = Integer.valueOf(var.get('Quantity'));
        }

        //ToDo: Perform an update on the records in the productMap
        if (productMap.size() > 0) {
            update productMap.values();
        }
    }

}