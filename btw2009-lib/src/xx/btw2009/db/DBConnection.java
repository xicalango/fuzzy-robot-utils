package xx.btw2009.db;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

public interface DBConnection {
	Connection newConnection() throws SQLException;
	
	Statement createStatement() throws SQLException;
	PreparedStatement prepareStatement(String statement) throws SQLException;
}
