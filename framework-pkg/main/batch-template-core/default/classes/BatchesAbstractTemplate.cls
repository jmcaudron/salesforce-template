/**
 * @description This abstract template class is extended by classes which are batches checkbox checked take the address of their related account. Abstract batch template that centralizes execution flow, DML handling,
 * logging, and report generation for inheriting batch classes.
 */
global inherited sharing abstract class BatchesAbstractTemplate implements Database.Batchable<SObject>, Schedulable, Database.Stateful, Database.AllowsCallouts {
    global String query; // The Query used in the start() method, must be setted in the constructor of the Batch Class
    global String batchName; // The name of the Batch Class
    global Map<String, String> batchParameters; // The parameters that have been given to the batch, optional

    global LogHandler logHandler; // handle the batch execution issues management

    // DML Operations Counters
    global Integer nbRequestedRecords; // The number of records retrieved by the query
    global Integer nbProcessingRecord; // The number of records that have to be processed
    global Integer nbSuccess; // The number of records successfully processed (Modify on mail report Number of success)
    global Integer nbErrors; // The number of errors handled

    // Used to checks that every instance of Execute() method has correctly ended.
    global Integer nbExecuteStart; // The number of Execute() method begginning
    global Integer nbExecuteEnd; // The number of Execute() method ending

    // DML Statements Lists
    global List<SObject> toBeInsertedList; // The list used for Insert DML queries
    global List<SObject> toBeUpdatedList; // The list used for Update DML queries
    global List<SObject> toBeDeletedList; // The list used for Delete DML queries

    //mangement of heapsize
    global Integer limitHeapSizePercent;

    /*
     * Needs to be Overridden when the batch has to be scheduled,
     * must contain "Database.execute(new MyBatch()) in its body"
     */
    /**
     * @description Scheduling entry point for inheriting batches.
     * @param sc Scheduler context provided by the platform.
     */
    global virtual void execute(SchedulableContext sc) {
    }

    /**
     * @description Initializes runtime counters, parameter storage, and heap usage threshold.
     */
    global BatchesAbstractTemplate() {
        // Retrieving the Name of the Batch
        batchName = String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));

        // Initializing the counters
        nbRequestedRecords = 0;
        nbProcessingRecord = 0;
        nbSuccess = 0;
        nbErrors = 0;
        nbExecuteStart = 0;
        nbExecuteEnd = 0;

        // Initialize the batch parameters
        batchParameters = new Map<String, String>();

        //initialize the limit of heapsize
        limitHeapSizePercent = 90;
    }

    /**
     * @description Initializes monitoring and returns the query locator for batch execution.
     * @param bc Batch context provided by the platform.
     * @return Query locator built from the configured batch query.
     */
    global virtual Database.QueryLocator start(Database.BatchableContext bc) {
        // Initiating the monitoring process
        logHandler = new LogHandler(batchName, 'Apex Batch');

        logHandler.log.Query__c = query;

        return Database.getQueryLocator(query);
    }

    /**
     * @description Main batch execution flow that processes records and performs DML operations.
     * @param bc Batch context provided by the platform.
     * @param objects Current scope of records to process.
     */
    global void execute(Database.BatchableContext bc, list<SObject> objects) {
        // Increment the number of execute() beginning
        nbExecuteStart++;

        // Initialize the DML operations Lists
        initializeLists();

        // Retrieve the number of requested records
        nbRequestedRecords += objects.size();

        // Try / Catch block to handle Exceptions which are non directly related to DML Operations
        try {
            checkLimits();
            // Process records
            processObjects(objects);

            // byPass the specified Triggers
            bypassTriggers();

            // Launch DML Operations
            handleDMLOperations();

            // Execute Post-DML logic
            afterDML();
        } catch (HeapSizeException e) {
            logHandler.submitErrorLog(e);
            nbErrors++;
            finish(bc);
            System.abortJob(bc.getJobId());
        } catch (Exception e) {
            logHandler.submitErrorLog(e);
            nbErrors++;
        }

        // Increment the number of Execute() ending
        nbExecuteEnd++;
    }

    /**
     * @description Validates heap usage and aborts processing when threshold is exceeded.
     */
    global void checkLimits() {
        if (Limits.getHeapSize() > ((Limits.getLimitHeapSize() * limitHeapSizePercent) / 100)) {
            throw new HeapSizeException('the heapsize limit is exceeded');
        }
    }

    /**
     * @description Reinitializes DML staging lists before each execute scope.
     */
    global void initializeLists() {
        toBeInsertedList = new List<SObject>();
        toBeUpdatedList = new List<SObject>();
        toBeDeletedList = new List<SObject>();
    }

    // Processes the requested sObjects and sets the differents sObjects Lists
    /**
     * @description Transforms queried records into insert/update/delete staging lists.
     * @param objects Current scope of records from the batch query.
     */
    global abstract void processObjects(List<SObject> objects);

    // Can be overriden to active set bypasses during DML Operations
    /**
     * @description Optional hook to set trigger bypass flags before DML operations.
     */
    global virtual void bypassTriggers() {
    }

    // Launch the DML Operations
    /**
     * @description Executes staged insert, update, and delete operations in order.
     */
    global void handleDMLOperations() {
        // Insert records in toBeInsertedList
        insertObjects();

        // Update records in toBeUpdatedList
        updateObjects();

        // Delete records in tobeDeletedList
        deleteObjects();
    }

    /*
     * This method simulates the behaviour of the standard DML statement Database.upsert()
     * since this statement can't be used by providing a list of generic SObject parameter
     * This method should be called from the processObjects() method
     */
    /**
     * @description Performs generic upsert behavior by splitting records into insert/update
     * buckets and logging duplicate external id scenarios.
     * @param recordToUpsertList Records to upsert.
     * @param objectType API name of the target object.
     * @param externalIdField External id field used as match key.
     */
    global void upsertObjects(
        List<SObject> recordToUpsertList,
        String objectType,
        Schema.SObjectField externalIdField
    ) {
        Map<String, SObject> externalIdValuesToRecordToUpsertMap = new Map<String, SObject>();
        List<SObject> recordsToUpsertWithDuplicateExternalIdValue = new List<SObject>();

        /*
         * 1st Step : Filter out the records with a duplicate external id value
         * & register a Log Line for each record flagged as duplicate
         */

        String recordFieldValue;
        for (SObject recordToUpsert : recordToUpsertList) {
            recordFieldValue = (String) recordToUpsert.get(externalIdField);
            if (recordFieldValue != null) {
                if (!externalIdValuesToRecordToUpsertMap.containsKey(recordFieldValue)) {
                    // If the map doesn't already contains the external id value, put the current record
                    externalIdValuesToRecordToUpsertMap.put(recordFieldValue, recordToUpsert);
                } else {
                    // If the map does already contain it, put the current record in the duplicate record list
                    recordsToUpsertWithDuplicateExternalIdValue.add(recordToUpsert);
                    // If it hasn't already been done, put also the record that was in the map in the duplicate list & replace it by a null as a placeholder
                    if (externalIdValuesToRecordToUpsertMap.get(recordFieldValue) != null) {
                        recordsToUpsertWithDuplicateExternalIdValue.add(
                            externalIdValuesToRecordToUpsertMap.get(recordFieldValue)
                        );
                        externalIdValuesToRecordToUpsertMap.put(recordFieldValue, null);
                    }
                }
            } else {
                // If the external id field of the record is null, then insert it
                toBeInsertedList.add(recordToUpsert);
            }
        }

        // For each record with a duplicate value, submit a new LogLine about it & remove the duplicate value from the valueToRecord Map
        for (SObject recordWithDuplicateValue : recordsToUpsertWithDuplicateExternalIdValue) {
            // Increment processedRecords & error counters
            nbProcessingRecord++;
            nbErrors++;

            // Submit a logLine for each record with a duplicate external Id value
            logHandler.submitErrorLog(
                'UPSERT FAILED : You tried to upsert multiple ' +
                objectType +
                ' records with the same ' +
                externalIdField +
                ' value : "' +
                recordWithDuplicateValue.get(externalIdField) +
                '"',
                recordWithDuplicateValue.Id,
                objectType
            );

            // Remove the external id value reference from the map
            if (
                externalIdValuesToRecordToUpsertMap.containsKey(
                    (String) recordWithDuplicateValue.get(externalIdField)
                )
            ) {
                externalIdValuesToRecordToUpsertMap.remove(
                    (String) recordWithDuplicateValue.get(externalIdField)
                );
            }
        }

        /*
         * 2nd Step: Query the records using the unique external id values provided,
         * filter out the external id values used by multiple records in database
         * & register a logLine for each external id values flagged as duplicate
         */

        Map<String, SObject> externalIdValueToQueriedRecordMap = new Map<String, SObject>();
        Set<String> duplicateExternalIdValueRetrievedList = new Set<String>();
        Set<String> externalIdValuesToQuerySet = externalIdValuesToRecordToUpsertMap.keySet();
        String query =
            'SELECT ' +
            externalIdField +
            ' FROM ' +
            objectType +
            ' WHERE ' +
            externalIdField +
            ' IN: externalIdValuesToQuerySet';
        if (Test.isRunningTest()) {
            query += ' LIMIT 100';
        }
        List<SObject> retrievedRecordList = Database.query(query);
        String retrievedFieldValue;
        for (SObject retrievedRecord : retrievedRecordList) {
            retrievedFieldValue = (String) retrievedRecord.get(externalIdField);
            if (!externalIdValueToQueriedRecordMap.containsKey(retrievedFieldValue)) {
                // If the map doesn't already contains the external id value, put the current record
                externalIdValueToQueriedRecordMap.put(retrievedFieldValue, retrievedRecord);
            } else {
                if (externalIdValueToQueriedRecordMap.get(retrievedFieldValue) != null) {
                    // If the map does already contain it, put the current external id value in the duplicate value set
                    duplicateExternalIdValueRetrievedList.add(retrievedFieldValue);
                    // Replace the record in the map by a null placeholder
                    externalIdValueToQueriedRecordMap.put(retrievedFieldValue, null);
                }
            }
        }

        // For each duplicate external id value queried, submit a new LogLine about it & remove the null placeholder from the valueToRecord Map
        for (String duplicateExternalIdValueRetrieved : duplicateExternalIdValueRetrievedList) {
            // Increment processedRecords & error counters
            nbProcessingRecord++;
            nbErrors++;

            // Remove the external id value reference from the map
            logHandler.submitErrorLog(
                'UPSERT FAILED : multiple ' +
                objectType +
                ' records were found with the same ' +
                externalIdField +
                ' value : "' +
                duplicateExternalIdValueRetrieved +
                '"',
                null,
                objectType
            );

            // Remove the external id value reference from the map used in both checks
            externalIdValueToQueriedRecordMap.remove(duplicateExternalIdValueRetrieved);
            externalIdValuesToRecordToUpsertMap.remove(duplicateExternalIdValueRetrieved);
        }

        /*
         * 3rd Step: For each record that hasn't been discarded in the 1st or 2nd step,
         * Check if a corresponding record has been queried in the 2nd step
         * If so, then Update the record after having assigned it the id of the found record
         * If not, then Insert it
         */

        String recordToUpsertFieldValue;
        for (
            SObject recordToUpsertWithUniqueExternalIdValue : externalIdValuesToRecordToUpsertMap.values()
        ) {
            recordToUpsertFieldValue = (String) recordToUpsertWithUniqueExternalIdValue.get(
                externalIdField
            );
            if (
                recordToUpsertFieldValue != null &&
                externalIdValueToQueriedRecordMap.containsKey(recordToUpsertFieldValue)
            ) {
                recordToUpsertWithUniqueExternalIdValue.Id = externalIdValueToQueriedRecordMap.get(
                        recordToUpsertFieldValue
                    )
                    .Id;
                toBeUpdatedList.add(recordToUpsertWithUniqueExternalIdValue);
            } else {
                toBeInsertedList.add(recordToUpsertWithUniqueExternalIdValue);
            }
        }

    }

    // Insert the records in toBeInsertedList & manage the SaveResult records
    /**
     * @description Inserts staged records and logs row-level DML errors.
     */
    global void insertObjects() {
        // Check if there are some records to Insert, and that the DML transactions won't exceed the Governor Limits
        if (
            !tobeInsertedList.isEmpty() && logHandler.checkDMLGovernorLimits(tobeInsertedList.size())
        ) {
            // Retrieve the number of records being processed
            nbProcessingRecord += tobeInsertedList.size();

            // Insert Records and retrieve SaveResult[] for error analysis
            List<Database.SaveResult> insertResultList = Database.insert(tobeInsertedList, false);

            if (!insertResultList.isEmpty()) {
                // Iterate through each returned result
                for (Integer i = 0; i < insertResultList.size(); i++) {
                    if (insertResultList[i].isSuccess()) {
                        nbSuccess++;
                    } else {
                        // Operation failed, so get all errors
                        for (Database.Error error : insertResultList[i].getErrors()) {
                            // Increment the error counter & log error
                            nbErrors++;
                            logHandler.submitErrorLog(
                                error.getMessage(),
                                null,
                                String.valueOf(toBeInsertedList[i].getSObjectType())
                            );
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Executes update DML for staged records and allows test override.
     * @param toBeUpdatedList Records to update.
     * @return Save results returned by `Database.update`.
     */
    global virtual List<Database.SaveResult> doUpdate(List<SObject> toBeUpdatedList) {
        return Database.update(toBeUpdatedList, false);
    }

    // Update the records in toBeUpdatedList & manage the SaveResult records
    /**
     * @description Updates staged records and logs row-level DML errors.
     */
    global void updateObjects() {
        // Check if there are some records to Insert, and that the DML transactions won't exceed the Governor Limits
        if (
            !toBeUpdatedList.isEmpty() && logHandler.checkDMLGovernorLimits(toBeUpdatedList.size())
        ) {
            // Retrieve the number of records being processed
            nbProcessingRecord += toBeUpdatedList.size();

            // Insert Records and retrieve SaveResult[] for error analysis
            List<Database.SaveResult> updateResultList = doUpdate(toBeUpdatedList);

            if (!updateResultList.isEmpty()) {
                // Iterate through each returned result
                for (Integer i = 0; i < updateResultList.size(); i++) {
                    if (updateResultList[i].isSuccess()) {
                        nbSuccess++;
                    } else {
                        // Operation failed, so get all errors
                        for (Database.Error error : updateResultList[i].getErrors()) {
                            // Increment the error counter
                            nbErrors++;
                            logHandler.submitErrorLog(
                                error.getMessage(),
                                updateResultList[i].getId(),
                                String.valueOf(toBeUpdatedList[i].getSObjectType())
                            );
                        }
                    }
                }
            }
        }
    }

    // Delete the records in toBeDeletedList & manage the DeleteResult records
    /**
     * @description Deletes staged records and logs row-level DML errors.
     */
    global void deleteObjects() {
        // Check if there are some records to Delete, and that the DML transactions won't exceed the Governor Limits
        if (
            !tobeDeletedList.isEmpty() && logHandler.checkDMLGovernorLimits(tobeDeletedList.size())
        ) {
            nbProcessingRecord += tobeDeletedList.size();

            Database.DeleteResult[] deleteResultList = Database.delete(tobeDeletedList, false);

            // Iterate through each returned result
            for (Integer i = 0; i < deleteResultList.size(); i++) {
                if (deleteResultList[i].isSuccess()) {
                    nbSuccess++;
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error error : deleteResultList[i].getErrors()) {
                        // Increment the error counter
                        nbErrors++;
                        logHandler.submitErrorLog(
                            error.getMessage(),
                            deleteResultList[i].getId(),
                            String.valueOf(tobeDeletedList[i].getSObjectType())
                        );
                    }
                }
            }
        }
    }

    // Can be overriden to handle process to be executed after the DML statement executions
    /**
     * @description Optional hook executed after all DML operations for the scope.
     */
    global virtual void afterDML() {
    }

    // Update batchLog, Insert LogLines & send the batch execution report email
    /**
     * @description Finalizes batch execution by committing logs and generating email report.
     * @param bc Batch context provided by the platform.
     */
    global virtual void finish(Database.BatchableContext bc) {
        updateBatchLog();

        generateBatchReport(logHandler.log);
    }

    /**
     * @description Updates aggregate counters and parameters on the parent log record.
     */
    public void updateBatchLog() {
        // Check that all batch executions have concluded correctly
        if (nbExecuteStart != nbExecuteEnd) {
            logHandler.submitErrorLog(
                'LimitException: LimitException occured limit exceeded',
                null,
                null
            );
            nbErrors++;
        }

        // If some parameters has been given, add them to the batchLog
        if (!batchParameters.isEmpty()) {
            String stringifiedParameters;
            for (String parameter : batchParameters.keySet()) {
                if (stringifiedParameters != null) {
                    stringifiedParameters +=
                        '\n' +
                        parameter +
                        ' : ' +
                        batchParameters.get(parameter);
                } else {
                    stringifiedParameters = parameter + ' : ' + batchParameters.get(parameter);
                }
            }
            logHandler.log.Parameters__c = stringifiedParameters;
        }

        // Update batch log record with DML counters & query
        logHandler.log.Query__c = query;
        logHandler.log.Queried_Records_Number__c = nbRequestedRecords;
        logHandler.log.DML_Process_Number__c = nbProcessingRecord;
        logHandler.log.Success_Number__c = nbSuccess;
        logHandler.log.Error_Number__c = nbErrors;

        logHandler.commitLogLines();
    }

    /**
     * @description Sends an execution report email to members of the configured public group.
     * @param log Log record used as merge context for the email template.
     */
    public static void generateBatchReport(Log__c log) {
        if (log == null) {
            return;
        }
        List<EmailTemplate> templates = [
            SELECT Id, Name
            FROM EmailTemplate
            WHERE DeveloperName = :'BatchFrameworkAppReportTemplate'
            LIMIT 1
        ];

        if (templates.isEmpty()) {
            return;
        }
        EmailTemplate template = templates[0];

        List<User> recipientList = [
            SELECT id, Email
            FROM User
            WHERE
                Id IN (
                    SELECT UserOrGroupId
                    FROM GroupMember
                    WHERE Group.name = :'GroupToSendBatchReport'
                )
        ];

        if (recipientList.isEmpty()) {
            return;
        }

        List<Messaging.SingleEmailMessage> emailToSendList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage emailToSend;
        for (User recipient : recipientList) {
            emailToSend = Messaging.renderStoredEmailTemplate(template.Id, recipient.id, log.Id);
            emailToSend.setSaveAsActivity(false);
            emailToSend.setTargetObjectId(recipient.Id);
            emailToSend.setSenderDisplayName('Batch Automated Process');
            emailToSendList.add(emailToSend);
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail(emailToSendList);
        }
    }

    /**
     * @description Raised when heap size threshold is exceeded during execution.
     */
    public class HeapSizeException extends Exception {
    }
}
