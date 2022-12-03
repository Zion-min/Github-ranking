<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script language="javascript">
	function submit(){
		document.aa.submit();
	}
</script>
<% session.invalidate(); %>
</head>
<body>
<form name="aa" action="loginAction.jsp" method = post>
	<table border="1">
		<tr>
			<td align=center colspan="2"><font size="5px"><b>로그인 페이지</b></font></td>
		</tr>
		<tr>
			<td align=center>아이디</td>
			<td><input type="text" AUTOCOMPLETE="off" name="loginid"></td>
		</tr>
		<tr>
			<td align=center>패스워드</td>
			<td><input type="password" name="loginpass"></td>
		</tr>
		<tr>
			<td align=center colspan="2">
			<a href="javascript:submit();">로그인</a>
			&nbsp;&nbsp;
			<a href="join.jsp">회원가입</a>
			</td>
		</tr>
	</table>
</form>

</body>
</html>