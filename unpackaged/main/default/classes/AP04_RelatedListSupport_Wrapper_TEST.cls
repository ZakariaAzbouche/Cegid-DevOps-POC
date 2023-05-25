/***
* @author      Comforth - SRA
* @date        24/07/2020
* @description Test class for wrapper class for AP04_RelatedListSupport_Wrapper
***/
@IsTest
public class AP04_RelatedListSupport_Wrapper_TEST {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '['+
		'    {'+
		'        \"short_description\": \"Problème de réédition commande client\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1515355\",'+
		'        \"opened_at\": \"2020-04-21 10:36:14\",'+
		'        \"state\": \"3\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/653a4f12db12a78cf49714a05b961922\",'+
		'            \"value\": \"653a4f12db12a78cf49714a05b961922\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Problème de valeur sur la balise LC80_MT_LIGNE_CMD\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1603098\",'+
		'        \"opened_at\": \"2020-06-24 14:15:03\",'+
		'        \"state\": \"3\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/428f2b3f1b111850a18bfc839b4bcb71\",'+
		'            \"value\": \"428f2b3f1b111850a18bfc839b4bcb71\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Bug lors de la modification des documents de type AR ou Offre\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1609768\",'+
		'        \"opened_at\": \"2020-06-29 14:52:28\",'+
		'        \"state\": \"3\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/428f2b3f1b111850a18bfc839b4bcb71\",'+
		'            \"value\": \"428f2b3f1b111850a18bfc839b4bcb71\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Problème de génération et aperçu PDF sous PMI\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Gisele HEBRARD\",'+
		'            \"email\": \"g.hebrard@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1501439\",'+
		'        \"opened_at\": \"2020-04-09 08:06:57\",'+
		'        \"state\": \"3\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/653a4f12db12a78cf49714a05b961922\",'+
		'            \"value\": \"653a4f12db12a78cf49714a05b961922\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Problème de mise en pièce jointe entre PMI et Outlook\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1382559\",'+
		'        \"opened_at\": \"2020-01-29 14:32:51\",'+
		'        \"state\": \"3\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/653a4f12db12a78cf49714a05b961922\",'+
		'            \"value\": \"653a4f12db12a78cf49714a05b961922\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Problème de réplication des modifications d\'articles entre entités\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1384926\",'+
		'        \"opened_at\": \"2020-01-30 13:03:28\",'+
		'        \"state\": \"10\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/653a4f12db12a78cf49714a05b961922\",'+
		'            \"value\": \"653a4f12db12a78cf49714a05b961922\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Pb de copie d\'éléments sur les documents\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1378820\",'+
		'        \"opened_at\": \"2020-01-28 10:37:30\",'+
		'        \"state\": \"10\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/653a4f12db12a78cf49714a05b961922\",'+
		'            \"value\": \"653a4f12db12a78cf49714a05b961922\"'+
		'        }'+
		'    },'+
		'    {'+
		'        \"short_description\": \"Le calcul de prix de revient ne fonctionne plus\",'+
		'        \"priority\": \"3\",'+
		'        \"service_level\": {'+
		'            \"code\": \"E02\",'+
		'            \"description\": \"Cegid CONTACT - INDUSTRY\"'+
		'        },'+
		'        \"contact\": {'+
		'            \"name\": \"Jean DONG\",'+
		'            \"email\": \"j.dong@electrocalorique.com\"'+
		'        },'+
		'        \"case_number\": \"CS1616771\",'+
		'        \"opened_at\": \"2020-07-02 11:32:07\",'+
		'        \"state\": \"10\",'+
		'        \"demande_type\": {'+
		'            \"category\": \"30\",'+
		'            \"subcategory\": \"33\"'+
		'        },'+
		'        \"asset\": {'+
		'            \"link\": \"https://cegiddev.service-now.com:443/api/now/table/alm_asset/428f2b3f1b111850a18bfc839b4bcb71\",'+
		'            \"value\": \"428f2b3f1b111850a18bfc839b4bcb71\"'+
		'        }'+
		'    }'+
		']';
		List<AP04_RelatedListSupport_Wrapper> r = AP04_RelatedListSupport_Wrapper.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AP04_RelatedListSupport_Wrapper objWebserviceSupportV3 = new AP04_RelatedListSupport_Wrapper(System.JSON.createParser(json));
		System.assert(objWebserviceSupportV3 != null);
		System.assert(objWebserviceSupportV3.short_description == null);
		System.assert(objWebserviceSupportV3.priority == null);
		System.assert(objWebserviceSupportV3.service_level == null);
		System.assert(objWebserviceSupportV3.contact == null);
		System.assert(objWebserviceSupportV3.case_number == null);
		System.assert(objWebserviceSupportV3.opened_at == null);
		System.assert(objWebserviceSupportV3.state == null);
		System.assert(objWebserviceSupportV3.demande_type == null);
		System.assert(objWebserviceSupportV3.asset == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AP04_RelatedListSupport_Wrapper.Service_level objService_level = new AP04_RelatedListSupport_Wrapper.Service_level(System.JSON.createParser(json));
		System.assert(objService_level != null);
		System.assert(objService_level.code == null);
		System.assert(objService_level.description == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AP04_RelatedListSupport_Wrapper.Demande_type objDemande_type = new AP04_RelatedListSupport_Wrapper.Demande_type(System.JSON.createParser(json));
		System.assert(objDemande_type != null);
		System.assert(objDemande_type.category == null);
		System.assert(objDemande_type.subcategory == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AP04_RelatedListSupport_Wrapper.Asset objAsset = new AP04_RelatedListSupport_Wrapper.Asset(System.JSON.createParser(json));
		System.assert(objAsset != null);
		System.assert(objAsset.link == null);
		System.assert(objAsset.value == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		AP04_RelatedListSupport_Wrapper.Contact objContact = new AP04_RelatedListSupport_Wrapper.Contact(System.JSON.createParser(json));
		System.assert(objContact != null);
		System.assert(objContact.name == null);
		System.assert(objContact.email == null);
	}
}