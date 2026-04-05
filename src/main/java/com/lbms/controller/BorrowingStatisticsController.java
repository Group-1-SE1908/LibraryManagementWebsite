package com.lbms.controller;

import com.lbms.model.BorrowingStatistics;
import com.lbms.service.BorrowingStatisticsService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet(name = "BorrowingStatisticsController", urlPatterns = { "/admin/statistics" })
public class BorrowingStatisticsController extends HttpServlet {

    private BorrowingStatisticsService statsService;

    @Override
    public void init() throws ServletException {

        statsService = new BorrowingStatisticsService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startParam = request.getParameter("startDate");
        String endParam = request.getParameter("endDate");
        String action = request.getParameter("action");

        if (isInvalidDateRange(startParam, endParam)) {
            request.getSession().setAttribute("flash", "Định dạng ngày không hợp lệ. Vui lòng thử lại!");
            response.sendRedirect(request.getContextPath() + "/admin/statistics");
            return;
        }

        try {

            BorrowingStatistics stats = statsService.getStatistics(startParam, endParam);

            if ("export".equals(action)) {
                handleExportAction(response, stats, startParam, endParam);
            } else {
                handleViewAction(request, response, stats, startParam, endParam);
            }

        } catch (Exception e) {
            e.printStackTrace();

            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi xử lý dữ liệu thống kê: " + e.getMessage());
        }
    }

    private void handleViewAction(HttpServletRequest request, HttpServletResponse response,
            BorrowingStatistics stats, String start, String end)
            throws ServletException, IOException {

        request.setAttribute("stats", stats);
        request.setAttribute("startDate", start);
        request.setAttribute("endDate", end);

        request.getRequestDispatcher("/WEB-INF/views/admin/borrowingStatistics.jsp").forward(request, response);
    }

    private void handleExportAction(HttpServletResponse response, BorrowingStatistics stats,
            String start, String end) throws IOException {

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"));
        String fileName = "Bao_Cao_Thu_Vien_" + timestamp + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        statsService.exportToExcel(stats, start, end, response.getOutputStream());
    }

    private boolean isInvalidDateRange(String start, String end) {
        boolean startOk = (start == null || start.isEmpty() || statsService.isValidDate(start));
        boolean endOk = (end == null || end.isEmpty() || statsService.isValidDate(end));
        return !(startOk && endOk);
    }

    @Override
    public String getServletInfo() {
        return "Controller xử lý thống kê mượn trả và xuất báo cáo Excel";
    }
}