/**
 * @description       : 
 * @author            : MAIT - @moidriss
 * @group             : 
 * @last modified on  : 04-12-2023
 * @last modified by  : MAIT - @moidriss
**/
public with sharing class TH_RecommendationScore extends TriggerHandler {
    public override void afterUpdate() {
        Map<Id, Recommendation_score__c> rcScoresToBeProcess = (Map<Id, Recommendation_score__c>)CheckRecursivCall.checkRunOnce(Trigger.newMap, System.TriggerOperation.AFTER_UPDATE);     
        if(rcScoresToBeProcess.isEmpty()) {
            System.debug('No Recommendation_score__c to be processed');
        } else {
            generateTask(rcScoresToBeProcess.values(), (Map<Id, Recommendation_score__c>) Trigger.oldMap);
        }
    }

    public void generateTask(List<Recommendation_score__c> rcScores, Map<Id, Recommendation_score__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> contactAccount = new Map<Id, Account>();
        List<Task> tsks = new List<Task>();
        Map<Id, Set<Id>> accByTerrs = new Map<Id, Set<Id>>();
        Set<Id> terrIds = new Set<Id>();
        Map<Id, Id> csmUserByTerr = new Map<Id, Id>();
        Map<Id, Id> accMrrToUserCSM = new Map<Id, Id>();

        List<String> buToGroup = new List<String>{
            '350',
            '340',
            '310',
            '360',
            '370'
        };

        for(Recommendation_score__c rcScore : rcScores) {
            if(rcScore.Recommendation_score__c <= 6 && rcScore.Asked_to_be_contacted_back__c && rcScore.Team_in_charge_of_contacting_back__c == 'CSM' && 
              (oldMap.get(rcScore.Id).Recommendation_score__c > 6 || !oldMap.get(rcScore.Id).Asked_to_be_contacted_back__c || oldMap.get(rcScore.Id).Team_in_charge_of_contacting_back__c != 'CSM')) {
                contactIds.add(rcScore.Contact__c);
            }
        }

        for(AccountContactRelation accCont : [SELECT AccountId, Account.OwnerId, ContactId 
                                              FROM AccountContactRelation 
                                              WHERE IsDirect = true AND ContactId IN : contactIds]) {
            contactAccount.put(accCont.ContactId, new Account(Id = accCont.AccountId, ownerId = accCont.Account.ownerId));
            accIds.add(accCont.AccountId);
        }

        List<ObjectTerritory2Association> accTerrs = [SELECT Id, ObjectId, Territory2Id 
                                                      FROM ObjectTerritory2Association 
                                                      WHERE ObjectId IN : accIds 
                                                      ];

        for(ObjectTerritory2Association accTerr : accTerrs) {
            terrIds.add(accTerr.Territory2Id);
            if(!accByTerrs.containsKey(accTerr.ObjectId)) {
                accByTerrs.put(accTerr.ObjectId, new Set<Id>());
            }
            accByTerrs.get(accTerr.ObjectId).add(accTerr.Territory2Id);
        }

        System.debug(accByTerrs);

        //Amine
        Map<Id, Id> usersIdToTerr = new Map<Id, Id>();
        List<String> csmTerrExpertise = new List<String>();
        //

        List<UserTerritory2Association> userTerrs = [SELECT UserId, Territory2Id, Territory2.expertise__c 
                                                      FROM UserTerritory2Association 
                                                      WHERE Territory2Id IN : terrIds
                                                      AND RoleInTerritory2 ='CSM' ];
        
       	Set<Id> terrCSM = new Set<Id>();

        
        for(UserTerritory2Association usrTerr : userTerrs) {
            //Amine
            usersIdToTerr.put(usrTerr.UserId, usrTerr.Territory2Id);
            terrCSM.add(usrTerr.Territory2Id);
            csmTerrExpertise.add(usrTerr.Territory2.expertise__c);
            //
            csmUserByTerr.put(usrTerr.Territory2Id, usrTerr.userId);
        }

        //Amine
        //Organizing CSMs for Account
        Map<Id, Set<Id>> accsToCSM = new Map<Id, Set<Id>>();

        for(Id userId: usersIdToTerr.keySet()) {
            for(ObjectTerritory2Association accTerr : accTerrs) {
                if(accTerr.Territory2Id == usersIdToTerr.get(userId)) {
                    if(!accsToCSM.containsKey(accTerr.ObjectId)) {
                        accsToCSM.put(accTerr.ObjectId, new Set<Id>());
                    }
                    accsToCSM.get(accTerr.ObjectId).add(userId);
                    break;
                }
            }
        }

        //Baptiste
        List<Id> accsExpertiseIds = new List<Id>(); //List to Set

        //Check number of CSM
        for(Id accId: accsToCSM.keySet()){
            if(accsToCSM.get(accId).size() > 1) {
                accsExpertiseIds.add(accId);
            }
        }

        //Getting Expertise and Organizing by MAX MRR
        if(accsExpertiseIds != null && accsExpertiseIds.size() > 0) {
            List<Account_Expertise__c> accsExpertise = [SELECT Account__c, MRR__c, Expertise__c
                                                        FROM Account_Expertise__c 
                                                        WHERE Account__c IN : accsExpertiseIds AND Expertise__c IN :csmTerrExpertise];
                                                    
            Map<Id, Decimal> accToMaxMRR = new Map<Id, Decimal>();
            Map<Id, String> accToMaxMRRExpertise = new Map<Id, String>();

            //Group Expertise by Account
            Map<Id, List<Account_Expertise__c>> accToExpertises = new Map<Id, List<Account_Expertise__c>>();
            for(Account_Expertise__c accExp: accsExpertise) {
                if(accToExpertises.containsKey(accExp.Account__c)) {
                    accToExpertises.get(accExp.Account__c).add(accExp);
                } else {
                    accToExpertises.put(accExp.Account__c, new List<Account_Expertise__c>{accExp});
                }
            }

            //Seeking BU Grouping
            List<Id> accIdsBUFinance = new List<Id>();
            for(Id acc: accToExpertises.keySet()) {
                Integer moreThan2 = 0;
                Decimal sumMRR = 0;
                Decimal maxMRR = 0;
                for(Account_Expertise__c accExp: accToExpertises.get(acc)){
                    if(buToGroup.contains(accExp.Expertise__c)) {
                        moreThan2++;
                        if(moreThan2 >= 2) {
                            sumMRR += accExp.MRR__c;
                            //Acc with BU Finance
                        } else {
                            sumMRR = accExp.MRR__c;
                        }
                    } else {
                        //Calculating Max MRR
                        if(accExp.MRR__c > maxMRR) {
                            maxMRR = accExp.MRR__c;
                            accToMaxMRRExpertise.put(acc, accExp.Expertise__c);
                        }
                    }
                }
                
                System.debug('sumMRR => '+sumMRR);
                System.debug('maxMRR => '+maxMRR);

                if(sumMRR > maxMRR) {
                    maxMRR = sumMRR;
                    accToMaxMRRExpertise.put(acc, '316');
                }

                accToMaxMRR.put(acc, maxMRR);
                
                System.debug('acc => '+acc);
                System.debug('accToMaxMRR => '+accToMaxMRR);
                System.debug('accToMaxMRRExpertise => '+accToMaxMRRExpertise);
            }

            //Organizing by MAX MRR - Obsolete
            // for(Account_Expertise__c accExp: accsExpertise) {
            //     if((accToMaxMRRExpertise.containsKey(accExp.Account__c) && accExp.MRR__c > accToMaxMRR.get(accExp.Account__c)) || !accToMaxMRRExpertise.containsKey(accExp.Account__c)) {
            //         accToMaxMRR.put(accExp.Account__c, accExp.MRR__c);
            //         accToMaxMRRExpertise.put(accExp.Account__c, accExp.Expertise__c);
            //     }
            // }

            List<Id> accsFromMRR = new List<Id>(accToMaxMRRExpertise.keySet());//:List to Set
            Map<Id, Id> terrsToAccMrr = new Map<Id, Id>();

            //Requery Terr for Accs concerned
            List<ObjectTerritory2Association> accTerrsForMrr = [SELECT Id, ObjectId, Territory2Id, Territory2.Name, Territory2.Expertise__c, Territory2.BU__c
                                                                FROM ObjectTerritory2Association 
                                                                WHERE ObjectId IN :accsFromMRR];

            //Reorganize terr By Account from Expertise (MAX MRR)
            for(Id accIdMrr: accsFromMRR) {
                for(ObjectTerritory2Association accTerr: accTerrsForMrr) {
                    System.debug('accTerr.Territory2Id => '+accTerr.Territory2Id);
                    System.debug('accTerr.Territory2.BU__c => '+accTerr.Territory2.BU__c);
                    System.debug('accTerr.Territory2.Name => '+accTerr.Territory2.Name);
                    if(accTerr.ObjectId == accIdMrr && accTerr.Territory2.BU__c == accToMaxMRRExpertise.get(accIdMrr) && terrCSM.contains(accTerr.Territory2Id)) {
                        terrsToAccMrr.put(accIdMrr, accTerr.Territory2Id);
                        break;
                    }
                    
                    if(accTerr.ObjectId == accIdMrr && accTerr.Territory2.Expertise__c == accToMaxMRRExpertise.get(accIdMrr) && terrCSM.contains(accTerr.Territory2Id)) {
                        terrsToAccMrr.put(accIdMrr, accTerr.Territory2Id);
                        break;
                    }
                }
            }

            List<Id> accsMrrTerrs = new List<Id>(terrsToAccMrr.values());
			System.debug('accsMrrTerrs => '+accsMrrTerrs);
            
            //Requery Users For MRR => possbility tu use pre queried Users ?
            if(accsMrrTerrs != null && accsMrrTerrs.size() > 0) {
                List<UserTerritory2Association> userForAccMRR = [SELECT UserId, Territory2Id 
                                                                 FROM UserTerritory2Association 
                                                                 WHERE Territory2Id IN :accsMrrTerrs
                                                                 AND RoleInTerritory2 ='CSM' ORDER BY User.Name ASC];
                    
                System.debug('userForAccMRR => '+userForAccMRR);
                for(Id accId: terrsToAccMrr.keySet()) {
                    for(UserTerritory2Association userMrrAssociation: userForAccMRR /*userTerrs*/) {
                        System.debug('userMrrAssociation.Territory2Id => '+userMrrAssociation.Territory2Id);
                        System.debug('terrsToAccMrr.get(accId) => '+terrsToAccMrr.get(accId));
                        System.debug('userMrrAssociation.UserId => '+userMrrAssociation.UserId);
                        if(userMrrAssociation.Territory2Id == terrsToAccMrr.get(accId)) {
                            accMrrToUserCSM.put(accId, userMrrAssociation.UserId);
                        }
                    }
                }
            }
        }
        //Amine => This is bad for performance CPU TimeOut will increase considerably :(, could not find another way to do it.. Hope it helps
        //

        System.debug(userTerrs);

        for(Id idCont : contactIds) {
            Id taskOwnerId;
            //Baptiste à voir si ça fonctionne
            if(accsToCSM.get(contactAccount.get(idCont).Id).size() > 1) {
                taskOwnerId = accMrrToUserCSM.get(contactAccount.get(idCont).Id);
            } else {
                if(accByTerrs.containsKey(contactAccount.get(idCont).Id)) {
                    for(Id terrId : accByTerrs.get(contactAccount.get(idCont).Id)) {
                        if(csmUserByTerr.containsKey(terrId)) {
                            taskOwnerId = csmUserByTerr.get(terrId);
                        }
                    }
                    if(taskOwnerId == null) {
                        taskOwnerId = contactAccount.get(idCont).OwnerId;
                    }
                } else {
                    taskOwnerId = contactAccount.get(idCont).OwnerId;
                }
            }
            //
            
            tsks.add(new Task(Subject='Recommendation survey – call back', Type__c = 'Make a Call', SubType__c='Survey', WhoId=idCont, WhatId = contactAccount.get(idCont).Id,OwnerId = taskOwnerId, Status = 'Open', ActivityDate = Date.today() + 7, Description='Following the recommendation survey, this respondent asked to be contacted back. Please call this contact back'));
        }
        System.debug(tsks);
        
        if(tsks.size() > 0) {
            insert tsks;
        } 
    }   
}