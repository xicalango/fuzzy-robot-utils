public class Timeout {

	private long min;
	private long max;

	public Timeout(long t) {
		this.min = t * 800;
		this.max = t * 1200;
	}

	public long getTimeout() {
		return (long) (this.min + (Math.random() * (this.max - this.min)));
	}

}
