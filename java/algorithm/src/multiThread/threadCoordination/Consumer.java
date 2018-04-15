package multiThread.threadCoordination;

public class Consumer implements Runnable {

	private Storage storage = null;

	
	public Consumer(Storage storage) {
		super();
		this.storage = storage;
	}

	
	@Override
	public void run() {
		consume();
	}
	
	public void consume() {
		storage.consume();
	}
	
	public Storage getStorage() {
		return storage;
	}

	public void setStorage(Storage storage) {
		this.storage = storage;
	}


}
