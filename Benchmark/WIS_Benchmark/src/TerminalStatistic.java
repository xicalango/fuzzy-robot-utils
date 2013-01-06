
public class TerminalStatistic {

	private AccessTimeContainer accessTimes;

	public TerminalStatistic() {
		this.accessTimes = new AccessTimeContainer();
	}

	public void addEntry(UrlInfo i, double timeNeeded) {
		this.accessTimes.addAccessTime(i, timeNeeded);
	}

	public double getMeanTime(UrlInfo info) {
		int sum = 0;
		int measures = 0;
		for (Double i : accessTimes.getAccessTime(info).getAccessTime()) {
			sum += i;
			measures++;
		}
		return sum / measures;
	}

	public String printStatistics() {
		String s = "";
		for (int i = 0; i < this.accessTimes.size(); i++) {
			UrlInfo info = this.accessTimes.get(i).getUrl();
			s += info.toString() + " Avg: " + this.getMeanTime(info) + " ms\n";
		}
		return s;
	}

	public AccessTimeContainer getAccessTimes() {
		return accessTimes;
	}
	
	 

}
