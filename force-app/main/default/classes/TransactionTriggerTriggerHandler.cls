/**
 * @description       : 
 * @author            : manoj543@gmail.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : manoj.roy@veolia.com
**/
public with sharing class TransactionTriggerTriggerHandler {

    public static void OnBeforeInsert(List<Transaction__c> newTransactionList){
        // before insert processing goes here
    }

    public static void OnAfterInsert(List<Transaction__c> newTransactionList, Map<id,Transaction__c> newTransactionMap){

        processTransaction(newTransactionList);
    }

    public static void OnBeforeUpdate(List<Transaction__c> newTransactionList, List<Transaction__c> oldTransactionList, Map<id,Transaction__c> newTransactionMap, Map<id,Transaction__c> oldTransactionMap){
        // before update processing goes here
    }

    public static void OnAfterUpdate(List<Transaction__c> newTransactionList, List<Transaction__c> oldTransactionList, Map<id,Transaction__c> newTransactionMap, Map<id,Transaction__c> oldTransactionMap){
        
        processTransaction(newTransactionList);
    }

    public static void OnBeforeDelete(List<Transaction__c> oldTransactionList, Map<id,Transaction__c> oldTransactionMap){
        // before delete processing goes here
    }

    public static void OnAfterDelete(List<Transaction__c> oldTransactionList, Map<id,Transaction__c> oldTransactionMap){
        // after delete processing goes here
    }

    private static void processTransaction(List<Transaction__c> newTransactionList){

        // Since we cannot do callout in trigger and don not want to hit the Future governer limits we would use platform events to do the callout
        List<ID> txnIDList = new List<ID>();

        // List to hold final transactions to be sent via http call
        //List<Id> txnIDList = new List<Id>();

        for(Transaction__c txn : newTransactionList){

            //if all the transaction line items are present
            if(txn.Transaction_Line_Item_Counts__c == txn.Related_Transaction_Count__c){

                //Transaction is not already sent or a resend request has been made
                if(txn.Send_Status__c != 'SUCCESS' || txn.Resend__c == true){
                    txnIDList.add(txn.id);
                }
            }
        }

        
        // now we have list of all transactions which needs to be posted to HTTP callout, lets 
        // get the transaction and line items data
        List<Transaction__c> txnList = 
        [SELECT 
            ID, 
            Error_Details__c, 
            Related_Transaction_Count__c, 
            Resend__c, 
            Send_Date__c, 
            Send_Status__c, 
            Total_Cost__c, 
            Total_Discount__c, 
            Transaction_Date__c, 
            Transaction_Line_Item_Counts__c,
            (SELECT ID, Name, Item_Cost__c  FROM Transaction_Line_Items__r)
            FROM Transaction__c
            WHERE ID IN :txnIDList
            WITH SECURITY_ENFORCED]; 

        // Now lets process each transactions   
        for(Transaction__c eachTxn : txnList){

            // Create transaction Payload
            TransactionPayload txnPayload = new TransactionPayload(new TransactionPayload.ClsKeys(eachTxn.id), new TransactionPayload.ClsValues(eachTxn.Total_Cost__c, eachTxn.Total_Discount__c, eachTxn.Transaction_Date__c));
            string serializedTxnPayload = JSON.serialize(txnPayload);


            // Create transaction Line Items Payload
            List<TransactionLIPayload> txnLIPayload = new List<TransactionLIPayload>();

            if(eachTxn.Transaction_Line_Items__r.size() > 0){
                for(Transaction_Line_Item__c eachTxnLI : eachTxn.Transaction_Line_Items__r){
                    txnLIPayload.add(new TransactionLIPayload(new TransactionLIPayload.ClsKeys(eachTxnLI.id), new TransactionLIPayload.ClsValues(eachTxnLI.Item_Cost__c, eachTxnLI.name)));
                }    
            }
            string serializedTxnLIPayload = JSON.serialize(txnLIPayload);

            // now we have the payload created, post it via http
            sendRequest(serializedTxnLIPayload, SerializedTxnPayload);
        }
    }

    /**
    * @description 
    * @author manoj543@gmail.com | 03-23-2022 
    * @param txnLIPayload 
    * @param txnPayload 
    **/
    @future (callout=true)
    private static void sendRequest(string txnLIPayload, string txnPayload){

        // System.debug('txnLIPayload ==> ' + txnLIPayload); 
        // System.debug('txnPayload ==> ' + txnPayload);

        Http http = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://katzion-test.p.rapidapi.com/add');
        request.setMethod('POST');
        request.setHeader('Content-Type'    , 'application/json;charset=UTF-8');
        request.setHeader('X-RapidAPI-Host' , 'katzion-test.p.rapidapi.com');
        request.setHeader('X-RapidAPI-Key'  , 'e57ee93554msh915291fef6b1b2fp1b695fjsn2bbfe2504574');
        
        // Set the body as a JSON object
        request.setBody(txnLIPayload);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 201){

            System.debug('Response Body  ==> ' + response.getBody()); 

            request.setBody(txnPayload);
            HttpResponse response1 = http.send(request);
            if(response1.getStatusCode() == 201){
                System.debug('Response1 Body 1 ==> ' + response1.getBody()); 
            }else{
                System.debug('CALLOUT ERROR' + response1.getStatusCode() + ' ' + response1.getStatus());
            }
        }else{
            System.debug('CALLOUT ERROR' + response.getStatusCode() + ' ' + response.getStatus());
        }
        
    }
}
