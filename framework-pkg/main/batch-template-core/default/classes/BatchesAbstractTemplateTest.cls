@isTest
/**
 * @description This Test Class has the purpose of providing test coverage & asserting changes on Log & LogLine records.Test implementation of the abstract batch template to validate
 * logging behavior for insert/update/upsert/delete failures.
 */
public class BatchesAbstractTemplateTest extends BatchesAbstractTemplate {
  /*
   * This Test batch has the purpose of covering all the situations
  * where a LogLine record is generated in BatchesAbstractTemplate.
   */
  /**
   * @description Builds a test batch scoped to a single user record.
   * @param userId User id used to build the batch query.
   */
  public BatchesAbstractTemplateTest(Id userId) {
    super();

    batchParameters.put('userId', userId);

    query = 'SELECT Id ' + 'FROM User ' + 'WHERE Id = \'' + userId + '\'';
  }

  /**
   * @description Helper to execute this test batch.
   */
  public static void run() {
    Database.executeBatch(
      new BatchesAbstractTemplateTest(UserInfo.getUserId())
    );
  }

  /**
   * @description Builds failure scenarios to exercise logging paths.
   * @param objects Batch scope records (unused in this test implementation).
   */
  public override void processObjects(List<SObject> objects) {
    nbExecuteStart++;

    User userTestUpdateFailure = new User(
      Id = UserInfo.getUserId(),
      ProfileId = null
    );

    // Cause an Insert & an Update failure (Both records are missing mandatory information)
    upsertObjects(
      new List<User>{ new User(), userTestUpdateFailure },
      'User',
      User.fields.Id
    );

    // Cause an Upsert failure (We can't upsert two records with the same field value at once)
    upsertObjects(
      new List<User>{ userTestUpdateFailure, userTestUpdateFailure },
      'User',
      User.fields.Id
    );

    // Cause an Upsert failure (We can't upsert a record when there is two or more records with the same field value in database)
    upsertObjects(
      new List<User>{ new User(DefaultGroupNotificationFrequency = 'N') },
      'User',
      User.fields.DefaultGroupNotificationFrequency
    );

    // Cause a Delete failure (We can't delete a user record in APEX)
    toBeDeletedList.add(new User(Id = UserInfo.getUserId()));
  }

  /**
   * @description Verifies batch execution updates counters and creates expected log lines.
   */
  @IsTest
  static void testBatchExecution() {
    Test.startTest();

    BatchesAbstractTemplateTest.run();

    Test.stopTest();

    Log__c logToAssert = [
      SELECT
        Id,
        Parameters__c,
        Queried_Records_Number__c,
        DML_Process_Number__c,
        Success_Number__c,
        Error_Number__c
      FROM Log__c
    ];

    System.assertEquals(
      'userId : ' + UserInfo.getUserId(),
      logToAssert.Parameters__c
    );
    System.assertEquals(1, logToAssert.Queried_Records_Number__c);
    System.assertEquals(6, logToAssert.DML_Process_Number__c);
    System.assertEquals(0, logToAssert.Success_Number__c);
    System.assertEquals(7, logToAssert.Error_Number__c);

    Integer numberLogLines = [SELECT COUNT() FROM Log_Line__c];

    System.assertEquals(logToAssert.Error_Number__c, numberLogLines);
  }
}
