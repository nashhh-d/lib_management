package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import db.DatabaseManager;
import java.util.regex.Pattern;

public class RegisterServlet extends HttpServlet {
    
    // Email validation pattern
    private static final Pattern EMAIL_PATTERN = 
        Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        // Backend validation
        StringBuilder errors = new StringBuilder();
        
        // Validate name
        if (name == null || name.trim().length() < 3) {
            errors.append("Name must be at least 3 characters. ");
        }
        
        // Validate email
        if (email == null || !EMAIL_PATTERN.matcher(email.trim()).matches()) {
            errors.append("Invalid email format. ");
        }
        
        // Validate password
        if (password == null || password.length() < 6) {
            errors.append("Password must be at least 6 characters. ");
        }
        
        // Validate password confirmation
        if (confirmPassword != null && !password.equals(confirmPassword)) {
            errors.append("Passwords do not match. ");
        }
        
        // Validate role
        if (role == null || (!role.equals("student") && !role.equals("librarian") && !role.equals("admin"))) {
            role = "student"; // Default to student if invalid
        }
        
        // If validation fails, redirect back with error
        if (errors.length() > 0) {
            response.sendRedirect("register.jsp?error=validation&msg=" + 
                java.net.URLEncoder.encode(errors.toString(), "UTF-8"));
            return;
        }

        // Sanitize inputs
        name = name.trim();
        email = email.trim().toLowerCase();
        
        // Database insertion
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = DatabaseManager.getConnection();
            
            // Check if email already exists
            ps = con.prepareStatement("SELECT email FROM users WHERE email = ?");
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                response.sendRedirect("register.jsp?error=exists");
                return;
            }
            
            rs.close();
            ps.close();
            
            // Insert new user
            ps = con.prepareStatement(
                "INSERT INTO users(name, email, password, role) VALUES(?, ?, ?, ?)");
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password); // In production, hash this with BCrypt!
            ps.setString(4, role);
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                response.sendRedirect("login.jsp?success=registered");
            } else {
                response.sendRedirect("register.jsp?error=exception");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            
            // Check if it's a duplicate entry error
            if (e.getMessage().contains("Duplicate entry")) {
                response.sendRedirect("register.jsp?error=exists");
            } else {
                response.sendRedirect("register.jsp?error=exception");
            }
            
        } finally {
            // Close resources
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // Prevent direct GET access
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("register.jsp");
    }
}