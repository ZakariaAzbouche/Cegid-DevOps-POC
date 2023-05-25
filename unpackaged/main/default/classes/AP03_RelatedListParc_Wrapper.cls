/***
* @author      Comforth - SRA
* @date        08/06/2020
* @description Wrapper Class for AP03_RelatedListParc
***/
public class AP03_RelatedListParc_Wrapper {

	public class Niveau_de_service {
		@AuraEnabled public String link{get;set;}
		@AuraEnabled public String value{get;set;}
	}
    
    public class Entitee_Cegid_qui_a_souscrit_le_contrat {
		@AuraEnabled public String link{get;set;}
		@AuraEnabled public String value{get;set;}
	}
    
    public class numero_de_souscription {
		@AuraEnabled public String link{get;set;}
		@AuraEnabled public String value{get;set;}
	}

	@AuraEnabled public String Code_Article_SIC{get;set;}
	@AuraEnabled public String Nom_du_produit{get;set;}
	@AuraEnabled public String Sous_contrat{get;set;}
	@AuraEnabled public Niveau_de_service Niveau_de_service{get;set;}
    @AuraEnabled public numero_de_souscription numero_de_souscription{get;set;}
    @AuraEnabled public Entitee_Cegid_qui_a_souscrit_le_contrat Entitee_Cegid_qui_a_souscrit_le_contrat{get;set;}
	@AuraEnabled public Object code_seria{get;set;}
	@AuraEnabled public String Version_en_cours{get;set;}
	@AuraEnabled public String Quantite{get;set;}
	@AuraEnabled public String Numero_de_serie{get;set;}
	@AuraEnabled public String etat{get;set;}
	@AuraEnabled public String etat_en_service{get;set;}
	@AuraEnabled public String statut{get;set;}
	//@AuraEnabled public Niveau_de_service numero_de_souscription{get;set;}
	@AuraEnabled public String activitee_niveau_1{get;set;}
	@AuraEnabled public String Hebergee{get;set;}
	//@AuraEnabled public String Entitee_Cegid_qui_a_souscrit_le_contrat_V2{get;set;}
	@AuraEnabled public String Date_debut_de_contrat{get;set;}
	@AuraEnabled public String Date_fin_de_contrat{get;set;}

	@AuraEnabled
	public static AP03_RelatedListParc_Wrapper parse(String json) {
        //String json = RestContext.request.requestBody.toString();
		return (AP03_RelatedListParc_Wrapper) System.JSON.deserialize(json, AP03_RelatedListParc_Wrapper.class);
	}
}