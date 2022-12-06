// 패키지명, 클래스명 바꾸
package rankinghub;

import java.sql.*;
import java.sql.*;
import java.util.ArrayList;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import rankinghub.config;


public class transaction {
	public static Connection conn = null; // Connection object
	public static Statement stmt = null;	// Statement object
    public static String sql = ""; // an SQL statement 
   
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Connection conn = null; // Connection object
		Statement stmt = null;	// Statement object
		String sql = ""; // an SQL statement 
		ResultSet rs = null;

		config c = new config();
		String serverIP = c.serverIP;
		String strSID = c.strSID;
		String portNum = c.portNum;
		String user = c.user;
		String pass = c.pass;
		String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;
		
		try {
			// Load a JDBC driver for Oracle DBMS
			Class.forName("oracle.jdbc.driver.OracleDriver");
			// Get a Connection object 
			System.out.println("Driver Loading: Success!");
		}catch(ClassNotFoundException e) {
			System.err.println("error = " + e.getMessage());
			System.exit(1);
		}
		
		// Make a connection
		try{
			conn = DriverManager.getConnection(url, user, pass); 
			System.out.println("Oracle Connected.\n");
		}catch(SQLException ex) {
			ex.printStackTrace();
			System.err.println("Cannot get a connection: " + ex.getLocalizedMessage());
			System.err.println("Cannot get a connection: " + ex.getMessage());
			System.exit(1);
		}
		
		ArrayList<String> seqList = new ArrayList<>();
		seqList.add("post");
		seqList.add("file"); seqList.add("comment");
		
		try {
			conn.setAutoCommit(false);   
			stmt = conn.createStatement();
			 for (int index = 0; index < seqList.size(); index++) {
				 int res = 0;
					sql = String.format("DROP sequence %s_seq", seqList.get(index));
					try {
						 res = stmt.executeUpdate(sql); 
					}catch(Exception ex) {
						System.out.println(ex.getMessage());
					}
			 }
			 
			 System.out.println("Wait: Sequence Creating...");
			 ArrayList<String> maxidList = new ArrayList<>();
			 
			 sql = String.format("select max(post_id) from post");
			 rs = stmt.executeQuery(sql);
			 rs.next();
			 maxidList.add(rs.getString(1));
			 
			 sql = String.format("select max(file_id) from files");
			 rs = stmt.executeQuery(sql);
			 rs.next();
			 maxidList.add(rs.getString(1));
			 
			 sql = String.format("select max(comment_id) from comments");
			 rs = stmt.executeQuery(sql);
			 rs.next();
			 maxidList.add(rs.getString(1));
			 
			 
			 for (int index = 0; index < seqList.size(); index++) {
				 int res = 0;
					sql = String.format("CREATE sequence %s_seq  INCREMENT BY 1 START WITH %s MINVALUE %s MAXVALUE 99999 NOCYCLE NOCACHE NOORDER",
							seqList.get(index), Integer.parseInt(maxidList.get(index))+1, Integer.parseInt(maxidList.get(index))+1);
					stmt.addBatch(sql); 
			 }
			
				 int[] count = stmt.executeBatch();
				 System.out.println("[+]"+count.length + " Sequence inserted.");
				 conn.commit();	
			 } catch(SQLException ex2) {
					System.err.println("sql error = " + ex2.getMessage());
					System.exit(1);
			}
		}
}
