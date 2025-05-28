public class V11_KeyValueMap {

    public static Map<String,String> createKeyValueMap(String objectType){

        Map<String,String> keyValueMap = new Map<String,String>();
        List<KeyValuePair__c> kvpList = [SELECT Field__c,Key__c,Value__c FROM KeyValuePair__c WHERE Object__c =:objectType];
        for(KeyValuePair__c kvp:kvpList){
            keyValueMap.put(kvp.Field__c + kvp.Key__c, kvp.Value__c);
        }
        return keyValueMap;        
    }

    public static Map<String,String> createInverseKeyValueMap(String objectType){

        Map<String,String> keyValueMap = new Map<String,String>();
        List<KeyValuePair__c> kvpList = [SELECT Field__c,Key__c,Value__c FROM KeyValuePair__c WHERE Object__c =:objectType];
        for(KeyValuePair__c kvp:kvpList){
            keyValueMap.put(kvp.Field__c + kvp.Value__c, kvp.Key__c);
        }
        return keyValueMap;        
    }


}