/**
 * @author Varun Molla - Comforth Karoo
 * @date 2021-09-15
 * @modified 
 * @group B2B
 * @description US W-001599 - BtoB_US28_mail de confirmation de commande   
*/
public without sharing class B2B_OrderConfirmationEmail {

    private static final B2B_Settings__c B2B_SETTINGS = B2B_Settings__c.getOrgDefaults();
    private static final OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'noreply@cegid.com'];

    @InvocableMethod(label='Create Training Session Records' description='Creates training session records from the list of Participants x the number of cart items' category='Order')
    public static void createTrainingSessionRecords(List<CartCheckoutSession> listMainCheckoutSession){
        //System.debug('>>> B2B_OrderConfirmationEmail listMainCheckoutSession: ' + listMainCheckoutSession);

        CartCheckoutSession mainCheckoutSession = listMainCheckoutSession[0];

        String orderId = '';

        for(CartCheckoutSession ccs : [SELECT Id, OrderId FROM CartCheckoutSession WHERE Id = :mainCheckoutSession.Id]){
            orderId = ccs.OrderId;
        }

        String strQueryOrder = '';
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Order.fields.getMap();
        for (String fieldName : schemaFieldMap.keySet()) {
            if(schemaFieldMap.get(fieldName).getDescribe().isAccessible()){
                strQueryOrder += (strQueryOrder == '') ? 'SELECT ' + fieldName : ', ' + fieldName;
            }
        }
        strQueryOrder += ' FROM Order where Id =: orderId';

        Order order = Database.query(strQueryOrder);

        //System.debug('>> order ID: ' + order);

        if(order.B2BOrder__c){
            Map<String, Id> mapOrderIdProductId_WithOrderItemId = new Map<String, Id>();

            //System.debug('>> OrderItem Perm: ' + Schema.sObjectType.OrderItem.isAccessible());

            List<Orderitem> listOrderItem = new List<Orderitem>();

            for(OrderItem orderItem : [SELECT Id, OrderId, Product2Id, TECH_ProductName__c FROM OrderItem WHERE OrderId = :order.Id]){
                mapOrderIdProductId_WithOrderItemId.put(orderItem.OrderId + ':' +orderItem.Product2Id, orderItem.Id);
                listOrderItem.add(orderItem);
            }

            //System.debug('>> mapOrderIdProductId_WithOrderItemId: ' + mapOrderIdProductId_WithOrderItemId);
            //System.debug('>> listOrderItem: ' + listOrderItem);

            List<CartItem> listCartItem = new List<CartItem>();
            Set<Id> setCartItemIds = new Set<Id>();

            for(WebCart cart : [SELECT Id, (SELECT Id, Product2Id, TECH_SessionDate__c, TECH_SessionCode__c FROM CartItems) FROM WebCart WHERE Id = :order.Cart__c]){
                listCartItem = cart.CartItems;
                /* for(CartItem cartItem : cart.CartItems){
                    setCartItemIds.add(cartItem.Id);
                } */
            }

            //System.debug('>> listCartItem: ' + listCartItem);

            for(CartItem cartItem : listCartItem){
                setCartItemIds.add(cartItem.Id);
            }

            //System.debug('>> setCartItemIds: ' + setCartItemIds);

            Map<Id, List<Participant__c>> mapCartItemId_WithListParticipant = new Map<Id, List<Participant__c>>();

            for(Participant__c participant : [SELECT Id, CartItemId__c, Civilite__c, EmailAddress__c, Prenom__c, Nom__c, Name FROM Participant__c WHERE CartItemId__c IN :setCartItemIds]){
                if(mapCartItemId_WithListParticipant.containsKey(participant.CartItemId__c)){
                    mapCartItemId_WithListParticipant.get(participant.CartItemId__c).add(participant);
                }else{
                    mapCartItemId_WithListParticipant.put(participant.CartItemId__c, new List<Participant__c>{participant});
                }
            }

            //System.debug('>> mapCartItemId_WithListParticipant: ' + mapCartItemId_WithListParticipant);

            List<TrainingSession__c> listTrainingSessionToInsert = new List<TrainingSession__c>();

            for(CartItem cartItem : listCartItem){
                if(mapCartItemId_WithListParticipant.containsKey(cartItem.Id)){
                    for(Participant__c participant : mapCartItemId_WithListParticipant.get(cartItem.Id)){
                        TrainingSession__c trainingSession = new TrainingSession__c();
                        trainingSession.Order__c = order.Id;
                        trainingSession.Order_Product__c = mapOrderIdProductId_WithOrderItemId.containsKey(order.Id + ':' + cartItem.Product2Id) ? mapOrderIdProductId_WithOrderItemId.get(order.Id + ':' + cartItem.Product2Id) : null;
                        trainingSession.ParticipantSalutation__c = participant.Civilite__c;
                        trainingSession.ParticipantFirstName__c = participant.Name;
                        trainingSession.ParticipantLastName__c = participant.Prenom__c;
                        trainingSession.ParticipantEmail__c = participant.EmailAddress__c;
                        trainingSession.SessionCode__c = cartItem.TECH_SessionCode__c;
                        trainingSession.SessionDate__c = cartItem.TECH_SessionDate__c;
                        listTrainingSessionToInsert.add(trainingSession);
                    }
                }
            }

            //System.debug('>> listTrainingSessionToInsert: ' + listTrainingSessionToInsert);

            if(listTrainingSessionToInsert.size() > 0){
                Database.insert(listTrainingSessionToInsert);
            }

            if(String.isNotBlank(order.IBAN__c) || String.isNotBlank(order.New_IBAN__c)){
                sendEmailAndMandatSEPAToClient(order, listOrderItem);
            }else{
                sendEmailToClientUsedCreditCard(order, listOrderItem);
            }
        }
    }

    @TestVisible
    private static void sendEmailAndMandatSEPAToClient(Order order, List<Orderitem> listOrderItem){
        String orderId = order.Id;

        PageReference mandatSEPA_PDF = Page.B2B_MandatSEPA;
        mandatSEPA_PDF.getParameters().put('Id', order.Id);

        String pdfName = 'Commande ' + order.OrderNumber + ' Mandat SEPA.pdf';

        Attachment attach = new Attachment();
        Blob body;
        
        try{
            body = mandatSEPA_PDF.getContentAsPDF();
        }catch(VisualforceException e){
            body = Blob.valueOf('ERROR');
        }

        try{
            EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'B2B_Order_Confirmation_Mail_Mandat_SEPA_To_Client'];

            Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
            attach1.setContentType('application/pdf');
            attach1.setFileName(pdfName);
            attach1.setInline(false);
            attach1.Body = body;
            
            //Will now send the real email
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setUseSignature(false);
            emailToSend.setToAddresses(new List<String>{UserInfo.getUserEmail()});

            String productInformation = '';
            String emailBody = emailTemplate.HtmlValue;

            /* for(Order order1 : [SELECT Id, (SELECT Id, TECH_ProductName__c, Product2Id FROM OrderItems) FROM Order WHERE Id = :order.Id]){
                Map<OrderItem, String> mapOrderItem_WithPublicLink = findTrainingProgramFileAndGeneratePublicLink(order1.OrderItems);
                System.debug('>> mapOrderItem_WithPublicLink: ' + mapOrderItem_WithPublicLink);
                for(OrderItem orderItem : mapOrderItem_WithPublicLink.keySet()){
                    if(mapOrderItem_WithPublicLink.containsKey(orderItem)){
                        productInformation += emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>').replace('<productNameFromApex>', orderItem.TECH_ProductName__c).replace('ProgrammeDeFormationLinkFromApex', mapOrderItem_WithPublicLink.get(orderItem));
                    }
                }
            } */

            Map<OrderItem, String> mapOrderItem_WithPublicLink = findTrainingProgramFileAndGeneratePublicLink(listOrderItem);

            //System.debug('>> mapOrderItem_WithPublicLink: ' + mapOrderItem_WithPublicLink);

            for(OrderItem orderItem : listOrderItem){
                if(mapOrderItem_WithPublicLink.containsKey(orderItem)){
                    productInformation += emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>').replace('<productNameFromApex>', orderItem.TECH_ProductName__c).replace('ProgrammeDeFormationLinkFromApex', mapOrderItem_WithPublicLink.get(orderItem));
                }else{
                    String strSentenceLink = emailBody.substringBetween('<noPublicLink>', '</noPublicLink>');
                    productInformation += emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>').replace('<productNameFromApex>', orderItem.TECH_ProductName__c).replace(strSentenceLink, '');
                }
            }

            emailToSend.setTargetObjectId(UserInfo.getUserId()); 
            //emailToSend.setSenderDisplayName('CEGID'); 
            emailToSend.setReplyTo('noreply@cegid.com');
             
            emailBody = emailBody.replace('{!User.Name}', UserInfo.getName());
            emailBody = emailBody.replace('{!Order.OrderNumber}', order.OrderNumber);
            emailBody = emailBody.replace('{!Order.TECH_CreatedDateFrench__c}', order.TECH_CreatedDateFrench__c);
            emailBody = emailBody.replace('{!Order.TECH_AccountName__c}', order.TECH_AccountName__c);
            emailBody = emailBody.replace('StoreLoginURL__c', B2B_SETTINGS.StoreLoginURL__c);
            emailBody = emailBody.replace(emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>'), productInformation);
            emailToSend.setHtmlBody(emailBody);
            emailToSend.setSaveAsActivity(false);
            emailToSend.setSubject(emailTemplate.Subject);
            emailToSend.setTemplateID(emailTemplate.Id); 
            emailToSend.setWhatId(orderId);
            emailToSend.setOrgWideEmailAddressId(owa.Id);//VMO 2021-11-17
            emailToSend.setFileAttachments(new Messaging.EmailFileAttachment[]{
                attach1
            });
            
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailToSend });
            }
        }catch(Exception ex){
            Messaging.SingleEmailMessage[] listEmailMsgs = new List <Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String errorMsg = String.valueOf(ex) + '\n\n';
            errorMsg += 'StackTraceString : ' + ex.getStackTraceString() + '\n';
            mail.setSubject('CEGID - Exception : ' + ex.getStackTraceString());
            mail.setPlainTextBody(errorMsg);
            mail.setToAddresses(new List <String>{
               'varun.molla@comforth-karoo.eu'
            });
            listEmailMsgs.add(mail);
            if (!Test.isRunningTest()){
                Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(listEmailMsgs);
            }
        }
    }

    @TestVisible
    private static void sendEmailToClientUsedCreditCard(Order order,  List<Orderitem> listOrderItem){
        String orderId = order.Id;

        try{
            EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE DeveloperName = 'B2B_Order_Confirmation_Mail_Credit_Card_To_Client'];
            
            //Will now send the real email
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setUseSignature(false);
            emailToSend.setToAddresses(new List<String>{UserInfo.getUserEmail()});

            String productInformation = '';
            String emailBody = emailTemplate.HtmlValue;

            /* for(Order order1 : [SELECT Id, (SELECT Id, TECH_ProductName__c, Product2Id FROM OrderItems) FROM Order WHERE Id = :order.Id]){
                Map<OrderItem, String> mapOrderItem_WithPublicLink = findTrainingProgramFileAndGeneratePublicLink(order1.OrderItems);
                for(OrderItem orderItem : mapOrderItem_WithPublicLink.keySet()){
                    if(mapOrderItem_WithPublicLink.containsKey(orderItem)){
                        productInformation += emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>').replace('<productNameFromApex>', orderItem.TECH_ProductName__c).replace('ProgrammeDeFormationLinkFromApex', mapOrderItem_WithPublicLink.get(orderItem));
                    }
                }
            } */

            Map<OrderItem, String> mapOrderItem_WithPublicLink = findTrainingProgramFileAndGeneratePublicLink(listOrderItem);

            //System.debug('>> mapOrderItem_WithPublicLink: ' + mapOrderItem_WithPublicLink);

            for(OrderItem orderItem : listOrderItem){
                if(mapOrderItem_WithPublicLink.containsKey(orderItem)){
                    productInformation += emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>').replace('<productNameFromApex>', orderItem.TECH_ProductName__c).replace('ProgrammeDeFormationLinkFromApex', mapOrderItem_WithPublicLink.get(orderItem));
                }else{
                    String strSentenceLink = emailBody.substringBetween('<noPublicLink>', '</noPublicLink>');
                    productInformation += emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>').replace('<productNameFromApex>', orderItem.TECH_ProductName__c).replace(strSentenceLink, '');
                }
            }

            emailToSend.setTargetObjectId(UserInfo.getUserId()); 
            //emailToSend.setSenderDisplayName('CEGID'); 
            emailToSend.setReplyTo('noreply@cegid.com');
             
            emailBody = emailBody.replace('{!User.Name}', UserInfo.getName());
            emailBody = emailBody.replace('{!Order.OrderNumber}', order.OrderNumber);
            emailBody = emailBody.replace('{!Order.TECH_CreatedDateFrench__c}', order.TECH_CreatedDateFrench__c);
            emailBody = emailBody.replace('{!Order.TECH_AccountName__c}', order.TECH_AccountName__c);
            emailBody = emailBody.replace('StoreLoginURL__c', B2B_SETTINGS.StoreLoginURL__c);
            emailBody = emailBody.replace(emailBody.substringBetween('<OrderProductInfo>', '</OrderProductInfo>'), productInformation);
            emailToSend.setHtmlBody(emailBody);
            emailToSend.setSaveAsActivity(false);
            emailToSend.setSubject(emailTemplate.Subject);
            emailToSend.setTemplateID(emailTemplate.Id); 
            emailToSend.setWhatId(orderId);
            emailToSend.setOrgWideEmailAddressId(owa.Id);//VMO 2021-11-17
            
            if (!Test.isRunningTest()) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailToSend });
            }
        }catch(Exception ex){
            Messaging.SingleEmailMessage[] listEmailMsgs = new List <Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            String errorMsg = String.valueOf(ex) + '\n\n';
            errorMsg += 'StackTraceString : ' + ex.getStackTraceString() + '\n';
            mail.setSubject('CEGID - Exception : ' + ex.getStackTraceString());
            mail.setPlainTextBody(errorMsg);
            mail.setToAddresses(new List <String>{
               'varun.molla@comforth-karoo.eu'
            });
            listEmailMsgs.add(mail);
            if (!Test.isRunningTest()){
                Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(listEmailMsgs);
            }
        }
    }

    @TestVisible
    private static Map<OrderItem, String> findTrainingProgramFileAndGeneratePublicLink(List<OrderItem> ListOrderItem){
        Set<Id> setProductIds = new Set<Id>();
        Set<Id> setOrderItemIds = new Set<Id>();
        Map<OrderItem, String> mapOrderItem_WithPublicLink = new Map<OrderItem, String>();
        Map<Id, List<ContentDocumentLink>> mapProductId_WithListCDL = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, Id> mapContentDocID_WithContentVersionId = new Map<Id, Id>();
        Map<Id, ContentVersion> mapContentVersionID_WithContentVersion = new Map<Id, ContentVersion>();
        Map<Id, String> mapContentVersionID_WithPublicLink = new Map<Id, String>();

        for(OrderItem orderItem : ListOrderItem){
            setProductIds.add(orderItem.Product2Id);
        }

        Set<Id> setCDLIds = new Set<Id>();

        //('>> setProductIds: '+setProductIds);

        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setProductIds]){
            setCDLIds.add(cdl.ContentDocumentId);

            if(mapProductId_WithListCDL.containsKey(cdl.LinkedEntityId)){
                mapProductId_WithListCDL.get(cdl.LinkedEntityId).add(cdl);
            }else{
                mapProductId_WithListCDL.put(cdl.LinkedEntityId, new List<ContentDocumentLink>{cdl});
            }
        }

        //System.debug('>> mapProductId_WithListCDL: '+mapProductId_WithListCDL);

        for(ContentVersion cv : [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :setCDLIds AND Title LIKE '%Programme De Formation%']){
            mapContentDocID_WithContentVersionId.put(cv.ContentDocumentId, cv.Id);
            mapContentVersionID_WithContentVersion.put(cv.Id, cv);
        }

        for(ContentDistribution contentDist : [SELECT Id, DistributionPublicUrl, ContentVersionId FROM ContentDistribution WHERE ContentVersionId IN :mapContentDocID_WithContentVersionId.values()]){
            mapContentVersionID_WithPublicLink.put(contentDist.ContentVersionId, String.isNotBlank(contentDist.DistributionPublicUrl) ? contentDist.DistributionPublicUrl : '');
        }

        //System.debug('>> mapContentDocID_WithContentVersionId (1): '+mapContentDocID_WithContentVersionId);

        List<ContentDistribution> listContentDistributionToInsert = new List<ContentDistribution>();

        //if(mapContentVersionID_WithPublicLink.isEmpty()){
            for(Id cvId : mapContentVersionID_WithContentVersion.keySet()){
                if(!mapContentVersionID_WithPublicLink.containsKey(cvId) && mapContentVersionID_WithContentVersion.containsKey(cvId)){
                    ContentDistribution cdist = new ContentDistribution();
                    cdist.Name = mapContentVersionID_WithContentVersion.get(cvId).Title;
                    cdist.ContentVersionId = cvId;
                    cdist.PreferencesAllowViewInBrowser = true;
                    //insert cdist;
                    listContentDistributionToInsert.add(cdist);

                    //List<ContentDistribution> listContentDist = [SELECT Id, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId = :cvId];
                }
            }

            insert listContentDistributionToInsert;

            for(ContentDistribution cdist : [SELECT Id, DistributionPublicUrl, ContentVersionId FROM ContentDistribution WHERE ContentVersionId = :mapContentVersionID_WithContentVersion.keySet()]){
                mapContentVersionID_WithPublicLink.put(cdist.ContentVersionId, String.isNotBlank(cdist.DistributionPublicUrl) ? cdist.DistributionPublicUrl : '');
            }
        //}

        //System.debug('>> mapContentDocID_WithContentVersionId (2): '+mapContentDocID_WithContentVersionId);
        //System.debug('>> mapContentVersionID_WithContentVersion: '+mapContentVersionID_WithContentVersion);
        //System.debug('>> mapContentVersionID_WithPublicLink: '+mapContentVersionID_WithPublicLink);

        for(OrderItem orderItem : ListOrderItem){
            if(mapProductId_WithListCDL.containsKey(orderItem.Product2Id)){
                for(ContentDocumentLink cdl : mapProductId_WithListCDL.get(orderItem.Product2Id)){
                    if(mapContentDocID_WithContentVersionId.containsKey(cdl.ContentDocumentId)){
                        String contentVersionId = mapContentDocID_WithContentVersionId.get(cdl.ContentDocumentId);
                        String publicLink = mapContentVersionID_WithPublicLink.get(contentVersionId);
                        mapOrderItem_WithPublicLink.put(orderItem, publicLink);
                        break;
                    }
                }
            }
        }

        return mapOrderItem_WithPublicLink;
    }
}