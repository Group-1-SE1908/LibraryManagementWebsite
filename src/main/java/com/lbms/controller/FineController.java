package com.lbms.controller;

import com.lbms.dao.BorrowDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = { "/fines", "/fines/history" })
public class FineController extends HttpServlet {

    private BorrowDAO borrowDAO;

    @Override
    public void init() {
        this.borrowDAO = new BorrowDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        String activePanel = path.endsWith("/history") ? "history" : "outstanding";

        try {
            List<BorrowRecord> unpaid = borrowDAO.listUnpaidFinesByUser(currentUser.getId());
            List<BorrowRecord> history = borrowDAO.listFineHistoryByUser(currentUser.getId());

            BigDecimal totalOutstanding = unpaid.stream()
                    .map(BorrowRecord::getFineAmount)
                    .filter(amount -> amount != null)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            Object flash = req.getSession().getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash);
                req.getSession().removeAttribute("flash");
            }

            req.setAttribute("unpaidRecords", unpaid);
            req.setAttribute("historyRecords", history);
            req.setAttribute("totalOutstanding", totalOutstanding);
            req.setAttribute("activePanel", activePanel);
            req.getRequestDispatcher("/WEB-INF/views/manage_fines.jsp").forward(req, resp);
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }
}
