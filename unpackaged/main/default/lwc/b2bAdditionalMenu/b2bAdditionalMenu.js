import { LightningElement } from 'lwc';
/*ALL LABELS*/

import pageDescription from '@salesforce/label/c.b2bSubMenuPageDescription';
import formationTitle from '@salesforce/label/c.b2bSubMenuTitleFormation';
import formationDescription from '@salesforce/label/c.b2bSubMenuDescriptionFormation';
import solutionTitle from '@salesforce/label/c.b2bSubMenuTitleSolution';
import solutionDescription from '@salesforce/label/c.b2bSubMenuDescriptionSolution';

import formationsGestionCabinet from '@salesforce/label/c.b2bFormationsGestionCabinet';
import formationsGestionPaieRH from '@salesforce/label/c.b2bFormationsGestionPaieRH';
import formationsProductionFinanciere from '@salesforce/label/c.b2bFormationsProductionFinanciere';
import formationsProductionIndustrielle from '@salesforce/label/c.b2bFormationsProductionIndustrielle';
import formationsDeveloppementVentes from '@salesforce/label/c.b2bFormationsDeveloppementVentes';
import formationb2bFormationsMigrationsPrestations from '@salesforce/label/c.b2bFormationsMigrationsPrestations';

import solutionsGestionCabinet from '@salesforce/label/c.b2bSolutionsGestionCabinet';
import solutionsGestionPaieRH from '@salesforce/label/c.b2bSolutionsGestionPaieRH';
import solutionsProductionFinanciere from '@salesforce/label/c.b2bSolutionsProductionFinanciere';

import gestionDuCabinet from '@salesforce/label/c.b2bFormationGestionDuCabinet';
import gestionPaieEtDesRH from '@salesforce/label/c.b2bFormationGestionPaieEtDesRH';
import migrationPrestations from '@salesforce/label/c.b2bFormationMigrationPrestations';
import portailDeGestion from '@salesforce/label/c.b2bFormationPortailDeGestion';
import productionFinanciereOuComptable from '@salesforce/label/c.b2bFormationProductionFinanciereOuComptable';
import productionIndustrielle from '@salesforce/label/c.b2bFormationProductionIndustrielle';
import developpementDesVentes from '@salesforce/label/c.b2bFormationDeveloppementDesVentes';

export default class B2bAdditionalMenu extends LightningElement {
    label = {
        pageDescription,
        formationTitle,
        formationDescription,
        solutionTitle,
        solutionDescription,
        formationsGestionCabinet,
        formationsGestionPaieRH,
        formationsProductionFinanciere,
        formationsProductionIndustrielle,
        formationsDeveloppementVentes,
        formationb2bFormationsMigrationsPrestations,
        solutionsGestionCabinet,
        solutionsGestionPaieRH,
        solutionsProductionFinanciere,
        gestionDuCabinet,
        gestionPaieEtDesRH,
        migrationPrestations,
        portailDeGestion,
        productionFinanciereOuComptable,
        productionIndustrielle,
        developpementDesVentes
    }
}