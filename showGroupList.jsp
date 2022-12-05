<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ page language="java" import="java.text.*,java.sql.*"%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Rankinghub:Group_Desc</title>
<link rel="stylesheet"  href="../css/styles.css?after">
</head>
<body>
	<header id='header' >
		<div class="navbar">
			<table>
				<tr>
					<td>
						<img src="../images/logo.png" height="50">
					</td>
					<td>
						<a class="navbar-brand" href="#">
							<span>Rankinghub for <b class="bold-green">Github</b></span>
						</a>
					</td>
				</tr>
			</table>
		</div>
	</header>
	
	<main id='content'>
	
		<%
			String serverIP = "localhost";
			String strSID = "orcl";
			String portNum = "1521";
			String user = "gitrank";
			String pass = "gitrank";
			String url = "jdbc:oracle:thin:@" + serverIP + ":" + portNum + ":" + strSID;
			//System.out.println(url);
			Connection conn = null;
			Statement stmt;
			ResultSet rs;
			Class.forName("oracle.jdbc.driver.OracleDriver");
			conn = DriverManager.getConnection(url, user, pass);
	
			// get user ID :: 임시용
			stmt = conn.createStatement();
			int groupId = Integer.parseInt(request.getParameter("groupId")) ;
			
			request.setCharacterEncoding("UTF-8");
		    String name = request.getParameter("groupId");
			
			String profileQuery = "select group_name from challenge_group where group_id = " + groupId;
			rs = stmt.executeQuery(profileQuery);
			rs.next();
			
			String temp = rs.getString(1);
			out.println("<p>" + temp + "</p>");
			
			rs.close();
			stmt.close();
			conn.close();
			%>
			
	
	</main>
	
	<footer id='footer'>
		<p class='footer-desc'>team describe</p>
		<div class="footer__spliter pc-only"></div>
		<p class='footer-github'>github link</p>
	</footer>
</body>
</html>