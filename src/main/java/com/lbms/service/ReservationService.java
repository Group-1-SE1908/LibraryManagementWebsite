package com.lbms.service;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.dao.ReservationDAO;
import com.lbms.model.Book;
import com.lbms.model.Reservation;

import java.sql.SQLException;
import java.util.List;

/**
 * ReservationService – Business logic cho toàn bộ luồng đặt trước sách.
 *
 * Implement đầy đủ Use Case UC-RES-01:
 *  - Basic Flow       : createReservation()
 *  - Alt A1           : kiểm tra sách còn hàng
 *  - Alt A2           : kiểm tra đã đặt rồi (existsActive)
 *  - Alt A3           : kiểm tra giới hạn MAX_RESERVATIONS
 *  - Alt A3+          : kiểm tra tổng (đang mượn + đặt trước) <= MAX_TOTAL
 *  - Expiration Rule  : processExpiredReservations() – gọi từ scheduler
 *  - Notification     : tích hợp NotificationService
 */
public class ReservationService {

    /** Số đặt trước tối đa cùng lúc */
    private static final int MAX_RESERVATIONS = 3;

    /** Tổng (đang mượn + đặt trước) tối đa */
    private static final int MAX_TOTAL = 5;

    private final ReservationDAO      reservationDAO = new ReservationDAO();
    private final BookDAO             bookDAO        = new BookDAO();
    private final BorrowDAO           borrowDAO      = new BorrowDAO();
    private final NotificationService notifService   = new NotificationService();

    // ════════════════════════════════════════════════════════════════
    //  1. TẠO RESERVATION – Basic Flow + Alternative Flows
    // ════════════════════════════════════════════════════════════════
    /**
     * Tạo reservation mới cho userId với bookId.
     *
     * @throws IllegalArgumentException lỗi nghiệp vụ (A1, A2, A3)
     * @throws SQLException             lỗi database (E1, E2)
     */
    public long createReservation(long userId, long bookId) throws SQLException {

        // ── Bước 1: Kiểm tra sách tồn tại ────────────────────────────────
        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new IllegalArgumentException("Sách không tồn tại trong hệ thống.");
        }

        // ── Bước 2: Alt A1 – Sách còn hàng → không cho đặt trước ────────
        if (book.getQuantity() > 0) {
            throw new IllegalArgumentException(
                    "Sách hiện còn sẵn, bạn có thể mượn trực tiếp mà không cần đặt trước.");
        }

        // ── Bước 3: Alt A2 – Đã đặt trước rồi ───────────────────────────
        if (reservationDAO.existsActive(userId, bookId)) {
            throw new IllegalArgumentException("Bạn đã đặt trước cuốn sách này rồi.");
        }

        // ── Bước 4: Alt A3 – Vượt giới hạn reservation ───────────────────
        int activeReservations = reservationDAO.countActive(userId);
        if (activeReservations >= MAX_RESERVATIONS) {
            throw new IllegalArgumentException(
                    "Bạn đã đạt giới hạn " + MAX_RESERVATIONS + " đặt trước cùng lúc. " +
                            "Vui lòng hủy bớt trước khi đặt thêm.");
        }

        // ── Bước 5: Kiểm tra tổng (đang mượn + đặt trước) <= MAX_TOTAL ───
        int activeBorrows = borrowDAO.countActiveBorrows(userId);
        int total = activeBorrows + activeReservations;
        if (total >= MAX_TOTAL) {
            throw new IllegalArgumentException(
                    "Bạn đang có " + activeBorrows + " sách đang mượn và " +
                            activeReservations + " đặt trước (tổng " + total + "/" + MAX_TOTAL + "). " +
                            "Vui lòng trả sách hoặc hủy đặt trước trước khi đặt thêm.");
        }

        // ── Bước 5: Tìm và tái kích hoạt bản ghi cũ (CANCELLED/EXPIRED) ──
        //    → tránh tạo dư thừa dữ liệu, đồng thời gán lại queue_position mới
        Reservation old = reservationDAO.findCancelledOrExpired(userId, bookId);
        int queuePos = reservationDAO.getNextQueuePosition(bookId);

