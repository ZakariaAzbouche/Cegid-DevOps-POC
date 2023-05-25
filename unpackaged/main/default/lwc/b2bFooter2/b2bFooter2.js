/**
 * @description       : 
 * @author            : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
 * @group             : 
 * @last modified on  : 2021-12-08
 * @last modified by  : Gulshan DOORGAH gulshan.doorgah@comforth-karoo.eu
**/
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

/*ALL LABELS*/
import FooterCabinetExperts from '@salesforce/label/c.b2bFooterCabinetExperts';
import FooterTpeEntrepreneurs from '@salesforce/label/c.b2bFooterTpeEntrepreneurs';
import FooterPME from '@salesforce/label/c.b2bFooterPME';
import FooterETI from '@salesforce/label/c.b2bFooterETI';
import FooterGrandComptes from '@salesforce/label/c.b2bFooterGrandComptes';
import FooterRetailerEnseigne from '@salesforce/label/c.b2bFooterRetailerEnseigne';

import FooterClient from '@salesforce/label/c.b2bFooterClient';
import FooterSeConnecter from '@salesforce/label/c.b2bFooterSeConnecter';
import FooterCustomerCare from '@salesforce/label/c.b2bFooterCustomerCare';
import FooterPartenaires from '@salesforce/label/c.b2bFooterPartenaires';
import FooterSeConnecterPartenaires from '@salesforce/label/c.b2bFooterSeConnecterPartenaires';
import FooterDevenirPartenaireDistributeur from '@salesforce/label/c.b2bFooterDevenirPartenaireDistributeur';
import FooterTrouverPartenaireDistributeur from '@salesforce/label/c.b2bFooterTrouverPartenaireDistributeur';

import FooterNosLivresBlancs from '@salesforce/label/c.b2bFooterNosLivresBlancs';
import FooterDossiersthematiques from '@salesforce/label/c.b2bFooterDossiersthematiques';
import FooterBlogUrl from '@salesforce/label/c.b2bFooterBlogUrl';
import FooterCasClient from '@salesforce/label/c.b2bFooterCasClient';

import FooterWebdemoWebinar from '@salesforce/label/c.b2bFooterWebdemoWebinar';
import FooterFAQ from '@salesforce/label/c.b2bFooterFAQ';
import FooterGlossaire from '@salesforce/label/c.b2bFooterGlossaire';

import FooterQuiSommesNous from '@salesforce/label/c.b2bFooterQuiSommesNous';
import FooterLeSaasByCegid from '@salesforce/label/c.b2bFooterLeSaasByCegid';
import FooterEspacePresse from '@salesforce/label/c.b2bFooterEspacePresse';
import FooterRejoignezNous from '@salesforce/label/c.b2bFooterRejoignezNous';
import FooterCegidSolidaire from '@salesforce/label/c.b2bFooterCegidSolidaire';

import FooterInnovationStore from '@salesforce/label/c.b2bFooterInnovationStore';
import FooterCegidEducation from '@salesforce/label/c.b2bFooterCegidEducation';
import FooterBoutique from '@salesforce/label/c.b2bFooterBoutique';
import FooterEvenements from '@salesforce/label/c.b2bFooterEvenements';

import FooterSiegeSocial from '@salesforce/label/c.b2bFooterSiegeSocial';
import FooterTousDroit from '@salesforce/label/c.b2bFooterTousDroit';
import FooterMentionsLegales from '@salesforce/label/c.b2bFooterMentionsLegales';
import FooterConditions from '@salesforce/label/c.b2bFooterConditions';
import FooterPolitiquesCookies from '@salesforce/label/c.b2bFooterPolitiquesCookies';

import FooterGererMaComptabilite from '@salesforce/label/c.b2bFooterGererMaComptabilite';
import FooterGererMaFinance from '@salesforce/label/c.b2bFooterGererMaFinance';
import FooterPaieEtRH from '@salesforce/label/c.b2bFooterPaieEtRH';
import FooterGererMonEntreprise from '@salesforce/label/c.b2bFooterGererMonEntreprise';
import FooterMeFormerAvecCegid from '@salesforce/label/c.b2bFooterMeFormerAvecCegid';

