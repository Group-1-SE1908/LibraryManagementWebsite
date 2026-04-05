package com.lbms.controller;

import com.lbms.model.DashboardSummary;
import com.lbms.service.DashboardService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@WebServlet(urlPatterns = { "/admin", "/admin/dashboard" })
public class AdminDashboardController extends HttpServlet {

    private DashboardService dashboardService;

    @Override
    public void init() throws ServletException {

        dashboardService = new DashboardService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startParam = request.getParameter("startDate");
        String endParam = request.getParameter("endDate");
        String action = request.getParameter("action");

        if (startParam != null && startParam.trim().isEmpty())
            startParam = null;
        if (endParam != null && endParam.trim().isEmpty())
            endParam = null;

        if (!dashboardService.validateDates(startParam, endParam)) {

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        try {

            DashboardSummary ds = dashboardService.getDashboardData(startParam, endParam);

            if ("export".equals(action)) {
                handleExcelExport(response, ds, startParam, endParam);
            } else {
                handleDisplayDashboard(request, response, ds, startParam, endParam);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi xử lý Dashboard: " + e.getMessage());
        }
    }

    private void handleExcelExport(HttpServletResponse response, DashboardSummary ds, String start, String end)
            throws IOException {

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"));
        String filename = "Library_Report_" + timestamp + ".xlsx";

        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=" + filename);

        dashboardService.exportDashboardToExcel(ds, start, end, response.getOutputStream());
    }

    private void handleDisplayDashboard(HttpServletRequest request, HttpServletResponse response,
            DashboardSummary ds, String start, String end)
            throws ServletException, IOException {

        request.setAttribute("dashboardData", ds);
        request.setAttribute("startDate", start);
        request.setAttribute("endDate", end);

        request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response);
    }
}