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
     * HÀM HELPER 1: Xử lý chuẩn hóa Tỉnh/Thành phố khớp với DB của GHTK
     */
    private String cleanProvince(String province) {
        if (province == null) return "";
        province = province.trim();
        
        if (province.equalsIgnoreCase("Thành phố Hồ Chí Minh") || province.equalsIgnoreCase("TP Hồ Chí Minh")) {
            return "TP. Hồ Chí Minh";
        }
        if (province.startsWith("Thành phố ")) {
            return province.replace("Thành phố ", "");
        }
        if (province.startsWith("Tỉnh ")) {
            return province.replace("Tỉnh ", "");
        }
        return province;
    }

    /**
     * HÀM HELPER 2: An toàn Encode URL (Tương thích Java 8) và chặn NullPointer
     */
    private String safeEncode(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "";
        }
        try {
            return URLEncoder.encode(value.trim(), "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }

    /**
     * 1. API Tính phí vận chuyển
     */
    public long calculateFee(ShippingDetails userAddress, int weightGram) {
        // GHTK yêu cầu trọng lượng tối thiểu, set cứng 200g nếu nhỏ hơn hoặc bằng 0
        int validWeight = weightGram > 0 ? weightGram : 200; 

        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) {
            return 30000; // Trả về phí ảo nếu chưa cấu hình Token
        }

        try {
            // Làm sạch tên tỉnh trước khi gửi
            String cleanProv = cleanProvince(userAddress.getCity());

            // Dùng safeEncode để chống chết luồng do Null hoặc khác bản Java
            String url = AppConfig.GHTK_API_BASE_URL + "/services/shipment/fee"
                    + "?pick_province=" + safeEncode(LIB_PROVINCE)
                    + "&pick_district=" + safeEncode(LIB_DISTRICT)
                    + "&province=" + safeEncode(cleanProv)
                    + "&district=" + safeEncode(userAddress.getDistrict())
                    + "&ward=" + safeEncode(userAddress.getWard())
                    + "&weight=" + validWeight;

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
            System.err.println("API Tính phí GHTK báo lỗi: " + resp.body());
            return 35000;
        } catch (Exception e) {
            System.err.println("Lỗi tính phí GHTK: " + e.getMessage());
            return 35000;
        }
    }

    /**
     * 2. API Tạo đơn hàng tự động
     */
    public String createOrder(BorrowRecord record, int weightGram) {
        int validWeight = weightGram > 0 ? weightGram : 200;

        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) {
            return "S" + System.currentTimeMillis();
        }

        try {
            ShippingDetails sd = record.getShippingDetails();
            String cleanProv = cleanProvince(sd.getCity());

            JsonArray products = new JsonArray();
            JsonObject product = new JsonObject();
            product.addProperty("name", "Sách mượn: " + record.getBook().getTitle());
            product.addProperty("weight", validWeight);
            products.add(product);

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
            order.addProperty("province", cleanProv);
            order.addProperty("district", sd.getDistrict());
            order.addProperty("ward", sd.getWard());
            order.addProperty("value", 0);

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
                return obj.getAsJsonObject("order").get("label").getAsString();
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
        if (trackingCode == null || trackingCode.isBlank()) return "CREATED";
        if (AppConfig.GHTK_TOKEN == null || AppConfig.GHTK_TOKEN.isBlank()) return "CREATED";

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