import FooterGererEtDevelopperMonCommerce from '@salesforce/label/c.b2bFooterGererEtDevelopperMonCommerce';
import FooterGererMaProductionIndustrielle from '@salesforce/label/c.b2bFooterGererMaProductionIndustrielle';
import FooterPiloterUneActiviteRetail from '@salesforce/label/c.b2bFooterPiloterUneActiviteRetail';
import FooterGererMonCabinetEtMesMission from '@salesforce/label/c.b2bFooterGererMonCabinetEtMesMission';

import FooterTitre from '@salesforce/label/c.b2bFooter2Titre';
import FooterSuivezNous from '@salesforce/label/c.b2bFooter2SuivezNous';
import FooterNumeroDappel from '@salesforce/label/c.b2bFooter2NumeroDappel';
import FooterServiceGratuit from '@salesforce/label/c.b2bFooter2ServiceGratuit';
import FooterPrixAppel from '@salesforce/label/c.b2bFooter2PrixAppel';

import FooterJesuis from '@salesforce/label/c.b2bFooterJeSuis';


import B2B_RESSOURCES from '@salesforce/resourceUrl/B2B_Ressources';
import TWITTER_LOGO from '@salesforce/resourceUrl/b2btwitterlogo';
import LINKEDIN_LOGO from '@salesforce/resourceUrl/b2blinkedinlogo';
import FACEBOOK_LOGO from '@salesforce/resourceUrl/b2bfacebooklogo';
import YOUTUBE_LOGO from '@salesforce/resourceUrl/b2byoutubelogo';

/*Footer Url */

import b2bFooterCabinetExpertsURL from '@salesforce/label/c.b2bFooterCabinetExpertsURL';
import b2bFooterTpeEntrepreneursURL from '@salesforce/label/c.b2bFooterTpeEntrepreneursURL';
import b2bFooterPMEURL from '@salesforce/label/c.b2bFooterPMEURL';
import b2bFooterETIURL from '@salesforce/label/c.b2bFooterETIURL';
import b2bFooterGrandComptesURL from '@salesforce/label/c.b2bFooterGrandComptesURL';
import b2bFooterRetailerEnseigneURL from '@salesforce/label/c.b2bFooterRetailerEnseigneURL';


import b2bFooterGererMaComptabiliteURL from '@salesforce/label/c.b2bFooterGererMaComptabiliteURL';
import b2bFooterGererMaFinanceURL from '@salesforce/label/c.b2bFooterGererMaFinanceURL';
import b2bFooterPaieEtRHURL from '@salesforce/label/c.b2bFooterPaieEtRHURL';
import b2bFooterGererMonEntrepriseURL from '@salesforce/label/c.b2bFooterGererMonEntrepriseURL';
import b2bFooterMeFormerAvecCegidURL from '@salesforce/label/c.b2bFooterMeFormerAvecCegidURL';

import b2bFooterGererEtDevelopperMonCommerceURL from '@salesforce/label/c.b2bFooterGererEtDevelopperMonCommerceURL';
import b2bFooterGererMaProductionIndustrielleURL from '@salesforce/label/c.b2bFooterGererMaProductionIndustrielleURL';
import b2bFooterPiloterUneActiviteRetailURL from '@salesforce/label/c.b2bFooterPiloterUneActiviteRetailURL';
import b2bFooterGererMonCabinetEtMesMissionURL from '@salesforce/label/c.b2bFooterGererMonCabinetEtMesMissionURL';

import b2bFooterSeConnecterURL from '@salesforce/label/c.b2bFooterSeConnecterURL';
import b2bFooterCustomerCareURL from '@salesforce/label/c.b2bFooterCustomerCareURL';
import b2bFooterSeConnecterPartenairesURL from '@salesforce/label/c.b2bFooterSeConnecterPartenairesURL';
import b2bFooterDevenirPartenaireDistributeurURL from '@salesforce/label/c.b2bFooterDevenirPartenaireDistributeurURL';
import b2bFooterTrouverPartenaireDistributeurURL from '@salesforce/label/c.b2bFooterTrouverPartenaireDistributeurURL';

import b2bFooterNosLivresBlancsURL from '@salesforce/label/c.b2bFooterNosLivresBlancsURL';
import b2bFooterDossiersthematiquesURL from '@salesforce/label/c.b2bFooterDossiersthematiquesURL';
import b2bBlogURL from '@salesforce/label/c.b2bBlogURL';
import b2bFooterCasClientURL from '@salesforce/label/c.b2bFooterCasClientURL';
import b2bFooterWebdemoWebinarURL from '@salesforce/label/c.b2bFooterWebdemoWebinarURL';
import b2bFooterFAQURL from '@salesforce/label/c.b2bFooterFAQURL';
import b2bFooterGlossaireURL from '@salesforce/label/c.b2bFooterGlossaireURL';


