package com.lbms.config;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

public final class EnvConfig {
    private static final Map<String, String> FALLBACK = new HashMap<>();

    static {
        loadFallback();
    }

    private static void loadFallback() {
        try (InputStream stream = EnvConfig.class.getResourceAsStream("/.env")) {
            if (stream == null) {
                return;
            }
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    line = line.trim();
                    if (line.isEmpty() || line.startsWith("#")) {
                        continue;
                    }
                    int idx = line.indexOf('=');
                    if (idx <= 0) {
                        continue;
                    }
                    String key = line.substring(0, idx).trim();
                    String value = line.substring(idx + 1).trim();
                    FALLBACK.put(key, value);
                }
            }
        } catch (Exception ignored) {
        }
    }

    private EnvConfig() {
    }

    public static String get(String name) {
        String value = System.getenv(name);
        if (value != null && !value.isBlank()) {
            return value;
        }
        value = FALLBACK.get(name);
        return value == null ? "" : value;
    }

    public static String getOrDefault(String name, String defaultValue) {
        String value = get(name);
        return value.isEmpty() ? defaultValue : value;
    }

    public static int getInt(String name, int defaultValue) {
        String value = get(name);
        if (value.isEmpty()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    public static boolean getBoolean(String name, boolean defaultValue) {
        String value = get(name);
        if (value.isEmpty()) {
            return defaultValue;
        }
        return Boolean.parseBoolean(value);
    }
}
