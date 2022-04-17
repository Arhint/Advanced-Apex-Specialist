/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
**/
public class OrderExtension {

    public Order orderRecord {get;set;}
    public List<OrderItem> orderItemList {get;set;}
    public String selectedFamily {get;set;}
    public List<chartHelper.chartData> pieData {get;set;}
    public Decimal total {get;set;}

    public Map<Id,OrderItem> orderItemMap;
    ApexPages.StandardSetController standardSetController;

    public OrderExtension(ApexPages.StandardController standardController){
        orderRecord = (Order)standardController.getRecord();
        orderItemMap = new Map<id,OrderItem>();
        if ( orderRecord.Id != null ){
            orderRecord = queryOrderRecord(orderRecord.Id);
        }
        initStandardSetController();
        total = 0;
        for (OrderItem var : orderRecord.OrderItems) {
            orderItemMap.put(var.Product2Id, var);
            if (var.Quantity > 0) {
                total += var.UnitPrice * var.Quantity;
                if (pieData == null) {
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new ChartHelper.ChartData(var.Product2.Name, var.Quantity * var.UnitPrice));
            }
        }
        populateOrderItemList();
    }

    public void initStandardSetController() {
        String query = 'SELECT Product2.Quantity_Ordered__c, Product2.Quantity_Remaining__c, UnitPrice, Product2.Family, Name, Product2.Name, Pricebook2Id FROM PricebookEntry WHERE IsActive = true';

        if (String.isNotBlank(selectedFamily) && selectedFamily != Constants.SELECT_ONE) {
            query += ' AND Product2.Family = \'' + selectedFamily + '\'';
        }
        standardSetController = new ApexPages.StandardSetController(Database.getQueryLocator(query));
        standardSetController.setPageSize(Constants.DEFAULT_ROWS);
    }
    
    //ToDo: Implement your own method to populate orderItemList
    //  that you will call after pagination and/or family selection
    public void populateOrderItemList() {
        orderItemList = new List<OrderItem>();
        for (SObject obj : standardSetController.getRecords()) {
        
            PricebookEntry pbe = (PricebookEntry)obj;
            if(orderItemMap.containsKey(pbe.Product2Id)) {
                orderItemList.add(orderItemMap.get(pbe.Product2Id));
            } else {
                OrderItem oi = new OrderItem();
                oi.Quantity = 0;
                oi.PricebookEntryId = pbe.Id;
                oi.Product2Id = pbe.Product2Id;
                oi.UnitPrice = pbe.UnitPrice;
                oi.Product2 = pbe.Product2;

                orderItemList.add(oi);
                orderItemMap.put(pbe.Product2Id, oi);
            }
        }
    }

    /**
     * @name OnFieldChange
     * @description
    **/
    public void OnFieldChange(){
        //ToDo: Implement logic to store the values changed on the page
        //      and populate pieData
        //      and populate total
        for (OrderItem var : orderItemList) {
            orderItemMap.put(var.Product2Id, var);
        }
        pieData = null;
        total = 0;

        for (OrderItem var : orderItemMap.values()) {
            orderItemMap.put(var.Product2Id, var);
            if (var.Quantity > 0) {
                total += var.UnitPrice * var.Quantity;
                if (pieData == null) {
                    pieData = new List<ChartHelper.ChartData>();
                }
                pieData.add(new ChartHelper.ChartData(var.Product2.Name, var.Quantity * var.UnitPrice));
            }
        }
    }

    /**
     * @name SelectFamily
     * @description
    **/
    public void SelectFamily(){
        //ToDo: Implement logic to filter based on the selected product family
        initStandardSetController();
        populateOrderItemList();

    }

    /**
     * @name Save
     * @description
    **/
    public void Save(){
        //ToDo: Implement logic to save the Order and populated OrderItems
        System.Savepoint sp = Database.setSavepoint();

        try {
            if(orderRecord.Pricebook2Id == null) {
                orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            upsert orderRecord;
        
            List<OrderItem> orderItemsToUpsert = new List<OrderItem>();
            List<OrderItem> orderItemsToDelete = new List<OrderItem>();
        
            for (OrderItem var : orderItemMap.values()) {
                if (var.Quantity > 0) {
                    if (var.OrderId == null) {
                        var.OrderId = orderRecord.Id;
                    }
                    orderItemsToUpsert.add(var);
                } else if (var.Id != null) {
                    orderItemsToDelete.add(new OrderItem(id=var.Id));
                    var.Id = null;
                }
            }
        
            upsert orderItemsToUpsert;
            delete orderItemsToDelete;

        } catch (Exception e) {
            Database.rollback(sp);
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,Constants.ERROR_MESSAGE));
        }
    }


    /**
     * @name First
     * @description
    **/
    public void First(){
        standardSetController.first();
        populateOrderItemList();
    }


    /**
     * @name Next
     * @description
    **/
    public void Next(){
        standardSetController.next();
        populateOrderItemList();
    }


    /**
     * @name Previous
     * @description
    **/
    public void Previous(){
        standardSetController.previous();
        populateOrderItemList();
    }

    /**
     * @name Last
     * @description
    **/
    public void Last(){
        standardSetController.last();
        populateOrderItemList();
    }

    /**
     * @name GetHasPrevious
     * @description
    **/
    public Boolean GetHasPrevious(){
        return standardSetController.getHasPrevious();
        // return null;
    }

    /**
     * @name GetHasNext
     * @description
    **/
    public Boolean GetHasNext(){
        return standardSetController.getHasNext();
        // return null;
    }

    /**
     * @name GetTotalPages
     * @description
    **/
    public Integer GetTotalPages(){
        return (Integer)Math.ceil(standardSetController.getResultSize() / (Decimal)Constants.DEFAULT_ROWS);
        // return null;
    }

    /**
     * @name GetPageNumber
     * @description
    **/
    public Integer GetPageNumber(){
        return standardSetController.getPageNumber();
        // return null;
    }

    /**
     * @name GetFamilyOptions
     * @description
    **/
    public List<SelectOption> GetFamilyOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for (Schema.PicklistEntry var : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(var.getValue(), var.getLabel()));
        }

        return options;
    }

    /**
     * @name QueryOrderRecord
     * @description
    **/
    public static Order QueryOrderRecord(Id orderId){
        return [
            SELECT Id, AccountId, EffectiveDate, Name, Status, Pricebook2Id,
                (
                    SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Product2Id,
                         Product2.Name, Product2.Family, Product2.Quantity_Remaining__c
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :orderId
        ];
    }

}