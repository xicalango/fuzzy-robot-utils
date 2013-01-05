import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Test {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		ArrayList<URL_Freq> l = new ArrayList<URL_Freq>();

		
		List<String> q1 = Arrays.asList("http://192.168.34.10/btw2009/fuzzy-robot/adapters/sitzverteilung_diag_daten.php");

		ArrayList<String> q2 = new ArrayList<String>();
		q2.add("http://www.leereseite.com/");
		l.add(new URL_Freq(new UrlInfo(q2), 50));

		Output.INSTANCE.setOutputToFile("output.txt");
		
		Benchmark b = new Benchmark(new WorkloadMix(l), 1, new Timeout(1), 10);
		
		try {
			b.startBenchmark();
			Output.stream().println(b.getStatistics());
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		Output.INSTANCE.close();
	}

}
