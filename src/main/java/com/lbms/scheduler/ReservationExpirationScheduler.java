package com.lbms.scheduler;

import com.lbms.service.ReservationService;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.sql.SQLException;
import java.util.Timer;
import java.util.TimerTask;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * ReservationExpirationScheduler
 *
 * Chạy định kỳ mỗi giờ để:
 *  1. Hủy các reservation AVAILABLE đã quá hạn 3 ngày → chuyển sang người tiếp theo
 *  2. Gửi nhắc nhở cho reservation AVAILABLE còn dưới 1 ngày
 *
 * Khai báo @WebListener → Tomcat tự khởi động khi deploy.
 * Không cần cấu hình thêm.
 */
@WebListener
public class ReservationExpirationScheduler implements ServletContextListener {

    private static final Logger logger = Logger.getLogger(
            ReservationExpirationScheduler.class.getName());

    /** Chạy mỗi 1 giờ (milliseconds) */
    private static final long INTERVAL_MS = 60 * 60 * 1000L;

    private Timer timer;
    private final ReservationService reservationService = new ReservationService();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        timer = new Timer("ReservationExpirationScheduler", true); // daemon thread

        timer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                try {
                    logger.info("[Scheduler] Đang xử lý reservation hết hạn...");
                    reservationService.processExpiredReservations();

                    logger.info("[Scheduler] Đang gửi nhắc nhở sắp hết hạn...");
                    reservationService.processExpiringReminders();

                    logger.info("[Scheduler] Hoàn tất.");
                } catch (SQLException e) {
                    logger.log(Level.SEVERE,
                            "[Scheduler] Lỗi khi xử lý reservation hết hạn", e);
                }
            }
        }, 0, INTERVAL_MS); // delay=0: chạy ngay khi khởi động server

        logger.info("[Scheduler] ReservationExpirationScheduler đã khởi động. " +
                "Chu kỳ: mỗi 1 giờ.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (timer != null) {
            timer.cancel();
            logger.info("[Scheduler] ReservationExpirationScheduler đã dừng.");
        }
    }
}