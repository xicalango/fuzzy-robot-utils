package xx.btw2009.beans;

import xx.btw2009.beans.factory.Setter;

public class Landeskandidat implements BTW2009Bean {
	private int id;
	private String vorname;
	private String nachname;
	private int listenrang;
	
	public int getId() {
		return id;
	}
	
	@Setter("id")
	public void setId(int id) {
		this.id = id;
	}
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
	public int getListenrang() {
		return listenrang;
	}
	
	@Setter("listenrang")
	public void setListenrang(int listenrang) {
		this.listenrang = listenrang;
	}
	
	
}
