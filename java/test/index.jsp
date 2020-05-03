<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<!-- 在10秒钟之后正在浏览的页面将会自动变为target.html这一页。10为刷新的延迟时间，以秒为单位。targer.html为你想转向的目标页,若为本页则为自动刷新本页 -->
<!-- 直接写/WEB-INF/jsp/pathtest.jsp是不可行的，WEB-INF下面的文件是受保护的，不能直接访问  -->
<!-- <meta http-equiv="refresh" content="10; url='ptjsp'"> -->
<!-- <meta http-equiv="refresh" content="10; url='/test/js/index.jsp'"> --><!-- WEB-INF文件夹及子文件夹以外的可以访问 -->
<title>Insert title here</title>
</head>
<body>
aaaaaaaaa

<%-- <jsp:forward page="WEB-INF/jsp/pathtest.jsp"></jsp:forward><!-- 大小写相关 --> --%>
<jsp:forward page="ptjsp"></jsp:forward>
<%
/* response.setContentType("text/html; charset=utf-8");
response.sendRedirect("/test/js/index.jsp"); */

/* response.setStatus(HttpServletResponse.SC_MOVED_PERMANENTLY);
/* String newLocn = "/test/js/index.jsp"; */
/* String newLocn = "ptjsp";
response.setHeader("Location",newLocn); */

%>
</body>
</html>