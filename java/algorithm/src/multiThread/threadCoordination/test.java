package multiThread.threadCoordination;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class test {

	public static void main(String[] args) {

		Storage storage = new Storage();
		
		ExecutorService exec = Executors.newFixedThreadPool(16);
		ExecutorService exec2 = Executors.newFixedThreadPool(16);
		
		for (int i = 0; i < 100; i++) {
			exec.execute(new Consumer(storage));
			exec2.execute(new Producer(storage));
		}
		
		exec.shutdown();
		exec2.shutdown();
		
		/*
		// 生产者对象  
        Producer p1 = new Producer(storage);  
        Producer p2 = new Producer(storage);  
        Producer p3 = new Producer(storage);  
        Producer p4 = new Producer(storage);  
        Producer p5 = new Producer(storage);  
        Producer p6 = new Producer(storage);  
        Producer p7 = new Producer(storage);  
  
        // 消费者对象  
        Consumer c1 = new Consumer(storage);  
        Consumer c2 = new Consumer(storage);  
        Consumer c3 = new Consumer(storage);
        
        Thread tc1 = new Thread(c1);
        Thread tc2 = new Thread(c2);
        Thread tc3 = new Thread(c3);
        
        Thread t1 = new Thread(p1);
        Thread t2 = new Thread(p2);
        Thread t3 = new Thread(p3);
        Thread t4 = new Thread(p4);
        Thread t5 = new Thread(p5);
        Thread t6 = new Thread(p6);
        Thread t7 = new Thread(p7);
        
        
        tc1.start();
        tc2.start();  
        tc3.start();  
        t1.start();  
        t2.start();  
        t3.start();  
        t4.start();  
        t5.start();  
        t6.start();  
        t7.start();
*/
	}

}
