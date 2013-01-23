package domain;

public class FederalState {

	
	private int ID;
	private String name;
	private int year;

	public int getID() {
		return ID;
	}

	public String getName() {
		return name;
	}

	public int getYear() {
		return year;
	}
	
	public FederalState(int ID, String name, int year){
		this.ID = ID; 
		this.name = name;
		this.year = year;
	}
	
	public boolean equals(Object o){
		if(o instanceof FederalState){
			FederalState s = (FederalState) o;
			if(s.ID == this.ID) return true;
		}
		return false;
	}
	
	public String toString(){
		return this.name;
	}
	
	
}