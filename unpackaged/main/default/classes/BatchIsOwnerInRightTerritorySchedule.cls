/**
* @author BCR - Capgemini
* @date Creation 12 Jan-2023
* @description BatchIsOwnerInRightTerritory
*        
*/ 
/**
 * @File Name          : BatchIsOwnerInRightTerritory
 * @Description        : Update 
 * @Author             : SRA   
 * @Group              : Capgemini
 * @Last Modified By   : BCR
 * @Last Modified On   : 17/01/2023
 * @Modification Log   : 
 * Ver       Date            Author              Modification
 * ---    -----------       -------           ------------------------ 
 * 1.0    17/01/2023         BCR              Initial Version
 * ---    -----------       -------           ------------------------ 
           
**/
global class BatchIsOwnerInRightTerritorySchedule implements Schedulable {
    /*global static String scheduleMe() {
        BatchIsOwnerInRightTerritorySchedule batchSchedule = new BatchIsOwnerInRightTerritorySchedule(); 	
            
        return 'OK';
    }*/
    global void execute(SchedulableContext ctx) {
        BatchIsOwnerInRightTerritory IsOwnerInTerritorybatch = new BatchIsOwnerInRightTerritory(); 
        ID batchprocessid = Database.executeBatch(IsOwnerInTerritorybatch, 200);
    }
}