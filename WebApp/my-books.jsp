<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*,java.sql.*,db.DatabaseManager,java.time.*,java.time.temporal.ChronoUnit" %>
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
    <title>My Books - Library System</title>
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
        .message {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .stats-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        .stat-item {
            text-align: center;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
        }
        .stat-label {
            color: #666;
            margin-top: 5px;
            font-size: 14px;
        }
        .books-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .books-card h2 {
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
        td {
            color: #333;
        }
        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-borrowed {
            background: #e3f2fd;
            color: #1976d2;
        }
        .status-overdue {
            background: #ffebee;
            color: #c62828;
        }
        .status-due-soon {
            background: #fff3e0;
            color: #f57c00;
        }
        .btn-return {
            padding: 8px 16px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 13px;
        }
        .btn-return:hover {
            background: #45a049;
        }
        .no-books {
            text-align: center;
            padding: 50px;
            color: #999;
        }
        .no-books a {
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
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
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            
            if ("borrowed".equals(success)) {
        %>
            <div class="message success">✓ Book borrowed successfully!</div>
        <%
            } else if ("returned".equals(success)) {
        %>
            <div class="message success">✓ Book returned successfully!</div>
        <%
            }
            
            if (error != null) {
                String errorMsg = "";
                if ("unavailable".equals(error)) errorMsg = "Book is not available";
                else if ("alreadyborrowed".equals(error)) errorMsg = "You already have this book";
                else if ("limitreached".equals(error)) errorMsg = "Maximum borrowing limit reached (3 books)";
                else errorMsg = "An error occurred";
        %>
            <div class="message error">✗ <%= errorMsg %></div>
        <%
            }
        %>

        <%
            // Get statistics
            int currentlyBorrowed = 0;
            int overdue = 0;
            int dueSoon = 0;
            
            try (Connection con = DatabaseManager.getConnection()) {
                PreparedStatement ps = con.prepareStatement(
                    "SELECT COUNT(*) as cnt, " +
                    "SUM(CASE WHEN due_date < CURDATE() THEN 1 ELSE 0 END) as overdue_cnt, " +
                    "SUM(CASE WHEN due_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY) THEN 1 ELSE 0 END) as due_soon_cnt " +
                    "FROM borrowing_records WHERE user_id = ? AND status = 'borrowed'");
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                
                if (rs.next()) {
                    currentlyBorrowed = rs.getInt("cnt");
                    overdue = rs.getInt("overdue_cnt");
                    dueSoon = rs.getInt("due_soon_cnt");
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>

        <div class="stats-card">
            <div class="stats-grid">
                <div class="stat-item">
                    <div class="stat-number"><%= currentlyBorrowed %></div>
                    <div class="stat-label">Currently Borrowed</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><%= overdue %></div>
                    <div class="stat-label">Overdue</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><%= dueSoon %></div>
                    <div class="stat-label">Due Soon</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number"><%= 3 - currentlyBorrowed %></div>
                    <div class="stat-label">Available Slots</div>
                </div>
            </div>
        </div>

        <div class="books-card">
            <h2>📚 My Borrowed Books</h2>
            
            <%
                try (Connection con = DatabaseManager.getConnection()) {
                    PreparedStatement ps = con.prepareStatement(
                        "SELECT br.borrow_id, br.book_id, br.borrow_date, br.due_date, " +
                        "b.title, b.author, b.isbn " +
                        "FROM borrowing_records br " +
                        "JOIN books b ON br.book_id = b.book_id " +
                        "WHERE br.user_id = ? AND br.status = 'borrowed' " +
                        "ORDER BY br.due_date ASC");
                    ps.setInt(1, userId);
                    ResultSet rs = ps.executeQuery();
                    
                    boolean hasBooks = false;
                    
                    if (rs.next()) {
                        hasBooks = true;
            %>
                        <table>
                            <thead>
                                <tr>
                                    <th>Title</th>
                                    <th>Author</th>
                                    <th>Borrow Date</th>
                                    <th>Due Date</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
            <%
                        do {
                            int borrowId = rs.getInt("borrow_id");
                            int bookId = rs.getInt("book_id");
                            String title = rs.getString("title");
                            String author = rs.getString("author");
                            Date borrowDate = rs.getDate("borrow_date");
                            Date dueDate = rs.getDate("due_date");
                            
                            LocalDate today = LocalDate.now();
                            LocalDate due = dueDate.toLocalDate();
                            long daysUntilDue = ChronoUnit.DAYS.between(today, due);
                            
                            String statusClass = "";
                            String statusText = "";
                            
                            if (daysUntilDue < 0) {
                                statusClass = "status-overdue";
                                statusText = "Overdue (" + Math.abs(daysUntilDue) + " days)";
                            } else if (daysUntilDue <= 3) {
                                statusClass = "status-due-soon";
                                statusText = "Due in " + daysUntilDue + " day" + (daysUntilDue != 1 ? "s" : "");
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
                                    <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
                                    <td>
                                        <form action="return-book" method="post" style="display: inline;">
                                            <input type="hidden" name="borrowId" value="<%= borrowId %>">
                                            <button type="submit" class="btn-return">Return Book</button>
                                        </form>
                                    </td>
                                </tr>
            <%
                        } while (rs.next());
            %>
                            </tbody>
                        </table>
            <%
                    }
                    
                    if (!hasBooks) {
            %>
                        <div class="no-books">
                            <h3>📖 No borrowed books</h3>
                            <p>You haven't borrowed any books yet.</p>
                            <p><a href="search-books.jsp">Search and borrow books</a></p>
                        </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            %>
        </div>
    </div>
</body>
</html>