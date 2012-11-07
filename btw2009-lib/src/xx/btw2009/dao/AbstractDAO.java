package xx.btw2009.dao;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import xx.btw2009.beans.BTW2009Bean;
import xx.btw2009.beans.factory.BeanFactory;
import xx.btw2009.db.DBConnection;

public abstract class AbstractDAO<T extends BTW2009Bean> implements DAO<T> {

	protected DBConnection conn;
	private BeanFactory<T> factory;
	
	public AbstractDAO(DBConnection conn, BeanFactory<T> factory) {
		super();
		this.conn = conn;
		this.factory = factory;
	}

	@Override
	public List<T> selectAll() {
		Connection c = null;
		
		try {
			
			c = conn.newConnection();
			return doSelectAll(c);
			
		} catch (SQLException e) {
			throw new RuntimeException(e);
		} finally {
			if( c != null) {
				try {
					c.close();
				} catch (SQLException e) {
					throw new RuntimeException(e);
				}
			}
		}
	}
	
	protected T newBean(ResultSet rs) throws SQLException {
		return factory.fromResultSet(rs);
	}
	
	protected abstract List<T> doSelectAll(Connection c) throws SQLException;

	

}
