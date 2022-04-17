@isTest (seeAllData=false)
private class Product2Tests {

    /**
     * @name product2Extension_UnitTest
     * @description UnitTest for product2Extension
    **/
    static TestMethod void Product2Extension_UnitTest(){
        Test.startTest();

            // Pagereference pageRef = Page.Product2New;

            Product2 prodc = new Product2();
            prodc.Name = 'For test';
            prodc.IsActive = true;
            ApexPages.StandardController controller = new Apexpages.StandardController(prodc);
            Product2Extension ext = new Product2Extension(controller);
            System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());

            ext.addRows();
            System.assertEquals(Constants.DEFAULT_ROWS * 2, ext.productsToInsert.size());

            for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
                Product2 prod = new Product2();
                prod.Name                   = 'StandWithUkraine ' + i;
                prod.IsActive               = true;
                prod.Family                 = Constants.PRODUCT_FAMILY[Math.mod(i, 4)].getValue();
                prod.Initial_Inventory__c   = 10;

                ext.productsToInsert.get(i).productRecord = prod;

                PricebookEntry pbe = new PricebookEntry();
                pbe.UnitPrice               = i + 10;
                pbe.IsActive                = true;

                ext.productsToInsert.get(i).pricebookEntryRecord = pbe;
            }
            ext.save();
            ext.GetFamilyOptions();
            ext.GetInventory();

            List<Product2> newProdsList = [SELECT Id FROM Product2];
            System.assertEquals(Constants.DEFAULT_ROWS, newProdsList.size());

        Test.stopTest();
    }

    @isTest
    static void Product2Trigger_UnitTest() {

        Test.startTest();
        Product2 prod = new Product2();
        prod.Name = 'TestProduct';
        prod.Family = 'Side';
        prod.IsActive = true;
        prod.Quantity_Ordered__c = 2;
        prod.Initial_Inventory__c = 33;
        insert prod;

        CollaborationGroup c = new CollaborationGroup();
        c.Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS;
        c.Description = 'test';
        c.CollaborationType = 'Public';
        insert c;

        prod.Quantity_Ordered__c=3;
        update prod;
        Test.stopTest();
    }

}

