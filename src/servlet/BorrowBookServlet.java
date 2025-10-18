package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import db.DatabaseManager;
import java.time.LocalDate;

public class BorrowBookServlet extends HttpServlet {
    
    // Default borrowing period in days
    private static final int DEFAULT_BORROW_DAYS = 14;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=session");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String userRole = (String) session.getAttribute("role");
        
        // Only students can borrow books
        if (!"student".equals(userRole)) {
            response.sendRedirect("search-books.jsp?error=notallowed");
            return;
        }

        String bookIdStr = request.getParameter("bookId");
        
        if (bookIdStr == null || bookIdStr.isEmpty()) {
            response.sendRedirect("search-books.jsp?error=invalid");
            return;
        }

        int bookId;
        try {
            bookId = Integer.parseInt(bookIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("search-books.jsp?error=invalid");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = DatabaseManager.getConnection();
            con.setAutoCommit(false); // Start transaction
            
            // 1. Check if book is available
            ps = con.prepareStatement(
                "SELECT available_copies FROM books WHERE book_id = ? FOR UPDATE");
            ps.setInt(1, bookId);
            ResultSet rs = ps.executeQuery();
            
            if (!rs.next()) {
                con.rollback();
                response.sendRedirect("search-books.jsp?error=notfound");
                return;
            }
            
            int availableCopies = rs.getInt("available_copies");
            if (availableCopies <= 0) {
                con.rollback();
                response.sendRedirect("search-books.jsp?error=unavailable");
                return;
            }
            
            rs.close();
            ps.close();
            
            // 2. Check if user already has this book
            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM borrowing_records WHERE user_id = ? AND book_id = ? AND status = 'borrowed'");
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            rs = ps.executeQuery();
            rs.next();
            
            if (rs.getInt(1) > 0) {
                con.rollback();
                response.sendRedirect("search-books.jsp?error=alreadyborrowed");
                return;
            }
            
            rs.close();
            ps.close();
            
            // 3. Check borrowing limit (max 3 books per student)
            ps = con.prepareStatement(
                "SELECT COUNT(*) FROM borrowing_records WHERE user_id = ? AND status = 'borrowed'");
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            rs.next();
            
            if (rs.getInt(1) >= 3) {
                con.rollback();
                response.sendRedirect("search-books.jsp?error=limitreached");
                return;
            }
            
            rs.close();
            ps.close();
            
            // 4. Calculate dates
            LocalDate borrowDate = LocalDate.now();
            LocalDate dueDate = borrowDate.plusDays(DEFAULT_BORROW_DAYS);
            
            // 5. Create borrowing record
            ps = con.prepareStatement(
                "INSERT INTO borrowing_records (user_id, book_id, borrow_date, due_date, status, issued_by) VALUES (?, ?, ?, ?, 'borrowed', ?)");
            ps.setInt(1, userId);
            ps.setInt(2, bookId);
            ps.setDate(3, Date.valueOf(borrowDate));
            ps.setDate(4, Date.valueOf(dueDate));
            ps.setInt(5, userId); // Self-issued for students
            
            int rowsInserted = ps.executeUpdate();
            ps.close();
            
            if (rowsInserted == 0) {
                con.rollback();
                response.sendRedirect("search-books.jsp?error=failed");
                return;
            }
            
            // 6. Update book availability
            ps = con.prepareStatement(
                "UPDATE books SET available_copies = available_copies - 1 WHERE book_id = ?");
            ps.setInt(1, bookId);
            
            int rowsUpdated = ps.executeUpdate();
            ps.close();
            
            if (rowsUpdated == 0) {
                con.rollback();
                response.sendRedirect("search-books.jsp?error=failed");
                return;
            }
            
            // Commit transaction
            con.commit();
            
            // Success!
            response.sendRedirect("my-books.jsp?success=borrowed");
            
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("search-books.jsp?error=exception");
            
        } finally {
            try {
                if (ps != null) ps.close();
                if (con != null) {
                    con.setAutoCommit(true);
                    con.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("search-books.jsp");
    }
}