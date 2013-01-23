package domain;

public class Party{

	private String name;
	private int ID;
	
	public String getName() {
		return name;
	}

	public int getID() {
		return ID;
	}

	
	public Party(int ID, String name){
		this.ID = ID;
		this.name = name;		
	}
	
	public String toString(){
		return this.name;
	}

}
