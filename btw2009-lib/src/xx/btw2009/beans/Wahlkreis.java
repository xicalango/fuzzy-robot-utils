package xx.btw2009.beans;

import java.util.List;

import xx.btw2009.beans.factory.Setter;

public class Wahlkreis implements BTW2009Bean {
	private int id;
	private String name;
	private List<Wahlbezirk> wahlbezirke;
	private List<Direktkandidat> direktkandidaten;
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
	
	public List<Wahlbezirk> getWahlbezirke() {
		return wahlbezirke;
	}
	
	public void setWahlbezirke(List<Wahlbezirk> wahlbezirke) {
		this.wahlbezirke = wahlbezirke;
	}
	
	public List<Direktkandidat> getDirektkandidaten() {
		return direktkandidaten;
	}
	
	public void setDirektkandidaten(List<Direktkandidat> direktkandidaten) {
		this.direktkandidaten = direktkandidaten;
	}
	

}
