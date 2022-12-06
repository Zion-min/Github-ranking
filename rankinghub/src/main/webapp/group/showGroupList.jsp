<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*,rankinghub.*"%>    
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Rankinghub:Group_Desc</title>
<link rel="stylesheet" type="text/css" href="../css/MainpageStyle.css">
<link rel="stylesheet" type="text/css" href="../css/global.css">
<link rel="stylesheet" type="text/css" href="../css/group.css">
<link rel="icon" type="image/png" href="../images/logo.png">
</head>
<body>
	<header id="header">
    	<div class="header__wrap">
        	<div class="header__column">
            	<div class='nav-bar'>
					<img src="../images/logo.png" height="50">
					<a class ="header__link" href="../index-user.jsp">
						<span class="header__title">Rankinghub for<p class="bold-green">Github</p></span>
									
					</a>
				</div>
                <a role="button" class="header__menu-btn">
                 	<svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="bars" class="svg-inline--fa fa-bars fa-w-14 " role="img" xmlns="http://www.w3.org/2000/svg" viewbox="0 0 448 512">
                    	<path fill="currentColor" d="M16 132h416c8.837 0 16-7.163 16-16V76c0-8.837-7.163-16-16-16H16C7.163 60 0 67.163 0 76v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16z"></path>
                    </svg>
                </a>
           </div>
           <nav class="header__column header__navbar navbar">
            	<ul class="navbar__menu">
                     <li>
                         <a aria-current="page" class="navbar__item" href="../index-user.jsp">순위</a>
                     </li>
                     <li>
                         <a class="navbar__item" href="#../post/board-qna.jsp">게시판</a>
                     </li>
                     <% if(session.getAttribute("sid") == null) {%>
                     <li>
                         <a class="log-in-btn" href="../join/login.jsp">로그인</a>
                     </li>
                     <li>
                     <%} else { 
                     	out.println(
                              "<a class='navbar__item' href='../profile/showProfile.jsp?gitid=" + session.getAttribute("sid") + "'><span>" + session.getAttribute("sid") + "</span> 님의 프로필</a>" +
                        		 "<a class='navbar__item  active' href='../group/showGroup.jsp?gitid=" + session.getAttribute("sid") + "'>그룹</a>"
                              ); %>
                         <a class="log-in-btn" href="../join/logout.jsp">로그아웃</a>
                     </li>
                     <% }%>
                 </ul>
             </nav>
         </div>
     </header>
	
	<main id='content'>
		<div class="container">
		<%
			request.setCharacterEncoding("UTF-8");
		
			config c = new config();
			String serverIP = c.serverIP;
			String strSID = c.strSID;
			String portNum = c.portNum;
			String user = c.user;
			String pass = c.pass;
			String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;
			
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
				
				out.println(
						"<div>" + 
							"<span class='group-pnt'>" + progressPnt + " %</span>" + 
							"<span class='remain-days'> ( " + progressDays + " / " + rs.getInt(3) + " )</span>" +
						"</div>" + 	
						"<div class='gage-bar' style='width:" + progressPnt + "%'></div>" +
					"</div>" +
				"</div>"
				);
			}
			out.println(
					"</div>");
			
			rs.close();
			stmt.close();
			conn.close();
			%>
	</main>
	
	<footer id="footer">
		<p class="footer__desc">Copyright © DB_Programing_Team3</p>
		<div class="footer__spliter pc-only"></div>
		<p class="git_link">
			<img src="../images/logo.png" width=50px alt="">
			<a class="footer__desc" href="https://github.com/Zion-min/Rankinghub">
				Go_github
			</a>
		</p>
    </footer>
</body>
</html>