<!DOCTYPE html>
<html>
<head>
    <title>Register - Library Management System</title>
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
            padding: 20px;
        }
        .register-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.2);
            width: 450px;
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
        input[type="text"], input[type="email"], input[type="password"], select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        input:focus, select:focus {
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
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: bold;
        }
        .login-link a:hover {
            text-decoration: underline;
        }
        .password-strength {
            height: 5px;
            margin-top: 5px;
            border-radius: 3px;
            transition: all 0.3s;
        }
        .weak { background-color: #e74c3c; width: 33%; }
        .medium { background-color: #f39c12; width: 66%; }
        .strong { background-color: #27ae60; width: 100%; }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>📚 Register for Library System</h2>
        
        <% 
            String error = request.getParameter("error");
            if (error != null) {
                String errorMsg = "";
                if (error.equals("exists")) errorMsg = "Email already registered!";
                else if (error.equals("exception")) errorMsg = "System error. Please try again.";
        %>
                <div class="message error-message"><%= errorMsg %></div>
        <% } %>
        
        <form action="register" method="post" id="registerForm" onsubmit="return validateRegister()">
            <div class="form-group">
                <label for="name">Full Name:</label>
                <input type="text" id="name" name="name" required>
                <div class="error" id="nameError">Name must be at least 3 characters</div>
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
                <div class="error" id="emailError">Please enter a valid email</div>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
                <div class="password-strength" id="strengthBar"></div>
                <div class="error" id="passwordError">Password must be at least 6 characters</div>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Confirm Password:</label>
                <input type="password" id="confirmPassword" name="confirmPassword" required>
                <div class="error" id="confirmError">Passwords do not match</div>
            </div>
            
            <div class="form-group">
                <label for="role">Role:</label>
                <select id="role" name="role">
                    <option value="student">Student</option>
                    <option value="librarian">Librarian</option>
                </select>
            </div>
            
            <button type="submit" class="btn">Register</button>
        </form>
        
        <div class="login-link">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </div>
    
    <script>
        function validateRegister() {
            let isValid = true;
            
            // Name validation
            const name = document.getElementById('name').value.trim();
            const nameError = document.getElementById('nameError');
            if (name.length < 3) {
                nameError.style.display = 'block';
                isValid = false;
            } else {
                nameError.style.display = 'none';
            }
            
            // Email validation
            const email = document.getElementById('email').value.trim();
            const emailError = document.getElementById('emailError');
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailPattern.test(email)) {
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
            
            // Confirm password validation
            const confirmPassword = document.getElementById('confirmPassword').value;
            const confirmError = document.getElementById('confirmError');
            if (password !== confirmPassword) {
                confirmError.style.display = 'block';
                isValid = false;
            } else {
                confirmError.style.display = 'none';
            }
            
            return isValid;
        }
        
        // Real-time validation
        document.getElementById('name').addEventListener('blur', function() {
            const nameError = document.getElementById('nameError');
            if (this.value.trim().length < 3) {
                nameError.style.display = 'block';
            } else {
                nameError.style.display = 'none';
            }
        });
        
        document.getElementById('email').addEventListener('blur', function() {
            const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            const emailError = document.getElementById('emailError');
            if (!emailPattern.test(this.value.trim())) {
                emailError.style.display = 'block';
            } else {
                emailError.style.display = 'none';
            }
        });
        
        // Password strength indicator
        document.getElementById('password').addEventListener('input', function() {
            const password = this.value;
            const strengthBar = document.getElementById('strengthBar');
            const passwordError = document.getElementById('passwordError');
            
            if (password.length === 0) {
                strengthBar.className = 'password-strength';
                return;
            }
            
            let strength = 0;
            if (password.length >= 6) strength++;
            if (password.length >= 10) strength++;
            if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
            if (/\d/.test(password)) strength++;
            if (/[^a-zA-Z\d]/.test(password)) strength++;
            
            if (strength <= 2) {
                strengthBar.className = 'password-strength weak';
            } else if (strength <= 4) {
                strengthBar.className = 'password-strength medium';
            } else {
                strengthBar.className = 'password-strength strong';
            }
            
            if (password.length < 6) {
                passwordError.style.display = 'block';
            } else {
                passwordError.style.display = 'none';
            }
        });
        
        document.getElementById('confirmPassword').addEventListener('input', function() {
            const password = document.getElementById('password').value;
            const confirmError = document.getElementById('confirmError');
            if (this.value !== password && this.value.length > 0) {
                confirmError.style.display = 'block';
            } else {
                confirmError.style.display = 'none';
            }
        });
    </script>
</body>
</html>