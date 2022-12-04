<%@ page language="java" contentType="text/html; charset=EUC-KR"
	pageEncoding="EUC-KR"%>
<%@ page language="java" import="java.text.*,java.sql.*"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Rankinghub:User_profile</title>
<link rel="stylesheet"  href="../css/profile.css?after">
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
			<div class="split-area black"> </div>
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
							"<img class='base-profile-level' src='../images/" + plantsImg + ".png' width=50></img>" + 
							"<a class='github-url' href='" + githubUrl + "' target='_blank'>" + 
								"<span class='profile-id'>" + userID + "</span>" + 
							"</a>");
	
			if (local != null) {
				out.println("<span class='local'>" + local + "</span>");
			}
	
			out.println(
							"<ul>" + 
								"<li>" + "<span>랭킹</span>" + "<span>" + ranking + "</span>" + "</li>" + 
								"<li>" + "<span>점수</span>" + "<span>" + score + "</span>" + "</li>" + 
							"</ul>" + 
							"<ul>" + 
								"<li>" + "<span>Star</span>" + "<span>" + star + "</span>" + "</li>" + 
								"<li>" + "<span>Follower</span>" + "<span>" + followers + "</span>" + "</li>" + 
								"<li>" + "<span>Commit</span>" + "<span>" + commits + "</span>" + "</li>" + 
								"<li>" + "<span>CodeLine</span>" + "<span>"	+ codeline + "</span>" + "</li>" + 
							"</ul>" + 
						"</div>" + 
					"</div>" +
	
					"<div class='split-area white'> </div>" + 
					
					"<div class='controbutions  float-box'>" + // Contribution
						"<h1>Contributions Chart</h1>" +
						"<img src='" + ghchartUrl + "'></img>" +
					"</div>" +
								
					"<div class='split-area white'> </div>" + 
					
					"<div class='level-container  float-box'>" + // Level
						"<h1>Level</h1>" +  
						"<div class='level-info'>" + 
							"<img class='level-img' src='../images/" + plantsImg + ".png' width=100></img>" + 
							"<span class='level-label'>LV. " + plantsLevel + "</span>" + 
						"</div>" + 
						"<div class='exp-info'>" + 
							exp	+ " / " + maxExp + 
						"</div>" + 
					"</div>" +
	
					"<div class='split-area white'> </div>" + 
					
					"<div class='language-container  float-box'>" + // Language
						"<h1>Language</h1>" + 
						"<div class='language-use-chart'>" + 
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
			}
	
			out.println(
							"</ul>" +
						"</div>" +
					"</div>" +
	
					"<div class='rank-container  float-box'>" + // Rank 
						"<h1>Github Ranking</h1>");
			
			profileQuery = "select max(rank) "
					+ "from user_ranks";
			rs = stmt.executeQuery(profileQuery);
			
			rs.next();
			
			double maxRank = rs.getInt(1);
			double rankPnt = ranking / maxRank * 100;
	
			out.println(
						"<div class='rank-num'>" +
							"<p>" + ranking + "</p>" + 
						"</div>" +
						"<div class='ranking-pnt'>" +
							"<p>" + userID + "님은 현재 상위 <span>" + Math.round(rankPnt) + "</span> %에 속합니다.</p>" +
						"</div>" +
					"</div>" +
	
					"<div class='split-area white'> </div>" +
					
					"<div class='repo-cotainer float-box'>" + 
						"<details>" +
							"<summary class='repo-toggle'>Repository List</summary>");
			
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
										"<p class='repo-info-fork'>" + 
											"<span>FORK</span>" +
											"<span>" + rs.getInt(4) + "</span>" +
										"</p>" +
										"<p class='repo-info-star'>" + 
											"<span>STAR</span>" +
											"<span>" + rs.getInt(5) + "</span>" +
										"</p>" +
										"<p class='repo-info-pr'>" + 
											"<span>PR</span>" +
											"<span>" + rs.getInt(6) + "</span>" +
										"</p>" +
										"<p class='repo-info-issue'>" + 
											"<span>ISSUE</span>" +
											"<span>" + rs.getInt(7) + "</span>" +
										"</p>" +
										"<p class='repo-info-commit'>" + 
											"<span>COMMIT</span>" +
											"<span>" + rs.getInt(8) + "</span>" +
										"</p>" +
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
	<footer id='footer'>
		<p class='footer-desc'>team describe</p>
		<div class="footer__spliter pc-only"></div>
		<p class='footer-github'>github link</p>
	</footer>
	

</body>
</html>