        long reservationId;
        if (old != null) {
            reservationDAO.reactivate(old.getId(), queuePos);
            reservationId = old.getId();
        } else {
            reservationId = reservationDAO.create(userId, bookId, queuePos);
        }

        return reservationId;
    }

    // ════════════════════════════════════════════════════════════════
    //  2. HỦY RESERVATION
    // ════════════════════════════════════════════════════════════════
    public void cancelReservation(long reservationId, long userId) throws SQLException {
        // Lấy thông tin để gửi notification sau khi hủy
        Reservation res = reservationDAO.getById(reservationId);

        reservationDAO.cancel(reservationId, userId);   // DAO tự re-order queue

        if (res != null) {
            notifService.notifyReservationCancelled(userId, res.getBookTitle());
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  3. XỬ LÝ KHI SÁCH ĐƯỢC TRẢ – gọi từ BorrowService khi return
    //     Implement: Reservation Expiration Rule bước 1-3 & 6
    // ════════════════════════════════════════════════════════════════
    /**
     * Gọi method này khi 1 cuốn sách được trả lại.
     * Hệ thống sẽ tìm người đầu hàng chờ, chuyển sang AVAILABLE
     * và gửi thông báo.
     *
     * @param bookId ID của cuốn sách vừa được trả
     */
    public void onBookReturned(long bookId) throws SQLException {
        Reservation first = reservationDAO.getFirstWaiting(bookId);
        if (first == null) return;  // Không có ai trong hàng chờ

        // Set AVAILABLE + notified_at + expired_at = now + 3 ngày
        reservationDAO.markAvailable(first.getId());

        // Gửi thông báo cho user đầu hàng chờ
        notifService.notifyBookAvailable(first.getUserId(), first.getBookTitle());
    }

    // ════════════════════════════════════════════════════════════════
    //  4. XỬ LÝ HẾT HẠN – gọi định kỳ từ ReservationExpirationScheduler
    //     Implement: Reservation Expiration Rule bước 4-6
    // ════════════════════════════════════════════════════════════════
    /**
     * Quét các reservation AVAILABLE đã quá 3 ngày:
     *  1. Set status = EXPIRED
     *  2. Gửi thông báo cho user đó
     *  3. Chuyển sang người tiếp theo trong hàng chờ (gọi onBookReturned)
     */
    public void processExpiredReservations() throws SQLException {
        List<Reservation> expired = reservationDAO.findExpiredAvailable();
        for (Reservation res : expired) {
            reservationDAO.updateStatus(res.getId(), "EXPIRED");
            notifService.notifyReservationExpired(res.getUserId(), res.getBookTitle());

            // Chỉ notify người tiếp nếu sách đang có sẵn (availability > 0)
            Book book = bookDAO.findById(res.getBookId());
            if (book != null && book.getQuantity() > 0) {
                onBookReturned(res.getBookId());
            }
            // Nếu không còn sách → người tiếp vẫn ở WAITING, đợi đến khi sách thực sự được trả
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  5. NHẮC NHỞ SẮP HẾT HẠN – gọi từ scheduler mỗi giờ
    // ════════════════════════════════════════════════════════════════
    public void processExpiringReminders() throws SQLException {
        List<Reservation> expiring = reservationDAO.findExpiringAvailable();

        for (Reservation res : expiring) {
            notifService.notifyBookExpiringSoon(
                    res.getUserId(), res.getBookTitle(), res.getExpiredAt());
            reservationDAO.markReminded(res.getId());
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  6. QUERY METHODS
    // ════════════════════════════════════════════════════════════════
    public List<Reservation> listByUser(long userId) throws SQLException {
        return reservationDAO.listByUser(userId);
    }

    public List<Reservation> listAll() throws SQLException {
        return reservationDAO.listAll();
    }

    public List<Reservation> listWaitingQueue(long bookId) throws SQLException {
        return reservationDAO.listWaitingQueue(bookId);
    }

    public int getMaxReservations() {
        return MAX_RESERVATIONS;
    }
}