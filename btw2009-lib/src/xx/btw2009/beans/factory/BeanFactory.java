package xx.btw2009.beans.factory;

import java.sql.ResultSet;
import java.sql.SQLException;

import xx.btw2009.beans.BTW2009Bean;

public interface BeanFactory<T extends BTW2009Bean> {
	T fromResultSet(ResultSet rs) throws SQLException;
}
