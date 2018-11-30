@IsTest
private class SendSMSController_Test{
    static testMethod void sucessTest() {
      Account acc = new Account();
      acc.Name='Abhishek';
      insert acc;
      Contact c = new Contact();
      c.lastname='Verma';
      c.Phone='9167467256';
      c.accountid=acc.id;
      insert c;
      Contact c1 = new Contact();
      c1.lastname='Verma';
      c1.Phone='9187467256';
      c1.accountid=acc.id;
      insert c1;
      
      Test.startTest();

      ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(new List<Account>());
      
      PageReference pageRef = Page.Send_SMS;
        pageRef.getParameters().put('accId', String.valueOf(acc.Id));
        Test.setCurrentPage(pageRef);
    
      SendSMSController ext = new SendSMSController(stdSetController);
      ext.selectedContactId =c.id+','+c1.id;
      ext.smsText='test';
      ext.page=2;
      ext.totalPages=10;
      ext.doNext();
      ext.doPrevious();
      ext.page=0;
      ext.totalPages=0;
     ext.doNext();
      ext.doPrevious();
      
      //ext.getHasPrevious();
      //ext.getHasNext();
     
      ext.sendSMS();
       ext.smsText='';
      ext.sendSMS();
 Test.stopTest();
      
     }
static testMethod void failTest() {
     
      
     }
}