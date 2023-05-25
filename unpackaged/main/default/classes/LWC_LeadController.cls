public with sharing class LWC_LeadController {
    
    @AuraEnabled
    public static List<Lead> getLeadByEmail(String email) {
        return [SELECT Id, email, Status FROM Lead WHERE email =: email AND IsConverted = false];
    }
}