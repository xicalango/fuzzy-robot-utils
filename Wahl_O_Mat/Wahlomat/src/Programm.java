import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import gui.BallotCardPanel;
import gui.LoginWindow;
import gui.VoteFrame;

import javax.swing.JFrame;
import javax.swing.JRadioButton;

import persistence.DataHandler;
import persistence.IDataHandler;

import domain.BallotCard;
import domain.DCandidate;
import domain.District;
import domain.FederalState;
import domain.LCandidate;
import domain.Party;
import domain.PartyList;


public class Programm {

	/**
	 * @param args
	 * @throws SQLException 
	 * @throws ClassNotFoundException 
	 */
	public static void main(String[] args) throws ClassNotFoundException, SQLException {
		
	
		
		IDataHandler dh = new DataHandler();
				
		char[] psw = {'a'};
		new LoginWindow(dh, psw);
				
	}

}
