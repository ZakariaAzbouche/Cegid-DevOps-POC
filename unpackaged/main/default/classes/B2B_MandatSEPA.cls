public class B2B_MandatSEPA {
    public String strBIC {get;set;}
    public String strNewBIC {get;set;}
    public String strIBAN {get;set;}
    public String strnewIBAN {get;set;}

    public B2B_MandatSEPA(ApexPages.StandardController controller) {
        Id orderId = (Id)controller.getId();

        Order order = [SELECT Id, BIC__c, New_BIC__c, IBAN__c, New_IBAN__c FROM Order WHERE Id = :orderId];

        Blob cryptoKey = Crypto.generateAesKey(256);  
        
        strBIC = '';
        strNewBIC = '';
        strIBAN = '';
        strnewIBAN = '';

        Blob dataBIC = String.isNotBlank(order.BIC__c) ? Blob.valueOf(order.BIC__c) : null;
        Blob dataNewBIC = String.isNotBlank(order.New_BIC__c) ? Blob.valueOf(order.New_BIC__c) : null;
        Blob dataIBAN = String.isNotBlank(order.IBAN__c) ? Blob.valueOf(order.IBAN__c) : null;
        Blob dataNewIBAN = String.isNotBlank(order.New_IBAN__c) ? Blob.valueOf(order.New_IBAN__c) : null;

        if(dataBIC != null){
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, dataBIC);        
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
            strBIC = decryptedData.toString();
        }else{
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, dataNewBIC);        
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
            strNewBIC = decryptedData.toString();
        }

        if(dataIBAN != null){
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, dataIBAN);        
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
            strIBAN = decryptedData.toString();
        }else{
            Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, dataNewIBAN);        
            Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encryptedData);
            strnewIBAN = decryptedData.toString();
        }
    }
}