/**
* @author Keshav - Comforth
* @date Creation 4-12-2021
* @description SM018_RedistributionOfDiscount
* @last modified on  : 2022-10-03
* @last modified by  : Ratish ISURI
*              
*/
public class SM018_RedistributionOfDiscount {

    public static void recalculationv1(Map<Id,set<string>> mapQuoteStructures, Map<Id,SBQQ__Quote__c> mapQuote){

        Boolean isAbove = false;
        List<SBQQ__QuoteLine__c> listQuoteLineToBeUpdated = new List<SBQQ__QuoteLine__c>();

        set<String> setStructures = new set<String>();

        for(set<String> setName : mapQuoteStructures.values()){

            setStructures.addAll(setName);

        }
        
        Decimal nonDiscountable190 = 0;
        Decimal nonDiscountable110 = 0;
        Decimal nonDiscountable120 = 0;
        Decimal nonDiscountable140 = 0;
        Decimal nonDiscountable130 = 0;
        Decimal nonDiscountableAll = 0;

        List<SBQQ__QuoteLine__c> listQuoteLine = [
            SELECT Id, ListUnitPrice_Display__c,ListPrice_Display__c,Additionnal_Discount_Amount__c,Additionnal_Discount_Percentage__c,SBQQ__Product__c, SBQQ__Quote__c,SBQQ__Discount__c,SBQQ__AdditionalDiscountAmount__c,
            NetUnitPrice_Display__c ,Purchasing_Price__c,SBQQ__Quantity__c,
            SBQQ__Product__r.Family,SBQQ__Product__r.Purchasing_Price__c,SBQQ__Product__r.SBQQ__NonDiscountable__c,
            SBQQ__Quote__r.TargetedPriceForHardware__c,SBQQ__Quote__r.TargetedPriceForLicense__c,SBQQ__Quote__r.TargetedPriceForMaintenance__c,SBQQ__Quote__r.TargetedPriceForProfessional_Services__c,
            SBQQ__Quote__r.TargetedPriceForSaas__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c IN:mapQuoteStructures.keySet() AND SBQQ__Product__r.Family IN:setStructures
            AND ChargeOrUsageProduct__c = false];
       
        map<string, decimal> mapQuoteStructureTotal = new map<string, decimal> ();
        for(SBQQ__QuoteLine__c qutLine:listQuoteLine){
            
            if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c > 0){
                
				decimal purchasingQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purchasingQuantity:0;
                
                if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                	nonDiscountableAll += (qutLine.ListPrice_Display__c >0)?qutLine.ListPrice_Display__c:0;
                }else{
					nonDiscountableAll += purchasingPrice;
                }
                
                decimal tempTotal = (mapQuoteStructureTotal.containsKey(qutLine.SBQQ__Quote__c + '' + 'All')) ? 
                                mapQuoteStructureTotal.get(qutLine.SBQQ__Quote__c + '' + 'All') : 0;
            	tempTotal += (qutLine.ListPrice_Display__c != null) ? qutLine.ListPrice_Display__c : 0;
            	mapQuoteStructureTotal.put(qutLine.SBQQ__Quote__c + '' + 'All', tempTotal);
                
                
            }else{
                
                if(qutLine.SBQQ__Product__r.Family =='130' && (qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c || qutLine.SBQQ__Product__r.Purchasing_Price__c > 0)){
                	decimal purchasingQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                	decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purchasingQuantity:0;
                
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        nonDiscountable130 += (qutLine.ListPrice_Display__c >0)?qutLine.ListPrice_Display__c:0;
                    }else{
                        nonDiscountable130 += purchasingPrice;
                    }
                    
                }
                
