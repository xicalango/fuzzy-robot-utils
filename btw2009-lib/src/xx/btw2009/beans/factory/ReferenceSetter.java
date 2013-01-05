package xx.btw2009.beans.factory;

public @interface ReferenceSetter {
	Class<?> refClass();
	String column();
}
