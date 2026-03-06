package com.lbms.service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.lbms.config.AppConfig;
import com.lbms.model.BorrowRecord;
import com.lbms.model.ShippingDetails;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

public class GHTKService {
    private final HttpClient http;
    private final Gson gson;

    // --- ĐỊA CHỈ THƯ VIỆN CỐ ĐỊNH LẤY HÀNG (FPT Cần Thơ) ---
    private static final String LIB_NAME = "Thư viện FPT";
    private static final String LIB_PHONE = "02873001866";
    private static final String LIB_PROVINCE = "Cần Thơ";
    private static final String LIB_DISTRICT = "Quận Ninh Kiều";
    private static final String LIB_WARD = "Phường An Bình";
    private static final String LIB_ADDRESS = "Số 600, đường Nguyễn Văn Cừ nối dài";

    public GHTKService() {
        this.http = HttpClient.newHttpClient();
        this.gson = new Gson();
    }

    /**
     * 1. API Tính phí vận chuyển
     */
    public long calculateFee(ShippingDetails userAddress, int weightGram) {
        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) return 30000; // Mock data nếu chưa có Token

        try {
            String url = AppConfig.GHTK_API_BASE_URL + "/services/shipment/fee"
                    + "?pick_province=" + URLEncoder.encode(LIB_PROVINCE, StandardCharsets.UTF_8)
                    + "&pick_district=" + URLEncoder.encode(LIB_DISTRICT, StandardCharsets.UTF_8)
                    + "&province=" + URLEncoder.encode(userAddress.getCity(), StandardCharsets.UTF_8)
                    + "&district=" + URLEncoder.encode(userAddress.getDistrict(), StandardCharsets.UTF_8)
                    + "&ward=" + URLEncoder.encode(userAddress.getWard(), StandardCharsets.UTF_8)
                    + "&weight=" + weightGram;

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Token", AppConfig.GHTK_TOKEN)
                    .GET()
                    .build();

            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            JsonObject obj = gson.fromJson(resp.body(), JsonObject.class);

            if (obj != null && obj.has("success") && obj.get("success").getAsBoolean()) {
                return obj.getAsJsonObject("fee").get("fee").getAsLong();
            }
            return 35000; // Phí mặc định nếu API lỗi
        } catch (Exception e) {
            System.err.println("Lỗi tính phí GHTK: " + e.getMessage());
            return 35000;
        }
    }

    /**
     * 2. API Tạo đơn hàng tự động
     */
    public String createOrder(BorrowRecord record, int weightGram) {
        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) {
            return "S" + System.currentTimeMillis(); // Mock mã vận đơn
        }

        try {
            ShippingDetails sd = record.getShippingDetails();

            // 1. Array Products
            JsonArray products = new JsonArray();
            JsonObject product = new JsonObject();
            product.addProperty("name", "Sách mượn thư viện: " + record.getBook().getTitle());
            product.addProperty("weight", weightGram); // GHTK tính bằng KG, nhưng API cũ tính bằng Gram tùy config, chuẩn là Gram.
            products.add(product);

            // 2. Object Order
            JsonObject order = new JsonObject();
            order.addProperty("id", "BR-" + record.getId());
            order.addProperty("pick_name", LIB_NAME);
            order.addProperty("pick_address", LIB_ADDRESS);
            order.addProperty("pick_province", LIB_PROVINCE);
            order.addProperty("pick_district", LIB_DISTRICT);
            order.addProperty("pick_ward", LIB_WARD);
            order.addProperty("pick_tel", LIB_PHONE);
            
            order.addProperty("tel", sd.getPhone());
            order.addProperty("name", sd.getRecipient());
            order.addProperty("address", sd.getStreet());
            order.addProperty("province", sd.getCity());
            order.addProperty("district", sd.getDistrict());
            order.addProperty("ward", sd.getWard());
            order.addProperty("value", 0); // Không thu hộ tiền

            // 3. Payload gộp
            JsonObject payload = new JsonObject();
            payload.add("products", products);
            payload.add("order", order);

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(AppConfig.GHTK_API_BASE_URL + "/services/shipment/order"))
                    .header("Content-Type", "application/json")
                    .header("Token", AppConfig.GHTK_TOKEN)
                    .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(payload)))
                    .build();

            HttpResponse<String> resp = http.send(req, HttpResponse.BodyHandlers.ofString());
            JsonObject obj = gson.fromJson(resp.body(), JsonObject.class);

            if (obj != null && obj.has("success") && obj.get("success").getAsBoolean()) {
                return obj.getAsJsonObject("order").get("label").getAsString(); // Lấy mã vận đơn thật
            }
            throw new RuntimeException("GHTK báo lỗi: " + obj.get("message").getAsString());
        } catch (Exception e) {
            throw new RuntimeException("Gọi API tạo đơn thất bại: " + e.getMessage(), e);
        }
    }
    /**
     * 3. API Lấy trạng thái đơn hàng theo tracking code
     */
    public String getStatus(String trackingCode) {
        if (trackingCode == null || trackingCode.isBlank())
            return "CREATED";
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
            System.err.println("Lỗi khi lấy trạng thái GHTK: " + e.getMessage());
            return "UNKNOWN";
        }
    }
}