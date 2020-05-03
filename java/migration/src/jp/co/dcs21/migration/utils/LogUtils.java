package jp.co.dcs21.migration.utils;

import java.io.IOException;

import org.apache.log4j.Appender;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Layout;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

public class LogUtils {

	private String outputFile = null;

	private Logger log = Logger.getLogger(LogUtils.class);

	public Logger getLog() {
		return log;
	}

	public void init() throws IOException {

		Layout layout = new PatternLayout("%d [%p] %m%n ");

		Appender appender = new FileAppender(layout, outputFile);

		log.addAppender(appender);

		log.setLevel(Level.ALL);

	}

	public String getOutputFile() {
		return outputFile;
	}

	public void setOutputFile(String outputFile) {
		this.outputFile = outputFile;
	}
}