                if(qutLine.SBQQ__Product__r.Family =='190' && (qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c || qutLine.SBQQ__Product__r.Purchasing_Price__c > 0)){
                    decimal purchasingQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purchasingQuantity:0;
                    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        nonDiscountable190 += (qutLine.ListPrice_Display__c >0)?qutLine.ListPrice_Display__c:0;
                    }else{
                        nonDiscountable190 += purchasingPrice;
                    }
                    
                }
                
                if(qutLine.SBQQ__Product__r.Family =='140' && (qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c || qutLine.SBQQ__Product__r.Purchasing_Price__c > 0)){
                    decimal purchasingQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purchasingQuantity:0;
                    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        nonDiscountable140 += (qutLine.ListPrice_Display__c >0)?qutLine.ListPrice_Display__c:0;
                    }else{
                        nonDiscountable140 += purchasingPrice;
                    }
                    
                }
                
                if(qutLine.SBQQ__Product__r.Family =='110' && (qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c || qutLine.SBQQ__Product__r.Purchasing_Price__c > 0)){
                    decimal purchasingQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purchasingQuantity:0;
                    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        nonDiscountable110 += (qutLine.ListPrice_Display__c >0)?qutLine.ListPrice_Display__c:0;
                    }else{
                        nonDiscountable110 += purchasingPrice;
                    }
                    
                }
                
                if(qutLine.SBQQ__Product__r.Family =='120' && (qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c || qutLine.SBQQ__Product__r.Purchasing_Price__c > 0)){
                    decimal purchasingQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purchasingQuantity:0;
                    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        nonDiscountable120 += (qutLine.ListPrice_Display__c >0)?qutLine.ListPrice_Display__c:0;
                    }else{
                        nonDiscountable120 += purchasingPrice;
                    }
                    
                }
                
                decimal tempTotal = (mapQuoteStructureTotal.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                mapQuoteStructureTotal.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
            	tempTotal += (qutLine.ListPrice_Display__c != null) ? qutLine.ListPrice_Display__c : 0;
            	mapQuoteStructureTotal.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, tempTotal);
                
            }
            
            system.debug('nonDiscountable110 : ' + nonDiscountable110);
            system.debug('nonDiscountable120 : ' + nonDiscountable120);
            system.debug('nonDiscountable130 : ' + nonDiscountable130);
            system.debug('nonDiscountable140 : ' + nonDiscountable140);
            system.debug('nonDiscountable190 : ' + nonDiscountable190);
			system.debug('nonDiscountableAll : ' + nonDiscountableAll);
            
        }

        system.debug('mapQuoteStructureTotal : ' + mapQuoteStructureTotal);

        //(Ex. Produit1 100€, Produit2 50€, total 150€, mais Targeted Price = 110€. Alors j'applique 150-110 = 40€ de discount, 
        //que je répartis sur Produit1 à 100/(100+50) = 66% donc 40*66% = 26,4€ et donc 13,6€ sur le Produit2.)


        //Si pour un ou des produits, le prix net (Gross - Discount) est inférieur à Purchasing_Price__c, 
        //mettre le discount max (tel que discountmax = Gross Unit Price - Purchasing Price). Tagguer cette ligne comme discount max atteint.
        map<string, decimal> mapQuoteLinesDiscount = new map<string, decimal> ();
        map<string, integer> mapQuoteLinesCount = new map<string, integer> ();


        for(SBQQ__QuoteLine__c qutLine:listQuoteLine){
            //reseting Field 

            if( qutLine.SBQQ__AdditionalDiscountAmount__c != null){
                qutLine.SBQQ__AdditionalDiscountAmount__c = null;
            }else if(qutLine.SBQQ__Discount__c != null){
                qutLine.SBQQ__Discount__c = null;
            }

            if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c > 0){
                decimal tempTotal = (mapQuoteStructureTotal.containsKey(qutLine.SBQQ__Quote__c + '' + 'All')) ? 
                                mapQuoteStructureTotal.get(qutLine.SBQQ__Quote__c + '' + 'All') : 0;
                
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c > 0  && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c && qutLine.ListUnitPrice_Display__c > 0){
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    if(nonDiscountable190 > mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c){
                        CalloutException e = new CalloutException();
                        e.setMessage('Targeted Price too low, please review your objective !');
                        throw e;
                    }
                    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + 'All')) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + 'All') : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + 'All')) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + 'All') : 0;
    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        remainingDiscount += additionalDiscountAmountCal ;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + 'All', remainingDiscount);
                    }else if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                        qutLine.SBQQ__AdditionalDiscountAmount__c = qutLine.ListPrice_Display__c - purchasingPrice;
                        remainingDiscount += additionalDiscountAmountCal - qutLine.SBQQ__AdditionalDiscountAmount__c;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + 'All', remainingDiscount);
                    }else{
                        qutLine.SBQQ__AdditionalDiscountAmount__c = additionalDiscountAmountCal;
                        remainingCount++;
                        mapQuoteLinesCount.put(qutLine.SBQQ__Quote__c + '' + 'All', remainingCount);
                    }
                    
                }
                
            }
            else{
                
                decimal tempTotal = (mapQuoteStructureTotal.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                mapQuoteStructureTotal.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;

                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForHardware__c > 0 && qutLine.SBQQ__Product__r.Family =='190'  && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForHardware__c && qutLine.ListUnitPrice_Display__c > 0){
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForHardware__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    if(nonDiscountable190 > mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForHardware__c){
                        CalloutException e = new CalloutException();
                        e.setMessage('Targeted Price too low, please review your objective !');
                        throw e;
                    }
                    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        remainingDiscount += additionalDiscountAmountCal ;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                        qutLine.SBQQ__AdditionalDiscountAmount__c = qutLine.ListPrice_Display__c - purchasingPrice;
                        remainingDiscount += additionalDiscountAmountCal - qutLine.SBQQ__AdditionalDiscountAmount__c;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else{
                        qutLine.SBQQ__AdditionalDiscountAmount__c = additionalDiscountAmountCal;
                        remainingCount++;
                        mapQuoteLinesCount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingCount);
                    }
                    
                }
    
    
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c > 0 && qutLine.SBQQ__Product__r.Family =='110'  && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c && qutLine.ListUnitPrice_Display__c > 0){
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                     if(nonDiscountable110 > mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c){
                        CalloutException e = new CalloutException();
                        e.setMessage('Targeted Price too low, please review your objective !');
                        throw e;
                    }
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
    
                    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        remainingDiscount += additionalDiscountAmountCal ;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                        qutLine.SBQQ__AdditionalDiscountAmount__c = qutLine.ListPrice_Display__c - purchasingPrice;
                        remainingDiscount += additionalDiscountAmountCal - qutLine.SBQQ__AdditionalDiscountAmount__c;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else{
                        qutLine.SBQQ__AdditionalDiscountAmount__c = additionalDiscountAmountCal;
                        remainingCount++;
                        mapQuoteLinesCount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingCount);
                    }
                }
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c > 0 && qutLine.SBQQ__Product__r.Family =='120'  && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c && qutLine.ListUnitPrice_Display__c > 0){
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    if(nonDiscountable120 > mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c){
                        CalloutException e = new CalloutException();
                        e.setMessage('Targeted Price too low, please review your objective !');
                        throw e;
                    }
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        remainingDiscount += additionalDiscountAmountCal ;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                        qutLine.SBQQ__AdditionalDiscountAmount__c = qutLine.ListPrice_Display__c - purchasingPrice;
                        remainingDiscount += additionalDiscountAmountCal - qutLine.SBQQ__AdditionalDiscountAmount__c;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else{
                        qutLine.SBQQ__AdditionalDiscountAmount__c = additionalDiscountAmountCal;
                        remainingCount++;
                        mapQuoteLinesCount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingCount);
                    }
                }
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c > 0 && qutLine.SBQQ__Product__r.Family =='140' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c && qutLine.ListUnitPrice_Display__c > 0){
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    if(nonDiscountable140 > mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c){
                        CalloutException e = new CalloutException();
                        e.setMessage('Targeted Price too low, please review your objective !');
                        throw e;
                    }
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
    
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        remainingDiscount += additionalDiscountAmountCal ;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                        qutLine.SBQQ__AdditionalDiscountAmount__c = qutLine.ListPrice_Display__c - purchasingPrice;
                        remainingDiscount += additionalDiscountAmountCal - qutLine.SBQQ__AdditionalDiscountAmount__c;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else{
                        qutLine.SBQQ__AdditionalDiscountAmount__c = additionalDiscountAmountCal;
                        remainingCount++;
                        mapQuoteLinesCount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingCount);
                    }
                }
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c > 0 && qutLine.SBQQ__Product__r.Family =='130' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c && qutLine.ListUnitPrice_Display__c > 0){
                    //tempTotal = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c;
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                       if(nonDiscountable130 > mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c){
                        CalloutException e = new CalloutException();
                        e.setMessage('Targeted Price too low, please review your objective !');
                        throw e;
                    }
                    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                    if(qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){
                        remainingDiscount += additionalDiscountAmountCal ;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                        qutLine.SBQQ__AdditionalDiscountAmount__c = qutLine.ListPrice_Display__c - purchasingPrice;
                        remainingDiscount += additionalDiscountAmountCal - qutLine.SBQQ__AdditionalDiscountAmount__c;
                        mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                    }else{
                        qutLine.SBQQ__AdditionalDiscountAmount__c = additionalDiscountAmountCal;
                        remainingCount++;
                        mapQuoteLinesCount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingCount);
                    }
                    
                }
                
            }//else
            
        }//endFor

        
        for(SBQQ__QuoteLine__c qutLine:listQuoteLine){
            
            if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c > 0){
                
				decimal tempTotal = (mapQuoteStructureTotal.containsKey(qutLine.SBQQ__Quote__c + ''  + 'All')) ? 
                                    mapQuoteStructureTotal.get(qutLine.SBQQ__Quote__c + ''  + 'All') : 0;
                
                 if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c > 0 && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c && qutLine.ListUnitPrice_Display__c > 0 && !qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){ 
              
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForGlobal__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + 'All')) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + 'All') : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + 'All')) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + 'All') : 0;
                    
                    system.debug('mapQuoteLinesDiscount Before : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + 'All'));
                    system.debug('Max disc To be allocated ' + (qutLine.ListPrice_Display__c - purchasingPrice));
                    if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                 
                    }else if(qutLine.ListPrice_Display__c != null && qutLine.ListPrice_Display__c > 0){
                        if(remainingDiscount > 0 ){
                            qutLine.SBQQ__AdditionalDiscountAmount__c = (qutLine.SBQQ__AdditionalDiscountAmount__c != null) ? qutLine.SBQQ__AdditionalDiscountAmount__c : 0;
                            
                            Decimal maxDisc = qutLine.ListPrice_Display__c - purchasingPrice;
                            if(qutLine.SBQQ__AdditionalDiscountAmount__c < maxDisc){
                                if( (qutLine.SBQQ__AdditionalDiscountAmount__c + remainingDiscount) <= maxDisc && purQuantity == 1){
                                    qutLine.SBQQ__AdditionalDiscountAmount__c += remainingDiscount;
                                    remainingDiscount = 0;                                    
                                }else if(purQuantity > 1){
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc/purQuantity;
                                }else{
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc;
                                }
                                mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + 'All', remainingDiscount);
                            }
                            
                            
                        }
                    }
                    
                }
                
                isAbove = ( mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + 'All') > 0);
                
                system.debug('mapQuoteLinesDiscount : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + 'All')); 
                listQuoteLineToBeUpdated.add(qutLine);
                
                
            }
            else{
                
				decimal tempTotal = (mapQuoteStructureTotal.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                    mapQuoteStructureTotal.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;

                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForHardware__c > 0 && qutLine.SBQQ__Product__r.Family =='190' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForHardware__c && qutLine.ListUnitPrice_Display__c > 0 && !qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){ 
                   decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                    
                   system.debug('mapQuoteLinesDiscount Before : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family));
                    system.debug('Max disc To be allocated ' + (qutLine.ListPrice_Display__c - purchasingPrice));
                    if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                 
                    }else if(qutLine.ListPrice_Display__c != null && qutLine.ListPrice_Display__c > 0){
                        if(remainingDiscount > 0 ){
                            qutLine.SBQQ__AdditionalDiscountAmount__c = (qutLine.SBQQ__AdditionalDiscountAmount__c != null) ? qutLine.SBQQ__AdditionalDiscountAmount__c : 0;
                            
                            Decimal maxDisc = qutLine.ListPrice_Display__c - purchasingPrice;
                            if(qutLine.SBQQ__AdditionalDiscountAmount__c < maxDisc){
                                if( (qutLine.SBQQ__AdditionalDiscountAmount__c + remainingDiscount) <= maxDisc && purQuantity == 1){
                                    qutLine.SBQQ__AdditionalDiscountAmount__c += remainingDiscount;
                                    remainingDiscount = 0;                                    
                                }else if(purQuantity > 1){
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc/purQuantity;
                                }else{
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc;
                                }
                                mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                            }
                            
                            
                        }
                    }
                    
                }
                
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c > 0 && qutLine.SBQQ__Product__r.Family =='110' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c && qutLine.ListUnitPrice_Display__c > 0 && !qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){ 
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForLicense__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                    
                   system.debug('mapQuoteLinesDiscount Before : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family));
                    system.debug('Max disc To be allocated ' + (qutLine.ListPrice_Display__c - purchasingPrice));
    
    
                    if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                 
                    }else if(qutLine.ListPrice_Display__c != null && qutLine.ListPrice_Display__c > 0){
                        if(remainingDiscount > 0 ){
                            qutLine.SBQQ__AdditionalDiscountAmount__c = (qutLine.SBQQ__AdditionalDiscountAmount__c != null) ? qutLine.SBQQ__AdditionalDiscountAmount__c : 0;
                            
                            Decimal maxDisc = qutLine.ListPrice_Display__c - purchasingPrice;
                            if(qutLine.SBQQ__AdditionalDiscountAmount__c < maxDisc){
                                if( (qutLine.SBQQ__AdditionalDiscountAmount__c + remainingDiscount) <= maxDisc && purQuantity == 1){
                                    qutLine.SBQQ__AdditionalDiscountAmount__c += remainingDiscount;
                                    remainingDiscount = 0;                                    
                                }else if(purQuantity > 1){
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc/purQuantity;
                                }else{
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                               
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc;
                                }
                                mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                            }
                            
                            
                        }
                    }
                    
                } 
    
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c > 0 && qutLine.SBQQ__Product__r.Family =='120' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c && qutLine.ListUnitPrice_Display__c > 0 && !qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){ 
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForMaintenance__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                    
                   system.debug('mapQuoteLinesDiscount Before : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family));
                    system.debug('Max disc To be allocated ' + (qutLine.ListPrice_Display__c - purchasingPrice));
                    if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                 
                    }else if(qutLine.ListPrice_Display__c != null && qutLine.ListPrice_Display__c > 0){
                        if(remainingDiscount > 0 ){
                            qutLine.SBQQ__AdditionalDiscountAmount__c = (qutLine.SBQQ__AdditionalDiscountAmount__c != null) ? qutLine.SBQQ__AdditionalDiscountAmount__c : 0;
                            
                            Decimal maxDisc = qutLine.ListPrice_Display__c - purchasingPrice;
                            if(qutLine.SBQQ__AdditionalDiscountAmount__c < maxDisc){
                                if( (qutLine.SBQQ__AdditionalDiscountAmount__c + remainingDiscount) <= maxDisc && purQuantity == 1){
                                    qutLine.SBQQ__AdditionalDiscountAmount__c += remainingDiscount;
                                    remainingDiscount = 0;                                    
                                }else if(purQuantity > 1){
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc/purQuantity;
                                }else{
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc;
                                }
                                mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                            }
                            
                            
                        }
                    }
                    
                } 
    
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c > 0 && qutLine.SBQQ__Product__r.Family =='140' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c && qutLine.ListUnitPrice_Display__c > 0 && !qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){ 
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForProfessional_Services__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                    
                   system.debug('mapQuoteLinesDiscount Before : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family));
                    system.debug('Max disc To be allocated ' + (qutLine.ListPrice_Display__c - purchasingPrice));
                    if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                 
                    }else if(qutLine.ListPrice_Display__c != null && qutLine.ListPrice_Display__c > 0){
                        if(remainingDiscount > 0 ){
                            qutLine.SBQQ__AdditionalDiscountAmount__c = (qutLine.SBQQ__AdditionalDiscountAmount__c != null) ? qutLine.SBQQ__AdditionalDiscountAmount__c : 0;
                            
                            Decimal maxDisc = qutLine.ListPrice_Display__c - purchasingPrice;
                            if(qutLine.SBQQ__AdditionalDiscountAmount__c < maxDisc){
                                if( (qutLine.SBQQ__AdditionalDiscountAmount__c + remainingDiscount) <= maxDisc && purQuantity == 1){
                                    qutLine.SBQQ__AdditionalDiscountAmount__c += remainingDiscount;
                                    remainingDiscount = 0;                                    
                                }else if(purQuantity > 1){
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc/purQuantity;
                                }else{
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc;
                                }
                                mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                            }
                            
                            
                        }
                    }
                    
                } 
    
                
                if(mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c > 0 && qutLine.SBQQ__Product__r.Family =='130' && tempTotal >  mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c && qutLine.ListUnitPrice_Display__c > 0 && !qutLine.SBQQ__Product__r.SBQQ__NonDiscountable__c){ 
              
                    decimal discountPrice = tempTotal - mapQuote.get(qutLine.SBQQ__Quote__c).TargetedPriceForSaas__c;
                    decimal purQuantity  = (qutline.SBQQ__Quantity__c >0)?qutline.SBQQ__Quantity__c:1;
                    decimal discPercentage = (qutLine.ListUnitPrice_Display__c * purQuantity) / tempTotal;
                    decimal additionalDiscountAmountCal= discountPrice * discPercentage;
                    decimal purchasingPrice =(qutLine.SBQQ__Product__r.Purchasing_Price__c >0)?qutLine.SBQQ__Product__r.Purchasing_Price__c* purQuantity:0;
                    
                    
    
                    decimal remainingDiscount = (mapQuoteLinesDiscount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                                mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                                                
                    integer remainingCount = (mapQuoteLinesCount.containsKey(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)) ? 
                                             mapQuoteLinesCount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) : 0;
                    
                   system.debug('mapQuoteLinesDiscount Before : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family));
                    system.debug('Max disc To be allocated ' + (qutLine.ListPrice_Display__c - purchasingPrice));
                    if((qutLine.ListPrice_Display__c - additionalDiscountAmountCal) < purchasingPrice ){
                 
                    }else if(qutLine.ListPrice_Display__c != null && qutLine.ListPrice_Display__c > 0){
                        if(remainingDiscount > 0 ){
                            qutLine.SBQQ__AdditionalDiscountAmount__c = (qutLine.SBQQ__AdditionalDiscountAmount__c != null) ? qutLine.SBQQ__AdditionalDiscountAmount__c : 0;
                            
                            Decimal maxDisc = qutLine.ListPrice_Display__c - purchasingPrice;
                            if(qutLine.SBQQ__AdditionalDiscountAmount__c < maxDisc){
                                if( (qutLine.SBQQ__AdditionalDiscountAmount__c + remainingDiscount) <= maxDisc && purQuantity == 1){
                                    qutLine.SBQQ__AdditionalDiscountAmount__c += remainingDiscount;
                                    remainingDiscount = 0;                                    
                                }else if(purQuantity > 1){
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc/purQuantity;
                                }else{
                                    remainingDiscount = remainingDiscount - (maxDisc - qutLine.SBQQ__AdditionalDiscountAmount__c);                                    
                                    qutLine.SBQQ__AdditionalDiscountAmount__c = maxDisc;
                                }
                                mapQuoteLinesDiscount.put(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family, remainingDiscount);
                            }
                            
                            
                        }
                    }
                    
                }
                
                isAbove = ( mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family) > 0);
                
                system.debug('mapQuoteLinesDiscount : ' +  mapQuoteLinesDiscount.get(qutLine.SBQQ__Quote__c + '' + qutLine.SBQQ__Product__r.Family)); 
                listQuoteLineToBeUpdated.add(qutLine);
                
                
            }// endElse

 
        }//endFor

        if(!isAbove){
            try{
                update listQuoteLineToBeUpdated; 
            }catch (DMLException dmlex) {
                throw new CalloutException(dmlex.getDmlMessage(0));
            } catch (Exception ex) {
                throw new CalloutException(ex.getMessage());
            }
        }else{
            CalloutException e = new CalloutException();
            e.setMessage('Targeted Price too low, please review your objective !');
            throw e;
        }

    }
}