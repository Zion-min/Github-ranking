<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page language="java" import="java.text.*,java.sql.*,java.util.Date,rankinghub.*" %>
<% 
	request.setCharacterEncoding("UTF-8");
	config c = new config();
	String serverIP = c.serverIP;
	String strSID = c.strSID;
	String portNum = c.portNum;
	String user = c.user;
	String pass = c.pass;
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
	
	if ((String)session.getAttribute("sid") == null) {
		out.println("<script>");
	    out.println("alert('로그인 후 좋아요를 눌러주세요~')");
	    out.println("location.href='" + request.getHeader("referer") + "'");
	    out.println("</script>");
	}

	if((String)session.getAttribute(Integer.toString(post_id)+"like")==null)
	{
		session.setAttribute(Integer.toString(post_id)+"like", "1");
		sql = "update post set likes = likes + 1 where post_id ="+post_id;
	  	stmt.executeUpdate(sql);
	  	
	  	out.println("<script>");
	    out.println("alert('좋아요를 눌렀습니다!')");
	    out.println("location.href='" + request.getHeader("referer") + "'");
	    out.println("</script>");
	}
	else if((String)session.getAttribute(Integer.toString(post_id)+"like")!=null)
	{
		out.println("<script>");
	    out.println("alert('한 게시글에 좋아요를 한 번이상 누를 수 없습니다.')");
	    out.println("location.href='" + request.getHeader("referer") + "'");
	    out.println("</script>");
	}

	stmt.close();
	conn.close();
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