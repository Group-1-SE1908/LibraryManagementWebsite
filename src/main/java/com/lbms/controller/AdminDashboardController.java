package com.lbms.controller;

import com.lbms.dao.DashboardDAO;
import com.lbms.model.DashboardModel;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

@WebServlet(urlPatterns = { "/admin", "/admin/dashboard" })
public class AdminDashboardController extends HttpServlet {
    private DashboardDAO dashboardDAO;

    @Override
    public void init() throws ServletException {
        dashboardDAO = new DashboardDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startParam = request.getParameter("startDate");
        String endParam = request.getParameter("endDate");
        String action = request.getParameter("action");
        if (startParam != null && startParam.trim().isEmpty())
            startParam = null;

        if (startParam != null && startParam.trim().isEmpty())
            startParam = null;
        if (endParam != null && endParam.trim().isEmpty())
            endParam = null;

        if ((startParam != null && !isValidDate(startParam)) ||
                (endParam != null && !isValidDate(endParam))) {

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        LocalDate today = LocalDate.now();

        LocalDate startDate = null;
        LocalDate endDate = null;

        if (startParam != null)
            startDate = LocalDate.parse(startParam);
        if (endParam != null)
            endDate = LocalDate.parse(endParam);

        if ((startDate != null && startDate.isAfter(today)) ||
                (endDate != null && endDate.isAfter(today))) {

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        if (startDate != null && endDate != null && startDate.isAfter(endDate)) {

            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            DashboardModel ds = dashboardDAO.getDashboardData(startParam, endParam, 10);

            if ("export".equals(action)) {
                handleExportExcel(response, ds, startParam, endParam);
                return;
            }

            request.setAttribute("dashboardData", ds);
            request.setAttribute("startDate", startParam);
            request.setAttribute("endDate", endParam);
            request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    private void handleExportExcel(HttpServletResponse response, DashboardModel ds, String start, String end)
            throws IOException {
        String filename = "Library_Report_" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"))
                + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=" + filename);

        try (Workbook workbook = new XSSFWorkbook()) {

            CellStyle headerStyle = createStyle(workbook, IndexedColors.INDIGO.getIndex(), true,
                    HorizontalAlignment.CENTER);
            CellStyle dataStyle = createStyle(workbook, null, false, HorizontalAlignment.LEFT);
            CellStyle currencyStyle = createStyle(workbook, null, false, HorizontalAlignment.RIGHT);
            currencyStyle.setDataFormat(workbook.createDataFormat().getFormat("#,##0\" ₫\""));

            CellStyle titleStyle = workbook.createCellStyle();
            Font tFont = workbook.createFont();
            tFont.setBold(true);
            tFont.setFontHeightInPoints((short) 16);
            titleStyle.setFont(tFont);

            Sheet sheet1 = workbook.createSheet("Tổng quan");

            Row r0 = sheet1.createRow(0);
            createCell(r0, 0, "BÁO CÁO CHỈ SỐ HỆ THỐNG", titleStyle);

            String filterText = "Khoảng thời gian: " + (start == null ? "Tất cả" : start) + " đến "
                    + (end == null ? "Hiện tại" : end);
            sheet1.createRow(1).createCell(0).setCellValue(filterText);
            sheet1.createRow(2).createCell(0).setCellValue(
                    "Ngày xuất: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));

            int currentRow = 4;
            Row kpiH = sheet1.createRow(currentRow++);
            createCell(kpiH, 0, "HẠNG MỤC THỐNG KÊ", headerStyle);
            createCell(kpiH, 1, "GIÁ TRỊ", headerStyle);

            Object[][] kpis = {
                    { "Tổng số đầu sách", (double) ds.getTotalBooks() },
                    { "Bạn đọc hoạt động (Active)", (double) ds.getActiveUsers() },
                    { "Sách đang trong hạn mượn", (double) ds.getPendingReturns() },
                    { "Sách đã quá hạn trả", (double) ds.getOverdueBooks() },
                    { "Tổng tiền phạt đã thu", ds.getFinesCollected() },
                    { "Tổng tiền phạt còn nợ", ds.getFinesPending() }
            };

            for (int i = 0; i < kpis.length; i++) {
                Row r = sheet1.createRow(currentRow++);
                createCell(r, 0, kpis[i][0].toString(), dataStyle);
                Cell cVal = r.createCell(1);
                cVal.setCellValue((Double) kpis[i][1]);
                cVal.setCellStyle(i >= 4 ? currencyStyle : dataStyle);
            }

            sheet1.autoSizeColumn(0);
            sheet1.setColumnWidth(1, 5000);

            Sheet sheet2 = workbook.createSheet("Top Thành viên");

            Row uTitleRow = sheet2.createRow(0);
            createCell(uTitleRow, 0, "DANH SÁCH THÀNH VIÊN MƯỢN SÁCH NHIỀU NHẤT", titleStyle);

            Row uH = sheet2.createRow(2);
            String[] uHeaders = { "STT", "Họ và tên", "Email liên hệ", "Số điện thoại", "Tổng lượt mượn" };
            for (int i = 0; i < uHeaders.length; i++) {
                createCell(uH, i, uHeaders[i], headerStyle);
            }

            int uIdx = 3;
            int stt = 1;
            for (DashboardModel.TopUser u : ds.getTopUsers()) {
                Row r = sheet2.createRow(uIdx++);
                createCell(r, 0, String.valueOf(stt++), dataStyle);
                createCell(r, 1, u.getFullName(), dataStyle);
                createCell(r, 2, u.getEmail(), dataStyle);
                createCell(r, 3, u.getPhone(), dataStyle);
                Cell c4 = r.createCell(4);
                c4.setCellValue(u.getTotalBorrows());
                c4.setCellStyle(dataStyle);
            }

            sheet2.setColumnWidth(0, 1500);
            for (int i = 1; i <= 4; i++) {
                sheet2.autoSizeColumn(i);
            }

            workbook.write(response.getOutputStream());
        }
    }

    private CellStyle createStyle(Workbook wb, Short bg, boolean bold, HorizontalAlignment align) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(bold);
        if (bg != null) {
            style.setFillForegroundColor(bg);
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            font.setColor(IndexedColors.WHITE.getIndex());
        }
        style.setFont(font);
        style.setAlignment(align);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        return style;
    }

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        if (style != null)
            cell.setCellStyle(style);
    }

    private boolean isValidDate(String dateStr) {
        try {
            LocalDate.parse(dateStr);
            return true;
        } catch (DateTimeParseException | NullPointerException e) {
            return false;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}