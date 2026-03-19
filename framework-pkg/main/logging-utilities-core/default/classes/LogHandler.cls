/**
 * @description This Class has the purpose of handling all the operations related to Log & LogLines records. Handles the lifecycle of batch/process logs by creating a `Log__c`
 * record, collecting `Log_Line__c` entries, and committing them at the end.
 */
global inherited sharing class LogHandler {
    global Log__c log;
    global List<Log_Line__c> logLines;

    /**
     * @description Initializes the log container and inserts the initial `Log__c` record.
     * @param processName Functional process name to store on the log record.
     * @param processType Process type label to store on the log record.
     */
    global LogHandler(String processName, String processType) {
        this.log = new Log__c(
            Process_Name__c = processName,
            Process_Type__c = processType,
            Start_Date__c = DateTime.now()
        );

        List<Database.SaveResult> initResults = Database.insert(new List<Log__c>{ this.log }, false);
        if (initResults.isEmpty() || !initResults[0].isSuccess()) {
            throw new LogInitializationException('Unable to initialize Log__c record.');
        }
        this.log.Id = initResults[0].getId();
        this.logLines = new List<Log_Line__c>();
    }

    // Method to be used before any DML statement while monitoring
    /**
     * @description Verifies that upcoming DML work remains under governor limits.
     * @param nbDMLRows Number of DML rows planned for the next operation.
     * @return True when DML execution can proceed; false when a log line is created for limit risk.
     */
    global boolean checkDMLGovernorLimits(Integer nbDMLRows) {
        if (
            ((Double) Limits.getDmlStatements() + 1) / (Double) Limits.getLimitDmlStatements() >=
            0.9 ||
            ((Double) Limits.getDmlRows() + nbDMLRows) / (Double) Limits.getLimitDmlRows() >= 0.9
        ) {
            Log_Line__c logLine = new Log_Line__c(
                Date__c = Datetime.now(),
                Log__c = log.Id,
                Error_Message__c = log.Process_Name__c +
                    '\'s execution has exceeded the DML Governor Limits'
            );

            this.logLines.add(logLine);

            return false;
        } else {
            return true;
        }
    }

    // Method to be used when a DML statement has failed
    /**
     * @description Adds an error log line for a failed DML operation.
     * @param errorMessage Human-readable error message.
     * @param sourceRecordId Record id associated to the failure, when available.
     * @param objectName API name of the object involved in the failure.
     */
    global void submitErrorLog(String errorMessage, Id sourceRecordId, String objectName) {
        Log_Line__c logLine = new Log_Line__c(
            Date__c = Datetime.now(),
            Log__c = log.Id,
            Error_Message__c = errorMessage,
            Record_id__c = sourceRecordId,
            Object_Name__c = objectName
        );

        this.logLines.add(logLine);
    }

    // Method to be used from a catch(Exception) statement
    /**
     * @description Adds an error log line from a caught exception and truncates values to field lengths.
     * @param e Exception captured during execution.
     */
    global void submitErrorLog(Exception e) {
        Log_Line__c logLine = new Log_Line__c(
            Date__c = Datetime.now(),
            Log__c = log.Id,
            Error_Message__c = e.getMessage(),
            Error_Stacktrace__c = e.getStackTraceString()
        );

        // Check that the Error_Message__c value doesn't exceed the max length
        Integer errorMessageMaxLength = Schema.SObjectType.Log_Line__c.fields.Error_Message__c.getLength();
        if (
            !String.isBlank(logLine.Error_Message__c) &&
            logLine.Error_Message__c.length() > errorMessageMaxLength
        ) {
            logLine.Error_Message__c = logLine.Error_Message__c.substring(
                0,
                errorMessageMaxLength - 1
            );
        }

        // Check that the Error_Stacktrace__c value doesn't exceed the max length
        Integer errorStackTraceMaxLength = Schema.SObjectType.Log_Line__c.fields.Error_Stacktrace__c.getLength();
        if (
            !String.isBlank(logLine.Error_Stacktrace__c) &&
            logLine.Error_Stacktrace__c.length() > errorStackTraceMaxLength
        ) {
            logLine.Error_Stacktrace__c = logLine.Error_Stacktrace__c.substring(
                0,
                errorStackTraceMaxLength - 1
            );
        }

        this.logLines.add(logLine);
    }

    // Method to be used when all the processes to monitor has been completed
    /**
     * @description Persists pending log lines and updates end-date information on the parent log.
     */
    global void commitLogLines() {
        // If some LogLine records have been submitted, insert those
        if (!logLines.isEmpty()) {
            List<Database.SaveResult> logLineSaveResults = Database.insert(logLines, false);
            for (Database.SaveResult saveResult : logLineSaveResults) {
                if (!saveResult.isSuccess()) {
                    continue;
                }
            }
        }
        // Update the End Date of the batchLog
        this.log.End_Date__c = System.now();

        // Update the Log record
        Database.SaveResult[] logUpdateResults = Database.update(new List<Log__c>{ log }, false);
        if (!logUpdateResults.isEmpty() && !logUpdateResults[0].isSuccess()) {
            return;
        }
    }

    /**
     * @description Raised when the initial log record cannot be created.
     */
    global class LogInitializationException extends Exception {
    }
}
