public class LCC001_SyncWithZuora {
    @AuraEnabled
    public static String makeCallout(String recordId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('x-client_id','c10da38c14724a398f3172c1bafb0387');
        request.setHeader('x-client_secret','472310ac9740406B92CE010fE5D8eCD4');
        request.setEndpoint('http://p-api-sync.de-c1.eu1.cloudhub.io/api/p-api-sync/v1/products/'+recordId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200) {
            // Deserializes the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return 'Synchronized with love <3 by Mulesoft!';
        }
        return '';
    }

}