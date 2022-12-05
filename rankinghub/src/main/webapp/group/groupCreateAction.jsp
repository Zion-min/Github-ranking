<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%
	Connection conn = null;
	Statement stmt;
	
	String group_name = (String)request.getParameter("gname"); //login 페이지의 loginid파라미터를 받아와 ID에 넣음
	String chanllenge_period = (String)request.getParameter("gperiod"); // loginpass를 받아와 pass에 넣어준다
	String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
	
	Date nowTime = new Date();
	SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
	
	String groupid_sql = "select max(Group_id) from challenge_group";
	String participated_sql="select count(*) from participate_in where Mgithub_id='" + userID +"'"; //데이터를 뽑아오기 위한 sql문을 작성
	String URL = "jdbc:oracle:thin:@localhost:1521:orcl";
	String USER_RANKINGHUB = "gitrank";
	String USER_PASSWD = "gitrank";
	
	conn = DriverManager.getConnection(URL, USER_RANKINGHUB, USER_PASSWD);
	conn.setAutoCommit(false); // auto-commit disabled
	stmt = conn.createStatement(); // Create a statement object
	
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
	
	// group insert 작업
	int group_id = 0;
	try {
		ResultSet rs = stmt.executeQuery(groupid_sql);
		rs.next();
		String group_id_str = rs.getString(1);
		group_id = Integer.parseInt(group_id_str);
	} catch (SQLException e1) {
		// TODO Auto-generated catch block
		e1.printStackTrace();
	}
	
	String group_insert_sql = String.format("INSERT INTO challenge_group values(%d, %s, %d, %s, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
			group_id + 1, "'" + group_name + "'", Integer.parseInt(chanllenge_period), "'"+userID+"'", "'"+sf.format(nowTime)+"'");
	String participate_sql = String.format("INSERT INTO participate_in values(%s, %d, to_timestamp(%s, 'YYYY-MM-DD HH24:MI:SS'))", 
			"'"+userID+"'", group_id + 1, "'"+sf.format(nowTime)+"'");
	stmt.addBatch(group_insert_sql);
	stmt.addBatch(participate_sql);
	stmt.executeBatch();
	conn.commit();
	
	out.println("<script>");
    out.println("alert('그룹이 생성되었습니다!!')");
    out.println("location.href='showGroup.jsp'");
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