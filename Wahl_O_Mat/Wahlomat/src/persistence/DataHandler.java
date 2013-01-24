package persistence;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.Vector;

import domain.DCandidate;
import domain.District;
import domain.FederalState;
import domain.LCandidate;
import domain.Party;
import domain.PartyList;
import java.sql.*;

import org.postgresql.util.PSQLException;

public class DataHandler implements IDataHandler {

	
	private Connection connection;
	
	//This is a cache-list (used for getDistricts in order to 
	private List<FederalState> loadedStates;
	private List<Party> loadedPartys;
	
	private String url;
	private String username;
	private String password;
	
	public DataHandler() throws ClassNotFoundException, SQLException, PSQLException{	
		this.loadedStates = new ArrayList<FederalState>();
		this.loadedPartys = new ArrayList<Party>();
		Class.forName("org.postgresql.Driver");		
	}	
	
	@Override
	public void establishConnection() throws SQLException {		
		this.connection = DriverManager.getConnection(url, username, password);		
	}


	@Override
	public void closeConnection() throws SQLException {
		this.connection.close();			
	}
	
	
	
	
	@Override
	public List<District> getDistricts() throws SQLException {
		Statement statement = this.connection.createStatement();
		ResultSet rs = statement.executeQuery("Select * from wahlkreis w, land l WHERE w.land_id = l.id AND l.jahr = 2009 order by w.name asc");
		Vector<District> districts = new Vector<District>();		
		while(rs.next()){
			int district_id = rs.getInt("id");
			String district_name = rs.getString("name");
			int district_electorate = rs.getInt("wahlberechtigte");
			int federalState_id = rs.getInt("land_id");
			
			FederalState f_state = this.getFederalStateByID(federalState_id);
			districts.add(new District(district_id, district_name, f_state, district_electorate));
		}		
		return districts;
	}
	
	

	@Override
	public List<DCandidate> getDCandidates(District district) throws SQLException {
		PreparedStatement getDCandByDistrict = this.connection.prepareStatement("Select * from Direktkandidat WHERE wahlkreis_id = ?" );
		getDCandByDistrict.setInt(1, district.getID());
		ResultSet rs = getDCandByDistrict.executeQuery();
		List<DCandidate> candidateList = new ArrayList<DCandidate>();
		while(rs.next()){
			int id = rs.getInt("id");
			String firstName = rs.getString("vorname");
			String lastName = rs.getString("nachname");
			int partyID = rs.getInt("partei_id");
			
			if(partyID != 0){
			candidateList.add(new DCandidate(id, firstName, lastName, district, this.getPartyByID(partyID)));
			}
			else{
				candidateList.add(new DCandidate(id, firstName, lastName, district, null));
			}
		}
		return candidateList;
	}
	
	
	private Party getPartyByID(int ID) throws SQLException{		
		for(Party p : this.getPartys()){
			if(p.getID() == ID) return p;
		}
		return null;
	}
	
	private List<Party> getPartys() throws SQLException{
		if(this.loadedPartys.size() == 0){
			Statement getAllPartys = this.connection.createStatement();		
			ResultSet rs = getAllPartys.executeQuery("Select * from partei order by name asc");
			
			List<Party> partys = new ArrayList<Party>();
			
			while(rs.next()){
				int id = rs.getInt("id");
				String name = rs.getString("name");
				partys.add(new Party(id, name));
			}		
				this.loadedPartys = partys;
			}
			return this.loadedPartys;
	}
	
	
	
	private FederalState getFederalStateByID(int ID) throws SQLException{		
		for(FederalState state : this.getFederalStates()){
			if(state.getID() == ID){
				return state;
			}
		}			
		return null;		
	}
	
	
	
	
	
	
	/*
	private District getDistrictByDCandidateID(int dCandidateID) throws SQLException{
		PreparedStatement getDCandByDistrict = this.connection.prepareStatement("Select w.id, w.name, w.land_id, w.wahlberechtigte from Wahlkreis, Direktkandidat WHERE w.id = d.wahlkreis_id AND d.id = " );
		getDCandByDistrict.setInt(1, dCandidateID);
		ResultSet rs = getDCandByDistrict.executeQuery();

		int land_id = rs.getInt("land_id");
		int wahlkreis_id = rs.getInt("id");
		String wahlkreis_name = rs.getString("name");		
		int wahlberechtigte = rs.getInt("wahlberechtigte");
		
		PreparedStatement getFederalStateById = this.connection.prepareStatement("Select l.id, l.name, l.jahr from Land where l.id = " );
		getFederalStateById.setInt(1, land_id);
		ResultSet federalState = getFederalStateById.executeQuery();
				
		String land_name = federalState.getString("name");
		int land_jahr = federalState.getInt("jahr");		
		
		FederalState state = new FederalState(land_id, land_name, land_jahr);
		District result = new District(wahlkreis_id, wahlkreis_name, state, wahlberechtigte);
		return result;
	}
	*/

