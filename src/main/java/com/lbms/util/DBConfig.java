package com.lbms.util;

import java.sql.Connection;

public final class DBConfig {

   
    private DBConfig() {
    }

    public static final String URL = System.getenv().getOrDefault("LBMS_DB_URL",
            "jdbc:sqlserver://localhost:1433;databaseName=LibraryDB;encrypt=true;trustServerCertificate=true;");

    public static final String USER = System.getenv().getOrDefault("LBMS_DB_USER", "sa");

    public static final String PASSWORD = System.getenv().getOrDefault("LBMS_DB_PASSWORD", "123456");
}
