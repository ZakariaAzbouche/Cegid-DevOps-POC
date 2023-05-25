public class QuoteGetMandatSepa_wrapper {
	@AuraEnabled public boolean success;
	@AuraEnabled public cls_mandates[] mandates;
	public class cls_mandates {
		@AuraEnabled public String info_nro_Item;	
		@AuraEnabled public String ICS;	
		@AuraEnabled public String Tiers;	
		@AuraEnabled public String RUM;	          
		@AuraEnabled public String CLEID;	
		@AuraEnabled public String LIBELLE;	
		@AuraEnabled public String BIC;	
		@AuraEnabled public String IBAN;	
		@AuraEnabled public String Paiement;	
		@AuraEnabled public String Type;	
		@AuraEnabled public String datemvtenvoi;	
		@AuraEnabled public String datesignature;	
		@AuraEnabled public String datemvtrejet;	
		@AuraEnabled public String statut;			
		@AuraEnabled public String bankName;
		@AuraEnabled public String bankCity;	
		@AuraEnabled public String nbrItem;	
		@AuraEnabled public String nbrItemTotal;	
    }

    public static QuoteGetMandatSepa_wrapper parse(String json) {
        return (QuoteGetMandatSepa_wrapper) System.JSON.deserialize(json, QuoteGetMandatSepa_wrapper.class);
}


}