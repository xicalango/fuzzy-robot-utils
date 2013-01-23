package domain;

public class DCandidate{
	
	private int ID;
	private String firstName;
	private String lastName;
	private District district;
	private Party party;
	
	public int getID() {
		return ID;
	}

	public String getFirstName() {
		return firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public District getDistrict() {
		return district;
	}

	public Party getParty() {
		return party;
	}	
	
	public DCandidate(int ID, String firstName, String lastName, District district, Party party){
		this.ID = ID; 
		this.firstName = firstName;
		this.lastName = lastName;
		this.district = district;
		this.party = party;
	}
	
	
	public String toString(){
		return firstName + " " + lastName;
	}
		
}
