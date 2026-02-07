package com.lbms.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {
    static {
        try {
            // Đăng ký SQL Server Driver
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy SQL Server JDBC Driver");
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DBConfig.URL, DBConfig.USER, DBConfig.PASSWORD);
    }
}
