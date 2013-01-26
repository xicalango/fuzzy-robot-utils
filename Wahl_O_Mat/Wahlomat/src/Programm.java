import gui.LoginWindow;
import java.sql.SQLException;
import persistence.DataHandler;
import persistence.IDataHandler;


public class Programm {

	/**
	 * @param args
	 * @throws SQLException 
	 * @throws ClassNotFoundException 
	 */
	public static void main(String[] args) throws ClassNotFoundException, SQLException {
		
	
		
		IDataHandler dh = new DataHandler();
				
		char[] psw = {'a'};
		// Starts the login Window for the Admin. Sets the Admin-Password to a
		new LoginWindow(dh, psw);
				
	}

}
