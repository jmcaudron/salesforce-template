Datetime sentAt = Datetime.now();
String complexMessageBody =
    'Bonjour team,' + '\n' +
    'Le client a ecrit: "Pouvez-vous confirmer la disponibilite pour demain ?"' + '\n' +
    'Reference interne: ticket #A-17, vendeur d\'origine: O\'Market.' + '\n' +
    'Merci, l\'agent "Nina" a ajoute 2 pieces jointes.';

Map<String, Object> eventExample = new Map<String, Object>{
    'Marketplace__c' => 'Amazon',
    'MarketplaceConversationId__c' => 'conv-test-001',
    'SalesforceMessageId__c' => 'a0B000000000001AAA',
    'ReplyType__c' => 'TEXT',
    'MessageBody__c' => complexMessageBody,
    'SentAt__c' => sentAt,
    'SenderName__c' => 'Integration Test Agent',
    'AttachmentCount__c' => 1,
    'Country__c' => 'FR',
    'Brand__c' => 'DemoBrand'
};

System.debug('Marketplace event payload example: ' + JSON.serializePretty(eventExample));

Database.SaveResult publishResult = MktConvReplyEventPub.publish(
    'Amazon',
    'conv-test-001',
    'a0B000000000001AAA',
    MktConvReplyEventPub.ReplyType.TEXT,
    complexMessageBody,
    sentAt,
    'Integration Test Agent',
    1,
    'FR',
    'DemoBrand'
);

if (!publishResult.isSuccess()) {
    String errorMessage = 'Unknown publish error';
    if (publishResult.getErrors() != null && !publishResult.getErrors().isEmpty()) {
        errorMessage = publishResult.getErrors()[0].getMessage();
    }
    System.assert(false, 'Platform Event publish failed: ' + errorMessage);
}

System.debug('Marketplace event published successfully. Event UUID: ' + publishResult.getId());
