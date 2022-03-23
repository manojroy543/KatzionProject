/**
 * @description       : 
 * @author            : manoj543@gmail.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : manoj.roy@veolia.com
**/
public with sharing class TransactionPayload {

    private ClsKeys keys;
    private ClsValues values;

    public class ClsKeys {
        private String TransactionID;

        public ClsKeys(String TransactionID){
            this.TransactionID = TransactionID;
        }
    }
    public class ClsValues {
        private Decimal TotalCost;
        private Decimal TotalDiscount;
        private Date TransactionDate;

        public ClsValues(Decimal TotalCost, Decimal TotalDiscount, Date TransactionDate){
            this.TotalCost = TotalCost;
            this.TotalDiscount = TotalDiscount;
            this.TransactionDate = TransactionDate;
        }
    }  

    public TransactionPayload(TransactionPayload.ClsKeys keys, TransactionPayload.ClsValues values){
        this.keys = keys;
        this.values = values;
    }
}
