<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*, java.util.*"%>    
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<% request.setCharacterEncoding("UTF-8"); %>
    
<%
	String serverIP = "localhost";
	String strSID = "orcl";
	String portNum = "1521";
	String user = "rankinghub";
	String pass = "comp322";
	String url = "jdbc:oracle:thin:@" + serverIP + ":" + portNum + ":" + strSID;
	
	Connection conn = null;
	Statement stmt;
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn = DriverManager.getConnection(url, user, pass);
	conn.setAutoCommit(false); // auto-commit disabled
	stmt = conn.createStatement();
	int groupId = Integer.parseInt(request.getParameter("groupId")) ;
	
	String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
	
	String participated_sql="select count(*) from participate_in where Mgithub_id='" + userID +"'"; //데이터를 뽑아오기 위한 sql문을 작성
	int group_num = 0;	// 현재 속해있는 그룹 수
	try {
		ResultSet rs = stmt.executeQuery(participated_sql);
		rs.next();
		String group_num_str = rs.getString(1);
		group_num = Integer.parseInt(group_num_str);
	} catch (SQLException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
	
	// 속한 그룹이 3개 이상일 경우
	if (group_num >= 3) {
		out.println("<script>");
	    out.println("alert('참여할 수 있는 그룹 개수가 3개를 초과할 수 없습니다!')");
	    out.println("location.href='showGroup.jsp'");
	    out.println("</script>"); 
	}
	else {
		Date nowTime = new Date();
		SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
		
		String participate_sql = String.format("INSERT INTO participate_in values(%s, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
				"'"+userID+"'", groupId, "'"+sf.format(nowTime)+"'");
		stmt.addBatch(participate_sql);
		stmt.executeBatch();
		conn.commit();
		
		out.println("<script>");
	    out.println("alert('그룹에 가입되었습니다!!')");
	    out.println("location.href='showGroup.jsp'");
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