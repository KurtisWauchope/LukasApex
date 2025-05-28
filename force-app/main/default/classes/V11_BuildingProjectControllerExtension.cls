public class V11_BuildingProjectControllerExtension {
    
    private final BuildingProject__c bp;
    public  Attachment  file        { set; get; }
    public  Boolean     hasPicture  { set; get; }
    private String      parentId    { set; get; }
    
    
    public V11_BuildingProjectControllerExtension(ApexPages.StandardController stdController) {
    
        this.bp = (BuildingProject__c)stdController.getRecord();
        
        this.parentId       = String.escapeSingleQuotes(stdController.getId());
        this.hasPicture     = false;

        List<Attachment> attList = new List<Attachment>();
        if (Schema.sObjectType.Attachment.fields.Id.isAccessible() 
            && Schema.sObjectType.Attachment.fields.ParentId.isAccessible()
            && Schema.sObjectType.Attachment.fields.Name.isAccessible()
            && Schema.sObjectType.Attachment.fields.ContentType.isAccessible()
            && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()) {        
            attList = [ Select ParentId, Name, Id, ContentType, BodyLength 
                                        From Attachment 
                                        where ParentId =: this.parentId and name = 'Contact Picture' limit 1];
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
        } /* */
        
        if( attList.size() > 0 ){
            this.file       = attList.get( 0 );
            this.file.Body  = Blob.valueOf('AuxString');
            this.hasPicture = true;
        }

        String fileName = this.bp.ComarchBuildingProjectNumber__c +	' - ' + this.bp.Name +'.pdf';
        String fileNameEncoded = EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+','%20');
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileNameEncoded);
    }

   /* @AuraEnabled(cacheable=false)
    public static void syncBPToComarch(Id BuildingProjectId){
        V11_ComarchNumberManager.setNumberBP(BuildingProjectId);
        V11_CreateOutboundCall.insertBuildingProject(BuildingProjectId,'create');
    }*/
    
    
    public List<Contact> getBidders(){
        return [
            SELECT ContactInfo__c,Account.name,salutation,FirstName,LastName,Account.BillingStreet,Account.BillingPostalCode,Account.BillingCity,Account.BillingCountry,Phone,MobilePhone,Email
            FROM Contact
            Where Id in (
            SELECT ContactPerson__c
            FROM Bidder__c
            WHERE Building_Project__c = :bp.Id AND Interest__c = 'Interested' AND RecordType.DeveloperName = 'Raico_bidder')
        ];
    }
    
    public List<Systems__c> getSystems(){
         return[
     
             SELECT SystemType__c, SystemSize__c, SystemUnit__c, BuildingProjectSystem__c 
             FROM Systems__c 
             WHERE BuildingProjectSystem__r.Id =: bp.Id
         
         ];
    }

    public List<Account> getArchs(){
             return[
                 SELECT Name, BillingStreet, BillingPostalCode, BillingCity 
                 FROM Account
                 Where Id in (
                 SELECT Account__c
                 FROM AccountBuildingProjectRelation__c
                 WHERE BuildingProject__c = :bp.Id AND Role__c = 'Architect')
             
             ];
        }
    public List<Account> getGC(){
             return[
                 SELECT Name, BillingStreet, BillingPostalCode, BillingCity 
                 FROM Account
                 Where Id in (
                 SELECT Account__c
                 FROM AccountBuildingProjectRelation__c
                 WHERE BuildingProject__c = :bp.Id AND Role__c = 'General Constructor' )
             
             ];
        }
        
        public List<Account> getPlanner(){
             return[
                 SELECT Name, BillingStreet, BillingPostalCode, BillingCity 
                 FROM Account
                 Where Id in (
                 SELECT Account__c
                 FROM AccountBuildingProjectRelation__c
                 WHERE BuildingProject__c = :bp.Id AND Role__c = 'Planner of cladding' )
             
             ];
        }
        
        public List<Account> getBAuth(){
             return[
                 SELECT Name, BillingStreet, BillingPostalCode, BillingCity 
                 FROM Account
                 Where Id in (
                 SELECT Account__c
                 FROM AccountBuildingProjectRelation__c
                 WHERE BuildingProject__c = :bp.Id AND Role__c = 'Builder/ Awarding Office' )
             
             ];
        }
        
    public List<User> getProjectSalesRep(){
             return[
                 SELECT Name, Phone, Email 
                 FROM User
                 Where Id in (
                 SELECT User__c
                 FROM Building_Project_Team__c
                 WHERE  BuildingProject__c =: bp.Id AND Role__c = 'Project Sales')
             
             ];
        }

}