<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Mượn tại quầy | Staff LBMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --bg-body: #f8fafc;
            --primary-dark: #1e293b;
            --accent-blue: #0b57d0;
            --border-color: #e2e8f0;
            --card-bg: #ffffff;
            --text-main: #334155;
        }

        body {
            margin: 0;
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-body);
            color: var(--text-main);
        }

        .main-content {
            margin-left: 280px; /* Độ rộng sidebar */
            padding: 40px;
            min-height: 100vh;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .page-header h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-dark);
            margin: 0;
        }

        /* Bố cục lưới cân xứng */
        .borrow-container {
            display: grid;
            grid-template-columns: 1fr 1.5fr; /* Tỷ lệ 1:1.5 */
            gap: 30px;
            align-items: start;
        }

        .card {
            background: var(--card-bg);
            border-radius: 12px;
            border: 1px solid var(--border-color);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            padding: 24px;
        }

        .card-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            color: var(--primary-dark);
            border-bottom: 1px dashed var(--border-color);
            padding-bottom: 12px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
            color: #64748b;
        }

        .form-control {
            width: 100%;
            padding: 12px 16px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            font-size: 15px;
            transition: 0.3s;
            box-sizing: border-box;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--accent-blue);
            box-shadow: 0 0 0 3px rgba(11, 87, 208, 0.1);
        }

        .book-preview {
            display: flex;
            gap: 15px;
            background: #f1f5f9;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
        }

        .btn-submit {
            background: var(--accent-blue);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            font-size: 16px;
            transition: 0.3s;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 10px;
        }

        .btn-submit:hover {
            background: #0842a0;
            transform: translateY(-2px);
        }

        .alert-info {
            background: #e0f2fe;
            color: #0369a1;
            padding: 12px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

    <div class="main-content">
        <div class="page-header">
            <div>
                <h1><i class="fas fa-hand-holding-medical"></i> Giao dịch mượn sách</h1>
                <p style="color: #64748b; margin-top: 5px;">Thực hiện quy trình cho mượn trực tiếp tại thư viện</p>
            </div>
            <a href="${pageContext.request.contextPath}/admin/borrowlibrary" style="text-decoration: none; color: var(--accent-blue); font-weight: 500;">
                <i class="fas fa-arrow-left"></i> Quay lại danh sách
            </a>
        </div>

        <form action="${pageContext.request.contextPath}/admin/borrowlibrary/inperson" method="post">
            <div class="borrow-container">
                
                <div class="card">
                    <div class="card-title">
                        <i class="fas fa-user-circle"></i> Người mượn
                    </div>
                    <div class="alert-info">
                        Nhập ID hoặc Username chính xác của người dùng trong hệ thống.
                    </div>
                    <div class="form-group">
                        <label>Tên đăng nhập hoặc ID thành viên</label>
                        <input type="text" name="username" class="form-control" placeholder="Ví dụ: user01, SV12345..." required>
                    </div>
                    <div class="form-group">
                        <label>Số điện thoại xác nhận (Tùy chọn)</label>
                        <input type="text" class="form-control" placeholder="Kiểm tra lại nếu cần">
                    </div>
                </div>

                <div class="card">
                    <div class="card-title">
                        <i class="fas fa-book-open"></i> Thông tin mượn sách
                    </div>
                    
                    <div class="form-group">
                        <label>Mã bản sao sách (Copy ID)</label>
                        <div style="display: flex; gap: 10px;">
                            <input type="text" name="bookCopyId" class="form-control" placeholder="Nhập mã barcode trên sách..." required>
                            <button type="button" class="btn-submit" style="width: auto; padding: 0 20px; background: var(--primary-dark);">
                                <i class="fas fa-search"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Ngày hẹn trả</label>
                        <input type="date" name="dueDate" class="form-control" required>
                        <small style="color: #64748b; margin-top: 5px; display: block;">Thời gian mượn mặc định là 14 ngày.</small>
                    </div>

                    <div class="form-group" style="margin-top: 30px;">
                        <button type="submit" class="btn-submit">
                            <i class="fas fa-check-circle"></i> Xác nhận cho mượn
                        </button>
                    </div>
                </div>

            </div>
        </form>
    </div>

    <script>
        // Tự động đặt ngày hẹn trả là 14 ngày kể từ hôm nay
        window.onload = function() {
            let date = new Date();
            date.setDate(date.getDate() + 14);
            document.getElementsByName('dueDate')[0].valueAsDate = date;
        }
    </script>

</body>
</html>