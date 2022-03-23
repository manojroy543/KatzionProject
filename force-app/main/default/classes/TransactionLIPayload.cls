/**
 * @description       : 
 * @author            : manoj543@gmail.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : manoj.roy@veolia.com
**/
public with sharing class TransactionLIPayload {

    private ClsKeys keys;
    private ClsValues values;

    public class ClsKeys {
        private String TransactionItemID;

        public ClsKeys(String TransactionItemID){
            this.TransactionItemID = TransactionItemID;
        }
    }
    public class ClsValues {
        private Decimal ItemCost;
        private String ItemName;

        public ClsValues(Decimal ItemCost, String ItemName){
            this.ItemCost = ItemCost;
            this.ItemName = ItemName;
        }
    }  

    public TransactionLIPayload(TransactionLIPayload.ClsKeys keys, TransactionLIPayload.ClsValues values){
        this.keys = keys;
        this.values = values;
    }

    
}
