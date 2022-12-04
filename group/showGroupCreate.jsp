<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page language="java" import="java.text.*,java.sql.*, java.util.*"%>
<% request.setCharacterEncoding("UTF-8"); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

<form action="groupCreateAction.jsp" method="post" accept-charset="utf-8">
	<label for="group_name">그룹이름</label><br>
	<input type="text" id="group_name" name="gname"><br><br>
	
	<span>챌린지 기간</span><br>
	<input type="radio" id="30" name="gperiod" value="30">
	<label for="30">30</label><br>
	<input type="radio" id="50" name="gperiod" value="50">
	<label for="50">50</label><br>
	<input type="radio" id="100" name="gperiod" value="100">
	<label for="100">100</label>
	<input type="radio" id="200" name="gperiod" value="200">
	<label for="200">200</label>
	<input type="radio" id="365" name="gperiod" value="365">
	<label for="365">365</label>
	
	<input type="submit" value="그룹 생성">
	<input type="reset" value="다시 입력">	<!-- </marquee> -->
</form>
</body>
</html>