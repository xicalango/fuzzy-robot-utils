package xx.btw2009.beans;

import java.util.List;

import xx.btw2009.dao.ReferenceSetterFor;
import xx.btw2009.dao.SetterFor;
import xx.btw2009.dao.TableName;

@TableName("Jahr")
public class Jahr implements BTW2009Bean {
	private int jahr;
	private List<Land> laender; 

	public int getJahr() {
		return jahr;
	}

	@SetterFor("jahr")
	public void setJahr(int jahr) {
		this.jahr = jahr;
	}

	public List<Land> getLaender() {
		return laender;
	}

	@ReferenceSetterFor(Land.class)
	public void setLaender(List<Land> laender) {
		this.laender = laender;
	}
	
	
	
	
}
