public class V11_helperClass {
        
    public static string getStringValue(string field){
        if(field == null){
            return '';
        }else{
            return field.escapeXml();
        }
    }

    public static string getPassword(String system_x){
        Auth__mdt cma = [SELECT Auth__c FROM Auth__mdt WHERE Label =:system_x];
        return EncodingUtil.base64Encode(Blob.valueOf(cma.Auth__c)); 
    }

    public static string getEndpoint(String objectType){
        Endpoint__mdt endpoint =[SELECT Endpoint__c FROM Endpoint__mdt WHERE Label =:objectType];
        return endpoint.Endpoint__c;
    }
    public static Boolean getIntegrationStatus(String system_x){
        Integration_Status__mdt cma = [SELECT isActive__c FROM Integration_Status__mdt WHERE Label =:system_x];
        return cma.isActive__c; 
    }

    public static string convertDate(Date date_x){
        string formattedDate = date_x.year()+'-'+date_x.month()+'-'+date_x.day()+'T00:00:00.000+02:00';
        return formattedDate;
    }
    public static List<string> splitName(String name){
        List<string> splittedName = new List<String>();
        Integer length = name.length();
        if(length<35){
            splittedName.add(name.substring(0,length));
        }else if(length<70){
            splittedName.add(name.substring(0, 35));
            splittedName.add(name.substring(35, length));
        }else if(length<105){
        splittedName.add(name.substring(0, 35));
        splittedName.add(name.substring(35, 70));
        splittedName.add(name.substring(70, length));
        }else{
            splittedName.add(name.substring(0, 35));
            splittedName.add(name.substring(35, 70));
            splittedName.add(name.substring(70, 105));
        }
        return splittedName;
    }

    public static void updateBP(List<String> bpIds){

        List<BuildingProject__c> bp = [SELECT Id FROM BuildingProject__c WHERE Id IN:bpIds];

        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.allowSave = true;

        Database.update(bp,dml);
    }


}