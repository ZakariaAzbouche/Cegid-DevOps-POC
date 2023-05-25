trigger OppTagAddcontentDocument on ContentDocumentLink (after insert) {
Id pId; 
Datetime myDT = Datetime.now();
 
Id profileId=userinfo.getProfileId();
String profileName=[Select Name from Profile where Id=:profileId].Name;       
if(profileName.equals('IM Partner'))
{  
for(contentDocumentLink att: Trigger.new){
    system.debug('**********For *******');
    if(String.valueOf(att.LinkedEntityId).substring(0, 3).equals('006')) 
    {pId=att.LinkedEntityId;
    //idContentDocumentLink =att.id;
    }    
}
system.debug('pid'+pId);
if(pId !=null)
{
List<Opportunity> opp=[select id, TECH_Last_PRM_File_Or_Note_Creation_Date__c from Opportunity where Id=:pId];
opp[0].TECH_Last_PRM_File_Or_Note_Creation_Date__c = myDT;
    update opp;
}
} 

}