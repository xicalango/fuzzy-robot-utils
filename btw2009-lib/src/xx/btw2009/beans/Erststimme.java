package xx.btw2009.beans;

import xx.btw2009.beans.factory.ReferenceSetter;

public class Erststimme implements BTW2009Bean {
	private Wahlbezirk wahlbezirk;
	private Direktkandidat direktkandidat;
	public Wahlbezirk getWahlbezirk() {
		return wahlbezirk;
	}
	
	@ReferenceSetter(refClass=Wahlbezirk.class, column="wahlbezirk_id")
	public void setWahlbezirk(Wahlbezirk wahlbezirk) {
		this.wahlbezirk = wahlbezirk;
	}
	public Direktkandidat getDirektkandidat() {
		return direktkandidat;
	}
	
	@ReferenceSetter(refClass=Direktkandidat.class, column="direktkandidat_id")
	public void setDirektkandidat(Direktkandidat direktkandidat) {
		this.direktkandidat = direktkandidat;
	}
	
	
}
