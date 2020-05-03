<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib uri="http://struts.apache.org/tags-html" prefix="html" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-logic" prefix="logic" %>
<%@ taglib uri="http://struts.apache.org/tags-nested" prefix="nested" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html:html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Loop Validate Test</title>
</head>
<body>
<span style="color: red;"><html:errors/></span>
<nested:form action="/loopValidate" method="get">
<html:text property="address"></html:text>
<table>
	<tr>
		<td>科目</td>
		<td>金額</td>
		<td>&nbsp;</td>
	</tr>
<!-- id is must be a property of form-->
	<nested:iterate id="nestbean" name="loopValidatorForm" property="loopList">
		<tr>
			<nested:define id="tbean" name="nestbean" property="tbean" />
			<td><nested:write name="tbean" property="item"/></td>
			<!-- indexed="true" is required -->
			<td><nested:text name="tbean" property="money" indexed="true"/></td>
			<td>&nbsp;</td>
		</tr>
	</nested:iterate>

	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td><nested:submit>validate</nested:submit></td>
	</tr>
</table>

<hr/>




</nested:form>
</body>
</html:html>