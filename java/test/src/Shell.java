import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.FutureTask;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;


public class Shell {
	
	private static final ExecutorService THREAD_POOL = Executors.newCachedThreadPool();
	
	private static <T> T timedCall(Callable<T> c, long timeout, TimeUnit timeUnit) throws InterruptedException, ExecutionException, TimeoutException {
	    FutureTask<T> task = new FutureTask<T>(c);
	    THREAD_POOL.execute(task);
	    return task.get(timeout, timeUnit);
	}
	
	public static void excuteShell(final String command, long timeout) {
		try{ 
		    int returnCode = timedCall(new Callable<Integer>() {
		        public Integer call() throws Exception {
		            java.lang.Process process = Runtime.getRuntime().exec(command); 
		            return process.waitFor();
		        }}, timeout, TimeUnit.SECONDS);
		} catch (TimeoutException e) {
		    // Handle timeout here
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ExecutionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

}
