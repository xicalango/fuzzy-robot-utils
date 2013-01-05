package xx.btw2009.beans;

import java.util.List;

import xx.btw2009.beans.factory.ReferenceSetter;
import xx.btw2009.beans.factory.Setter;

public class Landesliste implements BTW2009Bean {
	private int id;
	private int listenplatz;
	private List<Landeskandidat> kandidaten;
	private Partei partei;
	
	public int getId() {
		return id;
	}
	
	@Setter("id")
	public void setId(int id) {
		this.id = id;
	}
	public int getListenplatz() {
		return listenplatz;
	}
	
	@Setter("listenplatz")
	public void setListenplatz(int listenplatz) {
		this.listenplatz = listenplatz;
	}
	public List<Landeskandidat> getKandidaten() {
		return kandidaten;
	}
	public void setKandidaten(List<Landeskandidat> kandidaten) {
		this.kandidaten = kandidaten;
	}

	public Partei getPartei() {
		return partei;
	}

	@ReferenceSetter(refClass=Partei.class, column="partei_id")
	public void setPartei(Partei partei) {
		this.partei = partei;
	}
	
	
}
