<%@page import="org.eclipse.jdt.internal.compiler.util.HashtableOfType"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*,java.util.Date" %>
<!DOCTYPE html>
<% 
	request.setCharacterEncoding("UTF-8");
	String serverIP = "localhost";
	String strSID = "orcl";
	String portNum = "1521";
	String user = "rankinghub";
	String pass = "comp322";
	String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;
	//System.out.println(url);
	Connection conn = null;
	ResultSet rs;
	Class.forName("oracle.jdbc.driver.OracleDriver");
	conn = DriverManager.getConnection(url,user,pass);
	Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
	String sql = "";
%>	
<html lang="en">
    <head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width,initial-scale=1">
	    <title>RankingHub: 개발자 랭킹 </title>
        <link rel="stylesheet" type="text/css" href="./css/MainpageStyle.css">
        <link rel="stylesheet" type="text/css" href="./css/global.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.8.2/css/all.min.css" />
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
                                    <a aria-current="page" class="navbar__item" href="./join/index-user.jsp">순위</a>
                                </li>
                                <li>
                                    <a class="navbar__item active" href="./board-qna.jsp">게시판</a>
                                </li>
                                <% if(session.getAttribute("sid") == null) {%>
                                <li>
                                    <a class="navbar__item" href="./join/login.jsp">로그인</a>
                                </li>
                                <%} else { out.println(session.getAttribute("sid"));%>
                                <li>
                                <% out.println(
                                         "<a class='navbar__item' href='../profile/showProfile.jsp?gitid=" + session.getAttribute("sid") + "'>프로필</a>"
                                         ); %>
                                    <a class="navbar__item" href="logout.jsp">로그아웃</a>
                                </li>
                                <% }%>
                            </ul>
                        </nav>
                    </div>
                </header>
                <main id="content">
                	<div class="ranking__content tier-view">
	                	<table class="m-table">
	                    	<%
	                           int idx = Integer.parseInt(request.getParameter("post_id"));
	                       	
	                      		sql = "select title, is_anonymous, mgithub_id, content, views, likes, created_at "
	 										+ "from post "
	 										+ "where post_id ="+ idx;
	                      		
	                      		
                      			rs = stmt.executeQuery(sql);
                      			rs.next();
                 				String title = rs.getString(1);
                 				int is_an = rs.getInt(2);
                 				String author = rs.getString(3);
                 				String content = rs.getString(4);
                 				int views = rs.getInt(5);
                 				int likes = rs.getInt(6);
                 				String created_at = rs.getString(7);
                 				views++;
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
	                        <tbody>
								<tr>
									<td><%=title%></td>
									<%if(is_an==1){out.println("<td> 익명 </td>");}
									else{out.println("<td> "+author+" </td>");}%>
									<td><%=views%></td>
									<td><%=likes%></td>
									<td><%=created_at%></td>
								</tr>
							</tbody>
						</table>
						<% 
							if((String)session.getAttribute(Integer.toString(idx)+"view")==null)
							{
								session.setAttribute(Integer.toString(idx)+"view", "1");
								sql = "update post set views ="+views +" where post_id ="+idx;
		                      	stmt.executeUpdate(sql);
							}
						%>
						<div class="post__content">글 내용 : <%=content%></div>
						<div class="post__file">첨부파일 : <%
							rs.close();
						
							sql = "select file_path "
							+ "from files "
							+ "where post_id ="+idx;
											
							rs = stmt.executeQuery(sql);
							while(rs.next()){
								out.println("<img height=\"100\" src=\""+rs.getString(1)+"\">");
							}
							
							rs.close();
												
						%>
						</div>
						<div class="comment">
							<div class="comment__write">
								<%
									if(session.getAttribute("sid")==null)
									{
										out.println("로그인 후 댓글을 작성하세요.");
									}
									else{
								%>
								<% pageContext.setAttribute("newLineChar", "\n"); %>
								<form name="comment__form" method="post">
									<textarea style="white-space:pre;" name="comment__write content" placeholder="댓글 내용을 입력하세요" required rows="5" cols="30"></textarea>
									<label>익명 <input type="checkbox" name="is_anonymous"></label>
									<input type="submit" name="submit" value="작성" onchange="this.form.submit()" onclick="document.location.reload()"> 
								</form>
								<%
									}
									int post_id = idx;
									
									if(request.getParameter("submit")!=null)
									{
										String comment_content = request.getParameter("comment__write content");
										comment_content=comment_content.replace("\r\n","<br>");
										String is_anonymous;
										if(request.getParameter("is_anonymous")==null) {is_anonymous="0";}
										else{is_anonymous="1";}
										String mgithub_id = (String)session.getAttribute("sid");
										Date nowTime = new Date();
										SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss");
										
										sql = "select category_id "
				     							+ "from post "
				     							+ "where post_id = "+idx;
										
										rs = stmt.executeQuery(sql);
										rs.next();
										int category_id = rs.getInt(1);
										rs.close();
										
										sql = "select max(comment_id) from comments";
										rs = stmt.executeQuery(sql);
										rs.next();
										int comment_id = rs.getInt(1);
										rs.close();
										
										sql = "select content from comments where comment_id = "+comment_id;
										rs = stmt.executeQuery(sql);
										rs.next();
										String prev_comm = rs.getString(1);
										
										if(prev_comm.compareTo(comment_content)!=0)
										{
											sql = String.format("INSERT INTO comments values(%d, %d, %d, '%s', '%s', to_timestamp('%s', 'YYYY-MM-DD HH24:MI:SS'), to_timestamp('%s', 'YYYY-MM-DD HH24:MI:SS'), '%s')", 
													category_id, post_id, comment_id+1, is_anonymous, comment_content, sf.format(nowTime), sf.format(nowTime), mgithub_id);
											stmt.executeUpdate(sql);
										}
									}
									
								%>
							</div>
							<div class="comment__body">
								<%
									sql = "select comment_id "
		     							+ "from comments where post_id ="+idx;
		   							rs = stmt.executeQuery(sql);
		   						%>
		   						<table>
									<%
									rs.last();
									if(rs.getRow()==0)
									{	
										out.println("작성된 댓글이 없습니다.");
										rs.close();
									}
									else{%>
										<thead>
				                            <tr>
				                                <th>제목</th>
				                                <th>작성자</th>
				                                <th>작성일</th>
				                            </tr>
			                     		</thead>
			                     		<tbody>
		                     			<%
											sql = "select content, is_anonymous, mgithub_id, created_at "
				     							+ "from comments "
				     							+ "where post_id ="+idx
				     							+ " order by comment_id desc";
				      						
				   							rs = stmt.executeQuery(sql);
				   							
											while(rs.next())
											{
												out.println("<tr>");
												out.println("<td>"+rs.getString(1)+"</td>");
												if(rs.getInt(2)==1){out.println("<td> 익명 </td>");}
												else{out.println("<td> "+rs.getString(3)+" </td>");}
												out.println("<td>"+rs.getString(4)+"</td>");
												out.println("</tr>");
											}
											rs.close();
										}
											
										%>		
									</tbody>
		   						</table>
							</div>
						</div>
						<a href="board-qna.jsp"><button>목록</button></a>
						<div class="likes">
							<input type="submit" id="like" value="좋아요">
							<script>
							    var t = document.getElementById('like');
							    t.addEventListener('click', function(event){
							        <%
							        if((String)session.getAttribute(Integer.toString(idx)+"like")==null)
									{
										session.setAttribute(Integer.toString(idx)+"like", "1");
										sql = "update post set likes = likes + 1 where post_id ="+idx;
				                      	stmt.executeUpdate(sql);
				                      	%>document.location.reload();<%
									}
							        else if((String)session.getAttribute(Integer.toString(idx)+"like")!=null)
							        {
							        	%>alert("이미 좋아요한 게시물입니다.");
							        <%}%>
							    });
							</script>
						</div>
						<div class="post__delete">
							<script language='javascript'>
								function del() {
								  if (confirm("정말 삭제하시겠습니까?"))
								    list_ok.submit();
								}
							</script>
							<a href="boardDeleteAction.jsp?author=<%=author%>&group_id=<%=idx %>" onclick="del();">삭제</a>	
						</div>
						<%
							stmt.close();
							conn.close();
						%>
					</div>
                </main>
             	<footer id="footer">
		            <p class="footer__desc">Copyright © Team3 <img src="./img/logo.png" alt=""></p>
        		</footer>	
    		</div>
    	</div>
    </body>
</html>