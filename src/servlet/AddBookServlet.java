package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import db.DatabaseManager;

public class AddBookServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check session and authorization
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=session");
            return;
        }

        String userRole = (String) session.getAttribute("role");
        if (!"librarian".equals(userRole) && !"admin".equals(userRole)) {
            response.sendRedirect("dashboard.jsp?error=unauthorized");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        // Get form parameters
        String title = request.getParameter("title");
        String author = request.getParameter("author");
        String isbn = request.getParameter("isbn");
        String category = request.getParameter("category");
        String publisher = request.getParameter("publisher");
        String publicationYearStr = request.getParameter("publicationYear");
        String totalCopiesStr = request.getParameter("totalCopies");
        String description = request.getParameter("description");

        // Backend validation
        StringBuilder errors = new StringBuilder();

        if (title == null || title.trim().length() < 3) {
            errors.append("Title must be at least 3 characters. ");
        }

        if (author == null || author.trim().length() < 2) {
            errors.append("Author name must be at least 2 characters. ");
        }

        if (category == null || category.trim().isEmpty()) {
            errors.append("Category is required. ");
        }

        int publicationYear = 0;
        if (publicationYearStr != null && !publicationYearStr.isEmpty()) {
            try {
                publicationYear = Integer.parseInt(publicationYearStr);
                int currentYear = java.time.Year.now().getValue();
                if (publicationYear < 1800 || publicationYear > currentYear) {
                    errors.append("Invalid publication year. ");
                }
            } catch (NumberFormatException e) {
                errors.append("Invalid publication year format. ");
            }
        }

        int totalCopies = 1;
        try {
            totalCopies = Integer.parseInt(totalCopiesStr);
            if (totalCopies < 1) {
                errors.append("Total copies must be at least 1. ");
            }
        } catch (NumberFormatException e) {
            errors.append("Invalid total copies format. ");
        }

        // If validation fails
        if (errors.length() > 0) {
            response.sendRedirect("add-book.jsp?error=" + 
                java.net.URLEncoder.encode(errors.toString(), "UTF-8"));
            return;
        }

        // Sanitize inputs
        title = title.trim();
        author = author.trim();
        if (isbn != null) isbn = isbn.trim();
        if (publisher != null) publisher = publisher.trim();
        if (description != null) description = description.trim();

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DatabaseManager.getConnection();

            // Check if ISBN already exists (if ISBN is provided)
            if (isbn != null && !isbn.isEmpty()) {
                ps = con.prepareStatement("SELECT book_id FROM books WHERE isbn = ?");
                ps.setString(1, isbn);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    response.sendRedirect("add-book.jsp?error=isbn_exists");
                    return;
                }
                rs.close();
                ps.close();
            }

            // Insert new book
            String sql = "INSERT INTO books (title, author, isbn, category, publisher, " +
                        "publication_year, total_copies, available_copies, description, added_by) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(sql);
            ps.setString(1, title);
            ps.setString(2, author);
            ps.setString(3, isbn != null && !isbn.isEmpty() ? isbn : null);
            ps.setString(4, category);
            ps.setString(5, publisher != null && !publisher.isEmpty() ? publisher : null);
            
            if (publicationYear > 0) {
                ps.setInt(6, publicationYear);
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.setInt(7, totalCopies);
            ps.setInt(8, totalCopies); // Initially all copies are available
            ps.setString(9, description != null && !description.isEmpty() ? description : null);
            ps.setInt(10, userId);

            int rowsInserted = ps.executeUpdate();

            if (rowsInserted > 0) {
                response.sendRedirect("manage-books.jsp?success=added");
            } else {
                response.sendRedirect("add-book.jsp?error=failed");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            
            // Handle duplicate ISBN error
            if (e.getMessage().contains("Duplicate entry") && e.getMessage().contains("isbn")) {
                response.sendRedirect("add-book.jsp?error=isbn_exists");
            } else {
                response.sendRedirect("add-book.jsp?error=exception");
            }

        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("add-book.jsp");
    }
}