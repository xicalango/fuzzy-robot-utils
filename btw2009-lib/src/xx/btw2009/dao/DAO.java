package xx.btw2009.dao;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import xx.btw2009.beans.BTW2009Bean;
import xx.btw2009.db.DBConnection;

public class DAO<T extends BTW2009Bean> {
	
	public List<T> importFrom(DBConnection conn, Class<?> typeClass) {
		
		TableName tableNameAnnotation = typeClass.getAnnotation(TableName.class);
		
		String tableName = tableNameAnnotation.value();
		Map<String, Method> setters = new HashMap<>();
		Map<Class<?>, Method> referenceSetters = new HashMap<>();
		
		for( Method m : typeClass.getMethods()) {
			if(m.isAnnotationPresent(SetterFor.class)) {
				SetterFor setterForAnnotation = m.getAnnotation(SetterFor.class);
				
				setters.put(setterForAnnotation.value(), m);
			}else if(m.isAnnotationPresent(ReferenceSetterFor.class)) {
				ReferenceSetterFor setterForAnnotation =m.getAnnotation(ReferenceSetterFor.class);
				
				referenceSetters.put(setterForAnnotation.value(), m);
			}
		}
		
		
		try {
			
			List<T> results = new ArrayList<>();

			String generatedQuery = "SELECT * FROM \"" + tableName+ "\"";
			
			System.out.println(generatedQuery);
			
			PreparedStatement stmt = conn.prepareStatement(generatedQuery);
			
			ResultSet rs = stmt.executeQuery();
			
			while(rs.next()) {
				@SuppressWarnings("unchecked")
				T result = (T) typeClass.newInstance();

				for( Map.Entry<String, Method> entry : setters.entrySet() ) {
					entry.getValue().invoke(result, getValue(rs, entry.getKey(), entry.getValue()));
				}
				
				for( Map.Entry<Class<?>, Method> entry : referenceSetters.entrySet() ) {
					
					DAO<BTW2009Bean> referenceDAO = new DAO<>();
					List<BTW2009Bean> referenceValues = referenceDAO.importFrom(conn, entry.getKey());
					
					entry.getValue().invoke(result, referenceValues);
				}
				
				
				results.add(result);
			}
			
			return results;
			
		} catch (SQLException | InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
			throw new RuntimeException(e);
		}
		
		
		
		
		
	}

	private Object getValue(ResultSet rs, String column, Method method) throws SQLException {
		
		Class<?> type = method.getParameterTypes()[0];
		
		if(type.equals(String.class)) {
			return rs.getString(column);
		}
		else if(type.equals(Integer.class)) {
			return rs.getInt(column);
		}
		else {
			return rs.getObject(column);
		}
	}
	
}
