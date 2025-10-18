<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("user") == null) {
        response.sendRedirect("login.jsp?error=session");
        return;
    }
    
    String userName = (String) userSession.getAttribute("user");
    String userEmail = (String) userSession.getAttribute("email");
    String userRole = (String) userSession.getAttribute("role");
    if (userRole == null) userRole = "student";
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Library Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
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
        .navbar h1 {
            font-size: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .user-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .user-details {
            text-align: right;
        }
        .user-name {
            font-weight: bold;
            font-size: 16px;
        }
        .user-role {
            font-size: 12px;
            opacity: 0.9;
            text-transform: capitalize;
        }
        .logout-btn {
            background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.3);
            color: white;
            padding: 8px 20px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
        }
        .logout-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .welcome-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .welcome-card h2 {
            color: #333;
            margin-bottom: 10px;
        }
        .welcome-card p {
            color: #666;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .feature-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: block;
        }
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .feature-icon {
            font-size: 40px;
            margin-bottom: 15px;
        }
        .feature-card h3 {
            color: #667eea;
            margin-bottom: 10px;
            font-size: 18px;
        }
        .feature-card p {
            color: #666;
            font-size: 14px;
            line-height: 1.5;
        }
        .role-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
            margin-top: 10px;
        }
        .badge-student {
            background: #e3f2fd;
            color: #1976d2;
        }
        .badge-librarian {
            background: #fff3e0;
            color: #f57c00;
        }
        .badge-admin {
            background: #fce4ec;
            color: #c2185b;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            text-align: center;
        }
        .stat-number {
            font-size: 32px;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }
        .stat-label {
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>📚 Library Management System</h1>
        <div class="user-info">
            <div class="user-details">
                <div class="user-name"><%= userName %></div>
                <div class="user-role"><%= userRole %></div>
            </div>
            <a href="logout.jsp" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome-card">
            <h2>Welcome back, <%= userName %>! 👋</h2>
            <p>Logged in as: <%= userEmail %></p>
            <span class="role-badge badge-<%= userRole %>"><%= userRole.toUpperCase() %></span>
        </div>
        
        <% if (userRole.equals("student")) { %>
            <!-- STUDENT FEATURES -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Books Borrowed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Books Returned</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Due Soon</div>
                </div>
            </div>
            
            <div class="features-grid">
                <a href="search-books.jsp" class="feature-card">
                    <div class="feature-icon">🔍</div>
                    <h3>Search & Borrow Books</h3>
                    <p>Search for books and borrow available ones</p>
                </a>
                
                <a href="my-books.jsp" class="feature-card">
                    <div class="feature-icon">📚</div>
                    <h3>My Borrowed Books</h3>
                    <p>View and return your borrowed books</p>
                </a>
                
                <a href="borrowing-history.jsp" class="feature-card">
                    <div class="feature-icon">📋</div>
                    <h3>Borrowing History</h3>
                    <p>View your complete borrowing history</p>
                </a>
                
                <a href="profile.jsp" class="feature-card">
                    <div class="feature-icon">👤</div>
                    <h3>My Profile</h3>
                    <p>View and update your profile information</p>
                </a>
            </div>
        
        <% } else if (userRole.equals("librarian")) { %>
            <!-- LIBRARIAN FEATURES -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Total Books</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Books Borrowed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Available Books</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Overdue Books</div>
                </div>
            </div>
            
            <div class="features-grid">
                <a href="manage-books.jsp" class="feature-card">
                    <div class="feature-icon">📚</div>
                    <h3>Manage Books</h3>
                    <p>Add, update, or delete book records</p>
                </a>
                
                <a href="add-book.jsp" class="feature-card">
                    <div class="feature-icon">➕</div>
                    <h3>Add New Book</h3>
                    <p>Add new books to the library database</p>
                </a>
                
                <a href="borrowing-records.jsp" class="feature-card">
                    <div class="feature-icon">📋</div>
                    <h3>Borrowing Records</h3>
                    <p>View all borrowing and return transactions</p>
                </a>
                
                <a href="search-books.jsp" class="feature-card">
                    <div class="feature-icon">🔍</div>
                    <h3>Search Books</h3>
                    <p>Search and filter book inventory</p>
                </a>
                
                <a href="profile.jsp" class="feature-card">
                    <div class="feature-icon">👤</div>
                    <h3>My Profile</h3>
                    <p>View your profile information</p>
                </a>
            </div>
        
        <% } else if (userRole.equals("admin")) { %>
            <!-- ADMIN FEATURES -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Total Users</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Active Librarians</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Total Books</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">0</div>
                    <div class="stat-label">Transactions</div>
                </div>
            </div>
            
            <div class="features-grid">
                <a href="manage-books.jsp" class="feature-card">
                    <div class="feature-icon">📚</div>
                    <h3>Manage Books</h3>
                    <p>Full control over book inventory</p>
                </a>
                
                <a href="add-book.jsp" class="feature-card">
                    <div class="feature-icon">➕</div>
                    <h3>Add New Book</h3>
                    <p>Add books to the system</p>
                </a>
                
                <a href="borrowing-records.jsp" class="feature-card">
                    <div class="feature-icon">📋</div>
                    <h3>Borrowing Records</h3>
                    <p>View comprehensive borrowing records</p>
                </a>
                
                <a href="search-books.jsp" class="feature-card">
                    <div class="feature-icon">🔍</div>
                    <h3>Search Books</h3>
                    <p>Search library catalog</p>
                </a>
                
                <a href="profile.jsp" class="feature-card">
                    <div class="feature-icon">👤</div>
                    <h3>My Profile</h3>
                    <p>View your profile information</p>
                </a>
            </div>
        <% } %>
    </div>
</body>
</html>