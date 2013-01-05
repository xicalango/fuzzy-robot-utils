package xx.btw2009.beans;

import xx.btw2009.beans.factory.ReferenceSetter;
import xx.btw2009.beans.factory.Setter;

public class Direktkandidat implements BTW2009Bean {
	private String vorname;
	private String nachname;
	private Partei partei;
	
	
	public String getVorname() {
		return vorname;
	}
	
	@Setter("vorname")
	public void setVorname(String vorname) {
		this.vorname = vorname;
	}
	public String getNachname() {
		return nachname;
	}
	
	@Setter("nachname")
	public void setNachname(String nachname) {
		this.nachname = nachname;
	}
	
	public Partei getPartei() {
		return partei;
	}
	
	@ReferenceSetter(refClass = Partei.class, column="partei_id")
	public void setPartei(Partei partei) {
		this.partei = partei;
	}
	
	
}
