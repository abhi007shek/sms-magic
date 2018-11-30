public with sharing class SendSMSController{
    private List<Contact>contactsList;//List of contacts
    public List<ContactWrapper>contactWrapperList{get;set;}
    private static final Integer PAGE_SIZE = 10;
    public String selectedAccount{get;set;}
    public String smsText{get;set;}
    public String selectedContactId{get;set;}
    public list<String>accountIdList;
    public String pageMsg{get;set;}
    
    //pagination information
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    
    public class ContactWrapper{//Wrapper Class for Display Contacts and get the selected contacts
        public Boolean sendSms{get;set;}
        public Contact contactObj{get;set;}
         public ContactWrapper(Contact c, Boolean s){
            this.contactObj=c;
            this.sendSms=s;
        }
        
    }
   
    public SendSMSController(Apexpages.Standardsetcontroller cont){
        selectedContactId='';
        selectedAccount='';
        smsText='';
        pageMsg='';
        accountIdList = new List<String>();
        contactWrapperList = new List<ContactWrapper>();
        this.page = 1;
        accountIdList = ApexPages.currentpage().getparameters().get('accId').split(',');
        getContacts();
       
    }
    
    public void sendSMS(){
       List<sms__c>smsList = new List<sms__c>(); 
       for(String conId:selectedContactId.split(',')){
           sms__c sms = new sms__c();
           sms.Contact__c =conId;
           sms.SMS_Text__c = smsText;
           smsList.add(sms); 
       }
       Integer sucessCount=0;
       Integer failedCount=0;
       if(smsList.size()>0){
       
           Database.SaveResult[] lsr = Database.insert(smsList,false);
           // Iterate through each returned result
                for (Database.SaveResult sr : lsr) {
                    if (sr.isSuccess()) {
                       sucessCount++;
                    }
                    else {
                   failedCount++;
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                       }
          pageMsg=sucessCount+' SMS Send successfully. ';
         if(failedCount!=0){
         pageMsg = pageMsg +failedCount+' Unable to send SMS.';
     
         }
                       
    }
     public void doNext(){
        
        if(getHasNext()){
            this.page++;
            getContacts();
        }

    }
    
    
    /*
    *   advance to previous page
    */
    public void doPrevious(){
        
        if(getHasPrevious()){
            this.page--;
            getContacts();
        }
                
    }
    
    /*
    *   returns whether the previous page exists
    */
    public Boolean getHasPrevious(){
        if(this.page>1){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*
    *   returns whether the next page exists
    */
    public Boolean getHasNext(){
        if(this.page<this.totalPages){
            return true;
        }
        else{
            return false;
        }
    }
    
    
    
    /*
    *   return current page of records
    */
    public void getContacts(){
        
        //calculate range of records for capture
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        
        //clear container for records displayed
        this.contactWrapperList.clear();
        
        for(Contact c : [SELECT Id, Name, Phone,Account.Name,AccountId FROM Contact where Account.Name!='' AND AccountId IN: accountIdList ORDER BY Account.Name]){
        
            //capture records within the target range
            if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){   
           
                this.contactWrapperList.add( new ContactWrapper(c, false) );
            }
            
            //count the total number of records
            this.totalRecords++;
        
        }
        
        
        //calculate total pages
        Decimal pages = Decimal.valueOf(this.totalRecords);
        pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
        this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
        
        this.startIdx++;
        
        
        //adjust end index
        if(this.endIdx>this.totalRecords){
            this.endIdx = this.totalRecords;
        }
     
    }
  
        
}