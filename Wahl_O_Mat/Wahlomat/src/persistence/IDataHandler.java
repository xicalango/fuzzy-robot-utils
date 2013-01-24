package persistence;

import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

import domain.DCandidate;
import domain.District;
import domain.FederalState;
import domain.PartyList;

public interface IDataHandler {
	
	void setDBUrl(String url);
	
	void setDBUserName(String name);
	
	void setDBPasswd(String passwd);
	
	
	
	List<District> getDistricts() throws SQLException;
	
	List<DCandidate> getDCandidates(District district) throws SQLException;
	
	List<PartyList> getPartyLists(District district) throws SQLException;
	
	List<FederalState> getFederalStates() throws SQLException;
	
	boolean access(UUID uuid) throws SQLException;
	
	void vote(UUID uuid, PartyList party, DCandidate dCandidate, District district) throws SQLException;
	
	void establishConnection() throws SQLException;
	
	void closeConnection() throws SQLException;
}
