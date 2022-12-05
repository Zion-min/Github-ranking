<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Rankinghub: Log-in</title>
<link rel="stylesheet" type="text/css" href="../css/login.css?after">
<link rel="icon" type="image/png" href="../images/logo.png">
<script language="javascript">
	function submit(){
		document.aa.submit();
	}
</script>
<% session.invalidate(); %>
</head>
<body>
<div class="log-form">
	<form name="aa" action="loginAction.jsp" method = post>
		<div class="log-title">
			<a href="../index-user.jsp">
				<img src="../images/logo.png" width=100px>
				<p>Rankinghub Log-In</p>
			</a>
		</div>
		<div class="input-id">
			<input type="text" class="text-field id-field"  AUTOCOMPLETE="off" name="loginid" placeholder="아이디">
			<input type="password" class="text-field" name="loginpass" placeholder="비밀번호">
		</div>
		<div><a href="javascript:submit();"><div  class="log-btn">로그인</div></a></div>
		<div><a href="join.jsp"><div  class="log-btn">회원가입</div></a></div>
	</form>
</div>
</body>
</html>