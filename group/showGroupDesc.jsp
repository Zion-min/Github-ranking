<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ page language="java" import="java.text.*,java.sql.*, java.util.*"%>    
<% request.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Rankinghub:Group_Desc</title>
<link rel="stylesheet"  href="../css/styles.css?after">
<link rel="stylesheet"  href="../css/groupDesc.css?after">
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
		<div class='group-container'>
		<%					
			String serverIP = "localhost";
			String strSID = "orcl";
			String portNum = "1521";
			String user = "rankinghub";
			String pass = "comp322";
			String url = "jdbc:oracle:thin:@" + serverIP + ":" + portNum + ":" + strSID;
			
			Connection conn = null;
			Statement stmt;
			ResultSet rs;
			Class.forName("oracle.jdbc.driver.OracleDriver");
			conn = DriverManager.getConnection(url, user, pass);
	
			stmt = conn.createStatement();
			int groupId = Integer.parseInt(request.getParameter("groupId")) ;
			
			String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
		    
			// 현재 그룹에 사용자가 가입했는지의 여부
		    String is_in_query = "select count(*) from participate_in where mgithub_id = '" + userID + "' and group_id = " + groupId;
		    rs = stmt.executeQuery(is_in_query);
		    rs.next();
		    
		    int is_group_in = rs.getInt(1);
		    if (is_group_in == 0)
		    	out.println("<a href=\"showGroupParticipate.jsp?groupId=" + groupId + "\" class='group-link'>" + "그룹 참여" + "</a>");
			
			String groupQuery = "select C.group_name, C.manage_github_id ,C.group_period, C.group_start_date + 0 , C.group_start_date + C.group_period, TRUNC(SYSDATE) - TRUNC(C.group_start_date)"
					+ "from challenge_group C "
					+ "where C.group_id = " + groupId;
			rs = stmt.executeQuery(groupQuery);
			rs.next();
			
			String groupName = rs.getString(1);
			String groupMng = rs.getString(2);
			
			out.println(
				"<div class='group-desc-title'>" + 
					"<h1>" + groupName + "</h1>" +
					"<span>" +
						"<p>" + rs.getInt(3) + "일 :</p>" +
						"<p>" + rs.getDate(4) + " ~ " + rs.getDate(5) + "</p>" +
					"</span>" + 
				"</div>" +	
				"<div class='group-desc-progress'>" + 
					"<h2>Challenge 진행률</h2>");
			
			int progressPnt = 0;
			int progressDays = 0;
			
			if (rs.getFloat(3)<= rs.getFloat(6)){
					progressPnt = 100;
					progressDays = rs.getInt(3);
					out.println(	
							"<p class='group-alert'>해당 그룹은 Chanllenge가 종료되었습니다!</p>"
						);
			}
			else {
				progressPnt = Math.round(rs.getFloat(6) / rs.getFloat(3) * 100);
				progressDays = rs.getInt(6);
			}
			out.println(	
					"<p class='group-pnt'>" + progressPnt + " %</p>" + 
					"<p class='remain-days'>" + progressDays + " / " + rs.getInt(3) + "</p>" +
				"</div>");
			
			groupQuery = "select  M.avatar_url, U.rank "
					+ "from member M, user_ranks U "
					+ "where M.github_id = '" + groupMng + "'"
					+ "and U.user_rank_id = M.user_rank_id";
			rs = stmt.executeQuery(groupQuery);
			rs.next();
			
			out.println(				
				"<div class='group-desc-mng'>" + 
					"<h2>그룹 관리자</h2>" + 
					"<table class='mng-info'>" +
						"<tr>" +
							"<td>" +
								"<span>Github ID</span>" +
							"</td>" +
							"<td>" +
								"<span> </span>" +
							"</td>" +
							"<td>" + 
								"<span>전체 순위</span>" + 
							"</td>" +
						"</tr>" +
						"<tr>" +
							"<td>" + 
								"<img class='mng-img' src='" + rs.getString(1) + "'>" + 
							"</td>" +
							"<td>" +
								"<a href=\"../profile/showProfile.jsp?gitid=" + groupMng + "\">" +
									"<span>" + groupMng + "</span>" +
								"</a>" +
							"</td>" +
							"<td>" + 
								"<span>" + rs.getInt(2) + "위 </span>" + 
							"</td>" +
						"</tr>" +
					"</table>" +
				"</div>" + 
					
				"<div class='group-desc-member'>" +
					"<h2>그룹원 랭킹 정보</h2>" + 
					"<table class='member-info'>" +
						"<tr>" +
							"<td>" +
								"<span>Github ID</span>" +
							"</td>" +
							"<td>" +
								"<span> </span>" +
							"</td>" +
							"<td>" + 
								"<span>전체 순위</span>" + 
							"</td>" +
						"</tr>");
			
			groupQuery = "select M.github_id, M.avatar_url,U.Rank, TRUNC(C.group_start_date + C.group_period) - TRUNC(P.created_at) "
					+ "from member M, participate_in P, challenge_group C, user_ranks U " 
					+ "where C.group_id = " + groupId
					+ "and M.github_id = P.mgithub_id "
					+ "and P.group_id = C.group_id "
					+ "and U.user_rank_id = M.user_rank_id "
					+ "order by U.Rank";
			rs = stmt.executeQuery(groupQuery);
			
			int totalDates = 0;
			
			while (rs.next()) {
				totalDates += rs.getInt(4);
				if (rs.getString(1).equals(groupMng)){
					continue;
				}
				out.println(
						"<tr>" +
							"<td>" + 
								"<img class='member-img' src='" + rs.getString(2) + "'>" + 
							"</td>" +
							"<td>" +
								"<a href=\"../profile/showProfile.jsp?gitid=" + rs.getString(1) + "\">" +
									"<span>" + rs.getString(1) + "</span>" +
								"</a>" +
							"</td>" +
							"<td>" + 
								"<span>" + rs.getInt(3) + "위 </span>" + 
							"</td>" +
						"</tr>"
					);	
			}
			
			out.println(
					"</table>"+
				"</div>" + 
					"<div class='group-desc-attend'>" +
						"<h2>주간 출석부</h2>" +
							"<table class='attendance-chart'>" +
								"<tr>" +
									"<th>날짜</th>"
									);
			
			ArrayList<String> mems = new ArrayList<>();
			
			groupQuery = "select M.github_id "
					+ "from member M, participate_in P, challenge_group C "
					+ "where C.group_id = " + groupId + " "
					+ "and M.github_id = P.mgithub_id "
					+ "and P.group_id = C.group_id "
					+ "order by M.github_id";
			rs = stmt.executeQuery(groupQuery);
			int memCnt = 0;
			while(rs.next()) {
				mems.add(memCnt, rs.getString(1));
				memCnt++;
				out.println(
									"<th><span>" + rs.getString(1) +"</span></th>"
						);
			}
			
			out.println(
								"</tr>"
			);
			
			int[] weekcnt = new int[memCnt];
			Arrays.fill(weekcnt, 0);
			
			// i일 전 출석 확인 - 일주일 출석부
			for (int i = 0; i < 7 ; i++) {
				groupQuery = "select distinct MM.github_id, L.ccnt, sysdate - " + i + " "
						+ "from member MM left join ("
								+ "select M.github_id as name, count(*) as ccnt "
								+ "from member M, commits C "
								+ "where M.github_id = C.author "
								+ "and C.commit_date+0 >= SYSDATE - " + i + " "
								+ "and C.commit_date+0 < SYSDATE - " + i + " "
								+ "group by M.github_id) L "
								+ "on MM.github_id = L.name , participate_in P "
								+ "where P.group_id = " + groupId + " "
								+ "and P.mgithub_id = MM.github_id "
								+ "order by MM.github_id";
				rs = stmt.executeQuery(groupQuery);
				
				ArrayList<Integer> daycheck = new ArrayList<>();
				int tempidx = 0;
				String rowTimeStp = "";
				while(rs.next()){
					rowTimeStp = rs.getString(3);
					weekcnt[tempidx] += rs.getInt(2);
					daycheck.add(tempidx++, rs.getInt(2));
				}
				String[] checkDate = rowTimeStp.split(" ");
				
				out.println(
								"<tr>" +
										"<td><span>" + checkDate[0] + "</span></td>"
							);
				
				for (int j = 0; j < daycheck.size(); j++){
					if (daycheck.get(j) == 0) {
						out.println(
										"<td><img src='../images/no.png'>NOP</td>"
						);
					}
					else {
						out.println(
										"<td><img src='../images/yes.png'>YES</td>"
						);	
					}
				}
				out.println(
									"</tr>"
							);
				
				
			}		
			
			
			out.println(		
							"</table>" +
					"</div>" + 
				"<div class='group-desc-stats'>" + 
					"<div class='total-stat'>" + 
						totalDates + 
					"</div>" + 
					"<div class='tomorrow-stat'>" + 
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