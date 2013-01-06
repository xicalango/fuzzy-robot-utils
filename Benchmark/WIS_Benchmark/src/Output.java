import java.io.FileNotFoundException;
import java.io.PrintStream;


public enum Output {
	INSTANCE;
	
	private PrintStream output = System.out;
	
	public void setOutputToFile(String fileName) {
		closeIfOpen();
		
		try {
			output = new PrintStream(fileName);
		} catch (FileNotFoundException e) {
			throw new RuntimeException(e);
		}
	}
	
	private boolean isOutputToFile() {
		return output != System.out;
	}
	
	public void setOutputToStdout() {
		closeIfOpen();
		
		output = System.out;
	}
	
	private void closeIfOpen() {
		if(isOutputToFile()) {
			output.close();
		}
	}
	
	public void close() {
		closeIfOpen();
	}
	
	public static PrintStream stream() {
		return INSTANCE.output;
	}


}
