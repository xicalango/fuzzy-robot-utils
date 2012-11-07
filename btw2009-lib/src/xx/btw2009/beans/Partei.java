package xx.btw2009.beans;

import xx.btw2009.beans.factory.Setter;

public class Partei implements BTW2009Bean {

	private int id;
	private String name;
	
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
