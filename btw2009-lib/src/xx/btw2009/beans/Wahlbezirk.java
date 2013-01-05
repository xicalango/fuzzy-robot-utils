package xx.btw2009.beans;

import xx.btw2009.beans.factory.Setter;

public class Wahlbezirk implements BTW2009Bean {
	private int id;
	private int wahlberechtigte;
	private int ausgegebeneWahlscheine;
	
	public int getId() {
		return id;
	}
	
	@Setter("id")
	public void setId(int id) {
		this.id = id;
	}
	public int getWahlberechtigte() {
		return wahlberechtigte;
	}
	
	@Setter("wahlberechtigte")
	public void setWahlberechtigte(int wahlberechtigte) {
		this.wahlberechtigte = wahlberechtigte;
	}
	public int getAusgegebeneWahlscheine() {
		return ausgegebeneWahlscheine;
	}
	
	@Setter("ausgegebeneWahlscheine")
	public void setAusgegebeneWahlscheine(int ausgegebeneWahlscheine) {
		this.ausgegebeneWahlscheine = ausgegebeneWahlscheine;
	}
	
}
