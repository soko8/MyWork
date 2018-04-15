package multiThread.threadCoordination;

public class Producer implements Runnable {

	private Storage storage = null;


	public Producer(Storage storage) {
		super();
		this.storage = storage;
	}
	

	@Override
	public void run() {
		produce();
	}
	
	public void produce() {
		storage.produce();
	}
	
	public Storage getStorage() {
		return storage;
	}

	public void setStorage(Storage storage) {
		this.storage = storage;
	}
}
