package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import db.DatabaseManager;
import java.util.regex.Pattern;

public class LoginServlet extends HttpServlet {

    // Email validation pattern
    private static final Pattern EMAIL_PATTERN =
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Backend validation
        if (email == null || email.trim().isEmpty() ||
            !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            response.sendRedirect("login.jsp?error=invalid_email");
            return;
        }

        if (password == null || password.length() < 6) {
            response.sendRedirect("login.jsp?error=invalid_password");
            return;
        }

        // Sanitize input
        email = email.trim().toLowerCase();

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            con = DatabaseManager.getConnection();

            // Query database
            ps = con.prepareStatement(
                "SELECT user_id, name, email, role FROM users WHERE email = ? AND password = ?");
            ps.setString(1, email);
            ps.setString(2, password); // In production, use hashed password comparison!

            rs = ps.executeQuery();

            if (rs.next()) {
                // Create session and store user info
                HttpSession session = request.getSession();
                session.setAttribute("userId", rs.getInt("user_id"));
                session.setAttribute("user", rs.getString("name"));
                session.setAttribute("email", rs.getString("email"));
                session.setAttribute("role", rs.getString("role"));

                // Set session timeout (30 minutes)
                session.setMaxInactiveInterval(30 * 60);

                // Redirect to dashboard
                response.sendRedirect("dashboard.jsp");
            } else {
                // Invalid credentials
                response.sendRedirect("login.jsp?error=invalid_credentials");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=database_error");

        } finally {
            // ✅ Clean up resources properly
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
}
