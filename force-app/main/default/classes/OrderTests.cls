@isTest (seeAllData=false)
private class OrderTests {

    @testSetup static void SetupTestData() {
        TestDataFactory.InsertTestData(125);
    }

    static void OrderUpdate_UnitTest() {

        Product2 prodsListBefore = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1][0];

        Order ord = [SELECT Status FROM Order LIMIT 1];
        ord.Status = Constants.ACTIVATED_ORDER_STATUS;
        update ord;

        Product2 prodsListAfter = [SELECT Id, Quantity_Ordered__c FROM Product2 LIMIT 1];

        TestDataFactory.VerifyQuantityOrdered(prodsListBefore, prodsListAfter, Constants.DEFAULT_ROWS);
    }
}