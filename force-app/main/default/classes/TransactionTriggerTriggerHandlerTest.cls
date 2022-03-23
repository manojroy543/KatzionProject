/**
 * @description       : 
 * @author            : manoj543@gmail.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : manoj.roy@veolia.com
**/
@isTest
global class TransactionTriggerTriggerHandlerTest {


    @isTest static void testCallout() {

        Transaction__c txn = new Transaction__c();
        txn.Total_Cost__c = 250.00;
        txn.Total_Discount__c = 10;
        txn.Transaction_Date__c =  Date.today();
        txn.Related_Transaction_Count__c = 3;
        insert txn;

        List<Transaction_Line_Item__c> txnLIList = new List<Transaction_Line_Item__c>();

        for(Integer index =1 ; index <= 3; index++){
            txnLIList.add(new Transaction_Line_Item__c(Transaction__c= txn.id, Item_Cost__c = index*50));
        }

        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        test.startTest();

        insert txnLIList;

        Test.stopTest();
    
    }

    global class MockHttpResponseGenerator implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest req) {  
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success"}');
        res.setStatusCode(201);
        return res;
    }
    }

    
}
