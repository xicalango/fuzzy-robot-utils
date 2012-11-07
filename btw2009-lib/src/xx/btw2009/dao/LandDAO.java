package xx.btw2009.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import xx.btw2009.beans.Jahr;
import xx.btw2009.beans.Land;
import xx.btw2009.beans.factory.AnnotationBeanFactory;
import xx.btw2009.db.DBConnection;

public class LandDAO extends AbstractDAO<Land> {

	public LandDAO(DBConnection conn) {
		super(conn, new AnnotationBeanFactory<>(Land.class));
		// TODO Auto-generated constructor stub
	}

	@Override
	protected List<Land> doSelectAll(Connection c) throws SQLException {
		PreparedStatement s = c.prepareStatement("SELECT * FROM \"Land\"");
		
		ResultSet rs = s.executeQuery();
		
		List<Land> results = new ArrayList<>();
		
		while(rs.next()) {
			results.add(newBean(rs));
		}
		
		return results;
	}

	public List<Land> selectLandForJahr(Jahr j) {
		Connection c = null;
		
		try {
			
			c = conn.newConnection();
			return doSelectLandForJahr(c,j);
			
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

	private List<Land> doSelectLandForJahr(Connection c, Jahr j) throws SQLException{
		PreparedStatement s = c.prepareStatement("SELECT * FROM \"Land\" WHERE jahr = ?");
		s.setInt(1, j.getJahr());
		
		ResultSet rs = s.executeQuery();
		
		List<Land> results = new ArrayList<>();
		
		while(rs.next()) {
			results.add(newBean(rs));
		}
		
		return results;
	}
	
}
