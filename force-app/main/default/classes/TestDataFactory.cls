/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
**/
public with sharing class TestDataFactory {

    /**
     * @name ConstructCollaborationGroup
     * @description
    **/
    public static CollaborationGroup ConstructCollaborationGroup(){
        //ToDo: Ensure this method returns a single Chatter CollaborationGroup
        //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
        //    and configured so anyone can join, see and post updates.
        CollaborationGroup collGr = new CollaborationGroup();

        collGr.Name = 'Test' + Constants.INVENTORY_ANNOUNCEMENTS;
        collGr.CollaborationType = 'Public';

        return collGr;
    }

    /**
     * @name CreateProducts
     * @description Constructs a list of Product2 records for unit tests
    **/
    public static List<Product2> ConstructProducts(Integer cnt){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Product2 records
        //  with all the required fields populated
        //  and IsActive = true
        //  an Initial Inventory set to 10
        //  and iterating through the product family picklist values throughout the list.
        List<Product2> prods = new List<Product2>();

        for (Integer i = 0; i < cnt; i++) {
            Product2 pr = new Product2();

            pr.Name                 = 'Unigue ' + i;
            pr.IsActive             = true;
            pr.Initial_Inventory__c = 10;
            pr.Family               = Constants.PRODUCT_FAMILY[Math.mod(i, 4)].getValue();

            prods.add(pr);
        }
        return prods;
    }

    /**
     * @name CreatePricebookEntries
     * @description Constructs a list of PricebookEntry records for unit tests
    **/
    public static List<PricebookEntry> ConstructPricebookEntries(List<Product2> prods){
        //ToDo: Ensure this method returns a corresponding list of PricebookEntries records
        //  related to the provided Products
        //  with all the required fields populated
        //  and IsActive = true
        //  and belonging to the standard Pricebook
        List<PricebookEntry> pbeList = new List<PricebookEntry>();

        for (Product2 pr : prods) {
            PricebookEntry pbe = new PricebookEntry();

            pbe.Product2Id      = pr.Id;
            pbe.IsActive        = true;
            pbe.Pricebook2Id    = Constants.STANDARD_PRICEBOOK_ID;
            pbe.UnitPrice       = 13;

            pbeList.add(pbe);
        }
        return pbeList;
    }

    /**
     * @name CreateAccounts
     * @description Constructs a list of Account records for unit tests
    **/
    public static List<Account> ConstructAccounts(Integer cnt){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Account records
        //  with all of the required fields populated.
        List<Account> accList = new List<Account>();

        for (Integer i = 0; i < cnt; i++) {
            Account acc = new Account();

            acc.Name = 'NameOfAccount ' + i;
            accList.add(acc);
        }
        return accList;
    }

    /**
     * @name CreateContacts
     * @description Constructs a list of Contacxt records for unit tests
    **/
    public static List<Contact> ConstructContacts(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list, of size cnt, of uniquely named Contact records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Contact> contactList = new List<Contact>();

        Integer size = accts.size();
        for (Integer i = 0; i < cnt; i++  ) {
            Contact contact     = new Contact();
            contact.LastName    = 'Unique for Test ' + i;
            contact.AccountId   = accts[Math.mod(i, size)].Id;
            contactList.add(contact);
        }
        return contactList;
    }

    /**
     * @name CreateOrders
     * @description Constructs a list of Order records for unit tests
    **/
    public static List<Order> ConstructOrders(Integer cnt, List<Account> accts){
        //ToDo: Ensure this method returns a list of size cnt of uniquely named Order records
        //  related to the provided Accounts
        //  with all of the required fields populated.
        List<Order> orderList = new List<Order>();

        Integer size = accts.size();
        for (Integer i = 0; i < cnt; i++) {
            Order ord = new Order();

            ord.EffectiveDate   = Date.today() + i;
            ord.AccountId       = accts[Math.mod(i, size)].Id;
            ord.Pricebook2Id    = Constants.STANDARD_PRICEBOOK_ID;
            ord.Status          = 'Draft';

            orderList.add(ord);
        }
        return orderList;
    }

    /**
     * @name CreateOrderItems
     * @description Constructs a list of OrderItem records for unit tests
    **/
    public static List<OrderItem> ConstructOrderItems(integer cnt, list<pricebookentry> pbes, list<order> ords){
        //ToDo: Ensure this method returns a list of size cnt of OrderItem records
        //  related to the provided Pricebook Entries
        //  and related to the provided Orders
        //  with all of the required fields populated.
        //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
        List<OrderItem> orderItemsList = new List<OrderItem>();

        Integer sizeOrds = ords.size();
        Integer sizePbes = pbes.size();
        for (Integer i = 0; i < cnt; i++) {
            OrderItem ordItem = new OrderItem();

            ordItem.Quantity            = Constants.DEFAULT_ROWS;
            ordItem.UnitPrice           = cnt + 1;
            ordItem.PricebookEntryId    = pbes[Math.mod(i, sizePbes)].Id;
            ordItem.OrderId             = ords[Math.mod(i, sizeOrds)].Id;

            orderItemsList.add(ordItem);
        }
        return orderItemsList;
    }

    /**
     * @name SetupTestData
     * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
    **/
    public static void InsertTestData(Integer cnt){
        //ToDo: Ensure this method calls each of the construct methods
        //  and inserts the results for use as test data.
        insert ConstructCollaborationGroup();

        List<Product2> prods = ConstructProducts(cnt);
        insert prods;

        List<PricebookEntry> pbes = ConstructPricebookEntries(prods);
        insert pbes;

        List<Account> accts = ConstructAccounts(cnt);
        insert accts;

        List<Contact> cnts = ConstructContacts(cnt, accts);
        insert cnts;

        List<Order> ords = ConstructOrders(cnt, accts);
        insert ords;

        List<OrderItem> ordItem =  ConstructOrderItems(cnt, pbes, ords);
        insert ordItem;
    }

    public static void VerifyQuantityOrdered(Product2 originalProduct, Product2 updatedProduct, Integer qtyOrdered) {
        System.assertEquals(originalProduct.Quantity_Ordered__c.intValue() + qtyOrdered, updatedProduct.Quantity_Ordered__c.intValue());
    }
}