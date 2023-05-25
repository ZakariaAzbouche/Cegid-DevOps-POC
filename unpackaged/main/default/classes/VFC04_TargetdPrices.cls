public class VFC04_TargetdPrices {
    public String quoteId { get; set; }
    public VFC04_TargetdPrices() {

		quoteId = ApexPages.currentPage().getParameters().get('quoteId');
    }

}