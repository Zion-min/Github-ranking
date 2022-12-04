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
			request.setCharacterEncoding("UTF-8");
		
			String serverIP = "localhost";
			String strSID = "orcl";
			String portNum = "1521";
			String user = "rankinghub";
			String pass = "comp322";
			String url = "jdbc:oracle:thin:@" + serverIP + ":" + portNum + ":" + strSID;
			
			String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
			
			Connection conn = null;
			Statement stmt;
			ResultSet rs;
			Class.forName("oracle.jdbc.driver.OracleDriver");
			conn = DriverManager.getConnection(url, user, pass);
			conn.setAutoCommit(false); // auto-commit disabled
			stmt = conn.createStatement(); // Create a statement object
			// 챌린지가 끝난 그룹은 보여주지 x & 로그인 유저가 가입된 그룹 보여주지x
			String group_list = "select distinct group_id, group_name, Group_period, Manage_github_id, group_start_date + 0, group_start_date + group_period, TRUNC(SYSDATE) - TRUNC(group_start_date), group_start_date " + 
									"from challenge_group where group_id not in (select distinct group_id from participate_in where mgithub_id = '" + userID + "') and manage_github_id != '" + userID + "' and TRUNC(SYSDATE) - TRUNC(group_start_date) < group_period order by group_start_date desc";
			rs = stmt.executeQuery(group_list);
			
			out.println(
					"<div class='user-group-list'>"); // 그룹들의 정보
			while (rs.next()) {
				out.println(
						"<div class='user-group-info'>" +
							"<div class='group-info-title'>" + 
								"<h1 class='group-name'>" + 
									"<a href=\"showGroupDesc.jsp?groupId=" + rs.getInt(1) + "\" class='group-link'>" + rs.getString(2) + "</a>" + // 그룹명
								"</h1>" +
								"<div class='group-info-desc'>" + 
									"<ul>" + 
										"<li class=group-info-mng>" + 
											"<p> 관리자: " + rs.getString(4) + " </p>" +
										"</li>" +
										"<li class=group-info-period>" + 
											"<p> 진행기간: " + rs.getDate(5) + " ~ " + rs.getDate(6) + " (" + rs.getInt(3) + " 일) </p>" +
										"</li>" +
									"</ul>" + 
								"</div>" +
							"</div>" +
							"<div class='group-info-progress'>" +  // 그룹 진행률
								"<h2> Challange 진행률 </h2>");
				
				int progressPnt = 0;
				int progressDays = 0;
				
				if (rs.getFloat(3)<= rs.getFloat(7)){
						progressPnt = 100;
						progressDays = rs.getInt(3);
				}
				else {
					progressPnt = Math.round(rs.getFloat(7) / rs.getFloat(3) * 100);
					progressDays = rs.getInt(7);
				}
				
				out.println("<p class='group-pnt'>" + progressPnt + " %</p>" + 
							"<p class='remain-days'>" + progressDays + " / " + rs.getInt(3) + "</p>");
			}
			out.println("</div>" +
						"</div>" +
					"</div>");
			
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