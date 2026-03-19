@isTest
/**
 * @description This Class has the purpose of testing the LogHandler Class. Unit tests for `LogHandler` covering initialization,
 * DML limit checks, error logging, and final commit behavior.
 */
public class LogHandlerTest {
    /**
     * @description Verifies that log initialization persists the expected process metadata.
     */
    @IsTest
    static void testInitLog() {
        LogHandler logHandling = new LogHandler('testInitLog', 'Test Method');

        Log__c toBeAssertedLog = [SELECT Id, Process_Name__c, Process_Type__c FROM Log__c];

        System.assertEquals(logHandling.log.Id, toBeAssertedLog.Id);
        System.assertEquals(logHandling.log.Process_Name__c, toBeAssertedLog.Process_Name__c);
        System.assertEquals(logHandling.log.Process_Type__c, toBeAssertedLog.Process_Type__c);
    }

    /**
     * @description Verifies that DML governor limit checks create one log line when exceeded.
     */
    @IsTest
    static void testCheckDMLGovernorLimits() {
        LogHandler logHandling = new LogHandler('TestCheckDMLGovernorLimits', 'Test Method');

        logHandling.checkDMLGovernorLimits(Limits.getLimitDmlRows() / 2);
        logHandling.checkDMLGovernorLimits(Limits.getLimitDmlRows() * 2);

        logHandling.commitLogLines();

        Integer numberLogLineRecords = [SELECT COUNT() FROM Log_Line__c];

        System.assertEquals(
            1,
            numberLogLineRecords,
            'One log line record should have been inserted'
        );
    }

    /**
     * @description Verifies manual error submission writes message, record id, and object name.
     */
    @IsTest
    static void testSubmitErrorLogMessage() {
        LogHandler logHandling = new LogHandler('TestSubmitErrorLogMessage', 'Test Method');

        final String TEST_ERROR_MESSAGE = 'Test Error Message';
        final Id TEST_SOURCE_RECORD_ID = UserInfo.getUserId();
        final String TEST_OBJECT_NAME = 'Test Object Name';

        logHandling.submitErrorLog(TEST_ERROR_MESSAGE, TEST_SOURCE_RECORD_ID, TEST_OBJECT_NAME);

        logHandling.commitLogLines();

        Log_Line__c toBeAssertedLogLine = [
            SELECT Id, Error_Message__c, Record_id__c, Object_Name__c
            FROM Log_Line__c
        ];

        System.assertEquals(TEST_ERROR_MESSAGE, toBeAssertedLogLine.Error_Message__c);
        System.assertEquals(TEST_SOURCE_RECORD_ID, toBeAssertedLogLine.Record_id__c);
        System.assertEquals(TEST_OBJECT_NAME, toBeAssertedLogLine.Object_Name__c);
    }

    /**
     * @description Verifies exception-based error submission stores message and stack trace.
     */
    @IsTest
    static void testSubmitErrorLogException() {
        LogHandler logHandling = new LogHandler('TestSubmitErrorLogException', 'Test Method');

        try {
            throw new NullPointerException();
        } catch (NullPointerException npe) {
            logHandling.submitErrorLog(npe);
        }

        logHandling.commitLogLines();

        Log_Line__c toBeAssertedLogLine = [
            SELECT Id, Error_Message__c, Error_Stacktrace__c
            FROM Log_Line__c
        ];

        System.assertNotEquals(null, toBeAssertedLogLine.Error_Message__c);
        System.assertNotEquals(null, toBeAssertedLogLine.Error_Stacktrace__c);
    }

    /**
     * @description Verifies log lines and parent log are committed successfully.
     */
    @isTest
    static void testCommitLogLines() {
        LogHandler logHandling = new LogHandler('testCommitLogLines', 'Test Method');
        logHandling.logLines.add(
            new Log_Line__c(
                Log__c = logHandling.log.Id,
                Date__c = System.now(),
                Error_Message__c = 'testCommitLogLines'
            )
        );

        logHandling.commitLogLines();

        Integer numberLogLineRecords = [SELECT COUNT() FROM Log_Line__c];

        System.assertEquals(
            1,
            numberLogLineRecords,
            'One log line record should have been inserted'
        );
    }
}
