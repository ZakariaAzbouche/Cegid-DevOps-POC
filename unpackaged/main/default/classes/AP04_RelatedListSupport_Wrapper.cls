/***
* @author      Comforth - SRA
* @date        16/07/2020
* @description Class for AP04_RelatedListSupport_Wrapper
***/
public class AP04_RelatedListSupport_Wrapper {
    
	@AuraEnabled public String short_description {get;set;} 
	@AuraEnabled public String priority {get;set;} 
	@AuraEnabled public Service_level service_level {get;set;} 
	@AuraEnabled public Contact contact {get;set;} 
	@AuraEnabled public String case_number  {get;set;} // in json: number
	@AuraEnabled public String opened_at {get;set;} 
	@AuraEnabled public String state {get;set;} 
	@AuraEnabled public Demande_type demande_type {get;set;} // in json: demande-type
	@AuraEnabled public Asset asset {get;set;} 

	public AP04_RelatedListSupport_Wrapper(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
                system.debug('text'+text);
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    
					if (text == 'short_description') {
						short_description = parser.getText();
					} else if (text == 'priority') {
						priority = parser.getText();
					} else if (text == 'service_level') {
						service_level = new Service_level(parser);
					} else if (text == 'contact') {
						contact = new Contact(parser);
					} else if (text == 'case_number') {
						case_number  = parser.getText();
					} else if (text == 'opened_at') {
						opened_at = parser.getText();
					} else if (text == 'state') {
						state = parser.getText();
					} else if (text == 'demande_type') {
						demande_type = new Demande_type(parser);
					} else if (text == 'asset') {
						asset = new Asset(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'AP04_RelatedListSupport_Wrapper consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Service_level {
		@AuraEnabled public String code {get;set;} // in json: service_level.code
		@AuraEnabled public String description {get;set;} // in json: service_level.description

		public Service_level(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'description') {
							description = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Service_level consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Demande_type {
		@AuraEnabled public String category {get;set;} 
		@AuraEnabled public String subcategory {get;set;} 

		public Demande_type(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'category') {
							category = parser.getText();
						} else if (text == 'subcategory') {
							subcategory = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Demande_type consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Asset {
		@AuraEnabled public String link {get;set;} 
		@AuraEnabled public String value {get;set;} 
		@AuraEnabled public String libele {get;set;} 

		public Asset(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'link') {
							link = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						}else if (text == 'libele') {
							value = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Asset consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Contact {
		@AuraEnabled public String name {get;set;} 
		@AuraEnabled public String email {get;set;} 

		public Contact(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'name') {
							name = parser.getText();
						} else if (text == 'email') {
							email = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Contact consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	@AuraEnabled
	public static List<AP04_RelatedListSupport_Wrapper> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfAP04_RelatedListSupport_Wrapper(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<AP04_RelatedListSupport_Wrapper> arrayOfAP04_RelatedListSupport_Wrapper(System.JSONParser p) {
        List<AP04_RelatedListSupport_Wrapper> res = new List<AP04_RelatedListSupport_Wrapper>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new AP04_RelatedListSupport_Wrapper(p));
        }
        return res;
    }

}