<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*,java.sql.*,db.DatabaseManager" %>
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
    <title>Manage Books - Library System</title>
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
        .message {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .actions-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .btn-add {
            padding: 12px 25px;
            background: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .btn-add:hover { background: #45a049; }
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
        .filter-bar {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
        }
        .filter-bar input, .filter-bar select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        .btn-filter {
            padding: 10px 20px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        thead {
            background: #f8f9fa;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
            font-size: 14px;
        }
        th {
            color: #666;
            font-weight: 600;
        }
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .btn-edit, .btn-delete {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-edit {
            background: #2196F3;
            color: white;
        }
        .btn-delete {
            background: #f44336;
            color: white;
        }
        .btn-edit:hover { background: #0b7dda; }
        .btn-delete:hover { background: #da190b; }
        .availability {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
        }
        .avail-high { background: #e8f5e9; color: #2e7d32; }
        .avail-low { background: #fff3e0; color: #f57c00; }
        .avail-none { background: #ffebee; color: #c62828; }
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
        }
        .modal-content {
            background: white;
            margin: 5% auto;
            padding: 30px;
            border-radius: 10px;
            width: 90%;
            max-width: 500px;
        }
        .close {
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
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
        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            
            if ("added".equals(success)) {
        %>
            <div class="message success">✓ Book added successfully!</div>
        <%
            } else if ("updated".equals(success)) {
        %>
            <div class="message success">✓ Book updated successfully!</div>
        <%
            } else if ("deleted".equals(success)) {
        %>
            <div class="message success">✓ Book deleted successfully!</div>
        <%
            }
            
            if (error != null) {
        %>
            <div class="message error">✗ An error occurred: <%= error %></div>
        <%
            }
        %>

        <div class="actions-card">
            <h2>📚 Book Management</h2>
            <a href="add-book.jsp" class="btn-add">+ Add New Book</a>
        </div>

        <div class="books-card">
            <form action="manage-books.jsp" method="get" class="filter-bar">
                <input type="text" name="search" placeholder="Search by title or author..." 
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>" style="flex: 1;">
                <select name="category">
                    <option value="">All Categories</option>
                    <%
                        try (Connection con = DatabaseManager.getConnection()) {
                            Statement stmt = con.createStatement();
                            ResultSet cats = stmt.executeQuery("SELECT DISTINCT category FROM books ORDER BY category");
                            String selectedCat = request.getParameter("category");
                            while (cats.next()) {
                                String cat = cats.getString("category");
                                String selected = cat.equals(selectedCat) ? "selected" : "";
                    %>
                                <option value="<%= cat %>" <%= selected %>><%= cat %></option>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </select>
                <button type="submit" class="btn-filter">Filter</button>
            </form>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Author</th>
                        <th>ISBN</th>
                        <th>Category</th>
                        <th>Copies</th>
                        <th>Available</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        String search = request.getParameter("search");
                        String category = request.getParameter("category");
                        
                        StringBuilder sql = new StringBuilder("SELECT * FROM books WHERE 1=1");
                        
                        if (search != null && !search.trim().isEmpty()) {
                            sql.append(" AND (title LIKE ? OR author LIKE ? OR isbn LIKE ?)");
                        }
                        if (category != null && !category.isEmpty()) {
                            sql.append(" AND category = ?");
                        }
                        sql.append(" ORDER BY title");
                        
                        try (Connection con = DatabaseManager.getConnection();
                             PreparedStatement ps = con.prepareStatement(sql.toString())) {
                            
                            int paramIndex = 1;
                            if (search != null && !search.trim().isEmpty()) {
                                String searchPattern = "%" + search + "%";
                                ps.setString(paramIndex++, searchPattern);
                                ps.setString(paramIndex++, searchPattern);
                                ps.setString(paramIndex++, searchPattern);
                            }
                            if (category != null && !category.isEmpty()) {
                                ps.setString(paramIndex++, category);
                            }
                            
                            ResultSet rs = ps.executeQuery();
                            boolean hasBooks = false;
                            
                            while (rs.next()) {
                                hasBooks = true;
                                int bookId = rs.getInt("book_id");
                                String title = rs.getString("title");
                                String author = rs.getString("author");
                                String isbn = rs.getString("isbn");
                                String cat = rs.getString("category");
                                int totalCopies = rs.getInt("total_copies");
                                int availableCopies = rs.getInt("available_copies");
                                
                                String availClass = "";
                                String availText = "";
                                if (availableCopies == 0) {
                                    availClass = "avail-none";
                                    availText = "Unavailable";
                                } else if (availableCopies <= totalCopies / 3) {
                                    availClass = "avail-low";
                                    availText = "Low Stock";
                                } else {
                                    availClass = "avail-high";
                                    availText = "Available";
                                }
                    %>
                                <tr>
                                    <td><%= bookId %></td>
                                    <td><strong><%= title %></strong></td>
                                    <td><%= author %></td>
                                    <td><%= isbn != null ? isbn : "N/A" %></td>
                                    <td><%= cat %></td>
                                    <td><%= totalCopies %></td>
                                    <td><%= availableCopies %></td>
                                    <td><span class="availability <%= availClass %>"><%= availText %></span></td>
                                    <td>
                                        <div class="action-buttons">
                                            <a href="edit-book.jsp?id=<%= bookId %>" class="btn-edit">Edit</a>
                                            <button onclick="confirmDelete(<%= bookId %>, '<%= title.replace("'", "\\'") %>')" class="btn-delete">Delete</button>
                                        </div>
                                    </td>
                                </tr>
                    <%
                            }
                            
                            if (!hasBooks) {
                    %>
                                <tr>
                                    <td colspan="9" style="text-align: center; padding: 40px; color: #999;">
                                        No books found. <a href="add-book.jsp" style="color: #667eea;">Add your first book</a>
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

    <!-- Delete Confirmation Modal -->
    <div id="deleteModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h2>Confirm Deletion</h2>
            <p id="deleteMessage"></p>
            <form id="deleteForm" action="delete-book" method="post" style="margin-top: 20px;">
                <input type="hidden" id="deleteBookId" name="bookId">
                <button type="submit" class="btn-delete" style="width: 100%; padding: 12px;">Delete Book</button>
                <button type="button" onclick="closeModal()" style="width: 100%; padding: 12px; margin-top: 10px; background: #ccc; border: none; border-radius: 5px; cursor: pointer;">Cancel</button>
            </form>
        </div>
    </div>

    <script>
        function confirmDelete(bookId, bookTitle) {
            document.getElementById('deleteBookId').value = bookId;
            document.getElementById('deleteMessage').textContent = 
                'Are you sure you want to delete "' + bookTitle + '"? This action cannot be undone.';
            document.getElementById('deleteModal').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('deleteModal').style.display = 'none';
        }

        window.onclick = function(event) {
            const modal = document.getElementById('deleteModal');
            if (event.target == modal) {
                closeModal();
            }
        }
    </script>
</body>
</html>