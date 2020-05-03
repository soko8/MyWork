import java.io.IOException;

import org.apache.log4j.Appender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Layout;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;


public class testlog {

	public void test() {
		Logger log = Logger.getLogger(this.getClass());
		
		Layout layout = new PatternLayout("%d [%p] %m%n ");
		
		try {
			Appender appender = new FileAppender(layout, "d:/aa.log");
			log.addAppender(appender);
			
			log.setLevel(Level.ALL);
			
			log.error("XXXXXXXX");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
}
