package com.lbms.util;

public final class AppConfig {
    private AppConfig() {}

    // Gmail SMTP config via environment variables
    public static final String SMTP_HOST = System.getenv().getOrDefault("LBMS_SMTP_HOST", "smtp.gmail.com");
    public static final int SMTP_PORT = Integer.parseInt(System.getenv().getOrDefault("LBMS_SMTP_PORT", "587"));
    public static final String SMTP_USERNAME = System.getenv().getOrDefault("LBMS_SMTP_USERNAME", "");
    public static final String SMTP_PASSWORD = System.getenv().getOrDefault("LBMS_SMTP_PASSWORD", "");
    public static final String SMTP_FROM = System.getenv().getOrDefault("LBMS_SMTP_FROM", SMTP_USERNAME);

    public static final String APP_BASE_URL = System.getenv().getOrDefault("LBMS_APP_BASE_URL", "http://localhost:8080/lbms");

    public static final int RESET_TOKEN_MINUTES = Integer.parseInt(System.getenv().getOrDefault("LBMS_RESET_TOKEN_MINUTES", "15"));

    // GHTK config via environment variables
    public static final String GHTK_API_BASE_URL = System.getenv().getOrDefault("LBMS_GHTK_API_BASE_URL", "https://services.giaohangtietkiem.vn");
    public static final String GHTK_TOKEN = System.getenv().getOrDefault("LBMS_GHTK_TOKEN", "");
    public static final String GHTK_SHOP_PHONE = System.getenv().getOrDefault("LBMS_GHTK_SHOP_PHONE", "");
    public static final String GHTK_SHOP_ADDRESS = System.getenv().getOrDefault("LBMS_GHTK_SHOP_ADDRESS", "");
    public static final String GHTK_SHOP_DISTRICT = System.getenv().getOrDefault("LBMS_GHTK_SHOP_DISTRICT", "");
    public static final String GHTK_SHOP_PROVINCE = System.getenv().getOrDefault("LBMS_GHTK_SHOP_PROVINCE", "");
}
