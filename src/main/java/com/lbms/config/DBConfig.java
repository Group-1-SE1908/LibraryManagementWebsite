package com.lbms.config;

public final class DBConfig {

    private DBConfig() {
    }

    public static final String URL = EnvConfig.getOrDefault("LBMS_DB_URL",
            "jdbc:sqlserver://localhost:1433;databaseName=LibraryDB;encrypt=true;trustServerCertificate=true;");

    public static final String USER = EnvConfig.getOrDefault("LBMS_DB_USER", "sa");

    public static final String PASSWORD = EnvConfig.getOrDefault("LBMS_DB_PASSWORD", "123456");
}
