<%@page import="org.eclipse.jdt.internal.compiler.util.HashtableOfType"%>
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
	    <title>RankingHub: 자유게시판 </title>
        <link rel="stylesheet" type="text/css" href="../css/MainpageStyle.css">
        <link rel="stylesheet" type="text/css" href="../css/global.css">
        <link rel="stylesheet" type="text/css" href="../css/post.css">
        <link rel="icon" type="image/png" href="../images/logo.png">
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
                                   <a class="navbar__item  active" href="../post/board-qna.jsp">게시판</a>
                               </li>
                               <% if(session.getAttribute("sid") == null) {%>
                               <li>
                                   <a class="log-in-btn" href="../join/login.jsp">로그인</a>
                               </li>
                               <li>
                               <%} else { 
                               	out.println(
                                        "<a class='navbar__item' href='../profile/showProfile.jsp?gitid=" + session.getAttribute("sid") + "'><span>" + session.getAttribute("sid") + "</span> 님의 프로필</a>" +
                                  		 "<a class='navbar__item' href='../group/showGroup.jsp?gitid=" + session.getAttribute("sid") + "'>그룹</a>"
                                        ); %>
                                   <a class="log-in-btn" href="../join/logout.jsp">로그아웃</a>
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
                                            href="./board-qna.jsp"> Q&A  </a>
                                    </li>
                                    <li class="filter-nav__item">
                                        <a
                                            class="filter-nav__link  active"
                                            href="./board-freetalk.jsp"> 자유게시판 </a>
                                    </li>
                                    <li class="filter-nav__item">
                                        <a
                                            class="filter-nav__link"
                                            href="./board-tip.jsp"> 꿀팁 </a>
                                    </li>
                                </ul>
                            </div>
                        </div>
                        <div class="ranking__header pc-only">
                            <p class="ranking__help-text">자유게시판<br><span> 자유롭게 의견을 나누는 게시판 </span>
                            </p>
                        </div>
                        <div class="filtering">
                        	<form method="post">
	                        	<select class="sorting" name="order" onchange="this.form.submit()">
	                        		<%String ft = request.getParameter("order"); %>
	                        		<option value="recent"<%if(ft==null || ft.compareTo("recent")==0){%>selected="selected"<%}%>>최신순</option>
	                        		<option value="view"<%if(ft!=null && ft.compareTo("view")==0){%>selected="selected"<%}%>>조회순</option>
	                        		<option value="like"<%if(ft!=null && ft.compareTo("like")==0){%>selected="selected"<%}%>>좋아요순</option>
	                        	</select>
                        	</form>
                        	<span class="writing">
                        	<a href='boardCreate.jsp'>글쓰기</a>
                        	</span>
                        </div>
                        <div class="ranking__content tier-view">
                            <table class="m-table">
                                <thead>
                                </thead>
                                <tbody>
                                <%
                                	if (ft == null || ft.compareTo("recent")==0)
                                	{
                                		sql = "select title, is_anonymous, mgithub_id, views, likes, created_at, post_id "
        										+ "from post "
        										+ "where category_id = 2 "
        										+ "order by created_at desc";
                                	}
                                	else if (ft.compareTo("view")==0)
                                	{
                                		sql = "select title, is_anonymous, mgithub_id, views, likes, created_at, post_id "
        										+ "from post "
        										+ "where category_id = 2 "
        										+ "order by views desc";
                                	}
                                	else if (ft.compareTo("like")==0)
                                	{
                                		sql = "select title, is_anonymous, mgithub_id, views, likes, created_at, post_id "
        										+ "from post "
        										+ "where category_id = 2 "
        										+ "order by likes desc";
                                	}
                                
       								rs = stmt.executeQuery(sql);
       								%>
       								<thead>
	                                    <tr>
	                                        <th>제목</th>
	                                        <th>작성자</th>
	                                        <th>조회수</th>
	                                        <th>좋아요</th>
	                                        <th>작성일</th>
	                                    </tr>
                                	</thead>
       								<%
									while(rs.next()){
										out.println("<tr>");
										out.println("<td> <a href=\"board-view.jsp?post_id="+rs.getString(7)+"\" style=\"cursor: pointer;\">"+rs.getString(1)+"</a> </td>");
										if(rs.getInt(2)==1){out.println("<td> 익명 </td>");}
										else{out.println("<td> "+rs.getString(3)+" </td>");}
										out.println("<td> "+rs.getString(4)+" </td>");
										out.println("<td> "+rs.getString(5)+" </td>");
										out.println("<td> "+rs.getString(6)+" </td>");
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
			           	<img src="../images/logo.png" width=50px alt="">
			            <a class="footer__desc" href="https://github.com/Zion-min/Rankinghub">
			            Go_github
			            </a>
			        </p>
			    </footer>
    		</div>
    	</div>
    </body>
</html>