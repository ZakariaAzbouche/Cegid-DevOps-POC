public with sharing class B2B_GetConnectedUserEmail {
    @InvocableMethod(
        label = 'Method to Extract connected EmailAddress'
        description = 'Method to Extract connected EmailAddress'
    )
    public static List<String> B2B_GetConnectedUserEmail() {
        list<String> listString = new List<String>();
        String email = UserInfo.getUserEmail();
        listString.add(email);
        return listString;
    }
}