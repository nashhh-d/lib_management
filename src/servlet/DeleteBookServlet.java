package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import db.DatabaseManager;

public class DeleteBookServlet extends HttpServlet {
    
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

        String bookIdStr = request.getParameter("bookId");
        
        if (bookIdStr == null || bookIdStr.isEmpty()) {
            response.sendRedirect("manage-books.jsp?error=invalid");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("manage-books.jsp?error=invalid");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;

        try {
            con = DatabaseManager.getConnection();

            // Check if book has active borrowings
            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM borrowing_records WHERE book_id = ? AND status = 'borrowed'");
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            rs.next();
            
            int activeBorrowings = rs.getInt(1);
            rs.close();
            ps.close();

            if (activeBorrowings > 0) {
                response.sendRedirect("manage-books.jsp?error=has_borrowings");
                return;
            }

            // Delete the book
            ps = con.prepareStatement("DELETE FROM books WHERE book_id = ?");
            ps.setInt(1, bookId);

            int rowsDeleted = ps.executeUpdate();

            if (rowsDeleted > 0) {
                response.sendRedirect("manage-books.jsp?success=deleted");
            } else {
                response.sendRedirect("manage-books.jsp?error=notfound");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            
            // Handle foreign key constraint
            if (e.getMessage().contains("foreign key constraint")) {
                response.sendRedirect("manage-books.jsp?error=has_borrowings");
            } else {
                response.sendRedirect("manage-books.jsp?error=exception");
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
        response.sendRedirect("manage-books.jsp");
    }
}