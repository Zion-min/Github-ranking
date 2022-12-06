<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,rankinghub.*" %>
<%@ page import="javax.sql.*" %>
<%@ page import="javax.naming.*" %>
<%
    Connection conn = null;
    String ID = (String)request.getParameter("loginid"); //login 페이지의 loginid파라미터를 받아와 ID에 넣음
    String pass = (String)request.getParameter("loginpass"); // loginpass를 받아와 pass에 넣어준다
    
    session.setAttribute("sid", ID); // ID를 계속 사용하기 위해 session에 넣어준다.
    //out.println(session.getAttribute("sid"));
    String sql="SELECT Github_id, User_password FROM member where Github_id='" + ID + "'"; //데이터를 뽑아오기 위한 sql문을 작성
  
	config c = new config();
	String serverIP = c.serverIP;
	String strSID = c.strSID;
	String portNum = c.portNum;
	String user = c.user;
	String passwd = c.pass;
	String url = "jdbc:oracle:thin:@"+serverIP+":"+portNum+":"+strSID;
    
	try {
        Context init = new InitialContext(); //naming context를 획득한다.
        conn = DriverManager.getConnection(url, user, passwd);
        PreparedStatement pstmt = conn.prepareStatement(sql); //PreparedStatement에서 sql문을 컴파일한다.
        pstmt.executeUpdate(); //업데이트한 건수를 반환한다.
        ResultSet rs = pstmt.executeQuery(); //실제 데이터를 반환한다.
        if(rs.next()){ //값이 있으면 들어간다.
        	out.println(rs.getString(1) + rs.getString(2));
          if(ID.equals(rs.getString(1))==true && pass.equals(rs.getString(2))==true){ //ID와 pass가 같을 때
              rs.close(); //닫아줌
              response.sendRedirect("../index-user.jsp"); //success.jsp로 넘어간다
          }
       
          else if(pass.equals(rs.getString(2))==false){ // pass가 틀렸을 때
              rs.close();
              out.println("<script>");
              out.println("alert('패스워드가 잘못입력되었습니다.')");
              out.println(rs.getString(2) + " " + pass);
              out.println("location.href='login.jsp'");
              out.println("</script>"); 
              }
                
        
        }
        else{ //데이터가 존재하지 않을 때
            rs.close();
            out.println("<script>");
           
             out.println("alert('존재하지 않는 아이디입니다.')");
             out.println("location.href='login.jsp'");
             out.println("</script>"); 
         
        }
        }catch(Exception e){
        out.println(e);
        out.println("<h3>데이터 가져오기에 실패하였습니다.</h3>");
        e.printStackTrace();
    }finally{
        conn.close(); //연결을 끊어준다.
    }
    
    
    %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

</body>
</html>