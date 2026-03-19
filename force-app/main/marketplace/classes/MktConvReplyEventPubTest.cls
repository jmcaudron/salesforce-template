@isTest
/**
 * @description Tests for MktConvReplyEventPub.
 */
private class MktConvReplyEventPubTest {
    /**
     * @description Verifies single event publication success.
     */
    @IsTest
    static void testPublishSingleSuccess() {
        Test.startTest();
        Database.SaveResult result = MktConvReplyEventPub.publish(
            'Amazon',
            'conv-001',
            'a0B123456789012',
            MktConvReplyEventPub.ReplyType.TEXT,
            'Hello from agent',
            Datetime.now(),
            'Agent One',
            1,
            'FR',
            'DemoBrand'
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isSuccess());
    }

    /**
     * @description Verifies bulk publication success.
     */
    @IsTest
    static void testPublishBulkSuccess() {
        List<MktConvReplyEventPub.PublishRequest> requests =
            new List<MktConvReplyEventPub.PublishRequest>{
                new MktConvReplyEventPub.PublishRequest(
                    'Amazon',
                    'conv-100',
                    'a0B123456789013',
                    MktConvReplyEventPub.ReplyType.TEXT,
                    'First reply',
                    Datetime.now(),
                    'Agent One',
                    0,
                    'FR',
                    'BrandA'
                ),
                new MktConvReplyEventPub.PublishRequest(
                    'Allegro',
                    'conv-101',
                    'a0B123456789014',
                    MktConvReplyEventPub.ReplyType.TEXT_AND_ATTACHMENT,
                    'Second reply',
                    Datetime.now(),
                    'Agent Two',
                    2,
                    'PL',
                    'BrandB'
                )
            };

        Test.startTest();
        List<Database.SaveResult> results = MktConvReplyEventPub.publishBulk(requests);
        Test.stopTest();

        System.assertEquals(2, results.size());
        for (Database.SaveResult result : results) {
            System.assertEquals(true, result.isSuccess());
        }
    }

    /**
     * @description Verifies invalid country value is rejected.
     */
    @IsTest
    static void testPublishRejectsInvalidCountry() {
        Boolean hasThrown = false;

        try {
            MktConvReplyEventPub.publish(
                'Amazon',
                'conv-999',
                'a0B123456789015',
                MktConvReplyEventPub.ReplyType.ATTACHMENT,
                'Bad country',
                Datetime.now(),
                'Agent Three',
                1,
                'FRA',
                'BrandC'
            );
        } catch (IllegalArgumentException ex) {
            hasThrown = true;
            System.assert(ex.getMessage().contains('Country must contain exactly 2 characters.'));
        }

        System.assertEquals(true, hasThrown);
    }
}
