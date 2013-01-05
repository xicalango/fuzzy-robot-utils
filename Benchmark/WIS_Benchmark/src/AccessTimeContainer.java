import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public class AccessTimeContainer implements Iterable<UrlAccessTimes> {

	private List<UrlAccessTimes> accessTimes;

	public AccessTimeContainer() {
		this.accessTimes = new ArrayList<UrlAccessTimes>();
	}

	public void addAccessTime(UrlInfo u, double accessTime) {
		boolean found = false;
		for (UrlAccessTimes at : this.accessTimes) {
			if (at.getUrl().equals(u)) {
				at.addAccessTime(accessTime);
				found = true;
				break;
			}
		}
		if (!found) {
			UrlAccessTimes at = new UrlAccessTimes(u);
			at.addAccessTime(accessTime);
			this.accessTimes.add(at);

		}
	}

	public UrlAccessTimes getAccessTime(UrlInfo i) {
		for (UrlAccessTimes t : this.accessTimes) {
			if (t.getUrl().equals(i)) {
				return t;
			}
		}
		return null;
	}

	public UrlAccessTimes get(int i) {
		return this.accessTimes.get(i);
	}

	public int size() {
		return this.accessTimes.size();
	}

	@Override
	public Iterator<UrlAccessTimes> iterator() {
		return accessTimes.iterator();
	}

}
