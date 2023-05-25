public with sharing class ReportComponentController {
    @AuraEnabled
    public static String getReportMetadata ( Id reportId,Id recId ){
  
        
        string reportPlannedId=reportId;
        string filterId=String.valueOf(recId).substring(0, 15);
        // Retrieves report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportPlannedId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        // Add/Override filters
        Reports.ReportFilter filterlist = reportMd.getReportFilters()[0];
        filterlist .setValue(filterId);
        //and Run report
        Reports.ReportResults reportResult = Reports.ReportManager.runReport(reportPlannedId,reportMd,true);
        system.debug('ReportResultsJSON'+JSON.serialize(reportResult));
        return JSON.serialize(reportResult);
        
        // return JSON.serializePretty(Reports.ReportManager.runReport( reportId, true ) );
    }
}