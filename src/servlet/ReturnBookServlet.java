package servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.sql.*;
import db.DatabaseManager;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.math.BigDecimal;

public class ReturnBookServlet extends HttpServlet {
    
    // Fine per day for overdue books
    private static final BigDecimal FINE_PER_DAY = new BigDecimal("5.00");
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp?error=session");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");
        String borrowIdStr = request.getParameter("borrowId");
        
        if (borrowIdStr == null || borrowIdStr.isEmpty()) {
            response.sendRedirect("my-books.jsp?error=invalid");
            return;
        }

        int borrowId;
        try {
            borrowId = Integer.parseInt(borrowIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("my-books.jsp?error=invalid");
            return;
        }

        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = DatabaseManager.getConnection();
            con.setAutoCommit(false); // Start transaction
            
            // 1. Get borrowing record and verify ownership
            ps = con.prepareStatement(
                "SELECT book_id, due_date, status FROM borrowing_records " +
                "WHERE borrow_id = ? AND user_id = ? FOR UPDATE");
            ps.setInt(1, borrowId);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();
            
            if (!rs.next()) {
                con.rollback();
                response.sendRedirect("my-books.jsp?error=notfound");
                return;
            }
            
            int bookId = rs.getInt("book_id");
            Date dueDate = rs.getDate("due_date");
            String status = rs.getString("status");
            
            // Check if already returned
            if ("returned".equals(status)) {
                con.rollback();
                response.sendRedirect("my-books.jsp?error=alreadyreturned");
                return;
            }
            
            rs.close();
            ps.close();
            
            // 2. Calculate fine if overdue
            LocalDate today = LocalDate.now();
            LocalDate due = dueDate.toLocalDate();
            long daysOverdue = ChronoUnit.DAYS.between(due, today);
            
            BigDecimal fineAmount = BigDecimal.ZERO;
            String newStatus = "returned";
            
            if (daysOverdue > 0) {
                fineAmount = FINE_PER_DAY.multiply(new BigDecimal(daysOverdue));
                // Could set status to "returned_with_fine" if needed
            }
            
            // 3. Update borrowing record
            ps = con.prepareStatement(
                "UPDATE borrowing_records SET return_date = ?, status = ?, " +
                "fine_amount = ?, returned_to = ? WHERE borrow_id = ?");
            ps.setDate(1, Date.valueOf(today));
            ps.setString(2, newStatus);
            ps.setBigDecimal(3, fineAmount);
            ps.setInt(4, userId); // Self-returned for students
            ps.setInt(5, borrowId);
            
            int rowsUpdated = ps.executeUpdate();
            ps.close();
            
            if (rowsUpdated == 0) {
                con.rollback();
                response.sendRedirect("my-books.jsp?error=failed");
                return;
            }
            
            // 4. Increase available copies
            ps = con.prepareStatement(
                "UPDATE books SET available_copies = available_copies + 1 WHERE book_id = ?");
            ps.setInt(1, bookId);
            
            rowsUpdated = ps.executeUpdate();
            ps.close();
            
            if (rowsUpdated == 0) {
                con.rollback();
                response.sendRedirect("my-books.jsp?error=failed");
                return;
            }
            
            // Commit transaction
            con.commit();
            
            // Success - redirect with message
            if (fineAmount.compareTo(BigDecimal.ZERO) > 0) {
                response.sendRedirect("my-books.jsp?success=returned&fine=" + fineAmount);
            } else {
                response.sendRedirect("my-books.jsp?success=returned");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (con != null) con.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("my-books.jsp?error=exception");
            
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
        response.sendRedirect("my-books.jsp");
    }
}