<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*,java.sql.*,db.DatabaseManager,java.util.*" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp?error=session");
        return;
    }
    String userName = (String) userSession.getAttribute("user");
    String userRole = (String) userSession.getAttribute("role");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Search Books - Library System</title>
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
        .search-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .search-card h2 {
            color: #333;
            margin-bottom: 20px;
        }
        .search-form {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr auto;
            gap: 15px;
            margin-bottom: 20px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            margin-bottom: 5px;
            color: #666;
            font-size: 14px;
            font-weight: bold;
        }
        input, select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .btn {
            padding: 10px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            align-self: flex-end;
        }
        .btn:hover { opacity: 0.9; }
        .books-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
        }
        .book-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.3s;
        }
        .book-card:hover { transform: translateY(-5px); }
        .book-cover {
            height: 200px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
        }
        .book-info {
            padding: 20px;
        }
        .book-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
        }
        .book-author {
            color: #666;
            font-size: 14px;
            margin-bottom: 10px;
        }
        .book-meta {
            font-size: 12px;
            color: #999;
            margin-bottom: 15px;
        }
        .availability {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            margin-top: 10px;
        }
        .available {
            background: #e8f5e9;
            color: #2e7d32;
        }
        .unavailable {
            background: #ffebee;
            color: #c62828;
        }
        .btn-borrow {
            width: 100%;
            padding: 10px;
            background: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
        }
        .btn-borrow:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .no-results {
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
            <% if (userRole.equals("student")) { %>
                <a href="my-books.jsp">My Books</a>
            <% } %>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="search-card">
            <h2>🔍 Search Books</h2>
            <form action="search-books.jsp" method="get" class="search-form">
                <div class="form-group">
                    <label>Search by Title/Author</label>
                    <input type="text" name="query" placeholder="Enter title or author..." 
                           value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>">
                </div>
                <div class="form-group">
                    <label>Category</label>
                    <select name="category">
                        <option value="">All Categories</option>
                        <%
                            try (Connection con = DatabaseManager.getConnection()) {
                                Statement stmt = con.createStatement();
                                ResultSet categories = stmt.executeQuery("SELECT DISTINCT category FROM books ORDER BY category");
                                String selectedCat = request.getParameter("category");
                                while (categories.next()) {
                                    String cat = categories.getString("category");
                                    String selected = cat.equals(selectedCat) ? "selected" : "";
                        %>
                                    <option value="<%= cat %>" <%= selected %>><%= cat %></option>
                        <%      }
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Availability</label>
                    <select name="available">
                        <option value="">All Books</option>
                        <option value="yes" <%= "yes".equals(request.getParameter("available")) ? "selected" : "" %>>Available Only</option>
                    </select>
                </div>
                <button type="submit" class="btn">Search</button>
            </form>
        </div>

        <div class="books-grid">
            <%
                String query = request.getParameter("query");
                String category = request.getParameter("category");
                String available = request.getParameter("available");
                
                StringBuilder sql = new StringBuilder("SELECT * FROM books WHERE 1=1");
                
                if (query != null && !query.trim().isEmpty()) {
                    sql.append(" AND (title LIKE ? OR author LIKE ?)");
                }
                if (category != null && !category.isEmpty()) {
                    sql.append(" AND category = ?");
                }
                if ("yes".equals(available)) {
                    sql.append(" AND available_copies > 0");
                }
                sql.append(" ORDER BY title");
                
                try (Connection con = DatabaseManager.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql.toString())) {
                    
                    int paramIndex = 1;
                    if (query != null && !query.trim().isEmpty()) {
                        ps.setString(paramIndex++, "%" + query + "%");
                        ps.setString(paramIndex++, "%" + query + "%");
                    }
                    if (category != null && !category.isEmpty()) {
                        ps.setString(paramIndex++, category);
                    }
                    
                    ResultSet rs = ps.executeQuery();
                    boolean hasResults = false;
                    
                    while (rs.next()) {
                        hasResults = true;
                        int bookId = rs.getInt("book_id");
                        String title = rs.getString("title");
                        String author = rs.getString("author");
                        String cat = rs.getString("category");
                        String publisher = rs.getString("publisher");
                        int year = rs.getInt("publication_year");
                        int totalCopies = rs.getInt("total_copies");
                        int availableCopies = rs.getInt("available_copies");
                        boolean isAvailable = availableCopies > 0;
            %>
                        <div class="book-card">
                            <div class="book-cover">📖</div>
                            <div class="book-info">
                                <div class="book-title"><%= title %></div>
                                <div class="book-author">by <%= author %></div>
                                <div class="book-meta">
                                    <%= cat %> • <%= publisher %> • <%= year %><br>
                                    Available: <%= availableCopies %>/<%= totalCopies %>
                                </div>
                                <span class="availability <%= isAvailable ? "available" : "unavailable" %>">
                                    <%= isAvailable ? "✓ Available" : "✗ Not Available" %>
                                </span>
                                <% if (userRole.equals("student") && isAvailable) { %>
                                    <form action="borrow-book" method="post">
                                        <input type="hidden" name="bookId" value="<%= bookId %>">
                                        <button type="submit" class="btn-borrow">Borrow This Book</button>
                                    </form>
                                <% } %>
                            </div>
                        </div>
            <%
                    }
                    
                    if (!hasResults) {
            %>
                        <div class="no-results" style="grid-column: 1 / -1;">
                            <h3>No books found</h3>
                            <p>Try adjusting your search criteria</p>
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