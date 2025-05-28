public class V11_sendObjectToEnaio implements Queueable,Database.AllowsCallouts{

    public Account account;
    public BuildingProject__c bp;

    public V11_sendObjectToEnaio(Account account){
        this.account = account;
    }
    public V11_sendObjectToEnaio(BuildingProject__c bp){
        this.bp = bp;
    }
    class PartnerJSON{

            public string vendNr;
            public string vendName;
            public string PartnerType;
            public string vendStreet;
            public string vendCountry;
            public string vendZipCode;
            public string vendCity;
    }

    class BuildingProjectJSON{

            public string projNummer;
            public string projBez;
            public string projBetreuer;
    }

    public void execute(QueueableContext context){

        if(account != null){
            sendPartner(account);
        }else if( bp != null){
            sendBuildingproject(bp);
        }
    }


    public static void sendPartner(Account account) {

        Account accUpdate = [SELECT Id FROM Account WHERE Id =: account.Id];

        PartnerJSON partner = new PartnerJSON();
        partner.vendNr = account.ComarchAccountNumber__c;
        partner.vendName = account.Name;
        partner.PartnerType = 'Kunde';
        partner.vendStreet = account.BillingStreet;
        partner.vendCountry = account.BillingCountry;
        partner.vendZipCode = account.BillingPostalCode;
        partner.vendCity = account.BillingCity;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type','multipart/form-data; boundary="meinTest"' );
        req.setHeader('Content-Disposition','form-data; name="data"' );
        string auth = 'Basic ' + V11_helperClass.getPassword('enaio');
        req.setHeader('Authorization', auth);
        req.setEndpoint(V11_helperClass.getEndpoint('enaioAccount'));
        req.setBodyAsBlob(createRequest(JSOn.serialize(partner)));
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        accUpdate.enaioId__c = res.getBody();

        Update accUpdate;



    }

    public static void sendBuildingproject(BuildingProject__c bp) {
        
        User owner = [SELECT Id,Comarch_External_UserID__c FROM User WHERE Id=:bp.OwnerId];
        BuildingProject__c bpUpdate = [SELECT Id, enaioId__c FROM BuildingProject__c WHERE Id=:bp.Id];
        String bez = V11_helperClass.getStringValue(bp.Name)+', '+V11_helperClass.getStringValue(bp.ProjectAddress__City__s);
        String projName = bez;
        if (bez.length() > 64){
            projName = bez.substring(0, 53);
        }
        
        BuildingProjectJSON bpJSON = new BuildingProjectJSON();
        bpJSON.projNummer = bp.ComarchBuildingProjectNumber__c;
        bpJSON.projBez = projName;
        bpJSON.projBetreuer = owner.Comarch_External_UserID__c;

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type','multipart/form-data; boundary="meinTest"' );
        string auth = 'Basic ' + V11_helperClass.getPassword('enaio');
        req.setHeader('Authorization', auth);
        req.setEndpoint(V11_helperClass.getEndpoint('enaioBuildingProject'));
        req.setBodyAsBlob(createRequest(JSOn.serialize(bpJSON)));
        req.setTimeout(120000);

        Http http = new Http();
        HttpResponse res = new HttpResponse();
        res = http.send(req);
        bpUpdate.enaioId__c = res.getBody();

        Update bpUpdate;



    }

    private static Blob createRequest(String body){

        String boundary = 'meinTest';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="data"";\nContent-Type: application/json;charset=UTF-8';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
        header+=' ';
        headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(Blob.valueOf(body));

        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());

        if(last4Bytes.endsWith('==')) {
            // The '==' sequence indicates that the last group contained only one 8 bit byte
            // 8 digit binary representation of CR is 00001101
            // 8 digit binary representation of LF is 00001010
            // Stitch them together and then from the right split them into 6 bit chunks
            // 0000110100001010 becomes 0000 110100 001010
            // Note the first 4 bits 0000 are identical to the padding used to encode the
            // second original 6 bit chunk, this is handy it means we can hard code the response in
            // The decimal values of 110100 001010 are 52 10
            // The base64 mapping values of 52 10 are 0 K
            // See http://en.wikipedia.org/wiki/Base64 for base64 mapping table
            // Therefore, we replace == with 0K
            // Note: if using \n\n instead of \r\n replace == with 'oK'
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // We have appended the \r\n to the Blob, so leave footer as it is.
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
            } else if(last4Bytes.endsWith('=')) {
            // '=' indicates that encoded data already contained two out of 3x 8 bit bytes
            // We replace final 8 bit byte with a CR e.g. \r
            // 8 digit binary representation of CR is 00001101
            // Ignore the first 2 bits of 00 001101 they have already been used up as padding
            // for the existing data.
            // The Decimal value of 001101 is 13
            // The base64 value of 13 is N
            // Therefore, we replace = with N
            // Note: if using \n instead of \r replace = with 'K'
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            // We have appended the CR e.g. \r, still need to prepend the line feed to the footer
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
            } else {
            // Prepend the CR LF to the footer
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
            }

        return bodyBlob;
    }

}