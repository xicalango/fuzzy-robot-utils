package xx.btw2009.beans;

import xx.btw2009.dao.SetterFor;
import xx.btw2009.dao.TableName;

@TableName("Partei")
public class Partei implements BTW2009Bean {

	private int id;
	private String name;
	
	public int getId() {
		return id;
	}
	
	@SetterFor("id")
	public void setId(int id) {
		this.id = id;
	}
	
	public String getName() {
		return name;
	}
	
	@SetterFor("name")
	public void setName(String name) {
		this.name = name;
	}

	
	
}
