<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<% 
String userID = request.getParameter("gitid"); 
out.println(
"<title>Rankinghub: " + userID + " profile</title>"
		);
		%>


<link rel="stylesheet" type="text/css" href="../css/MainpageStyle.css">
<link rel="stylesheet" type="text/css" href="../css/global.css">
<link rel="stylesheet"  href="../css/profile.css?after">
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
                                   <a class="navbar__item" href="../post/board-qna.jsp">게시판</a>
                               </li>
                               <% if(session.getAttribute("sid") == null) {%>
                               <li>
                                   <a class="log-in-btn" href="../join/login.jsp">로그인</a>
                               </li>
                               <li>
                               <%} else { 
                               	out.println(
                                        "<a class='navbar__item  active' href='../profile/showProfile.jsp?gitid=" + session.getAttribute("sid") + "'><span>" + session.getAttribute("sid") + "</span> 님의 프로필</a>" +
                                  		 "<a class='navbar__item' href='../group/showGroup.jsp?gitid=" + session.getAttribute("sid") + "'>그룹</a>"
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
	
			String profileQuery = "select M.github_id, M.avatar_url, M.user_github_url, M.ghchart_url, U.rank, U.total_score, U.stargazers_count, U.codeline_count, U.followers_count, U.commit_count, M.member_level, M.exp, U.location "
					+ "from member M, user_ranks U " + "where M.github_id = '" + userID + "' "
					+ "and U.user_rank_id = M.user_rank_id";
			rs = stmt.executeQuery(profileQuery);
	
			rs.next();
			String avartarUrl = rs.getString(2);
			String githubUrl = rs.getString(3);
			String ghchartUrl = rs.getString(4);
			int ranking = rs.getInt(5);
			int score = rs.getInt(6);
			int star = rs.getInt(7);
			int codeline = rs.getInt(8);
			int followers = rs.getInt(9);
			int commits = rs.getInt(10);
			int level = rs.getInt(11);
			int exp = rs.getInt(12);
			String local = rs.getString(13);
	
			String plantsLevel = null;
			String plantsImg = null;
			int maxExp = 0;
	
			switch (level % 3) {
			case 0:
				maxExp = 10;
				break;
			case 1: 
				maxExp = 30;
				break;
			case 2: 
				maxExp = 30;
				break;
			}
			
			switch ((level - 1) / 3) {
			case 0: // 씨앗
				plantsLevel = "씨앗 " + level;
				plantsImg = "seed";
				switch (level % 3) {
				case 0:
					maxExp = 10;
					break;
				case 1: 
					maxExp = 30;
					break;
				case 2: 
					maxExp = 60;
					break;
				}
				break;
			case 1: // 새싹
				plantsLevel = "새싹 " + (level-3);
				plantsImg = "sprout";
				switch (level % 3) {
				case 0:
					maxExp = 100;
					break;
				case 1: 
					maxExp = 150;
					break;
				case 2: 
					maxExp = 210;
					break;
				}
				break;
			case 2: // 잎새
				plantsLevel = "잎새 " + (level-6);
				plantsImg = "leaf";
				switch (level % 3) {
				case 0:
					maxExp = 280;
					break;
				case 1: 
					maxExp = 360;
					break;
				case 2: 
					maxExp = 450;
					break;
				}
				break;
			case 3: // 가지
				plantsLevel = "가지 " + (level-9);
				plantsImg = "branch";
				switch (level % 3) {
				case 0:
					maxExp = 550;
					break;
				case 1: 
					maxExp = 660;
					break;
				case 2: 
					maxExp = 780;
					break;
				}
				break;
			case 5: // 열매
				plantsLevel = "열매 " + (level-12);
				plantsImg = "fruit";
				switch (level % 3) {
				case 0:
					maxExp = 910;
					break;
				case 1: 
					maxExp = 1050;
					break;
				case 2: 
					maxExp = 1200;
					break;
				}
				break;
			default: // 나무
				plantsLevel = "나무 " + (level-12);
				plantsImg = "tree";
				switch (level % 3) {
				case 0:
					maxExp = 1400;
					break;
				case 1: 
					maxExp = 1600;
					break;
				case 2: 
					maxExp = 1800;
					break;
				}
				break;
			}
	
			out.println(
					"<div class='base-profile  float-box'>" + // Base profile
						"<h1>Profile</h1>" +
						"<div class='profile-img-container  float-box'>" + 
							"<img src='" + avartarUrl + "' width=200></img>" + 
						"</div>" + 
						"<div class='profile-container  float-box'>" + 
							"<div class='profile-title'>" + 
								"<img class='base-profile-level' src='../images/" + plantsImg + ".png'></img>" + 
								"<a class='github-url' href='" + githubUrl + "' target='_blank'>" + 
									"<span class='profile-id'>" + userID + "</span>" + 
								"</a>"
								);
	
			if (local != null) {
				out.println(
								"<p class='local'>" + local + "</p>" +
							"</div>");
			}
			else {
				out.println(
								"<p class='local'>" + "</p>" +
							"</div>");
			}
	
			out.println(
							"<div class='space'> </div>" + 
							"<ul class='user-info-list fist'>" + 
								"<li>" + "<span class='icon-name'>랭킹</span>" + "<span>" + ranking + "</span>" + "</li>" + 
								"<li>" + "<span class='icon-name'>점수</span>" + "<span>" + score + "</span>" + "</li>" + 
							"</ul>" + 
							"<ul class='user-info-list second'>" + 
								"<li>" + "<span class='icon-name'>Star</span>" + "<span>" + star + "</span>" + "</li>" + 
								"<li>" + "<span class='icon-name'>Follower</span>" + "<span>" + followers + "</span>" + "</li>" + 
								"<li>" + "<span class='icon-name'>Commit</span>" + "<span>" + commits + "</span>" + "</li>" + 
								"<li>" + "<span class='icon-name'>CodeLine</span>" + "<span>"	+ codeline + "</span>" + "</li>" + 
							"</ul>" + 
						"</div>" + 
					"</div>" +
						
					"<hr>" +
					
					"<div class='controbutions  float-box'>" + // Contribution
						"<h1>Contributions Chart</h1>" +
						"<img src='" + ghchartUrl + "'></img>" +
					"</div>" +
					
					"<div class='level-container  float-box'>" + // Level
						"<h1>Level</h1>" + 
						"<div class='level-compo'>" + 
							"<div class='level-info'>" + 
								"<img class='level-img' src='../images/" + plantsImg + ".png' width=100></img>" + 
								"<p class='level-label'>LV. " + plantsLevel + "</p>" +
							"</div>" + 
							"<div class='exp-info'>" + 
								"<progress id='gage' value=" + exp + " max=" + maxExp + "></progress>" + 
								"<p>" + exp	+ " / " + maxExp + " EXP</p>" +  
							"</div>" + 
						"</div>" +
					"</div>" +
					
					"<div class='language-container  float-box'>" + // Language
						"<h1>Language</h1>" + 
						"<div class='language-use-chart'>"
							+
							"<ul>");
			
			profileQuery = "select Sum(L.language_byte) "
					+ "from language L, repository R "
					+ "where L.repo_id = R.repository_id "
					+ "and R.mgithub_id = '" + userID + "'";
			rs = stmt.executeQuery(profileQuery);
			
			rs.next();
			
			int totalBytes = rs.getInt(1);
			
			profileQuery = "select L.language, Sum(L.language_byte) as total_byte "
					+ "from language L, repository R "
					+ "where L.repo_id = R.repository_id "
					+ "and R.mgithub_id = '" + userID + "' "
					+ "group by L.language "
					+ "order by total_byte desc";
			rs = stmt.executeQuery(profileQuery);
			
			while(rs.next()) {
				double tempBytes = rs.getInt(2);
				double usePnt = tempBytes/totalBytes * 100;
				out.println("<li class='item'>" +
								rs.getString(1) + " : " + Math.round(usePnt) + "%" +
							"</li>");
				int r = (int)(Math.random() * 250);
				int g = (int)(Math.random() * 250);
				int b = (int)(Math.random() * 250);
				
		        out.println(
		        		"<div class='chart-data' style='background-color:rgb(" + r + "," + g + "," + b +");width:" + Math.round(usePnt) + "%'> </div>"
		        		);
			}
	
			out.println(
							"</ul>" +
						"</div>" +
					"</div>" +
	
					"<div class='rank-container  float-box'>" + // Rank 
						"<h1>Github Ranking</h1>"
						);
			
			profileQuery = "select max(rank) "
					+ "from user_ranks";
			rs = stmt.executeQuery(profileQuery);
			
			rs.next();
			
			double maxRank = rs.getInt(1);
			double rankPnt = ranking / maxRank * 100;
	
			out.println(
						"<div class='rank-num'>" +
							"<img src='../images/rank.png'>" +
							"<p>" + ranking + " 위</p>" + 
						"</div>" +
						"<div class='ranking-pnt'>" +
							"<p><span>" + userID + "</span> 님은 현재 상위 <span>" + Math.round(rankPnt) + "% </span> 에 속합니다.</p>" +
						"</div>" +
					"</div>" +
					
					"<hr>" +
					
					"<div class='repo-container'>" + 
						"<details>" +
							"<summary class='repo-toggle'>Repository List &nbsp; <span class='alert'> 유저의 repository를 보려면 여기를 누르세요.</span></summary>");
			
			profileQuery = "select * "
					+ "from repository "
					+ "where mgithub_id='" + userID + "'";
			rs = stmt.executeQuery(profileQuery);
			
			while (rs.next()) {
				out.println(
								"<div class='repo-item'>" + 
									"<div class='repo-item-title'>" + 
										"<h3>" +
											"<a href='" + rs.getString(3) +"' target='_brank'>" + rs.getString(2) +  "</a>" + 
										"</h3>" + 
									"</div>" + 
									"<div class='repo-item-detail'>" + 
										"<table>" +
											"<tr>" + 
												"<td class='repo-info-item'>" + 
													"<img src='../images/fork.png' width=30>" +
												"</td>" + 
												"<td class='repo-info-item'>" + 
													"<img src='../images/star.png' width=30>" +
												"</td>" + 
												"<td class='repo-info-item'>" + 
													"<img src='../images/pr.png' width=30>" +
												"</td>" + 
												"<td class='repo-info-item'>" + 
													"<img src='../images/issue.png' width=30>" +
												"</td>" + 
												"<td class='repo-info-item'>" + 
													"<img src='../images/commit.png' width=30>" +
												"</td>" + 
											"</tr>" + 
											"<tr>" + 
												"<td class='repo-info-item'>" + 
													"<span>FORK </span>" +
													"<span>" + rs.getInt(4) + "</span>" +
												"</td>" +
												"<td class='repo-info-item'>" + 
													"<span>STAR </span>" +
													"<span>" + rs.getInt(5) + "</span>" +
												"</td>" +
												"<td class='repo-info-item'>" +
													"<span>PR </span>" +
													"<span>" + rs.getInt(6) + "</span>" +
												"</td>" +
												"<td class='repo-info-item'>" +
													"<span>ISSUE </span>" +
													"<span>" + rs.getInt(7) + "</span>" +
												"</td>" +
												"<td class='repo-info-item'>" + 
													"<span>COMMIT </span>" +
													"<span>" + rs.getInt(8) + "</span>" +
												"</td>" +
											"</tr>" +
										"</table>" + 
									"</div>" + 
								"</div>"
						);
			}
			
			out.println(
						"</details>" +
					"</div>");
	
			rs.close();
			stmt.close();
			conn.close();
			%>
		</div>
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