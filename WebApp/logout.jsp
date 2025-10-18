<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*" %>
<%
    // Invalidate the current session
    HttpSession userSession = request.getSession(false);
    if (userSession != null) {
        userSession.invalidate();
    }
    
    // Redirect to login page with logout message
    response.sendRedirect("login.jsp?message=loggedout");
%>
