<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<%@page import="com.oreilly.servlet.MultipartRequest" %>
<%@page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@page import="java.util.*,java.io.*"%>
<% 
	String serverIP = "localhost";
	String strSID = "orcl";
	String portNum = "1521";
	String user = "gitrank";
	String pass = "gitrank";
	String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;
	//System.out.println(url);
	Connection conn = null;
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn = DriverManager.getConnection(url,user,pass);
	conn.setAutoCommit(false);
	Statement stmt = conn.createStatement();
	String sql = "";

	String saveFolder = "C:\\oracle\\comp322\\loginTest\\src\\main\\webapp\\files"; // out폴더에 fileSave 폴더 생성
	String encType = "utf-8";
	int maxSize = 5*1024*1024; // 최대 업로드 5mb
	
// 	String realFolder = "";
// 	ServletContext context = request.getServletContext();
// 	realFolder = context.getRealPath(saveFolder);
// 	out.println("the realpath is: " + realFolder + "<br>");
    
    MultipartRequest multi = null;
    multi = new MultipartRequest(request, saveFolder, maxSize, encType, new DefaultFileRenamePolicy());

	String title = multi.getParameter("title"); //title
 	String content = multi.getParameter("content"); // content
 	String category = multi.getParameter("category");	// category
 	String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
 	String is_anonymous = multi.getParameter("is_anonymous"); //title
 	String name = "", filename = "", original_name = "", type = "";
 	File file = null;
 	out.println((String)multi.getParameter("uploadFile"));
 	if ((String)multi.getParameter("uploadFile") != null) {
 		Enumeration files = multi.getFileNames();
 	 	
 	 	while(files.hasMoreElements()) {
 	        name = (String)files.nextElement();
 	        filename = multi.getFilesystemName(name);
 	        original_name = multi.getOriginalFileName(name);
 	        type = multi.getContentType(name);
 	        file = multi.getFile(name);

// 	         out.println("파라미터 이름" + name + "<br>");
// 	         out.println("실제 파일 이름" + original_name + "<br>");
// 	         out.println("저장된 파일 이름" + filename + "<br>");
// 	         out.println("파일 타입 이름" + type + "<br>");

// 	 	    if(file!= null) {
// 	 	        out.println("크기: " + file.length() + "<br>");
// 	 	    }
 	    }
 	}
    
	Date nowTime = new Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");

	// group insert 작업
	String postid_sql = "select max(Post_id) from post";
	int post_id = 0;
	try {
		ResultSet rs = stmt.executeQuery(postid_sql);
		rs.next();
		String post_id_str = rs.getString(1);
		post_id = Integer.parseInt(post_id_str);
	} catch (SQLException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
	
	if (is_anonymous == null)
		is_anonymous = "0";
	else
		is_anonymous = "1";
	
	String post_insert_sql = String.format("INSERT INTO post values(%d, %d, %s, %s, %d, %d, %s, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), %s)", 
			Integer.parseInt(category), post_id + 1, "'" + title + "'", "'" + content + "'", 0, 0, "'" + is_anonymous + "'", "'"+sf.format(nowTime)+"'", "'"+sf.format(nowTime)+"'",  "'"+userID+"'");
	// file
	String file_insert_sql = "";
	if (file != null) {
		String fileid_sql = "select max(File_id) from files";
		// group insert 작업
		int file_id = 0;
		try {
			ResultSet rs = stmt.executeQuery(fileid_sql);
			rs.next();
			String file_id_str = rs.getString(1);
			file_id = Integer.parseInt(file_id_str);
		} catch (SQLException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		file_insert_sql = String.format("INSERT INTO files values(%d, %s, %s, %s, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'), %d, %d)", 
				file_id + 1, "'"+original_name+"'", "'" + filename + "'", "'" + "files/" + filename + "'", "'"+sf.format(nowTime)+"'", Integer.parseInt(category), post_id + 1);
		// out.println(file_insert_sql);
	}
	
	// out.println(post_insert_sql);
	stmt.addBatch(post_insert_sql);
	if (file != null)
		stmt.addBatch(file_insert_sql);
	stmt.executeBatch();
	conn.commit();
	
	stmt.close();
	conn.close();
	
	out.println("<script>");
    out.println("alert('게시물이 생성되었습니다!!')");
    out.println("location.href='board-qna.jsp'");
    out.println("</script>");
    
%>	
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

</body>
</html>