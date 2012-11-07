package xx.btw2009.beans;

import java.util.List;

import xx.btw2009.beans.factory.Setter;

public class Jahr implements BTW2009Bean {
	private int jahr;
	private List<Land> laender; 

	public int getJahr() {
		return jahr;
	}

	@Setter("jahr")
	public void setJahr(int jahr) {
		this.jahr = jahr;
	}

	public List<Land> getLaender() {
		return laender;
	}

	public void setLaender(List<Land> laender) {
		this.laender = laender;
	}
	
	
	
}