import b2bFooterQuiSommesNousURL from '@salesforce/label/c.b2bFooterQuiSommesNousURL';
import b2bFooterLeSaasByCegidURL from '@salesforce/label/c.b2bFooterLeSaasByCegidURL';
import b2bFooterEspacePresseURL from '@salesforce/label/c.b2bFooterEspacePresseURL';
import b2bFooterRejoignezNousURL from '@salesforce/label/c.b2bFooterRejoignezNousURL';
import b2bFooterCegidSolidaireURL from '@salesforce/label/c.b2bFooterCegidSolidaireURL';


import b2bFooterMentionsLegalesURL from '@salesforce/label/c.b2bFooterMentionsLegalesURL';
import b2bFooterConditionsURL from '@salesforce/label/c.b2bFooterConditionsURL';
import b2bFooterPolitiquesCookiesURL from '@salesforce/label/c.b2bFooterPolitiquesCookiesURL';

import b2bFooterFacebookURL from '@salesforce/label/c.b2bFooterFacebookURL';
import b2BFooterYoutubeURL from '@salesforce/label/c.b2BFooterYoutubeURL';
import b2bFooterLinkedInURL from '@salesforce/label/c.b2bFooterLinkedInURL';
import b2bFooterTwitterURL from '@salesforce/label/c.b2bFooterTwitterURL';

import b2bFooterJaiBesoinDe from '@salesforce/label/c.b2bFooterJaiBesoinDe';
import b2bFooterEngagerAvecVous from '@salesforce/label/c.b2bFooterEngagerAvecVous';
import b2bFooterDecouvrirNosRessources from '@salesforce/label/c.b2bFooterDecouvrirNosRessources';
import b2bFooterApropos from '@salesforce/label/c.b2bFooterApropos';
 
export default class B2bFooter2 extends NavigationMixin(LightningElement)  {

  label = {
    FooterCabinetExperts,
    FooterTpeEntrepreneurs,
    FooterPME,
    FooterETI,
    FooterGrandComptes,
    FooterRetailerEnseigne,

    FooterClient,
    FooterSeConnecter,
    FooterCustomerCare,
    FooterPartenaires,
    FooterSeConnecterPartenaires,
    FooterDevenirPartenaireDistributeur,
    FooterTrouverPartenaireDistributeur,

    FooterNosLivresBlancs,
    FooterDossiersthematiques,
    FooterBlogUrl,
    FooterCasClient,

    FooterWebdemoWebinar,
    FooterFAQ,
    FooterGlossaire,

    FooterQuiSommesNous,
    FooterLeSaasByCegid,
    FooterEspacePresse,
    FooterRejoignezNous,
    FooterCegidSolidaire,

    FooterInnovationStore,
    FooterCegidEducation,
    FooterBoutique,
    FooterEvenements,

    FooterSiegeSocial,
    FooterTousDroit,
    FooterMentionsLegales,
    FooterConditions,
    FooterPolitiquesCookies,

    FooterGererMaComptabilite,
    FooterGererMaFinance,
    FooterPaieEtRH,
    FooterGererMonEntreprise,
    FooterMeFormerAvecCegid,

    FooterGererEtDevelopperMonCommerce,
    FooterGererMaProductionIndustrielle,
    FooterPiloterUneActiviteRetail,
    FooterGererMonCabinetEtMesMission,

    FooterTitre,
    FooterSuivezNous,
    FooterNumeroDappel,
    FooterServiceGratuit,
    FooterPrixAppel,

    b2bFooterCabinetExpertsURL,
    b2bFooterTpeEntrepreneursURL,
    b2bFooterPMEURL,
    b2bFooterETIURL,
    b2bFooterGrandComptesURL,
    b2bFooterRetailerEnseigneURL,

    b2bFooterGererMaComptabiliteURL,
    b2bFooterGererMaFinanceURL,
    b2bFooterPaieEtRHURL,
    b2bFooterGererMonEntrepriseURL,
    b2bFooterMeFormerAvecCegidURL,

    b2bFooterGererEtDevelopperMonCommerceURL,
    b2bFooterGererMaProductionIndustrielleURL,
    b2bFooterPiloterUneActiviteRetailURL,
    b2bFooterGererMonCabinetEtMesMissionURL,

    b2bFooterSeConnecterURL,
    b2bFooterCustomerCareURL,
    b2bFooterSeConnecterPartenairesURL,
    b2bFooterDevenirPartenaireDistributeurURL,
    b2bFooterTrouverPartenaireDistributeurURL,

    b2bFooterNosLivresBlancsURL,
    b2bFooterDossiersthematiquesURL,
    b2bBlogURL,
    b2bFooterCasClientURL,

    b2bFooterWebdemoWebinarURL,
    b2bFooterFAQURL,
    b2bFooterGlossaireURL,

    b2bFooterQuiSommesNousURL,
    b2bFooterLeSaasByCegidURL,
    b2bFooterEspacePresseURL,
    b2bFooterRejoignezNousURL,
    b2bFooterCegidSolidaireURL,

    b2bFooterMentionsLegalesURL,
    b2bFooterConditionsURL,
    b2bFooterPolitiquesCookiesURL,

    b2bFooterFacebookURL,
    b2BFooterYoutubeURL,
    b2bFooterLinkedInURL,
    b2bFooterTwitterURL,

    FooterJesuis,
    b2bFooterJaiBesoinDe,
    b2bFooterEngagerAvecVous,
    b2bFooterDecouvrirNosRessources,
    b2bFooterApropos
  };



