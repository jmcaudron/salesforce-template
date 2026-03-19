/**
 * @description Batch template implementation that realigns maintenance request
 * date-time fields to the current year and month while preserving time of day.
 */
global inherited sharing class MaintReqCurrentMonthBatch extends BatchesAbstractTemplate {
    private static final Integer DEFAULT_SCOPE_SIZE = 200;
    private static final String SCHEDULE_CRON_DAILY_3AM = '0 0 3 * * ?';
    private static final String SCHEDULE_NAME_PREFIX = 'MaintReqCurrentMonthBatch_3AM_';

    /**
     * @description Initializes batch query to retrieve records that can be adjusted.
     */
    global MaintReqCurrentMonthBatch() {
        super();
        query = 'SELECT Id, Scheduled__c, Completed__c ' +
            'FROM Maintenance_Request__c ' +
            'WHERE Scheduled__c != null OR Completed__c != null';
    }

    /**
     * @description Schedulable entry point that launches this batch.
     * @param sc Scheduler context.
     */
    global override void execute(SchedulableContext sc) {
        Database.executeBatch(new MaintReqCurrentMonthBatch(), DEFAULT_SCOPE_SIZE);
    }

    /**
     * @description Aligns `Scheduled__c` and `Completed__c` to current year/month.
     * @param objects Batch scope records.
     */
    global override void processObjects(List<SObject> objects) {
        Date today = Date.today();

        for (SObject objectRecord : objects) {
            Maintenance_Request__c request = (Maintenance_Request__c) objectRecord;
            Boolean hasChanges = false;

            if (request.Scheduled__c != null) {
                Datetime updatedScheduled = alignToCurrentYearMonth(request.Scheduled__c, today);
                if (request.Scheduled__c != updatedScheduled) {
                    request.Scheduled__c = updatedScheduled;
                    hasChanges = true;
                }
            }

            if (request.Completed__c != null) {
                Datetime updatedCompleted = alignToCurrentYearMonth(request.Completed__c, today);
                if (request.Completed__c != updatedCompleted) {
                    request.Completed__c = updatedCompleted;
                    hasChanges = true;
                }
            }

            if (hasChanges) {
                toBeUpdatedList.add(request);
            }
        }
    }

    /**
     * @description Schedules the batch daily at 03:00 AM server time.
     * @return The created scheduled job Id.
     */
    global static Id scheduleDailyAt3am() {
        String jobName = SCHEDULE_NAME_PREFIX + String.valueOf(Datetime.now().getTime());
        return System.schedule(jobName, SCHEDULE_CRON_DAILY_3AM, new MaintReqCurrentMonthBatch());
    }

    /**
     * @description Builds a new Datetime using current year/month and original day/time.
     * If the original day exceeds the current month length, it is clamped to the last day.
     * @param source Source Datetime value.
     * @param today Current date reference.
     * @return Datetime aligned to current month/year while preserving UTC time components.
     */
    @TestVisible
    private static Datetime alignToCurrentYearMonth(Datetime source, Date today) {
        Integer targetYear = today.year();
        Integer targetMonth = today.month();
        Integer maxDayInMonth = Date.daysInMonth(targetYear, targetMonth);
        Integer targetDay = Math.min(source.dayGmt(), maxDayInMonth);

        return Datetime.newInstanceGmt(
            targetYear,
            targetMonth,
            targetDay,
            source.hourGmt(),
            source.minuteGmt(),
            source.secondGmt()
        );
    }
}
