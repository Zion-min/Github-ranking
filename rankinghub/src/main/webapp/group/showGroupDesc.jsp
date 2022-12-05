<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*, java.util.*"%>    
<% request.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Rankinghub: Group_Desc</title>
<link rel="stylesheet" type="text/css" href="../css/MainpageStyle.css">
<link rel="stylesheet" type="text/css" href="../css/global.css">
<link rel="stylesheet" type="text/css" href="../css/groupDesc.css">
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
		<div class='group-container'>
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
			
			String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
		    
			// 현재 그룹에 사용자가 가입했는지의 여부
		    String is_in_query = "select count(*) from participate_in where mgithub_id = '" + userID + "' and group_id = " + groupId;
		    rs = stmt.executeQuery(is_in_query);
		    rs.next();
		    
		    int is_group_in = rs.getInt(1);
		    
			
			String groupQuery = "select C.group_name, C.manage_github_id ,C.group_period, C.group_start_date + 0 , C.group_start_date + C.group_period, TRUNC(SYSDATE) - TRUNC(C.group_start_date)"
					+ "from challenge_group C "
					+ "where C.group_id = " + groupId;
			rs = stmt.executeQuery(groupQuery);
			rs.next();
			
			String groupName = rs.getString(1);
			String groupMng = rs.getString(2);
			
			out.println(
				"<div class='group-desc-title'>" + 
					"<h1>" + groupName + "</h1>");
			
			if (is_group_in == 0)
		    	out.println("<div class='participate-group'><a href=\"showGroupParticipate.jsp?groupId=" + groupId + "\" class='group-link'>" + "# 그룹 참여" + "</a></div>");
			
			out.println(
					"<div>" +
						"<p>" + rs.getInt(3) + "일 :</p>" +
						"<p>" + rs.getDate(4) + " ~ " + rs.getDate(5) + "</p>" +
					"</div>" + 
				"</div>" +	
				"<hr>" + 
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
					"<div>" + 
						"<span class='group-pnt'>" + progressPnt + " %</span>" + 
						"<span class='remain-days'> ( " + progressDays + " / " + rs.getInt(3) + " ) </span>" +
					"</div>" +
					"<div class='gage-guideline'>" +
							"<div class='gage-bar' style='width:" + progressPnt + "%'></div>" +
					"</div>" +
				"</div>");
			
			groupQuery = "select  M.avatar_url, U.rank "
					+ "from member M, user_ranks U "
					+ "where M.github_id = '" + groupMng + "'"
					+ "and U.user_rank_id = M.user_rank_id";
			rs = stmt.executeQuery(groupQuery);
			rs.next();
			
			out.println(			
				"<hr>" +
				"<div class='group-desc-mng'>" + 
					"<h2>그룹 관리자</h2>" + 
					"<div class='helper'>"+
						"<div class='mng-profile'>" + 
							"<a href=\"../profile/showProfile.jsp?gitid=" + groupMng + "\">" +
								"<p>" +groupMng + "</p>" +
							"</a>" +
							"<img class='mng-img' src='" + rs.getString(1) + "'>" + 
						"</div>" +
						"<div class='mng-rank'>" + 
							"<p>전체 순위: <span>" + rs.getInt(2) + " 위</span></p>" + 
						"</div>" +
					"</div>" +	
				"</div>" +
					
				"<div class='group-desc-member'>" +
					"<h2>그룹원 랭킹 정보</h2>" 
					+ "<div class='helper'>"
					);
			
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
						"<div class='mem-info'>" +
							"<div class='mem-profile'>" + 
									"<a href=\"../profile/showProfile.jsp?gitid=" + rs.getString(1) + "\">" +
									"<p>" + rs.getString(1) + "</p>" +
								"</a>" +
								"<img class='mng-img' src='" + rs.getString(2) + "'>" + 
							"</div>" +
							"<div class='mem-rank'>" + 
								"<p>전체 순위: <span>" + rs.getInt(3) + " 위</span></p>" + 
							"</div>" +
						"</div>" 
					);	
			}
			
			out.println(
					"</div>"+
				"</div> <hr>" + 
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
								+ "and C.commit_date+0 < SYSDATE - " + (i+1) + " "
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
			
			int progressTotal = 0;
			int dateTotal = 0;
			
			groupQuery = "select M.github_id as name, count(*) as ccnt "
					+ "from member M, commits C, participate_in P "
					+ "where M.github_id = C.author "
					+ "and C.commit_date >= P.created_at "
					+ "and C.commit_date < SYSDATE "
					+ "and P.group_id = " + groupId + " "
					+ "and P.mgithub_id = M.github_id "
					+ "group by M.github_id ";
			rs = stmt.executeQuery(groupQuery);
			
			while(rs.next()) {
				progressTotal += rs.getInt(2);
			}
			
			groupQuery = "select M.github_id, trunc(sysdate)- trunc(P.created_at), C.group_period "
					+ "from member M, participate_in P, challenge_group C "
					+ "where P.group_id = " + groupId + " "
					+ "and P.mgithub_id=M.github_id "
					+ "and C.group_id = P.group_id ";
			rs = stmt.executeQuery(groupQuery);
			
			while(rs.next()) {
				dateTotal += rs.getInt(2);
			}
			
			double attendPnt = Math.round( (double) progressTotal / dateTotal * 100 );
			
			out.println(		
							"</table>" +
					"</div>" + 
				"<div class='group-desc-stats'>" + 
					"<div class='total-stat'>" + 
						"<h2>그룹 전체 출석률</h2>" +
						"<div class='groupatttd'><p>" + attendPnt + "%</p></div>" + 
						"<div class='gage-guideline'>" + 
							"<div class='gage-bar' style='width:" + attendPnt + "%'></div>" +
						"</div>" + 
					"</div>" + 
					"<div class='tomorrow-stat'>" + 
						"<h2>내일의 출석부</h2>" +
						"<p>그룹 멤버들이 내일 출석할 확률은 다음과 같습니다.</p>" +
						"<table class='attendance'>" + 
							"<tr>"
							);
			
			for (int i = 0; i < memCnt; i++) {
				out.println(
								"<th>" + mems.get(i) + "</th>"
						);
			}
			
			out.println(
							"</tr>" +
							"<tr>"
							);
			
			for (int i = 0; i < memCnt; i++) {
				double memAttendPnt = (double) weekcnt[i] / 7 * 100;
				out.println(
						"<td>" + memAttendPnt + "%</td>"
						);
			}
			
			out.println(
							"</tr>" +
						"</table>" +
					"</div>" + 
				"</div>" 
					);
			
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