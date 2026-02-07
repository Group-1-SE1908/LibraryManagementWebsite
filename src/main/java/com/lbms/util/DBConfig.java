package com.lbms.util;

public final class DBConfig {
    private DBConfig() {}

    public static final String URL = System.getenv().getOrDefault("LBMS_DB_URL",
            "jdbc:mysql://localhost:3306/lbms?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");

    public static final String USER = System.getenv().getOrDefault("LBMS_DB_USER", "root");

    public static final String PASSWORD = System.getenv().getOrDefault("LBMS_DB_PASSWORD", "123456");
}
