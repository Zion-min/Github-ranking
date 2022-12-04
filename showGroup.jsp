<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ page language="java" import="java.text.*,java.sql.*"%>
// 사용자 그룹 정보보기 + 그룹추가 및 참여하기
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Rankinghub:Group</title>
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
		<div class="container">
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
	
			// get user ID :: 임시용 => 정보 받아오는거 이부분 수정하시면 됩니다
			stmt = conn.createStatement();
			String userID = request.getParameter("gitid");
			
			out.println(
					"<div class='user-group-list'>"); // 유저가 속한 그룹들의 정보
					
			String profileQuery = "select C.group_name, C.group_period, C.manage_github_id, C.group_id, C.group_start_date + 0, C.group_start_date + C.group_period, TRUNC(SYSDATE) - TRUNC(C.group_start_date) "
					+ "from member M, participate_in P, challenge_group C "
					+ "where M.github_id = '" + userID + "' "
					+ "and M.github_id = P.mgithub_id "
					+ "and P.group_id = C.group_id";
			rs = stmt.executeQuery(profileQuery);
			
			int grCount = 0;
			
			while(rs.next()){ // 그룹 하나씩 추가하기
				grCount ++;
				out.println(
						"<div class='user-group-info'>" +
							"<div class='group-info-title'>" + 
								"<h1 class='group-name'>" + 
									"<a href=\"showGroupDesc.jsp?groupId=" + rs.getInt(4) + "\" class='group-link'>" + rs.getString(1) + "</a>" + // 그룹명
								"</h1>" +
								"<div class='group-info-desc'>" + 
									"<ul>" + 
										"<li class=group-info-mng>" + 
											"<p> 관리자: " + rs.getString(3) + " </p>" +
										"</li>" +
										"<li class=group-info-period>" + 
											"<p> 진행기간: " + rs.getDate(5) + " ~ " + rs.getDate(6) + " (" + rs.getInt(2) + " 일) </p>" +
										"</li>" +
									"</ul>" + 
								"</div>" +
							"</div>" +
							
							"<div class='group-info-progress'>" +  // 그룹 진행률
								"<h2> Challange 진행률 </h2>");
				int progressPnt = 0;
				int progressDays = 0;
				
				if (rs.getFloat(2)<= rs.getFloat(7)){
						progressPnt = 100;
						progressDays = rs.getInt(2);
				}
				else {
					progressPnt = Math.round(rs.getFloat(7) / rs.getFloat(2) * 100);
					progressDays = rs.getInt(7);
				}
				
				out.println(	
								"<p class='group-pnt'>" + progressPnt + " %</p>" + 
								"<p class='remain-days'>" + progressDays + " / " + rs.getInt(2) + "</p>"
							);
			}

			out.println(
							"</div>" +
						"</div>" +
					"</div>" + 
					
					// 그룹 추가 및 참여 기능
					"<div class='user-group-modify'>" + 
						"<div class='alert-info'>" +
							"<p> * 최대 그룹 가입 횟수는 3회입니다. 현재 회원님께서는 " + grCount + "개의 그룹에 가입한 상태입니다. *</p>" +
						"</div>" + 
						"<div class='group-btn'>" +
							"<div class='participate-group'>" + 
								"<a href=\"./showGroupList.jsp?userId='" + userID + "'\">참여하기</a>" +  // 참여하기, userID 정보로 넘어가면서 showGroupDescc.jsp로 넘어감
							"</div>" + 
							"<div class='create-group'>" + 
								"<a href=\"./showGroupCreate.jsp?userId='" + userID + "'\">그룹추가</a>" + // // 참여하기, userID 정보로 넘어가면서 showGroupList.jsp로 넘어감 
							"</div>" + 
						"</div>" +
					"</div>"
					);
			
			rs.close();
			stmt.close();
			conn.close();
			%>
		</div>
	</main>
	
	<footer id='footer'>
		<p class='footer-desc'>team describe</p>
		<div class="footer__spliter pc-only"></div>
		<p class='footer-github'>github link</p>
	</footer>
</body>
</html>