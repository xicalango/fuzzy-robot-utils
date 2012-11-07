package xx.btw2009.beans;

import java.util.List;

import xx.btw2009.beans.factory.Setter;

public class Land implements BTW2009Bean {
	
	private int id;
	private String name;
	
	private List<Wahlkreis> wahlkreise;
	private List<Landesliste> landeslisten;
	
	public List<Wahlkreis> getWahlkreise() {
		return wahlkreise;
	}

	public void setWahlkreise(List<Wahlkreis> wahlkreise) {
		this.wahlkreise = wahlkreise;
	}

	public List<Landesliste> getLandeslisten() {
		return landeslisten;
	}

	public void setLandeslisten(List<Landesliste> landeslisten) {
		this.landeslisten = landeslisten;
	}

	public int getId() {
		return id;
	}
	
	@Setter("id")
	public void setId(int id) {
		this.id = id;
	}
	
	public String getName() {
		return name;
	}
	
	@Setter("name")
	public void setName(String name) {
		this.name = name;
	}
	
	
}
