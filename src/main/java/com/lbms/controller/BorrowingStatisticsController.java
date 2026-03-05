package com.lbms.controller;

import com.lbms.dao.BorrowingStatisticsDAO;
import com.lbms.model.BorrowingStatistics;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "BorrowingStatisticsController", urlPatterns = { "/admin/statistics" })
public class BorrowingStatisticsController extends HttpServlet {

    private BorrowingStatisticsDAO statsDAO;

    @Override
    public void init() throws ServletException {
        statsDAO = new BorrowingStatisticsDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String startParam = request.getParameter("startDate");
        String endParam = request.getParameter("endDate");
        String action = request.getParameter("action");

        boolean isStartInvalid = (startParam != null && !startParam.isEmpty() && !isValidDate(startParam));
        boolean isEndInvalid = (endParam != null && !endParam.isEmpty() && !isValidDate(endParam));

        if (isStartInvalid || isEndInvalid) {
            response.sendRedirect(request.getContextPath() + "/admin/statistics");
            return;
        }

        String startDate = (startParam != null && !startParam.isEmpty()) ? startParam : null;
        String endDate = (endParam != null && !endParam.isEmpty()) ? endParam : null;

        try {

            BorrowingStatistics stats = statsDAO.getStatistics(startDate, endDate);

            if ("export".equals(action)) {
                handleExcelExport(response, stats, startDate, endDate);

            } else {

                request.setAttribute("stats", stats);
                request.setAttribute("startDate", startDate);
                request.setAttribute("endDate", endDate);
                request.getRequestDispatcher("/WEB-INF/views/admin/borrowingStatistics.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();

            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi xử lý dữ liệu: " + e.getMessage());
        }
    }

    private boolean isValidDate(String dateStr) {
        try {
            LocalDate.parse(dateStr);
            return true;
        } catch (DateTimeParseException | NullPointerException e) {
            return false;
        }
    }

    private void handleExcelExport(HttpServletResponse response, BorrowingStatistics stats, String start, String end)
            throws IOException {

        String fileName = "Bao_Cao_Thu_Vien_"
                + java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd_HHmm"))
                + ".xlsx";
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

        try (Workbook workbook = new XSSFWorkbook()) {

            CellStyle headerStyle = workbook.createCellStyle();
            Font hFont = workbook.createFont();
            hFont.setBold(true);
            hFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(hFont);
            headerStyle.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            applyBorder(headerStyle);

            CellStyle dataStyle = workbook.createCellStyle();
            applyBorder(dataStyle);

            CellStyle titleStyle = workbook.createCellStyle();
            Font tFont = workbook.createFont();
            tFont.setBold(true);
            tFont.setFontHeightInPoints((short) 16);
            titleStyle.setFont(tFont);

            CellStyle dateStyle = workbook.createCellStyle();
            dateStyle.cloneStyleFrom(dataStyle);
            dateStyle.setDataFormat(workbook.createDataFormat().getFormat("dd/MM/yyyy"));
            dateStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle currencyStyle = workbook.createCellStyle();
            currencyStyle.cloneStyleFrom(dataStyle);
            currencyStyle.setDataFormat(workbook.createDataFormat().getFormat("#,##0\" ₫\""));
            currencyStyle.setAlignment(HorizontalAlignment.RIGHT);

            String filterTime = "Khoảng thời gian: " + (start != null ? "Từ " + start : "")
                    + (end != null ? " Đến " + end : (start == null ? "Tất cả" : " nay"));
            String exportTime = "Ngày xuất báo cáo: " + java.time.LocalDateTime.now()
                    .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

            Sheet sheet1 = workbook.createSheet("Tổng quan");
            createCell(sheet1.createRow(0), 0, "BÁO CÁO THỐNG KÊ TỔNG QUAN", titleStyle);
            sheet1.createRow(1).createCell(0).setCellValue(filterTime);
            sheet1.createRow(2).createCell(0).setCellValue(exportTime);

            Row kpiH = sheet1.createRow(4);
            createCell(kpiH, 0, "Hạng mục", headerStyle);
            createCell(kpiH, 1, "Số liệu", headerStyle);

            Object[][] kpiData = {
                    { "Tổng số sách", stats.getTotalBooks() },
                    { "Người dùng hoạt động", stats.getActiveUsers() },
                    { "Tổng lượt mượn", stats.getTotalBorrows() },
                    { "Sách quá hạn", stats.getOverdueBooks() }
            };

            for (int i = 0; i < kpiData.length; i++) {
                Row r = sheet1.createRow(5 + i);
                createCell(r, 0, kpiData[i][0].toString(), dataStyle);
                Cell v = r.createCell(1);
                v.setCellValue(Double.parseDouble(kpiData[i][1].toString()));
                v.setCellStyle(dataStyle);
            }

            Sheet sheet2 = workbook.createSheet("Dữ liệu chi tiết");

            createCell(sheet2.createRow(0), 0, "DANH SÁCH CHI TIẾT MƯỢN TRẢ SÁCH", titleStyle);
            sheet2.createRow(1).createCell(0).setCellValue(filterTime);
            sheet2.createRow(2).createCell(0).setCellValue(exportTime);

            sheet2.createFreezePane(0, 5);

            String[] headers = { "STT", "Mã Đơn", "Thành viên", "Email", "Tên Sách", "Ngày Mượn", "Hạn Trả",
                    "Ngày Trả Thực", "Trạng Thái", "Tiền Phạt" };
            Row hRow = sheet2.createRow(4);
            for (int i = 0; i < headers.length; i++) {
                createCell(hRow, i, headers[i], headerStyle);
            }

            int dIdx = 5;
            List<BorrowingStatistics.BorrowingDetail> details = stats.getDetailedRecords();
            if (details != null) {
                for (BorrowingStatistics.BorrowingDetail d : details) {
                    Row r = sheet2.createRow(dIdx++);
                    createCell(r, 0, String.valueOf(dIdx - 5), dataStyle);
                    createCell(r, 1, "#" + d.getOrderId(), dataStyle);
                    createCell(r, 2, d.getBorrowerName(), dataStyle);
                    createCell(r, 3, d.getEmail() != null ? d.getEmail() : "-", dataStyle);
                    createCell(r, 4, d.getBookTitle(), dataStyle);

                    Cell c5 = r.createCell(5);
                    c5.setCellValue(d.getBorrowDate());
                    c5.setCellStyle(dateStyle);
                    Cell c6 = r.createCell(6);
                    c6.setCellValue(d.getDueDate());
                    c6.setCellStyle(dateStyle);

                    Cell c7 = r.createCell(7);
                    if (d.getReturnDate() != null) {
                        c7.setCellValue(d.getReturnDate());
                        c7.setCellStyle(dateStyle);
                    } else {
                        c7.setCellValue("-");
                        c7.setCellStyle(dataStyle);
                    }

                    createCell(r, 8, d.getStatus(), dataStyle);

                    Cell c9 = r.createCell(9);
                    Object fine = d.getFineAmount();
                    c9.setCellValue(fine instanceof Number ? ((Number) fine).doubleValue() : 0.0);
                    c9.setCellStyle(currencyStyle);
                }
            }

            if (dIdx > 5) {

                sheet2.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(4, dIdx - 1, 0, headers.length - 1));
            }

            sheet2.setColumnWidth(0, 1500);
            for (int i = 1; i < headers.length; i++) {
                sheet2.autoSizeColumn(i);
                sheet2.setColumnWidth(i, sheet2.getColumnWidth(i) + 1200);
            }

            workbook.write(response.getOutputStream());
        }
    }

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private void applyBorder(CellStyle style) {
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
    }
}