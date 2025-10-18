<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*,java.sql.*,db.DatabaseManager" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp?error=session");
        return;
    }
    
    int userId = (Integer) userSession.getAttribute("userId");
    String userName = (String) userSession.getAttribute("user");
    String userEmail = (String) userSession.getAttribute("email");
    String userRole = (String) userSession.getAttribute("role");

    // ✅ Declare variables outside any conditional block
    int totalBorrowed = 0;
    int currentlyBorrowed = 0;
    int totalReturned = 0;
    double totalFines = 0.0;

    // ✅ Fetch borrowing stats only for students
    if ("student".equals(userRole)) {
        try (Connection con = DatabaseManager.getConnection()) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT " +
                "COUNT(*) AS total, " +
                "SUM(CASE WHEN status = 'borrowed' THEN 1 ELSE 0 END) AS current, " +
                "SUM(CASE WHEN status = 'returned' THEN 1 ELSE 0 END) AS returned, " +
                "COALESCE(SUM(fine_amount), 0) AS fines " +
                "FROM borrowing_records WHERE user_id = ?"
            );
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                totalBorrowed = rs.getInt("total");
                currentlyBorrowed = rs.getInt("current");
                totalReturned = rs.getInt("returned");
                totalFines = rs.getDouble("fines");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Profile - Library System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .navbar { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .navbar h1 { font-size: 24px; }
        .nav-links a { color: white; text-decoration: none; margin-left: 20px; padding: 8px 15px; border-radius: 5px; transition: background 0.3s; }
        .nav-links a:hover { background: rgba(255,255,255,0.2); }
        .container { max-width: 900px; margin: 30px auto; padding: 0 20px; }
        .profile-card { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 30px; }
        .profile-header { display: flex; align-items: center; gap: 30px; margin-bottom: 30px; padding-bottom: 30px; border-bottom: 2px solid #f0f0f0; }
        .profile-avatar { width: 100px; height: 100px; border-radius: 50%; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; align-items: center; justify-content: center; font-size: 48px; color: white; }
        .profile-info h2 { color: #333; margin-bottom: 10px; }
        .profile-info p { color: #666; margin-bottom: 5px; }
        .role-badge { display: inline-block; padding: 5px 15px; border-radius: 20px; font-size: 12px; font-weight: bold; margin-top: 10px; }
        .badge-student { background: #e3f2fd; color: #1976d2; }
        .badge-librarian { background: #fff3e0; color: #f57c00; }
        .badge-admin { background: #fce4ec; color: #c2185b; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-box { text-align: center; padding: 25px; background: #f8f9fa; border-radius: 10px; }
        .stat-number { font-size: 36px; font-weight: bold; color: #667eea; margin-bottom: 10px; }
        .stat-label { color: #666; font-size: 14px; }
        .info-section { margin-bottom: 30px; }
        .info-section h3 { color: #333; margin-bottom: 20px; font-size: 20px; }
        .info-row { display: flex; padding: 15px; border-bottom: 1px solid #eee; }
        .info-row:last-child { border-bottom: none; }
        .info-label { width: 200px; font-weight: bold; color: #666; }
        .info-value { flex: 1; color: #333; }
        .btn-edit { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; text-decoration: none; display: inline-block; }
        .btn-edit:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>📚 Library Management System</h1>
        <div class="nav-links">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="search-books.jsp">Search Books</a>
            <% if ("student".equals(userRole)) { %>
                <a href="my-books.jsp">My Books</a>
            <% } %>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="profile-card">
            <div class="profile-header">
                <div class="profile-avatar">👤</div>
                <div class="profile-info">
                    <h2><%= userName %></h2>
                    <p><strong>Email:</strong> <%= userEmail %></p>
                    <p><strong>User ID:</strong> #<%= userId %></p>
                    <span class="role-badge badge-<%= userRole %>"><%= userRole.toUpperCase() %></span>
                </div>
            </div>

            <% if ("student".equals(userRole)) { %>
            <div class="stats-grid">
                <div class="stat-box">
                    <div class="stat-number"><%= totalBorrowed %></div>
                    <div class="stat-label">Total Books Borrowed</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number"><%= currentlyBorrowed %></div>
                    <div class="stat-label">Currently Borrowed</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number"><%= totalReturned %></div>
                    <div class="stat-label">Books Returned</div>
                </div>
                <div class="stat-box">
                    <div class="stat-number">₹<%= String.format("%.2f", totalFines) %></div>
                    <div class="stat-label">Total Fines</div>
                </div>
            </div>
            <% } %>

            <div class="info-section">
                <h3>Account Information</h3>
                <div class="info-row"><div class="info-label">Full Name:</div><div class="info-value"><%= userName %></div></div>
                <div class="info-row"><div class="info-label">Email Address:</div><div class="info-value"><%= userEmail %></div></div>
                <div class="info-row"><div class="info-label">User ID:</div><div class="info-value">#<%= userId %></div></div>
                <div class="info-row"><div class="info-label">Account Type:</div><div class="info-value" style="text-transform: capitalize;"><%= userRole %></div></div>
                <div class="info-row"><div class="info-label">Account Status:</div><div class="info-value" style="color: #4CAF50; font-weight: bold;">Active</div></div>
            </div>

            <% if ("student".equals(userRole)) { %>
            <div class="info-section">
                <h3>Borrowing Limits</h3>
                <div class="info-row"><div class="info-label">Maximum Books:</div><div class="info-value">3 books at a time</div></div>
                <div class="info-row"><div class="info-label">Borrowing Period:</div><div class="info-value">14 days</div></div>
                <div class="info-row"><div class="info-label">Fine per Day (Overdue):</div><div class="info-value">₹5.00</div></div>
                <div class="info-row"><div class="info-label">Available Slots:</div><div class="info-value"><strong><%= 3 - currentlyBorrowed %> / 3</strong></div></div>
            </div>
            <% } %>

            <div style="text-align: center; margin-top: 30px;">
                <a href="dashboard.jsp" class="btn-edit">Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
