/**
 * @name orderTrigger
 * @description
**/
trigger orderTrigger on Order (after update) {
    // try {
        OrderHelper.AfterUpdate(Trigger.New, Trigger.Old);
        
    // }catch ( Exception e ){
    
    // }
}