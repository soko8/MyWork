package encode;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.util.Map;

public class test {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
//		printAvailableCharsets();
		
		String fileIn = "D:\\\\ttt\\charsetTest.txt";
		String fileOut = "D:\\\\ttt\\charsetTest_O.txt";
		
		toUtf8(fileIn, fileOut);
		
	}

	private static void printAvailableCharsets() {
	    Map<String ,Charset> map = Charset.availableCharsets();
	    System.out.println("the available Charsets supported by jdk:"+map.size());
	    for (Map.Entry<String, Charset> entry :
	            map.entrySet()) {
	        System.out.println(entry.getKey());
	    }
	}
	
	private static void toUtf8(String fileIn, String fileOut) {
		
		int bufferSize = 8192;
		
		FileReader fr = null;
		BufferedReader br = null;
		
		FileWriter fw = null;
		BufferedWriter bw = null;
		
		File inFile= Paths.get(fileIn).toFile();
		File outFile= Paths.get(fileOut).toFile();
		
		Charset charset = StandardCharsets.UTF_8;
		
		try {
			fr = new FileReader(inFile);
			br = new BufferedReader(fr, bufferSize);
			
			fw = new FileWriter(outFile);
			bw = new BufferedWriter(fw);
			
			char[] cb = new char[bufferSize];
//			CharBuffer cb = CharBuffer.allocate(8192);
			
			int offset = 0;
			int count = -2;
			
			count = br.read(cb);
			while ((count = br.read(cb, offset, bufferSize)) != -1) {
//			while ((count = br.read(cb)) != -1) {
				System.out.println(count);
				System.out.println(cb);
//				System.out.println(cb.array());
//				bw.write(cb.array());
//				cb.flip();
//				ByteBuffer bb = charset.encode(cb);
//				System.out.println(bb.array());
//				CharBuffer newCb = charset.decode(bb);
//				newCb.flip();
//				while (newCb.hasRemaining()) {
//					char ch = newCb.get();
////					System.out.println(ch);
////					bw.write(ch);
//				}
//				char[] chs = newCb.array();
//				System.out.println(new String(chs));
//				bw.write(chs);
//				newCb.clear();
			}
			
			bw.flush();
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			try {
				if (null != fr) {
					fr.close();
				}
				
				if (null != br) {
					br.close();
				}
				
				if (null != fw) {
					fw.close();
				}
				
				if (null != bw) {
					bw.close();
				}
				
				
				
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
	}
	
}
