@isTest (seeAllData=false)
private class OrderTests {

    @testSetup static void SetupTestData() {
        TestDataFactory.InsertTestData(125);
    }

    @isTest
    static void OrderUpdate_UnitTest() {

        Test.startTest();
        Product2 prodsListBefore = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1][0];

        Order ord = [SELECT Status FROM Order LIMIT 1];
        ord.Status = Constants.ACTIVATED_ORDER_STATUS;
        update ord;

        Product2 prodsListAfter = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1];

        TestDataFactory.VerifyQuantityOrdered(prodsListBefore, prodsListAfter, Constants.DEFAULT_ROWS);
        Test.stopTest();
    }

    @isTest
    static void OrderExtension_UnitTest() {
        Pagereference pageRef = Page.OrderEdit;

        Test.setCurrentPage(pageRef);
        Order o = [SELECT Id FROM Order LIMIT 1];
        ApexPages.StandardController controller = new Apexpages.StandardController(o);

        OrderExtension ext = new OrderExtension(controller);

        ext.First();
        ext.Next();
        ext.Previous();
        ext.Last();
        ext.GetHasNext();
        ext.GetHasPrevious();
        ext.GetPageNumber();
        ext.GetTotalPages();
        ext.SelectFamily();
        ext.Save();
        ext.selectedFamily = 'Dessert';
        ext.initStandardSetController();
        ext.OnFieldChange();
    }
}