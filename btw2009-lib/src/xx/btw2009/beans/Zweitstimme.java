package xx.btw2009.beans;

import xx.btw2009.beans.factory.ReferenceSetter;

public class Zweitstimme implements BTW2009Bean {
	private Wahlbezirk wahlbezirk;
	private Landesliste landesliste;
	
	public Wahlbezirk getWahlbezirk() {
		return wahlbezirk;
	}
	@ReferenceSetter(refClass= Wahlbezirk.class, column="wahlbezirk_id")
	public void setWahlbezirk(Wahlbezirk wahlbezirk) {
		this.wahlbezirk = wahlbezirk;
	}
	public Landesliste getLandesliste() {
		return landesliste;
	}
	@ReferenceSetter(refClass= Landesliste.class, column="landesliste_id")
	public void setLandesliste(Landesliste landesliste) {
		this.landesliste = landesliste;
	}
	
	
}
