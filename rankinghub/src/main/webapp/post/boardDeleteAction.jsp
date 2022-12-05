<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*,java.util.Date" %>
<% 
	request.setCharacterEncoding("UTF-8");
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
	Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
	String sql = "";
%>

<%
	int post_id = Integer.parseInt(request.getParameter("group_id"));
	String author = (String)request.getParameter("author");
	
	if((String)session.getAttribute("sid")!=null && author.compareTo((String)session.getAttribute("sid"))==0) {
		sql = "delete from comments c\n"
				+"where post_id ="+post_id;
		stmt.addBatch(sql);
		
		sql = "delete from files c\n"
				+"where post_id ="+post_id;
		stmt.addBatch(sql);
		
		sql = "delete from post\n"
			+"where post_id = "+post_id;
		stmt.addBatch(sql);

		stmt.executeBatch();
		out.println("<script>");
	    out.println("alert('성공적으로 삭제되었습니다!!')");
	    out.println("location.href='board-qna.jsp'");
	    out.println("</script>");
	}
	else {
		out.println("<script>");
	    out.println("alert('작성자가 아닙니다!!!')");
	    out.println("location.href='" + request.getHeader("referer") + "'");
	    out.println("</script>");
   	}
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