  /*SOCIAL MEDIA LOGO*/
  twitterlogoUrl = TWITTER_LOGO;
  linkedinlogoUrl = LINKEDIN_LOGO;
  facebooklogoUrl = FACEBOOK_LOGO;
  youtubelogoUrl = YOUTUBE_LOGO;

  /*Cegid logo*/
  cegidLogo = B2B_RESSOURCES + '/icons/cegid--logo.png';

  /*SVG sprite*/
  linkIcon = B2B_RESSOURCES + '/icons/sprite.svg#ico-target-blank';

  /*FOOTER DYNAMIC YEAR*/
connectedCallback(){
  var newDate = new Date(); 
          this.dateValue = newDate.toISOString().slice(0,4) 
  }

  /*NAVIGATE TO "Cabinet experts comptables" URL*/
  navigateToWebPageExpertsComptables() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterCabinetExpertsURL
        }
    });
  }

  /*NAVIGATE TO "TPE & Entrepreneurs" URL*/
  navigateToWebPageTPEEntrepreneurs() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterTpeEntrepreneursURL
        }
    });
  }

  /*NAVIGATE TO "PME" URL*/
  navigateToWebPagePME() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterPMEURL
        }
    });
  }

  /*NAVIGATE TO "ETI" URL*/
  navigateToWebPageETI() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterETIURL
        }
    });
  }

  /*NAVIGATE TO "Retailer, enseigne ou marque spécialisée" URL*/
  navigateToWebGrandComptables() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterGrandComptesURL
        }
    });
  }

  /*NAVIGATE TO "Retailer, enseigne ou marque spécialisée" URL*/
  navigateToWebPageRetailerEnseigne() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterRetailerEnseigneURL
        }
    });
  }

  /*Second Col*/

    /*NAVIGATE TO "Gérer ma comptabilité et mes finances" URL*/
    navigateToWebPageGérerMaComptabiliteEtMesFinances() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGererMaComptabiliteURL
          }
      });
    }

    /*NAVIGATE TO "Gérer finances" URL*/
    navigateToWebPageGérerFinances() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGererMaComptabiliteURL
          }
      });
    }

    /*NAVIGATE TO "Paie et RH" URL*/
    navigateToWebPaieRH() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterPaieEtRHURL
          }
      });
    }

    /*NAVIGATE TO "Paie et RH" URL*/
    navigateToWebMonEntreprise() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGererMonEntrepriseURL
          }
      });
    }

    /*NAVIGATE TO "Paie et RH" URL*/
    navigateToWebAvecCegid() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterMeFormerAvecCegidURL
          }
      });
    }

    /*3rd Col */
    /*NAVIGATE TO "Gérer Developpe Ma Commerce" URL*/
    navigateToWebGererDeveloppeMaCommerce() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGererEtDevelopperMonCommerceURL
          }
      });
    }

    /*NAVIGATE TO "Gérer ma production industrielle" URL*/
    navigateToWebGererMaProductionIndustrielle() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGererMaProductionIndustrielleURL
          }
      });
    }
    /*NAVIGATE TO "Piloter une activité retail" URL*/
    navigateToWebPiloterUneActiviteRetail() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterPiloterUneActiviteRetailURL
          }
      });
    }
    /*NAVIGATE TO "Gérer mon cabinet et mes missions" URL*/
    navigateToWebGererMonCabinetEtMesMissions() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGererMonCabinetEtMesMissionURL
          }
      });
    }

