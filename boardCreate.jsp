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
<title>Insert title here</title>
</head>
<body>
	<h2>글쓰기</h2>
	<form action="boardCreateAction.jsp" method="post" enctype="multipart/form-data">
		<label for="category">카테고리</label><br>
		<select name="category" id="category">
	    <option value="1">Q&A</option>
	    <option value="2">자유게시판</option>
	    <option value="3">꿀팁</option>
	    </select>
	    <label>익명 <input type="checkbox" name="is_anonymous"></label>
	    <br><br>
	    <label for="title">제목</label><br>
	    <input type="text" id="title" name="title"><br>
	    <label for="content">내용</label><br>
	    <textarea id="content" style="white-space:pre;" name="content" placeholder="내용을 입력하세요" required rows="5" cols="30"></textarea>
	
		<input type="file" name="uploadFile"><br/><br/>
	    <input type="submit" value="Submit">
	</form> 
</body>
</html>