package xx.btw2009.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import xx.btw2009.beans.Jahr;
import xx.btw2009.beans.factory.AnnotationBeanFactory;
import xx.btw2009.db.DBConnection;

public class JahrDAO extends AbstractDAO<Jahr> {

	public JahrDAO(DBConnection conn) {
		super(conn, new AnnotationBeanFactory<>(Jahr.class));
	}

	@Override
	protected List<Jahr> doSelectAll(Connection c) throws SQLException {
		PreparedStatement s = c.prepareStatement("SELECT * FROM \"Jahr\"");
		
		ResultSet rs = s.executeQuery();
		
		List<Jahr> results = new ArrayList<>();
		
		while(rs.next()) {
			results.add(newBean(rs));
		}
		
		return results;
	}

	public void lazyFetchLaender(Jahr j) {
		j.setLaender( (new LandDAO(conn)).selectLandForJahr(j) );
	}

}
