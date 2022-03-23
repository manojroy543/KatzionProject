/**
 * @description       : 
 * @author            : manoj543@gmail.com
 * @group             : 
 * @last modified on  : 03-23-2022
 * @last modified by  : manoj.roy@veolia.com
**/
trigger TransactionTrigger on Transaction__c (before delete, before insert, before update, after delete, after insert, after update) {

    if( Trigger.isInsert && Trigger.isBefore){
        TransactionTriggerTriggerHandler.OnBeforeInsert(trigger.New);
    }

    if( Trigger.isInsert && Trigger.isAfter){
        TransactionTriggerTriggerHandler.OnAfterInsert(trigger.New, trigger.NewMap);
    }

    if( Trigger.isUpdate && Trigger.isBefore){
        TransactionTriggerTriggerHandler.OnBeforeUpdate(trigger.New, trigger.Old, trigger.NewMap, trigger.OldMap);
    }

    if( Trigger.isUpdate && Trigger.isAfter){
        TransactionTriggerTriggerHandler.OnAfterUpdate(trigger.New, trigger.Old, trigger.NewMap, trigger.OldMap);
    }

    if( Trigger.isDelete && Trigger.isBefore){
        TransactionTriggerTriggerHandler.OnBeforeDelete(trigger.Old, trigger.OldMap);
    }

    if( Trigger.isDelete && Trigger.isAfter){
        TransactionTriggerTriggerHandler.OnAfterDelete(trigger.Old, trigger.OldMap);
    }

}