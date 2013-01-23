package domain;

import java.util.List;

public class PartyList {

	private int ID;
	public int getID() {
		return ID;
	}

	private Party party;
	private int sortingNumber;
	private FederalState fState;	
	private List<LCandidate> candidates;
	
	public Party getParty() {
		return party;
	}

	public int getSortingNumber() {
		return sortingNumber;
	}

	public FederalState getfState() {
		return fState;
	}

	public List<LCandidate> getCandidates() {
		return candidates;
	}
	
	public PartyList(int ID, Party party, int sortingNumber, FederalState fState, List<LCandidate> candidates){
		this.ID = ID;
		this.party = party;
		this.sortingNumber = sortingNumber;
		this.fState = fState;
		this.candidates = candidates;
	}
	
	public String toString(){
		return party + " " + fState;
	}
	
}
