import java.util.List;

public class WorkloadMix {

	private List<URL_Freq> urlList;

	public List<URL_Freq> getUrlList() {
		return urlList;
	}

	private void setUrlList(List<URL_Freq> urlList) {
		this.urlList = urlList;
	}

	public WorkloadMix(List<URL_Freq> urlList) {
		this.setUrlList(urlList);
	}

}
