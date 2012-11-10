package xx.btw2009.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;

public enum DBConnections implements DBConnection {
	LOCALHOST("org.postgresql.Driver", "jdbc:postgresql://localhost/btw2009", "alexx", "alexx"),
	LINK("org.postgresql.Driver", "jdbc:postgresql://192.168.34.209/btw2009", "alexx", "alexx");

	private String driverClass;
	private String connectionString;
	private String username;
	private String password;

	private DBConnections(String driverClass, String connectionString,
			String username, String password) {
		this.driverClass = driverClass;
		this.connectionString = connectionString;
		this.username = username;
		this.password = password;
		
		try {
			Class.forName(driverClass);
		} catch (ClassNotFoundException e) {
			throw new RuntimeException(e);
		}
	}

	@Override
	public Connection newConnection() throws SQLException {
		return DriverManager.getConnection(connectionString, username, password);
	}

	@Override
	public Statement createStatement() throws SQLException {
		return newConnection().createStatement();
	}

	@Override
	public PreparedStatement prepareStatement(String statement) throws SQLException {
		return newConnection().prepareStatement(statement);
	}

}
