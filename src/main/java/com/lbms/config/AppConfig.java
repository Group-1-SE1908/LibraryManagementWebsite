package com.lbms.config;

public final class AppConfig {
        private AppConfig() {
        }

        // Gmail SMTP config via environment variables
        public static final String SMTP_HOST = EnvConfig.getOrDefault("LBMS_SMTP_HOST", "smtp.gmail.com");
        public static final int SMTP_PORT = EnvConfig.getInt("LBMS_SMTP_PORT", 587);
        public static final String SMTP_USERNAME = EnvConfig.getOrDefault("LBMS_SMTP_USERNAME", "");
        public static final String SMTP_PASSWORD = EnvConfig.getOrDefault("LBMS_SMTP_PASSWORD", "");
        public static final String SMTP_FROM = EnvConfig.getOrDefault("LBMS_SMTP_FROM", SMTP_USERNAME);
        public static final boolean SMTP_SSL = EnvConfig.getBoolean("LBMS_SMTP_SSL", false);

        public static final String APP_BASE_URL = EnvConfig.getOrDefault("LBMS_APP_BASE_URL",
                        "http://localhost:8080/lbms");

        public static final int RESET_TOKEN_MINUTES = EnvConfig.getInt("LBMS_RESET_TOKEN_MINUTES", 15);

        public static final int EMAIL_VERIFICATION_CODE_MINUTES = EnvConfig
                        .getInt("LBMS_EMAIL_VERIFICATION_CODE_MINUTES", 15);

        // GHTK config via environment variables
        public static final String GHTK_API_BASE_URL = EnvConfig.getOrDefault("LBMS_GHTK_API_BASE_URL",
                        "https://services.giaohangtietkiem.vn");
        public static final String GHTK_TOKEN = EnvConfig.getOrDefault("LBMS_GHTK_TOKEN", "");
        public static final String GHTK_SHOP_PHONE = EnvConfig.getOrDefault("LBMS_GHTK_SHOP_PHONE", "");
        public static final String GHTK_SHOP_ADDRESS = EnvConfig.getOrDefault("LBMS_GHTK_SHOP_ADDRESS", "");
        public static final String GHTK_SHOP_DISTRICT = EnvConfig.getOrDefault("LBMS_GHTK_SHOP_DISTRICT", "");
        public static final String GHTK_SHOP_PROVINCE = EnvConfig.getOrDefault("LBMS_GHTK_SHOP_PROVINCE", "");
}
