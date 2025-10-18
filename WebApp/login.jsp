<!DOCTYPE html>
<html>
<head>
    <title>Login - Library Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            width: 400px;
        }
        h2 {
            color: #333;
            margin-bottom: 30px;
            text-align: center;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: bold;
        }
        input[type="text"], input[type="email"], input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        input[type="text"]:focus, input[type="email"]:focus, input[type="password"]:focus {
            outline: none;
            border-color: #667eea;
        }
        .error {
            color: #e74c3c;
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }
        .message {
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .error-message {
            background-color: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }
        .success-message {
            background-color: #efe;
            color: #3c3;
            border: 1px solid #cfc;
        }
        .btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
        .btn:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        .register-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .register-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
        }
        .register-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>🔐 Library System Login</h2>
        
        <% 
            String error = request.getParameter("error");
            String message = request.getParameter("message");
            String success = request.getParameter("success");
            
            if (error != null) {
                String errorMsg = "";
                if (error.equals("invalid")) errorMsg = "Invalid email or password!";
                else if (error.equals("exception")) errorMsg = "System error. Please try again.";
                else if (error.equals("session")) errorMsg = "Session expired. Please login again.";
        %>
                <div class="message error-message"><%= errorMsg %></div>
        <% 
            }
            
            if (message != null && message.equals("loggedout")) {
        %>
                <div class="message success-message">You have been logged out successfully!</div>
        <%
            }
            
            if (success != null && success.equals("registered")) {
        %>
                <div class="message success-message">Registration successful! Please login.</div>
        <%
            }
        %>
        
        <form action="login" method="post" id="loginForm" onsubmit="return validateLogin()">
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
                <div class="error" id="emailError">Please enter a valid email</div>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
                <div class="error" id="passwordError">Password must be at least 6 characters</div>
            </div>
            
            <button type="submit" class="btn">Login</button>
        </form>
        
        <div class="register-link">
            Don't have an account? <a href="register.jsp">Register here</a>
        </div>
    </div>
    
    <script>
        function validateLogin() {
            let isValid = true;
            
            // Email validation
            const email = document.getElementById('email').value.trim();
            const emailError = document.getElementById('emailError');
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            
            if (!email || !emailPattern.test(email)) {
                emailError.style.display = 'block';
                isValid = false;
            } else {
                emailError.style.display = 'none';
            }
            
            // Password validation
            const password = document.getElementById('password').value;
            const passwordError = document.getElementById('passwordError');
            
            if (password.length < 6) {
                passwordError.style.display = 'block';
                isValid = false;
            } else {
                passwordError.style.display = 'none';
            }
            
            return isValid;
        }
        
        // Real-time validation
        document.getElementById('email').addEventListener('blur', function() {
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const emailError = document.getElementById('emailError');
            if (!this.value.trim() || !emailPattern.test(this.value.trim())) {
                emailError.style.display = 'block';
            } else {
                emailError.style.display = 'none';
            }
        });
        
        document.getElementById('password').addEventListener('input', function() {
            const passwordError = document.getElementById('passwordError');
            if (this.value.length < 6 && this.value.length > 0) {
                passwordError.style.display = 'block';
            } else {
                passwordError.style.display = 'none';
            }
        });
    </script>
</body>
</html>
