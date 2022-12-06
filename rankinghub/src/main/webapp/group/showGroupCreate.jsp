<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*, java.util.*"%>
<% request.setCharacterEncoding("UTF-8"); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rankinghub: Group_Create</title>
<link rel="stylesheet" type="text/css" href="../css/MainpageStyle.css">
<link rel="stylesheet" type="text/css" href="../css/global.css">
<link rel="stylesheet" type="text/css" href="../css/groupCreate.css">
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
		<div class="group-create-form">
			<h1>그룹 생성</h1>
			<form action="groupCreateAction.jsp" method="post" accept-charset="utf-8">
				<div class="create-item">
					<label for="group_name" class="group-label">그룹이름</label> <br>
					<input type="text" id="group_name" name="gname">
				</div>
				
				<div class="create-item">
				<span class="group-label">챌린지 기간</span><br>
					<div class="period-opt">
						<span>
						<input type="radio" id="30" name="gperiod" value="30">
						<label for="30">30</label>
						</span>
						<span>
						<input type="radio" id="50" name="gperiod" value="50">
						<label for="50">50</label>
						</span>
						<span>
						<input type="radio" id="100" name="gperiod" value="100">
						<label for="100">100</label>
						</span>
						<span>
						<input type="radio" id="200" name="gperiod" value="200">
						<label for="200">200</label>
						</span>
						<span>
						<input type="radio" id="365" name="gperiod" value="365">
						<label for="365">365</label>
						</span>
					</div>
				</div>
				
				<div class="btn-list">
					<input class="btn" id="create" type="submit" value="그룹 생성">
					<input class="btn" id="reset" type="reset" value="다시 입력">
				</div>	<!-- </marquee> -->
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