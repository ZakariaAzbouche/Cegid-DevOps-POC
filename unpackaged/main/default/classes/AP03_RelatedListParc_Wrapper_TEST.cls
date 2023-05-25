/***
* @author      Comforth - SRA
* @date        08/06/2020
* @description Test class for wrapper class for AP03_RelatedListParc_Wrapper
***/
@IsTest
public class AP03_RelatedListParc_Wrapper_TEST {
	
	static testMethod void testParse() {
		String json = '{'+
		'        \"Code_Article_SIC\": \"P500569903\",'+
		'        \"Nom_du_produit\": \"Quadra ETEBAC\",'+
		'        \"Sous_contrat\": \"true\",'+
		'        \"Niveau_de_service\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/sn_customerservice_level_agreement/c1377e91dbd94f006968f9c41d961968\",'+
		'            \"value\": \"c1377e91dbd94f006968f9c41d961968\"'+
		'        },'+
		'        \"code_seria\": null,'+
		'        \"Version_en_cours\": \"\",'+
		'        \"Quantite\": \"\",'+
		'        \"Numero_de_serie\": \"\",'+
		'        \"etat\": \"true\",'+
		'        \"etat_en_service\": \"\",'+
		'        \"statut\": \"\",'+
		'        \"numero_de_souscription\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/ast_contract/0818857edb5d2f442d092dcb0b96196b\",'+
		'            \"value\": \"0818857edb5d2f442d092dcb0b96196b\"'+
		'        },'+
		'        \"activitee_niveau_1\": \"\",'+
		'        \"Hebergee\": \"false\",'+
		//'        \"Entitee_Cegid_qui_a_souscrit_le_contrat\": \"tesing\",'+
		'        \"Date_debut_de_contrat\": \"2010-01-01\",'+
		'        \"Date_fin_de_contrat\": \"2099-12-31\"'+
		'    }';
		AP03_RelatedListParc_Wrapper obj = AP03_RelatedListParc_Wrapper.parse(json);
		System.assert(obj != null);
        AP03_RelatedListParc_Wrapper testWrapper = new AP03_RelatedListParc_Wrapper();
        AP03_RelatedListParc_Wrapper.Niveau_de_service niveauService = new AP03_RelatedListParc_Wrapper.Niveau_de_service();
        niveauService.link='testLink';
        niveauService.value='1234567';
        
        AP03_RelatedListParc_Wrapper.numero_de_souscription niveauSouscription = new AP03_RelatedListParc_Wrapper.numero_de_souscription();
        niveauSouscription.link='testLink';
        niveauSouscription.value='1234567';
        
        testWrapper.Code_Article_SIC ='P500569903';
        testWrapper.Nom_du_produit ='Quadra';
        testWrapper.Sous_contrat ='true';
        testWrapper.code_seria ='123456';
        testWrapper.Version_en_cours ='1';
        testWrapper.Quantite ='1';
        testWrapper.Numero_de_serie ='1';
        testWrapper.etat ='true';
        testWrapper.etat_en_service ='true';
        testWrapper.statut ='true';
        testWrapper.Hebergee ='true';
        testWrapper.activitee_niveau_1 ='1';
        testWrapper.Entitee_Cegid_qui_a_souscrit_le_contrat =null;
        testWrapper.Date_debut_de_contrat ='2010-01-01';
        testWrapper.Date_fin_de_contrat ='2010-01-01';
	}
}