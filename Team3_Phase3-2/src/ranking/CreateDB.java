package ranking;


import java.sql.*;
import java.util.ArrayList;
import java.util.regex.Pattern;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class CreateDB {
	public static Connection conn = null; // Connection object
	public static Statement stmt = null;	// Statement object
    public static String sql = ""; // an SQL statement 
    public static final String URL = "jdbc:oracle:thin:@localhost:1521:orcl";
	public static final String USER_RANKINGHUB = "gitrank";
	public static final String USER_PASSWD = "gitrank";
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Connection conn = null; // Connection object
		Statement stmt = null;	// Statement object
		String sql = ""; // an SQL statement 
		
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
			conn = DriverManager.getConnection(URL, USER_RANKINGHUB, USER_PASSWD); 
			System.out.println("Oracle Connected.\n");
		}catch(SQLException ex) {
			ex.printStackTrace();
			System.err.println("Cannot get a connection: " + ex.getLocalizedMessage());
			System.err.println("Cannot get a connection: " + ex.getMessage());
			System.exit(1);
		}
		ArrayList<String> TABLE_NAMES = new ArrayList<>();
		TABLE_NAMES.add("belong"); TABLE_NAMES.add("category");
		TABLE_NAMES.add("comments"); TABLE_NAMES.add("commits");
		TABLE_NAMES.add("files"); TABLE_NAMES.add("challenge_group");
		TABLE_NAMES.add("language"); TABLE_NAMES.add("member");
		TABLE_NAMES.add("organization_ranks"); TABLE_NAMES.add("organization");
		TABLE_NAMES.add("participate_in"); TABLE_NAMES.add("post");
		TABLE_NAMES.add("repository_ranks"); TABLE_NAMES.add("repository"); TABLE_NAMES.add("user_ranks"); 
		try {
			conn.setAutoCommit(false); // auto-commit disabled  
			// Create a statement object
			stmt = conn.createStatement();
			// Let's execute an SQL statement.
			 for (int index = 0; index < TABLE_NAMES.size(); index++) {
				 int res = 0;
					sql = "DROP TABLE " + TABLE_NAMES.get(index) + " CASCADE CONSTRAINT";
					try {
						 res = stmt.executeUpdate(sql); 
					}catch(Exception ex) {
						// in most cases, you'll see "table or view does not exist"
						System.out.println(ex.getMessage());
					}
			 }
			 System.out.println("Wait: Tables Creating...");
			 FileReader fr = new FileReader("sql/DDL_create_table.sql") ;
             BufferedReader br = new BufferedReader(fr) ;
             StringBuffer sb = new StringBuffer();
             String str;
             int cnt = 0;
             while ((str = br.readLine()) != null) {
            	 sb.append(str);
            	 if (str.isBlank()) {
            		 sql = sb.toString();
            		 int res = stmt.executeUpdate(sql); 
            		 if(res == 0) {
            			 cnt++;
            		 }
            		 sb = new StringBuffer();
            	 }
             }
             System.out.println(cnt + " Tables successfully created.");
			// Make the table permanently stored by a commit.
			conn.commit();	
			br.close();
		}catch(SQLException | IOException ex2) {
			System.err.println("sql error = " + ex2.getMessage());
			System.exit(1);
		}
		System.out.println("Wait: Data Inserting...");
		// insert 문 실행
		try {
//			sql = "set define off";
//			stmt.executeQuery(sql);
			FileReader fr = new FileReader("sql/DML_insert.sql") ;
			BufferedReader br = new BufferedReader(fr);
			String str;
			StringBuffer sb = new StringBuffer();
			while ((str = br.readLine()) != null) {
				if (str.isBlank()) continue;
				char end_ch = str.charAt(str.length() - 1);
				if (end_ch == ';') {
					str = str.substring(0, str.length() - 1);
					sb.append(str);
					sql = sb.toString();
//					System.out.println(sql);
					stmt.addBatch(sql);
					sb = new StringBuffer();
				}
				else {
					sb.append(str);
				}
            }
			int[] count = stmt.executeBatch();
			 System.out.println(count.length + " row inserted.");
			// Make the changes permanent 
			conn.commit();			
		}catch(SQLException ex2) {
			System.err.println("sql error = " + ex2.getMessage());
			System.exit(1);
		} catch (IOException ex) {
			// TODO Auto-generated catch block
			ex.printStackTrace();
		}
		System.out.println("Wait: Tables Updating...");
		// FOREIGN KEY 제약조건 추가
		try {
			FileReader fr = new FileReader("sql/DDL_alter_table.sql");
			BufferedReader br = new BufferedReader(fr) ;
			StringBuffer sb = new StringBuffer();
	        String str;
	        while ((str = br.readLine()) != null) {
				if (str.isBlank()) continue;
				char end_ch = str.charAt(str.length() - 1);
				if (end_ch == ';') {
					str = str.substring(0, str.length() - 1);
					sb.append(str);
					sql = sb.toString();
//					System.out.println(sql);
					stmt.addBatch(sql);
					sb = new StringBuffer();
				}
				else {
					sb.append(str);
				}
            }
	        int[] count = stmt.executeBatch();
			System.out.println(count.length + " tables update!");
			// Make the table permanently stored by a commit.
			conn.commit();	
			System.out.println();
			System.out.println("** Database Create FINISH");
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}

}
