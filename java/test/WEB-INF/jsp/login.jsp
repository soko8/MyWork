<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html:html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>login</title>
</head>
<body>
<html:errors/>
<html:form action="/login" method="post" >
	<table>
		<tr>
			<td>User Name : </td>
			<td><html:text property="userName" size="10" maxlength="10"></html:text></td>
		</tr>
		
		<tr>
			<td>Password : </td>
			<td><html:password property="password" maxlength="10" size="10"></html:password></td>
		</tr>
	
	
	</table>

	<html:submit >aaa</html:submit>
</html:form>

<%-- <html:button property="ccc" title="submit" onclick="document.form[0].submit();"></html:button> --%>
</body>
</html:html>