import java.util.List;

public class UrlInfo {

	private String name = "";
	private List<String> urls;

	public UrlInfo(List<String> urls) {
		this("",urls);
	}
	
	public UrlInfo(String name, List<String> urls) {
		this.name = name;
		this.urls = urls;
	}


	public String toString() {
		String s = name+":\n";
		for (String u : this.urls) {
			s += u + "\n";
		}

		return s;
	}

	public List<String> getUrls() {
		return urls;
	}

	public boolean equals(Object o) {
		if (o instanceof UrlInfo) {
			UrlInfo info = (UrlInfo) o;
			if (info.getUrls().equals(this.getUrls()))
				return true;
		}
		return false;
	}

	public String getName() {
		return name;
	}

}
