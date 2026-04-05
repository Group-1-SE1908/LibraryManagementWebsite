package com.lbms.service;

import com.lbms.dao.DashboardDAO;
import com.lbms.model.DashboardSummary;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public class DashboardService {

    private final DashboardDAO dashboardDAO = new DashboardDAO();

    public DashboardSummary getDashboardData(String start, String end) throws SQLException {

        return dashboardDAO.getDashboardData(start, end, 10);
    }

    public boolean validateDates(String start, String end) {
        try {
            LocalDate today = LocalDate.now();
            LocalDate startDate = (start != null && !start.isEmpty()) ? LocalDate.parse(start) : null;
            LocalDate endDate = (end != null && !end.isEmpty()) ? LocalDate.parse(end) : null;

            if (startDate != null && startDate.isAfter(today))
                return false;
            if (endDate != null && endDate.isAfter(today))
                return false;
            if (startDate != null && endDate != null && startDate.isAfter(endDate))
                return false;

            return true;
        } catch (DateTimeParseException e) {
            return false;
        }
    }

    public void exportDashboardToExcel(DashboardSummary ds, String start, String end, OutputStream out)
            throws IOException {
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

            fillOverviewSheet(workbook, ds, start, end, titleStyle, headerStyle, dataStyle, currencyStyle);

            fillTopUsersSheet(workbook, ds, titleStyle, headerStyle, dataStyle);

            workbook.write(out);
        }
    }

    private void fillOverviewSheet(Workbook wb, DashboardSummary ds, String start, String end,
            CellStyle titleS, CellStyle headS, CellStyle dataS, CellStyle currS) {
        Sheet sheet = wb.createSheet("Tổng quan");

        Row r0 = sheet.createRow(0);
        createCell(r0, 0, "BÁO CÁO CHỈ SỐ HỆ THỐNG", titleS);

        String filterText = "Khoảng thời gian: " + (start == null ? "Tất cả" : start) + " đến "
                + (end == null ? "Hiện tại" : end);
        sheet.createRow(1).createCell(0).setCellValue(filterText);
        sheet.createRow(2).createCell(0).setCellValue(
                "Ngày xuất: " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));

        Object[][] kpis = {
                { "Tổng số đầu sách", (double) ds.getTotalBooks() },
                { "Bạn đọc hoạt động (Active)", (double) ds.getActiveUsers() },
                { "Sách đang trong hạn mượn", (double) ds.getPendingReturns() },
                { "Sách đã quá hạn trả", (double) ds.getOverdueBooks() },
                { "Tổng tiền phạt đã thu", ds.getFinesCollected() },
                { "Tổng tiền phạt còn nợ", ds.getFinesPending() }
        };

        int rowIdx = 4;
        Row kpiH = sheet.createRow(rowIdx++);
        createCell(kpiH, 0, "HẠNG MỤC THỐNG KÊ", headS);
        createCell(kpiH, 1, "GIÁ TRỊ", headS);

        for (int i = 0; i < kpis.length; i++) {
            Row r = sheet.createRow(rowIdx++);
            createCell(r, 0, kpis[i][0].toString(), dataS);
            Cell cVal = r.createCell(1);
            cVal.setCellValue((Double) kpis[i][1]);
            cVal.setCellStyle(i >= 4 ? currS : dataS);
        }

        sheet.autoSizeColumn(0);
        sheet.setColumnWidth(1, 5000);
    }

    private void fillTopUsersSheet(Workbook wb, DashboardSummary ds, CellStyle titleS, CellStyle headS,
            CellStyle dataS) {
        Sheet sheet = wb.createSheet("Top Thành viên");
        Row r0 = sheet.createRow(0);
        createCell(r0, 0, "DANH SÁCH THÀNH VIÊN MƯỢN SÁCH NHIỀU NHẤT", titleS);

        String[] headers = { "STT", "Họ và tên", "Email liên hệ", "Số điện thoại", "Tổng lượt mượn" };
        Row headRow = sheet.createRow(2);
        for (int i = 0; i < headers.length; i++)
            createCell(headRow, i, headers[i], headS);

        int rowIdx = 3;
        int stt = 1;
        for (DashboardSummary.TopUser u : ds.getTopUsers()) {
            Row r = sheet.createRow(rowIdx++);
            createCell(r, 0, String.valueOf(stt++), dataS);
            createCell(r, 1, u.getFullName(), dataS);
            createCell(r, 2, u.getEmail(), dataS);
            createCell(r, 3, u.getPhone(), dataS);
            Cell c4 = r.createCell(4);
            c4.setCellValue(u.getTotalBorrows());
            c4.setCellStyle(dataS);
        }

        sheet.setColumnWidth(0, 1500);
        for (int i = 1; i <= 4; i++)
            sheet.autoSizeColumn(i);
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
        applyBorders(style);
        return style;
    }

    private void applyBorders(CellStyle style) {
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
    }

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        if (style != null)
            cell.setCellStyle(style);
    }
}