	@Override
	public List<PartyList> getPartyLists(District district) throws SQLException {
		PreparedStatement getParyListsByDistrictStatement = this.connection.prepareStatement("Select * from Landesliste WHERE  land_id = ?" );
		getParyListsByDistrictStatement.setInt(1, district.getfState().getID());
		ResultSet rs = getParyListsByDistrictStatement.executeQuery();
		
		List<PartyList> partyListList = new ArrayList<PartyList>();
		
		while(rs.next()){			
			int partyList_id = rs.getInt("id");
			int partyList_rank = rs.getInt("listenplatz");
			int party_id = rs.getInt("partei_id");			
			PartyList l = new PartyList(partyList_id, this.getPartyByID(party_id), partyList_rank, district.getfState(), this.getLCandidatesByPartyListID(partyList_id));			
			partyListList.add(l);		
		}		
		
		return partyListList;
	}

	
	private List<LCandidate> getLCandidatesByPartyListID(int partyList_id) throws SQLException{
		PreparedStatement getParyListsByDistrictStatement = this.connection.prepareStatement("Select * from Landeskandidat WHERE  landesliste_id = ?" );
		getParyListsByDistrictStatement.setInt(1, partyList_id);
		ResultSet rs = getParyListsByDistrictStatement.executeQuery();
		
		List<LCandidate> candList = new ArrayList<LCandidate>();
		
		while(rs.next()){
			int lCand_id = rs.getInt("id");
			String lCand_firstName = rs.getString("vorname");
			String lCand_lastName = rs.getString("nachname");
			int lCand_rank = rs.getInt("listenrang");			
			LCandidate cand = new LCandidate(lCand_id, lCand_firstName, lCand_lastName, lCand_rank);	
			candList.add(cand);
		}
		return candList;
	}
	
	@Override
	public boolean access(UUID uuid) throws SQLException {
		PreparedStatement accessStatement = this.connection.prepareStatement("SELECT check_uuid( ?, 2009)" ); 
		accessStatement.setObject(1, uuid);
		ResultSet rs = accessStatement.executeQuery();
		rs.next();

		return rs.getBoolean(1);		
	}

	@Override
	public void vote(UUID uuid, PartyList party, DCandidate dCandidate, District district) throws SQLException{
	this.connection.setAutoCommit(false);
	PreparedStatement firstVoteStatement = this.connection.prepareStatement("INSERT INTO Erststimme (wahlkreis_id, direktkandidat_id) values(?, ?)" ); 	
	firstVoteStatement.setInt(1, district.getID());
	firstVoteStatement.setInt(2, dCandidate.getID());	
	
	
	PreparedStatement secondVoteStatement = this.connection.prepareStatement("INSERT INTO Zweitstimme (wahlkreis_id, landesliste_id) values(?, ?)");
	secondVoteStatement.setInt(1, district.getID());
	secondVoteStatement.setInt(2, party.getID());	
	
	PreparedStatement updateUUIDTableStatement = this.connection.prepareStatement("Update berechtigten_uuid set used = true where id = ?");
	updateUUIDTableStatement.setObject(1, uuid);
	
	firstVoteStatement.executeUpdate();
	secondVoteStatement.executeUpdate();
	updateUUIDTableStatement.executeUpdate();
	
	this.connection.commit();
	this.connection.setAutoCommit(true);
	}

	@Override
	public List<FederalState> getFederalStates() throws SQLException {
		if(this.loadedStates.size() == 0){
		Statement getAllStates = this.connection.createStatement();		
		ResultSet rs = getAllStates.executeQuery("Select * from land where jahr = 2009 order by name asc");
		
		List<FederalState> states = new ArrayList<FederalState>();
		
		while(rs.next()){
			int id = rs.getInt("id");
			String name = rs.getString("name");
			int year = rs.getInt("jahr");
			states.add(new FederalState(id, name, year));
		}		
			this.loadedStates = states;		
		}
		return this.loadedStates;
	}

	public void setDBUrl(String url) {
		this.url = url;		
	}

	public void setDBUserName(String username) {
		this.username = username;
	}

	public void setDBPasswd(String password) {
		this.password = password;
	}




}
