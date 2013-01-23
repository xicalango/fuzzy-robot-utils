package domain;

public class District {
	
	private int ID;
	private String name;
	private FederalState fState;
	private int electorate;
	
	public int getID() {
		return ID;
	}

	public String getName() {
		return name;
	}

	public FederalState getfState() {
		return fState;
	}

	public int getElectorate() {
		return electorate;
	}

	
	public District(int ID, String name, FederalState fState, int electorate){
		this.ID = ID; 
		this.name = name;
		this.fState = fState;
		this.electorate = electorate;
	}
	
	public String toString(){
		return this.name;
	}
	
}
