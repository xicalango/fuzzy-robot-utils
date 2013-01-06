import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Benchmark {

	private WorkloadMix wm;
	private int terminals;
	private Timeout t;
	private int measurements;
	private List<Terminal> terminalList;
	private List<Thread> threadList;

	public Benchmark(WorkloadMix wm, int terminals, Timeout t, int measurements) {
		this.wm = wm;
		this.terminals = terminals;
		this.t = t;
		this.measurements = measurements;
		this.terminalList = new ArrayList<Terminal>();
		this.threadList = new ArrayList<Thread>();
	}

	public void startBenchmark() throws InterruptedException {
		for (int i = 0; i < this.terminals; i++) {
			terminalList.add(new Terminal(new CardDeck(this.wm), this.t,
					this.measurements));
		}
		for (Runnable r : this.terminalList) {
			Thread t = new Thread(r);
			t.start();
			this.threadList.add(t);
		}
		System.out.println("Benchmarks started\n");
		for (Thread t : this.threadList)
			t.join();
		System.out.println("Benchmarks finished\n\n");
	}

	public String getStatistics() {
		int number = 1;
		
		String s = "";
		
		for (Terminal t : this.terminalList) {
			s += ("Terminal " + number + ":\n" + t.getStatistic().printStatistics()) + "\n\n";
			number++;
		}
		return s;
	}

	public String getAggregatedStatistics() {
		Map<UrlInfo, List<Double>> completeStatistics = new HashMap<>();
		StringBuilder sb = new StringBuilder();
		
		for(Terminal t : this.terminalList) {
			for(UrlAccessTimes uat : t.getStatistic().getAccessTimes()) {
				if(!completeStatistics.containsKey(uat.getUrl())) {
					completeStatistics.put(uat.getUrl(), new ArrayList<Double>());
				}
				
				completeStatistics.get(uat.getUrl()).addAll(uat.getAccessTime());
			}
		}
		
		for(Map.Entry<UrlInfo, List<Double>> entries : completeStatistics.entrySet()) {
			
			final List<Double> times = entries.getValue();
			final UrlInfo urlInfo = entries.getKey();
			
			double sumTime = 0;
			for(double time : times) {
				sumTime += time;
			}
			
			double avgTime = sumTime / times.size();
			
			sb.append(urlInfo + "Executions: "+ times.size() +"\nSum time: " + sumTime +"\nAvg time: " + avgTime+"\n");
		}
		
		return sb.toString();
	}
}
