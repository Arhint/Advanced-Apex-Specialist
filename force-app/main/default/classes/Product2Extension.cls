public class Product2Extension {

    public List<ProductWrapper> productsToInsert {get;set;}

    public Product2Extension(ApexPages.StandardController controller){
        productsToInsert = new List<ProductWrapper>();
        addRows();
    }

    public void AddRows(){
        for ( Integer i = 0; i < Constants.DEFAULT_ROWS; i++ ){
            productsToInsert.add( new ProductWrapper() );
        }
    }

    public List<ChartHelper.ChartData> GetInventory(){
        return ChartHelper.GetInventory();
    }

    public PageReference Save(){

        Savepoint sp = Database.setSavepoint();

        try {

            List<Product2> prods = new List<Product2>();
            List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();

            for (ProductWrapper var : productsToInsert) {
                if (String.isNotBlank(var.productRecord.Name) &&
                var.productRecord.Family != Constants.SELECT_ONE &&
                var.productRecord.IsActive &&
                var.productRecord.Initial_Inventory__c != 0 &&
                var.pricebookEntryRecord.UnitPrice != null) {
                    
                    prods.add(var.productRecord);
                    priceBookEntries.add(var.pricebookEntryRecord);
                }
            }
            insert prods;

            for (Integer i = 0; i < priceBookEntries.size(); i++) {
                priceBookEntries[i].Product2Id = prods[i].Id;
                priceBookEntries[i].IsActive = true;
                priceBookEntries[i].Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
            }
            insert priceBookEntries;

            //If successful clear the list and display an informational message
            apexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,productsToInsert.size()+' Inserted'));
            productsToInsert.clear();   //Do not remove
            addRows();  //Do not remove
        } catch (Exception e){
            Database.rollback( sp );
            Apexpages.addMessage(new Apexpages.Message(Apexpages.Severity.ERROR, Constants.ERROR_MESSAGE));
        }
        return null;
    }

    public List<SelectOption> GetFamilyOptions() {

        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));

        for (Schema.PicklistEntry var : Constants.PRODUCT_FAMILY) {
            options.add(new SelectOption(var.getValue(), var.getLabel()));
        }

        return options;
    }

    public class ProductWrapper {
        
        public Product2 productRecord {get; set;}
        public PricebookEntry pricebookEntryRecord {get; set;}

        public ProductWrapper() {
            productRecord = new Product2(Initial_Inventory__c = 0);
            pricebookEntryRecord = new PricebookEntry();
        }
    }
}