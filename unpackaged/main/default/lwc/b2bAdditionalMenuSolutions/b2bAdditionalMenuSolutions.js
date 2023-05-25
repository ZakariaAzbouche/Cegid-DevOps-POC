import { LightningElement } from 'lwc';

/*ALL LABELS*/
import solutionTitle from '@salesforce/label/c.b2bSubMenuTitleSolution';
import solutionDescription from '@salesforce/label/c.b2bSubMenuDescriptionSolution';

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


export default class B2bAdditionalMenuSolutions extends LightningElement {
	label = {
        solutionTitle,
        solutionDescription,
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