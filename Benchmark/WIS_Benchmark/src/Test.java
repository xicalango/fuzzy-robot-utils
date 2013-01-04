import java.util.ArrayList;

public class Test {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		ArrayList<URL_Freq> l = new ArrayList<URL_Freq>();

		ArrayList<String> q1 = new ArrayList<String>();
		q1.add("http://www.gamestar.de");
		q1.add("http://www.gamepro.de");
		q1.add("http://www.heise.de");
		l.add(new URL_Freq(new UrlInfo(q1), 50));

		ArrayList<String> q2 = new ArrayList<String>();
		q2.add("http://www.google.de");
		l.add(new URL_Freq(new UrlInfo(q2), 50));

		Benchmark b = new Benchmark(new WorkloadMix(l), 10, new Timeout(1), 10);
		try {
			b.startBenchmark();
			System.out.println(b.getStatistics());
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
