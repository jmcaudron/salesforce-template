/**
 * @description Publishes marketplace conversation reply platform events.
 */
public with sharing class MktConvReplyEventPub {
    /**
     * @description Supported reply type values.
     */
    public enum ReplyType {
        TEXT,
        ATTACHMENT,
        TEXT_AND_ATTACHMENT
    }

    /**
     * @description Request payload used by bulk publication.
     */
    public class PublishRequest {
        public String marketplace;
        public String marketplaceConversationId;
        public String salesforceMessageId;
        public ReplyType replyType;
        public String messageBody;
        public Datetime sentAt;
        public String senderName;
        public Integer attachmentCount;
        public String country;
        public String brand;

        /**
         * @description Creates a new publication payload.
         */
        public PublishRequest(
            String marketplace,
            String marketplaceConversationId,
            String salesforceMessageId,
            ReplyType replyType,
            String messageBody,
            Datetime sentAt,
            String senderName,
            Integer attachmentCount,
            String country,
            String brand
        ) {
            this.marketplace = marketplace;
            this.marketplaceConversationId = marketplaceConversationId;
            this.salesforceMessageId = salesforceMessageId;
            this.replyType = replyType;
            this.messageBody = messageBody;
            this.sentAt = sentAt;
            this.senderName = senderName;
            this.attachmentCount = attachmentCount;
            this.country = country;
            this.brand = brand;
        }
    }

    /**
     * @description Publishes a single marketplace conversation reply event.
     * @return Save result produced by the platform event publish operation.
     */
    public static Database.SaveResult publish(
        String marketplace,
        String marketplaceConversationId,
        String salesforceMessageId,
        ReplyType replyType,
        String messageBody,
        Datetime sentAt,
        String senderName,
        Integer attachmentCount,
        String country,
        String brand
    ) {
        MarketplaceConversationReply__e eventRecord = buildEventRecord(
            new PublishRequest(
                marketplace,
                marketplaceConversationId,
                salesforceMessageId,
                replyType,
                messageBody,
                sentAt,
                senderName,
                attachmentCount,
                country,
                brand
            )
        );

        return EventBus.publish(eventRecord);
    }

    /**
     * @description Publishes multiple marketplace conversation reply events in one call.
     * @param requests List of requests to publish.
     * @return Save results for each published event.
     */
    public static List<Database.SaveResult> publishBulk(List<PublishRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            return new List<Database.SaveResult>();
        }

        List<MarketplaceConversationReply__e> eventRecords = new List<MarketplaceConversationReply__e>();
        for (PublishRequest requestItem : requests) {
            eventRecords.add(buildEventRecord(requestItem));
        }

        return EventBus.publish(eventRecords);
    }

    /**
     * @description Builds and validates a platform event record.
     * @param requestItem Publication request.
     * @return Platform event populated from request values.
     */
    private static MarketplaceConversationReply__e buildEventRecord(PublishRequest requestItem) {
        validateRequest(requestItem);

        return new MarketplaceConversationReply__e(
            Marketplace__c = requestItem.marketplace,
            MarketplaceConversationId__c = requestItem.marketplaceConversationId,
            SalesforceMessageId__c = requestItem.salesforceMessageId,
            ReplyType__c = requestItem.replyType.name(),
            MessageBody__c = requestItem.messageBody,
            SentAt__c = requestItem.sentAt,
            SenderName__c = requestItem.senderName,
            AttachmentCount__c = requestItem.attachmentCount,
            Country__c = requestItem.country,
            Brand__c = requestItem.brand
        );
    }

    /**
     * @description Validates payload values before publishing events.
     * @param requestItem Publication request.
     */
    private static void validateRequest(PublishRequest requestItem) {
        if (requestItem == null) {
            throw new IllegalArgumentException('Publish request cannot be null.');
        }

        if (String.isBlank(requestItem.marketplace)) {
            throw new IllegalArgumentException('Marketplace is required.');
        }

        if (String.isBlank(requestItem.marketplaceConversationId)) {
            throw new IllegalArgumentException('Marketplace conversation id is required.');
        }

        if (requestItem.sentAt == null) {
            throw new IllegalArgumentException('SentAt is required.');
        }

        if (requestItem.replyType == null) {
            throw new IllegalArgumentException('ReplyType is required.');
        }

        if (!String.isBlank(requestItem.country) && requestItem.country.length() != 2) {
            throw new IllegalArgumentException('Country must contain exactly 2 characters.');
        }

        if (requestItem.attachmentCount != null && (requestItem.attachmentCount < 0 || requestItem.attachmentCount > 999)) {
            throw new IllegalArgumentException('AttachmentCount must be between 0 and 999.');
        }
    }
}
