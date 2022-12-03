<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*" %>
<!DOCTYPE html>
<% 
	String serverIP = "localhost";
	String strSID = "xe";
	String portNum = "1521";
	String user = "rankinghub";
	String pass = "comp322";
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
	    <title>RankingHub: 개발자 랭킹 </title>
        <link rel="stylesheet" type="text/css" href="./css/MainpageStyle.css">
        <link rel="stylesheet" type="text/css" href="./css/global.css">
        <link rel="icon" type="image/png" href="./img/logo.png">
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
                            <a class="header__link" href="#/">
                                <h1 class="header__title"><span>Rankinghub</span>
                            	</h1>
                            </a>
                            <a role="button" class="header__menu-btn">
                            <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="bars" class="svg-inline--fa fa-bars fa-w-14 " role="img" xmlns="http://www.w3.org/2000/svg" viewbox="0 0 448 512">
                                <path fill="currentColor" d="M16 132h416c8.837 0 16-7.163 16-16V76c0-8.837-7.163-16-16-16H16C7.163 60 0 67.163 0 76v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16zm0 160h416c8.837 0 16-7.163 16-16v-40c0-8.837-7.163-16-16-16H16c-8.837 0-16 7.163-16 16v40c0 8.837 7.163 16 16 16z"></path>
                            </svg>
                        	</a>
                        </div>
                       	<nav class="header__column header__navbar navbar">
                            <ul class="navbar__menu">
                                <li>
                                    <a aria-current="page" class="navbar__item active" href="#/main">순위</a>
                                </li>
                                <li>
                                    <a class="navbar__item" href="#/users">게시판</a>
                                </li>
                                <li>
                                    <a class="navbar__item" href="#/notice">로그인</a>
                                </li>
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
                                            class="filter-nav__link active"
                                            href="./index-user.jsp"> 유저 🧑‍💻  </a>
                                    </li>
                                    <li class="filter-nav__item">
                                        <a
                                            class="filter-nav__link"
                                            href="./index-repository.jsp"> 레포지토리 🗳</a>
                                    </li>
                                    <li class="filter-nav__item">
                                        <a
                                            class="filter-nav__link"
                                            href="./index-organization.jsp"> 조직 🏢 </a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <div class="ranking__header pc-only">
                            <p class="ranking__help-text">유저 TOP 50<br><span>랭킹은 주기적으로 갱신됩니다.</span>
                            </p>
                        </div>
                        <div class="ranking__content tier-view">
                            <table class="m-table">
                                <thead>
                                    <tr>
                                        <th>랭킹</th>
                                        <th>아이디</th>
                                        <th>점수</th>
                                    </tr>
                                </thead>
                                <tbody>
                                   	<%
                                    	sql = "select u.rank, u.github_url, m.avatar_url, m.github_id, u.total_score "
        										+ "from user_ranks u, member m "
        										+ "where u.rank <= 50 and u.github_id = m.github_id "
        										+ "order by u.rank";
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
		            <p class="footer__desc">Copyright © Team3 <img src="./img/logo.png" alt=""></p>
        		</footer>	
    		</div>
    	</div>
    </body>
</html>