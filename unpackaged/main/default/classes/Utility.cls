public with sharing class Utility {
    public Utility() {

    }
    
    //@future
    public static void mentionTextPost(Id userToMentionId, String name,Id objectId, String body) {
        //system.debug('Create Chatter2');

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
         
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
         
        mentionSegmentInput.id = userToMentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
         
        textSegmentInput.text = body;
        messageBodyInput.messageSegments.add(textSegmentInput);
         
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = objectId;
        if (!Test.isRunningTest()) {
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        }       
    }

        //@future
        public static ConnectApi.BatchInput createBatchInput(Id userToMentionId, Id objectId, String body) {
    
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
             
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
             
            mentionSegmentInput.id = userToMentionId;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
             
            textSegmentInput.text = body;
            messageBodyInput.messageSegments.add(textSegmentInput);
             
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = objectId;
            
            ConnectApi.BatchInput batchInput;
            if (!Test.isRunningTest()) {
                batchInput = new ConnectApi.BatchInput(feedItemInput);
            }
            return batchInput;
        }


    public static Boolean isEmpty(String strValue) {
        return (strValue==null ||strValue.trim().length() ==0 );
    }
}