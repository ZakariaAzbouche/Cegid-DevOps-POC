trigger Recommendation_scoreTrigger on Recommendation_Score__c (after update) {
    new TH_RecommendationScore().run();
}