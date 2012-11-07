package xx.btw2009.dao;

import java.util.List;

import xx.btw2009.beans.BTW2009Bean;

public interface DAO<T extends BTW2009Bean> {
	List<T> selectAll();
}
