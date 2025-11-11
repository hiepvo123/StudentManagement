<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }
        /* Pagination */
        .pagination {
            margin-top: 20px;
            text-align: center;
        }
        .pagination a {
            display: inline-block;
            padding: 8px 12px;
            margin: 0 3px;
            text-decoration: none;
            color: #007bff;
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: white;
        }
        .pagination a.active {
            background-color: #007bff;
            color: white;
            font-weight: bold;
        }
        .pagination a:hover {
            background-color: #e9ecef;
        }
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>
    
    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            <%= request.getParameter("message") %>
        </div>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            <%= request.getParameter("error") %>
        </div>
    <% } %>
    
    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    <form action="list_students.jsp" method="GET">
        <input type="text" name="keyword" value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>" placeholder="Search by name or code...">
        <button type="submit">Search</button>
        <a href="list_students.jsp">Clear</a>
    </form>

    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        String keyword = request.getParameter("keyword");
        String pageParam = request.getParameter("page");

        int currentPage = 1;
        if (pageParam != null) {
            try {
                currentPage = Integer.parseInt(pageParam);
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }

        int recordsPerPage = 10;
        int offset = (currentPage - 1) * recordsPerPage;
        int totalRecords = 0;
        int totalPages = 0;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/student_management",
                "root",
                "Hiep@17082004"
            );

            // --- Bước 1: Đếm tổng số bản ghi ---
            PreparedStatement countStmt;
            if (keyword != null && !keyword.isEmpty()) {
                countStmt = conn.prepareStatement("SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ?");
                countStmt.setString(1, "%" + keyword + "%");
                countStmt.setString(2, "%" + keyword + "%");
            } else {
                countStmt = conn.prepareStatement("SELECT COUNT(*) FROM students");
            }
            ResultSet countRs = countStmt.executeQuery();
            if (countRs.next()) {
                totalRecords = countRs.getInt(1);
            }
            countRs.close();
            countStmt.close();

            totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

            // --- Bước 2: Lấy danh sách sinh viên ---
            String sql;
            if (keyword != null && !keyword.isEmpty()) {
                sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, "%" + keyword + "%");
                pstmt.setString(2, "%" + keyword + "%");
                pstmt.setInt(3, recordsPerPage);
                pstmt.setInt(4, offset);
            } else {
                sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, recordsPerPage);
                pstmt.setInt(2, offset);
            }

            rs = pstmt.executeQuery();
    %>

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Student Code</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Major</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
                int id = rs.getInt("id");
                String studentCode = rs.getString("student_code");
                String fullName = rs.getString("full_name");
                String email = rs.getString("email");
                String major = rs.getString("major");
                Timestamp createdAt = rs.getTimestamp("created_at");
        %>
            <tr>
                <td><%= id %></td>
                <td><%= studentCode %></td>
                <td><%= fullName %></td>
                <td><%= email != null ? email : "N/A" %></td>
                <td><%= major != null ? major : "N/A" %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
                    <a href="delete_student.jsp?id=<%= id %>" 
                       class="action-link delete-link"
                       onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                </td>
            </tr>
        <%
            } // end while
        %>
        </tbody>
    </table>

    <div class="pagination">
        <%
            if (totalPages > 1) {
                for (int i = 1; i <= totalPages; i++) {
                    if (i == currentPage) {
        %>
                        <a href="list_students.jsp?page=<%= i %><%= (keyword != null && !keyword.isEmpty()) ? "&keyword=" + keyword : "" %>" class="active"><%= i %></a>
        <%
                    } else {
        %>
                        <a href="list_students.jsp?page=<%= i %><%= (keyword != null && !keyword.isEmpty()) ? "&keyword=" + keyword : "" %>"><%= i %></a>
        <%
                    }
                }
            }
        %>
    </div>

    <%
        } catch (Exception e) {
            out.println("<tr><td colspan='7'>Error: " + e.getMessage() + "</td></tr>");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>
</body>
</html>
