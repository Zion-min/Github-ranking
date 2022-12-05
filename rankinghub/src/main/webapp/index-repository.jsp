<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*" %>
<!DOCTYPE html>
<% 
	String serverIP = "localhost";
	String strSID = "orcl";
	String portNum = "1521";
	String user = "gitrank";
	String pass = "gitrank";
	String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;
	//System.out.println(url);
	Connection conn = null;
	ResultSet rs;
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn = DriverManager.getConnection(url,user,pass);
	Statement stmt = conn.createStatement();
	String sql = "";
%>	
<html lang="en">
    <head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width,initial-scale=1">
	    <title> RankingHub </title>
        <link rel="stylesheet" type="text/css" href="./css/MainpageStyle.css">
        <link rel="stylesheet" type="text/css" href="./css/global.css">
        <link rel="icon" type="image/png" href="./images/logo.png">
		<script async="" src="https://www.googletagmanager.com/gtag/js?id=G-GMEG5REB2K">
		</script>
		<script> window.dataLayer = window.dataLayer || [];
	
	            function gtag() {
	                dataLayer.push(arguments);
	            }
	            gtag("js", new Date());

	            gtag("config", "G-GMEG5REB2K");</script>
    </head>
    <body>
        <div id="app">
            <div role="document" class="root">
                <header id="header">
                    <div class="header__wrap">
                    	<div class="header__column">
                    		<div class='nav-bar'>
								<img src="./images/logo.png" height="50">
								<a class ="header__link" href="./index-user.jsp">
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
                                    <a aria-current="page" class="navbar__item active" href="./index-user.jsp">순위</a>
                                </li>
                                <li>
                                    <a class="navbar__item" href="./post/board-qna.jsp">게시판</a>
                                </li>
                                <% if(session.getAttribute("sid") == null) {%>
                                <li>
                                    <a class="log-in-btn" href="./join/login.jsp">로그인</a>
                                </li>
                                <li>
                                <%} else { 
                                	out.println(
                                         "<a class='navbar__item' href='./profile/showProfile.jsp?gitid=" + session.getAttribute("sid") + "'><span>" + session.getAttribute("sid") + "</span> 님의 프로필</a>" +
                                   		 "<a class='navbar__item' href='./group/showGroup.jsp?gitid=" + session.getAttribute("sid") + "'>그룹</a>"
                                         ); %>
                                    <a class="log-in-btn" href="logout.jsp">로그아웃</a>
                                </li>
                                <% }%>
                            </ul>
                        </nav>
                    </div>
                </header>
                <main id="content">
                    <div id="ranking">
                        <div class="ranking__nav">
                            <div class="filter-nav">
                                <ul class="filter-nav__list">
                                    <li class="filter-nav__item">
                                        <a
                                            aria-current="page"
                                            class="filter-nav__link"
                                            href="./index-user.jsp"> 유저  </a>
                                    </li>
                                    <li class="filter-nav__item">
                                        <a
                                            class="filter-nav__link active"
                                            href="./index-repository.jsp"> 레포지토리 </a>
                                    </li>
                                    <li class="filter-nav__item">
                                        <a
                                            class="filter-nav__link"
                                            href="./index-organization.jsp"> 조직 </a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <div class="ranking__header pc-only">
                            <p class="ranking__help-text">레포지토리 TOP 50<br><span>랭킹은 주기적으로 갱신됩니다.</span>
                            </p>
                        </div>
                        <div class="ranking__content tier-view">
                            <table class="m-table">
                                <thead>
                                    <tr>
                                        <th>랭킹</th>
                                        <th>레포지토리 이름</th>
                                        <th>점수</th>
                                    </tr>
                                </thead>
                                <tbody>
                                   	<%
	                                   	sql = "select r.rank,  r.repo_url, m.avatar_url, r.full_name, r.total_score "
	    										+ "from repository_ranks r, repository p, member m "
	    										+ "where r.rank <= 50 and r.repo_rank_id = p.repo_rank_id and p.mgithub_id = m.github_id "
	    										+ "order by r.rank";
        								rs = stmt.executeQuery(sql);
										
										while(rs.next()){
											out.println("<tr>");
											out.println("<td style=\"vertical-align: middle;\"> <div>"+rs.getString(1)+"</div> </td>");
											out.println("<td style=\"vertical-align: middle;\"> <a href=\""+rs.getString(2)+"\" style=\"cursor: pointer;\">");
											out.println("<img width=\"30\" height=\"30\" class=\"a-avatar\"  src=\""+rs.getString(3)+"\"  title=\"\" style=\"border-radius: 7px; transform: translateY(calc(50% - 5px));\">");
											out.println("<span style=\"margin-left: 5px; cursor: inherit;\"> "+rs.getString(4)+"</span> </a> </td>");
											out.println("<td style=\"vertical-align: middle;\">"+rs.getString(5)+"</td>");	
											out.println("</tr>");		
										}
										
										rs.close();
										stmt.close();
										conn.close();
								%>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </main>
             	<footer id="footer">
		            <p class="footer__desc">Copyright © DB_Programing_Team3</p>
		            <div class="footer__spliter pc-only"></div>
		            <p class="git_link">
		            	<img src="./images/logo.png" width=50px alt="">
			            <a class="footer__desc" href="https://github.com/Zion-min/Rankinghub">
			            Go_github
			            </a>
			        </p>
        		</footer>	
    		</div>
    	</div>
    </body>
</html>