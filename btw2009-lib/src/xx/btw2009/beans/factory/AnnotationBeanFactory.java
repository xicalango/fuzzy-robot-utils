package xx.btw2009.beans.factory;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.sql.ResultSet;
import java.sql.SQLException;

import xx.btw2009.beans.BTW2009Bean;

public class AnnotationBeanFactory<T extends BTW2009Bean> implements BeanFactory<T>{

	private Class<T> targetClass;
	
	public AnnotationBeanFactory(Class<T> targetClass) {
		this.targetClass = targetClass;
	}
	
	@Override
	public T fromResultSet(ResultSet rs) throws SQLException {
		
		try {
			T result = targetClass.newInstance();
			
			for(Method m : targetClass.getMethods()) {
				
				if(m.isAnnotationPresent(Setter.class)) {
					Setter s = m.getAnnotation(Setter.class);
					m.invoke(result, rs.getObject(s.value()));
				}else if(m.isAnnotationPresent(ReferenceSetter.class)) {
					ReferenceSetter refSetter = m.getAnnotation(ReferenceSetter.class);
					
					
					
				}
				
			}
			
			return result;
		} catch (InstantiationException | IllegalAccessException | IllegalArgumentException | InvocationTargetException e) {
			throw new RuntimeException(e);
		}
		
	}

}
