public class V11_PostalCodeAssignment {
    
    List<Postal_Code_Range__c> ranges;
    
    
    public V11_PostalCodeAssignment(){
        ranges = [select PostalCodeAssignment__r.Role__c, PostalCodeAssignment__r.User__c, Postal_Code_Start__c,PostalCodeEnd__c,PostalCodeAssignment__r.Country__c, Post_Code_Prefix__c from Postal_Code_Range__c];
    }
    
    public List<Postal_Code_Range__c> getUserAndRole(String postCode, String countryCode)
    {
        Set<String> rolesFound = new Set<String>();
        List<Postal_Code_Range__c> resultRanges = new List<Postal_Code_Range__c>();
        
        for(Postal_Code_Range__c range : ranges){
            if(range.PostalCodeAssignment__r.Country__c == countryCode){
                if(!rolesFound.contains(range.PostalCodeAssignment__r.Role__c)){
                    
                        // Check if the postal code matches for UK (use string prefix matching)
                        if (countryCode == 'UK'|| countryCode == 'GB') {
                            String prefixUK = getCharactersBeforeFirstDigit(postCode);
                            
                            if(String.valueOf(range.Post_Code_Prefix__c) == prefixuk){
                                resultRanges.add(range);
                                rolesFound.add(range.PostalCodeAssignment__r.Role__c);
                            }
                        }
                        // otherwise if normal integer post codes, not like in the UK, use the post code ranges.
                        else{
                        // Convert postCode to Integer since Postal_Code_Start__c and PostalCodeEnd__c are Integer types
                Integer postalCodeInt = Integer.valueOf(postCode); 

                            if(range.Postal_Code_Start__c <= postalCodeInt && range.PostalCodeEnd__c>= postalCodeInt){
                                resultRanges.add(range);
                                rolesFound.add(range.PostalCodeAssignment__r.Role__c);
                            }
                        }
                                        
                }
                
                
            }
        }
        return resultRanges;
    }
    
    public static String getCharactersBeforeFirstDigit(String input) {
        // Remove any leading and trailing whitespace
                 
        Pattern patterns = Pattern.compile('^[A-Z]+');
        Matcher matchers = patterns.matcher(input.trim());
        String sub;
        if(matchers.find()){
        	sub = matchers.group(0);
            
        }   
        return sub;
    }
    
  
    
    public static void setOwnerAndAccountTeam(List<Id> accountIds)
    {
        V11_batchSetAccountTeam batchhandler = new V11_batchSetAccountTeam(accountIds);
        database.executeBatch(batchhandler,200);
    }
    public static void setOwnerContact (List<Id> contacts)
    {
        V11_batchSetContactOwner batchhandler = new V11_batchSetContactOwner(contacts);
        database.executeBatch(batchhandler,200);
    }
    
    
}