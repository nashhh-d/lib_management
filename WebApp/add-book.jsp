<%@ page import="jakarta.servlet.http.*,jakarta.servlet.*" %>
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
    <title>Add Book - Library System</title>
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
            max-width: 800px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .form-card {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-card h2 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
            font-size: 14px;
        }
        label .required {
            color: #f44336;
        }
        input, select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            font-family: inherit;
        }
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        .error {
            color: #f44336;
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }
        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        .btn {
            flex: 1;
            padding: 14px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            font-weight: bold;
            transition: transform 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
        .btn-submit {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-cancel {
            background: #f5f5f5;
            color: #666;
        }
        .btn-cancel:hover {
            background: #e0e0e0;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>📚 Library Management System</h1>
        <div class="nav-links">
            <a href="dashboard.jsp">Dashboard</a>
            <a href="manage-books.jsp">Manage Books</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="form-card">
            <h2>➕ Add New Book</h2>
            
            <form action="add-book" method="post" id="addBookForm" onsubmit="return validateForm()">
                <div class="form-grid">
                    <div class="form-group full-width">
                        <label for="title">Book Title <span class="required">*</span></label>
                        <input type="text" id="title" name="title" required>
                        <div class="error" id="titleError">Title must be at least 3 characters</div>
                    </div>

                    <div class="form-group">
                        <label for="author">Author <span class="required">*</span></label>
                        <input type="text" id="author" name="author" required>
                        <div class="error" id="authorError">Author name is required</div>
                    </div>

                    <div class="form-group">
                        <label for="isbn">ISBN</label>
                        <input type="text" id="isbn" name="isbn" placeholder="978-XXXXXXXXXX">
                        <div class="error" id="isbnError">Invalid ISBN format</div>
                    </div>

                    <div class="form-group">
                        <label for="category">Category <span class="required">*</span></label>
                        <select id="category" name="category" required>
                            <option value="">Select Category</option>
                            <option value="Fiction">Fiction</option>
                            <option value="Non-Fiction">Non-Fiction</option>
                            <option value="Science">Science</option>
                            <option value="Technology">Technology</option>
                            <option value="History">History</option>
                            <option value="Mathematics">Mathematics</option>
                            <option value="Literature">Literature</option>
                            <option value="Business">Business</option>
                            <option value="Self-Help">Self-Help</option>
                            <option value="Biography">Biography</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="publisher">Publisher</label>
                        <input type="text" id="publisher" name="publisher">
                    </div>

                    <div class="form-group">
                        <label for="publicationYear">Publication Year</label>
                        <input type="number" id="publicationYear" name="publicationYear" 
                               min="1800" max="<%= java.time.Year.now().getValue() %>" placeholder="2024">
                        <div class="error" id="yearError">Invalid year</div>
                    </div>

                    <div class="form-group">
                        <label for="totalCopies">Total Copies <span class="required">*</span></label>
                        <input type="number" id="totalCopies" name="totalCopies" min="1" value="1" required>
                        <div class="error" id="copiesError">Must be at least 1</div>
                    </div>

                    <div class="form-group full-width">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" placeholder="Brief description of the book..."></textarea>
                    </div>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn btn-submit">Add Book</button>
                    <a href="manage-books.jsp" class="btn btn-cancel" style="text-align: center; line-height: 14px; text-decoration: none;">Cancel</a>
                </div>
            </form>
        </div>
    </div>

    <script>
        function validateForm() {
            let isValid = true;

            // Title validation
            const title = document.getElementById('title').value.trim();
            if (title.length < 3) {
                document.getElementById('titleError').style.display = 'block';
                isValid = false;
            } else {
                document.getElementById('titleError').style.display = 'none';
            }

            // Author validation
            const author = document.getElementById('author').value.trim();
            if (author.length < 2) {
                document.getElementById('authorError').style.display = 'block';
                isValid = false;
            } else {
                document.getElementById('authorError').style.display = 'none';
            }

            // ISBN validation (optional but if provided, should be valid)
            const isbn = document.getElementById('isbn').value.trim();
            if (isbn && !/^(\d{3}-?)?\d{9}[\dX]$/.test(isbn.replace(/-/g, ''))) {
                document.getElementById('isbnError').style.display = 'block';
                isValid = false;
            } else {
                document.getElementById('isbnError').style.display = 'none';
            }

            // Year validation
            const year = document.getElementById('publicationYear').value;
            const currentYear = new Date().getFullYear();
            if (year && (year < 1800 || year > currentYear)) {
                document.getElementById('yearError').style.display = 'block';
                isValid = false;
            } else {
                document.getElementById('yearError').style.display = 'none';
            }

            // Copies validation
            const copies = document.getElementById('totalCopies').value;
            if (copies < 1) {
                document.getElementById('copiesError').style.display = 'block';
                isValid = false;
            } else {
                document.getElementById('copiesError').style.display = 'none';
            }

            return isValid;
        }

        // Real-time validation
        document.getElementById('title').addEventListener('blur', function() {
            if (this.value.trim().length < 3) {
                document.getElementById('titleError').style.display = 'block';
            } else {
                document.getElementById('titleError').style.display = 'none';
            }
        });

        document.getElementById('author').addEventListener('blur', function() {
            if (this.value.trim().length < 2) {
                document.getElementById('authorError').style.display = 'block';
            } else {
                document.getElementById('authorError').style.display = 'none';
            }
        });
    </script>
</body>
</html>