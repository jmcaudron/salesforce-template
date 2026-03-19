@isTest
/**
 * @description Tests for MaintReqCurrentMonthBatch.
 */
private class MaintReqCurrentMonthBatchTest {
    /**
     * @description Verifies that Scheduled__c and Completed__c are aligned to current year/month.
     */
    @IsTest
    static void testBatchUpdatesScheduledAndCompleted() {
        Datetime scheduled = Datetime.newInstanceGmt(2024, 8, 26, 8, 0, 0);
        Datetime completed = Datetime.newInstanceGmt(2024, 8, 26, 10, 30, 0);

        Maintenance_Request__c request = new Maintenance_Request__c(
            Scheduled__c = scheduled,
            Completed__c = completed
        );
        insert request;

        Test.startTest();
        Database.executeBatch(new MaintReqCurrentMonthBatch(), 50);
        Test.stopTest();

        Maintenance_Request__c refreshed = [
            SELECT Scheduled__c, Completed__c
            FROM Maintenance_Request__c
            WHERE Id = :request.Id
        ];

        Date today = Date.today();
        System.assertEquals(today.year(), refreshed.Scheduled__c.yearGmt());
        System.assertEquals(today.month(), refreshed.Scheduled__c.monthGmt());
        System.assertEquals(26, refreshed.Scheduled__c.dayGmt());
        System.assertEquals(8, refreshed.Scheduled__c.hourGmt());
        System.assertEquals(0, refreshed.Scheduled__c.minuteGmt());

        System.assertEquals(today.year(), refreshed.Completed__c.yearGmt());
        System.assertEquals(today.month(), refreshed.Completed__c.monthGmt());
        System.assertEquals(26, refreshed.Completed__c.dayGmt());
        System.assertEquals(10, refreshed.Completed__c.hourGmt());
        System.assertEquals(30, refreshed.Completed__c.minuteGmt());
    }

    /**
     * @description Verifies day clamping when the source day does not exist in current month.
     */
    @IsTest
    static void testAlignToCurrentYearMonthClampsDay() {
        Date today = Date.today();
        Integer expectedDay = Math.min(31, Date.daysInMonth(today.year(), today.month()));

        Datetime source = Datetime.newInstanceGmt(2024, 1, 31, 9, 15, 0);
        Datetime aligned = MaintReqCurrentMonthBatch.alignToCurrentYearMonth(source, today);

        System.assertEquals(today.year(), aligned.yearGmt());
        System.assertEquals(today.month(), aligned.monthGmt());
        System.assertEquals(expectedDay, aligned.dayGmt());
        System.assertEquals(9, aligned.hourGmt());
        System.assertEquals(15, aligned.minuteGmt());
    }

    /**
     * @description Verifies that daily 03:00 scheduling creates a cron trigger.
     */
    @IsTest
    static void testScheduleDailyAt3am() {
        Test.startTest();
        Id scheduledJobId = MaintReqCurrentMonthBatch.scheduleDailyAt3am();
        Test.stopTest();

        CronTrigger triggerRecord = [
            SELECT CronExpression
            FROM CronTrigger
            WHERE Id = :scheduledJobId
            LIMIT 1
        ];

        System.assertEquals('0 0 3 * * ?', triggerRecord.CronExpression);
    }
}
