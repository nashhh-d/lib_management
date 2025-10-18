<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*,java.sql.*,db.DatabaseManager" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?error=session");
        return;
    }
    
    int userId = (Integer) userSession.getAttribute("userId");
    String userName = (String) userSession.getAttribute("user");
    String userRole = (String) userSession.getAttribute("role");
    
    if (!"student".equals(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Borrowing History - Library System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        .navbar {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .navbar h1 { font-size: 24px; }
        .nav-links a {
            color: white;
            text-decoration: none;
            margin-left: 20px;
            padding: 8px 15px;
            border-radius: 5px;
            transition: background 0.3s;
        }
        .nav-links a:hover { background: rgba(255,255,255,0.2); }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .history-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .history-card h2 {
            margin-bottom: 20px;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        thead {
            background: #f8f9fa;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            color: #666;
            font-weight: 600;
            font-size: 14px;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-returned {
            background: #e8f5e9;
            color: #2e7d32;
        }
        .status-borrowed {
            background: #e3f2fd;
            color: #1976d2;
        }
        .status-overdue {
            background: #ffebee;
            color: #c62828;
        }
        .no-history {
            text-align: center;
            padding: 50px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>📚 Library Management System</h1>
        <div class="nav-links">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="search-books.jsp">Search Books</a>
            <a href="my-books.jsp">My Books</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="history-card">
            <h2>📋 My Borrowing History</h2>
            
            <table>
                <thead>
                    <tr>
                        <th>Book Title</th>
                        <th>Author</th>
                        <th>Borrow Date</th>
                        <th>Due Date</th>
                        <th>Return Date</th>
                        <th>Status</th>
                        <th>Fine</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection con = DatabaseManager.getConnection()) {
                            PreparedStatement ps = con.prepareStatement(
                                "SELECT br.*, b.title, b.author " +
                                "FROM borrowing_records br " +
                                "JOIN books b ON br.book_id = b.book_id " +
                                "WHERE br.user_id = ? " +
                                "ORDER BY br.borrow_date DESC");
                            ps.setInt(1, userId);
                            ResultSet rs = ps.executeQuery();
                            
                            boolean hasHistory = false;
                            
                            while (rs.next()) {
                                hasHistory = true;
                                String title = rs.getString("title");
                                String author = rs.getString("author");
                                Date borrowDate = rs.getDate("borrow_date");
                                Date dueDate = rs.getDate("due_date");
                                Date returnDate = rs.getDate("return_date");
                                String status = rs.getString("status");
                                double fine = rs.getDouble("fine_amount");
                                
                                String statusClass = "";
                                String statusText = "";
                                
                                if ("returned".equals(status)) {
                                    statusClass = "status-returned";
                                    statusText = "Returned";
                                } else if ("overdue".equals(status)) {
                                    statusClass = "status-overdue";
                                    statusText = "Overdue";
                                } else {
                                    statusClass = "status-borrowed";
                                    statusText = "Borrowed";
                                }
                    %>
                                <tr>
                                    <td><strong><%= title %></strong></td>
                                    <td><%= author %></td>
                                    <td><%= borrowDate %></td>
                                    <td><%= dueDate %></td>
                                    <td><%= returnDate != null ? returnDate : "-" %></td>
                                    <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                                    <td>₹<%= String.format("%.2f", fine) %></td>
                                </tr>
                    <%
                            }
                            
                            if (!hasHistory) {
                    %>
                                <tr>
                                    <td colspan="7">
                                        <div class="no-history">
                                            <h3>📖 No borrowing history</h3>
                                            <p>You haven't borrowed any books yet.</p>
                                        </div>
                                    </td>
                                </tr>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>