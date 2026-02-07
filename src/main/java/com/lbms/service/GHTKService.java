package com.lbms.service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.lbms.util.AppConfig;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class GHTKService {
    private final HttpClient http;
    private final Gson gson;

    public GHTKService() {
        this.http = HttpClient.newHttpClient();
        this.gson = new Gson();
    }

    /**
     * Tạo đơn hàng trên GHTK.
     *
     * Lưu ý: Đây là skeleton tối giản. Nếu chưa cấu hình token thì trả về mã giả lập.
     */
    public String createOrder(String address, String phone, String note) {
        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) {
            return "MOCK-" + System.currentTimeMillis();
        }

        try {
            // Payload tối giản dạng JSON (thực tế GHTK có cấu trúc 'order' và 'products').
            // Bạn có thể mở rộng sau.
            JsonObject payload = new JsonObject();
            payload.addProperty("address", address);
            payload.addProperty("tel", phone);
            payload.addProperty("note", note == null ? "" : note);

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(AppConfig.GHTK_API_BASE_URL + "/services/shipment/order"))
                    .header("Content-Type", "application/json")
                    .header("Token", AppConfig.GHTK_TOKEN)
                    .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(payload)))
                    .build();

            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());

            // Parse response
            JsonObject obj = gson.fromJson(resp.body(), JsonObject.class);
            // GHTK thường trả về: { success: true, order: { label: "Sxxxx" } }
            if (obj != null && obj.has("order")) {
                JsonObject order = obj.getAsJsonObject("order");
                if (order != null && order.has("label")) {
                    return order.get("label").getAsString();
                }
            }

            // fallback
            return "GHTK-" + System.currentTimeMillis();
        } catch (Exception e) {
            throw new RuntimeException("Gọi GHTK thất bại: " + e.getMessage(), e);
        }
    }

    /**
     * Lấy trạng thái đơn theo tracking code.
     * Nếu chưa cấu hình token thì trả về CREATED.
     */
    public String getStatus(String trackingCode) {
        if (trackingCode == null || trackingCode.isBlank()) return "CREATED";
        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) {
            return "CREATED";
        }

        try {
            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(AppConfig.GHTK_API_BASE_URL + "/services/shipment/v2/" + trackingCode))
                    .header("Token", AppConfig.GHTK_TOKEN)
                    .GET()
                    .build();

            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            JsonObject obj = gson.fromJson(resp.body(), JsonObject.class);
            if (obj != null && obj.has("status")) {
                return obj.get("status").getAsString();
            }
            return "UNKNOWN";
        } catch (Exception e) {
            return "UNKNOWN";
        }
    }
}
