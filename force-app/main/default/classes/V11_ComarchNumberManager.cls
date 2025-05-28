public class V11_ComarchNumberManager {

    /*public static void setNumberBP(Id Id){
        BuildingProject__c bp = [SELECT Id,ComarchBuildingProjectNumber__c FROM BuildingProject__c WHERE Id=:Id];

        if(bp.ComarchBuildingProjectNumber__c ==''||bp.ComarchBuildingProjectNumber__c == null){
            bp.ComarchBuildingProjectNumber__c = getNumber('Building Project');
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            Database.Update(bp,dml);
        }

    }
    public static void setNumberAccount(Id Id){
        Account acc = [SELECT Id,ComarchAccountNumber__c FROM Account WHERE Id=:Id];

        if(acc.ComarchAccountNumber__c ==''||acc.ComarchAccountNumber__c == null){
            acc.ComarchAccountNumber__c = getNumber('Account');
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            Database.Update(acc,dml);
        }

    }
    public static void setNumberContact(Id Id){
        Contact c = [SELECT Id,ExternalComarchContactId__c FROM Contact WHERE Id=:Id];

        if(c.ExternalComarchContactId__c ==''||c.ExternalComarchContactId__c == null){
            c.ExternalComarchContactId__c = getNumber('Contact');
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.allowSave = true;
            Database.Update(c,dml);
        }
    }*/

    public static string getNumber(string objectType){

        string comarchNumber;
        String newNumber;
        Comarch_Number__c cNumberObj = [SELECT Id,Comarch_Number_Prefix__c,Comarch_Number__c FROM Comarch_Number__c WHERE Object__c =:objectType FOR UPDATE];
        if(cNumberObj.Comarch_Number_Prefix__c != null){
            comarchNumber = cNumberObj.Comarch_Number_Prefix__c+cNumberObj.Comarch_Number__c;
        }else{
            comarchNumber =cNumberObj.Comarch_Number__c;
        }
        
        Integer i = Integer.valueOf(cNumberObj.Comarch_Number__c);
        i++;
        newNumber = String.valueOf(i);
        while(newNumber.length()<8){
            newNumber = '0'+newNumber;
        }
        cNumberObj.Comarch_Number__c = newNumber;

        Update cNumberObj;
        return comarchNumber;    



    }

}