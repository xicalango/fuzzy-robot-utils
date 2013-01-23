package domain;

public class LCandidate{

	
	private int ID;
	private String firstName;
	private String lastName;
	private int rank;
	
	public int getID() {
		return ID;
	}

	public String getFirstName() {
		return firstName;
	}

	public String getLastName() {
		return lastName;
	}

	public int getRank() {
		return rank;
	}
	
	public LCandidate(int ID, String firstName, String lastName, int rank){
		this.ID = ID;
		this.firstName = firstName;
		this.lastName = lastName;
		this.rank = rank;
	}

	
	
}
