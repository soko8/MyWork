package multiThread.threadCoordination;

import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Storage {
	
	public static final int MAX_SIZE = 4;

	private Queue<Product> queue = new LinkedList<Product>();
	
	private final Lock lock = new ReentrantLock();
	
	private final Condition isFull  = lock.newCondition();
	
	private final Condition isEmpty = lock.newCondition();
	
	// 自动阻塞
	//private LinkedBlockingQueue<Object> queue = new LinkedBlockingQueue<Object>(100);

	
	public void produce() {
		
		lock.lock();
		
		try {
			
			while (MAX_SIZE <= queue.size()) {
				System.err.println("queue is full. producer wait....");
				isFull.await();
			}
			
			// when queue is not full
			Product product = new Product();
			queue.offer(product);
			System.out.println("Produce a product.");
			
			isFull.signalAll();
			isEmpty.signalAll();
			
		} catch(InterruptedException e) {
			e.printStackTrace();
		} finally {
			lock.unlock();
		}
	}
	
	
	public void consume() {
		lock.lock();
		
		try {
			
			while(queue.size() < 1) {
				System.err.println("queue is Empty. consumer wait....");
				isEmpty.await();
			}
			
			// when queue is not empty
			Product product = queue.poll();
			
			// do something
			int i = 0;
			while (i < Integer.MAX_VALUE) {
				i++;
			}
			i = 0;
			while (i < Integer.MAX_VALUE) {
				i++;
			}
			i = 0;
			while (i < Integer.MAX_VALUE) {
				i++;
			}
			i = 0;
			while (i < Integer.MAX_VALUE) {
				i++;
			}
			i = 0;
			while (i < Integer.MAX_VALUE) {
				i++;
			}
			
			System.out.println("Consume a product.");
			
			isFull.signalAll();
			isEmpty.signalAll();
			
		} catch(InterruptedException e) {
			e.printStackTrace();
		} finally {
			lock.unlock();
		}
		
	}
	
	
	public Queue<Product> getQueue() {
		return queue;
	}

	public void setQueue(Queue<Product> queue) {
		this.queue = queue;
	}

}
