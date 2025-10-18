<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*,java.sql.*,db.DatabaseManager,java.time.*,java.time.temporal.ChronoUnit" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?error=session");
        return;
    }
    
    String userRole = (String) userSession.getAttribute("role");
    if (!"librarian".equals(userRole) && !"admin".equals(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Borrowing Records - Library System</title>
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
            max-width: 1400px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .filter-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .filter-bar {
            display: flex;
            gap: 15px;
            align-items: flex-end;
        }
        .filter-group {
            flex: 1;
        }
        .filter-group label {
            display: block;
            margin-bottom: 5px;
            color: #666;
            font-size: 14px;
            font-weight: bold;
        }
        .filter-group input, .filter-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .btn-filter {
            padding: 10px 25px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        .records-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .records-card h2 {
            margin-bottom: 20px;
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }
        thead {
            background: #f8f9fa;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            color: #666;
            font-weight: 600;
        }
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
        }
        .status-borrowed {
            background: #e3f2fd;
            color: #1976d2;
        }
        .status-returned {
            background: #e8f5e9;
            color: #2e7d32;
        }
        .status-overdue {
            background: #ffebee;
            color: #c62828;
        }
        .no-records {
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
            <a href="manage-books.jsp">Manage Books</a>
            <a href="borrowing-records.jsp">Borrowing Records</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="filter-card">
            <form action="borrowing-records.jsp" method="get" class="filter-bar">
                <div class="filter-group">
                    <label>Search User/Book</label>
                    <input type="text" name="search" placeholder="Enter user or book name..." 
                           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                </div>
                <div class="filter-group">
                    <label>Status</label>
                    <select name="status">
                        <option value="">All Status</option>
                        <option value="borrowed" <%= "borrowed".equals(request.getParameter("status")) ? "selected" : "" %>>Borrowed</option>
                        <option value="returned" <%= "returned".equals(request.getParameter("status")) ? "selected" : "" %>>Returned</option>
                        <option value="overdue" <%= "overdue".equals(request.getParameter("status")) ? "selected" : "" %>>Overdue</option>
                    </select>
                </div>
                <button type="submit" class="btn-filter">Filter</button>
            </form>
        </div>

        <div class="records-card">
            <h2>📋 All Borrowing Records</h2>
            
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User Name</th>
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
                        String search = request.getParameter("search");
                        String status = request.getParameter("status");
                        
                        StringBuilder sql = new StringBuilder(
                            "SELECT br.borrow_id, br.borrow_date, br.due_date, br.return_date, " +
                            "br.status, br.fine_amount, " +
                            "u.name as user_name, b.title, b.author " +
                            "FROM borrowing_records br " +
                            "JOIN users u ON br.user_id = u.user_id " +
                            "JOIN books b ON br.book_id = b.book_id " +
                            "WHERE 1=1");
                        
                        if (search != null && !search.trim().isEmpty()) {
                            sql.append(" AND (u.name LIKE ? OR b.title LIKE ? OR b.author LIKE ?)");
                        }
                        if (status != null && !status.isEmpty()) {
                            if ("overdue".equals(status)) {
                                sql.append(" AND br.status = 'borrowed' AND br.due_date < CURDATE()");
                            } else {
                                sql.append(" AND br.status = ?");
                            }
                        }
                        sql.append(" ORDER BY br.borrow_date DESC");
                        
                        try (Connection con = DatabaseManager.getConnection();
                             PreparedStatement ps = con.prepareStatement(sql.toString())) {
                            
                            int paramIndex = 1;
                            if (search != null && !search.trim().isEmpty()) {
                                String searchPattern = "%" + search + "%";
                                ps.setString(paramIndex++, searchPattern);
                                ps.setString(paramIndex++, searchPattern);
                                ps.setString(paramIndex++, searchPattern);
                            }
                            if (status != null && !status.isEmpty() && !"overdue".equals(status)) {
                                ps.setString(paramIndex++, status);
                            }
                            
                            ResultSet rs = ps.executeQuery();
                            boolean hasRecords = false;
                            
                            while (rs.next()) {
                                hasRecords = true;
                                int borrowId = rs.getInt("borrow_id");
                                String userName = rs.getString("user_name");
                                String title = rs.getString("title");
                                String author = rs.getString("author");
                                Date borrowDate = rs.getDate("borrow_date");
                                Date dueDate = rs.getDate("due_date");
                                Date returnDate = rs.getDate("return_date");
                                String recordStatus = rs.getString("status");
                                double fine = rs.getDouble("fine_amount");
                                
                                LocalDate today = LocalDate.now();
                                LocalDate due = dueDate.toLocalDate();
                                boolean isOverdue = returnDate == null && due.isBefore(today);
                                
                                String statusClass = "";
                                String statusText = "";
                                
                                if ("returned".equals(recordStatus)) {
                                    statusClass = "status-returned";
                                    statusText = "Returned";
                                } else if (isOverdue) {
                                    statusClass = "status-overdue";
                                    long daysOverdue = ChronoUnit.DAYS.between(due, today);
                                    statusText = "Overdue (" + daysOverdue + "d)";
                                } else {
                                    statusClass = "status-borrowed";
                                    statusText = "Borrowed";
                                }
                    %>
                                <tr>
                                    <td>#<%= borrowId %></td>
                                    <td><%= userName %></td>
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
                            
                            if (!hasRecords) {
                    %>
                                <tr>
                                    <td colspan="9">
                                        <div class="no-records">
                                            <h3>📋 No borrowing records found</h3>
                                            <p>No records match your search criteria.</p>
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