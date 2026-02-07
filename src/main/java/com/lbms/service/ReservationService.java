package com.lbms.service;

import com.lbms.dao.BookDAO;
import com.lbms.dao.ReservationDAO;
import com.lbms.model.Book;
import com.lbms.model.Reservation;

import java.sql.SQLException;
import java.util.List;

public class ReservationService {
    private final ReservationDAO reservationDAO;
    private final BookDAO bookDAO;

    public ReservationService() {
        this.reservationDAO = new ReservationDAO();
        this.bookDAO = new BookDAO();
    }

    public long createReservation(long userId, long bookId) throws SQLException {
        Book b = bookDAO.findById(bookId);
        if (b == null) throw new IllegalArgumentException("Sách không tồn tại");

        // Theo SRS: đặt trước khi sách hết
        if (b.getQuantity() > 0) {
            throw new IllegalArgumentException("Sách còn hàng, không cần đặt trước");
        }

        if (reservationDAO.existsActive(userId, bookId)) {
            throw new IllegalArgumentException("Bạn đã đặt trước sách này rồi");
        }

        return reservationDAO.create(userId, bookId);
    }

    public void cancelReservation(long reservationId, long userId) throws SQLException {
        reservationDAO.cancel(reservationId, userId);
    }

    public List<Reservation> listByUser(long userId) throws SQLException {
        return reservationDAO.listByUser(userId);
    }

    public List<Reservation> listAll() throws SQLException {
        return reservationDAO.listAll();
    }
}