/*second Row */

 /*NAVIGATE TO "Client Se connecter" URL*/
    navigateToWebPageClientSeConnecter() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterSeConnecterURL
          }
      });
    }

  /*NAVIGATE TO "Client Customer Care" URL*/
    navigateToWebPageClientCustomerCare() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterCustomerCareURL
        }
    });
  }

  /*NAVIGATE TO "Partenaire se connecter" URL*/
    navigateToWebPagePartenaireSeConnecter() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterSeConnecterPartenairesURL
          }
      });
    }

  /*NAVIGATE TO "Devenir partenaire distributeur" URL*/
    navigateToWebPageDevenirPartenaireDis() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterDevenirPartenaireDistributeurURL
          }
      });
    }

  /*NAVIGATE TO "Trouver un partenaire distributeur" URL*/
      navigateToWebPageTrouverPartenaireDis() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": b2bFooterTrouverPartenaireDistributeurURL

            }
        });
      }


/*second Row 2nd col  */
  /*NAVIGATE TO "Nos Livres Blanc" URL*/
    navigateToWebNosLivresBlanc() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterNosLivresBlancsURL
          }
      });
    }

  /*NAVIGATE TO "Dossier Thematiques" URL*/
  navigateToWebDossierThematiques() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterDossiersthematiquesURL
        }
    });
  }

  /*NAVIGATE TO "Blog" URL*/
    navigateToWebBlog() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bBlogURL
          }
      });
    }

  /*NAVIGATE TO "Cas Client" URL*/
  navigateToWebCasClient() {
    this[NavigationMixin.Navigate]({
        "type": "standard__webPage",
        "attributes": {
            "url": b2bFooterCasClientURL
        }
    });
  }

  /*NAVIGATE TO "FAQ" URL*/
    navigateToWebinar() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterWebdemoWebinarURL
          }
      });
    }
  
  /*NAVIGATE TO "FAQ" URL*/
    navigateToWebFAQ() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterFAQURL
          }
      });
    }

    /*NAVIGATE TO "Glossaire" URL*/
    navigateToWebGlossaire() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterGlossaireURL
          }
      });
    }

    /*second Row 2nd Col*/

      /*NAVIGATE TO "Qui sommes-nous" URL*/
      navigateToWebQuiSommesNous() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": b2bFooterQuiSommesNousURL
            }
        });
      }

      /*NAVIGATE TO "Qui sommes-nous" URL*/
      navigateToWebSaasByCegid() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": b2bFooterLeSaasByCegidURL
            }
        });
      }
    /*NAVIGATE TO "Espace presse" URL*/
      navigateToWebEspacePresse() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": b2bFooterEspacePresseURL
            }
        });
      }
    /*NAVIGATE TO "Rejoignez-nous" URL*/
    navigateToWebRejoingezNous() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterRejoignezNousURL
          }
      });
    }
    /*NAVIGATE TO "Cegid Solidaire" URL*/
      navigateToWebCegidSolidaire() {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": b2bFooterCegidSolidaireURL

            }
        });
      }



  /*NAVIGATE TO "Politique de confidentialité et cookies" URL*/
    navigateToWebPolitiqueDeConfidentialite() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterPolitiquesCookiesURL
          }
      });
    }

  /*NAVIGATE TO "Conditions générales de vente" URL*/
    navigateToWebConditionsGeneralesDeVente() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterConditionsURL
          }
      });
    }

  /*NAVIGATE TO "Mentions légales" URL*/
    navigateToWebMentionsLegales() {
      this[NavigationMixin.Navigate]({
          "type": "standard__webPage",
          "attributes": {
              "url": b2bFooterMentionsLegalesURL
          }
      });
    }





}