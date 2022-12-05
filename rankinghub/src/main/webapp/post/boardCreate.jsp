<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*" %>
<% 
	String userID = (String)session.getAttribute("sid");	// 현재 user 아이디
	if (userID == null) {
		out.println("<script>");
	    out.println("alert('회원만 글 작성이 가능합니다!')");
	    out.println("location.href='board-qna.jsp'");
	    out.println("</script>"); 
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rankinghub: 포스트 작성</title>
<link rel="stylesheet" type="text/css" href="../css/MainpageStyle.css">
<link rel="stylesheet" type="text/css" href="../css/global.css">
<link rel="stylesheet" type="text/css" href="../css/post.css">
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
		<div class="writing-form">
			<h2>글쓰기</h2>
		
			<form action="boardCreateAction.jsp" method="post" enctype="multipart/form-data">
				<div class="cate-unknown-opt">
					<span class="cate-opt">
						<label for="category">카테고리</label><br>
						<select name="category" id="category">
					    <option value="1">Q&A</option>
					    <option value="2">자유게시판</option>
					    <option value="3">꿀팁</option>
					    </select>
				    </span>
			    	<span class="ukwnown-opt">
					    <label>익명 <input type="checkbox" name="is_anonymous"></label>
					</span>
			    </div>
			    
			    <div class="create-body">
			    	<div class="input-post-title">
					    <label for="title">제목</label>
					    <input type="text" id="title" name="title">
				   </div>
				   <div class="input-post-cont">
					    <label for="content">내용</label>
					    <textarea id="post-content" style="white-space:pre;" name="content" placeholder="내용을 입력하세요" required rows="5" cols="30"></textarea>
					</div>
					
					<div class="attached">
						<input type="file" name="uploadFile">
					</div>
				</div>
				
				<div class="post-sub">
			    	<input type="submit" value="Submit">
				</div>
			</form> 
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