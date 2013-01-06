import java.util.Arrays;
import java.util.List;

public class Test {

	private static enum Wahlkreis {
		BREMEN_I(55), //256131 wahlberechtigte
		DEGGENDORF(227), //154767 wahlberechtigte
		WESEL_I(114); //207451 wahlberechtigte
		
		public final int id;

		private Wahlkreis(int id) {
			this.id = id;
		}
	}
	
	private static enum Partei {
		CSU(7);
		
		public final int id;

		private Partei(int id) {
			this.id = id;
		}
	}
	
	private static enum Host {
		LOCAL_LINK("192.168.34.10"),
		MINITUX("minitux.dyndns.org:8080");
		
		public final String host;

		private Host(String host) {
			this.host = host;
		}
	}
	
	public static void main(String[] args) {
		
		//Host usedHost = Host.LOCAL_LINK;
		Host usedHost = Host.MINITUX; //Take this when accessing from out of my home network ;)
		
		List<String> q1 = Arrays.asList("http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/sitzverteilung_diag_daten.php");
		
		List<String> q2 = Arrays.asList("http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/mitglieder_bundestag_list_daten.php");
		
		List<String> q3 = Arrays.asList(
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/erststimme_absolut_wahlkreis.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id,
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/erststimme_prozent_wahlkreis.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id,
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/zweitstimme_absolut_wahlkreis.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id,
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/zweitstimme_prozent_wahlkreis.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id,
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/erststimme_differenz_wahlkreis.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id,
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/zweitstimme_differenz_wahlkreis.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id,
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/wahlkreis_info.php?wahlkreisid=" + Wahlkreis.BREMEN_I.id
				);
		
		List<String> q4 = Arrays.asList(
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/wahlkreissieger_partei_erststimme.php",
				"http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/wahlkreissieger_partei_zweitstimme.php"
				);
		
		List<String> q5 = Arrays.asList("http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/ueberhangmandate.php");
		
		List<String> q6 = Arrays.asList("http://" + usedHost.host + "/btw2009/fuzzy-robot/adapters/top_10_knappste.php?parteiid=" + Partei.CSU.id);

		List<URL_Freq> l = Arrays.asList(
				new URL_Freq(new UrlInfo("q1",q1), 25),
				new URL_Freq(new UrlInfo("q2",q2), 10),
				new URL_Freq(new UrlInfo("q3",q3), 25),
				new URL_Freq(new UrlInfo("q4",q4), 10),
				new URL_Freq(new UrlInfo("q5",q5), 10),
				new URL_Freq(new UrlInfo("q6",q6), 10)
				);
		
		//Nächste zeile auskommentieren um statistik Ausgabe in Datei umzuleiten
		Output.INSTANCE.setOutputToFile("output.txt");
		
		Benchmark b = new Benchmark(new WorkloadMix(l), 10, new Timeout(1), 10);
		
		try {
			b.startBenchmark();
			Output.stream().println(b.getStatistics());
			Output.stream().println(b.getAggregatedStatistics());
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		Output.INSTANCE.close();
	}

}
