public class URL_Freq {

	public UrlInfo getUrl() {
		return url;
	}

	public int getFreq() {
		return freq;
	}

	public void setFreq(int freq) {
		this.freq = freq;
	}

	private UrlInfo url;
	private int freq;

	URL_Freq(UrlInfo url, int freq) {
		this.url = url;
		if (freq < 0 || freq > 100)
			throw new IllegalArgumentException("Illegal Frequency");
		this.freq = freq;
	}

}
