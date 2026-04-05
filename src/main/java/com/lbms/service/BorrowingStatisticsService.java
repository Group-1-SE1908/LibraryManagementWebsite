package com.lbms.service;

import com.lbms.dao.BorrowingStatisticsDAO;
import com.lbms.model.BorrowingStatistics;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.List;

public class BorrowingStatisticsService {

    private final BorrowingStatisticsDAO statsDAO = new BorrowingStatisticsDAO();

    public BorrowingStatistics getStatistics(String startDate, String endDate) throws SQLException {
        return statsDAO.getStatistics(startDate, endDate);
    }

    public boolean isValidDate(String dateStr) {
        if (dateStr == null || dateStr.isEmpty())
            return false;
        try {
            LocalDate.parse(dateStr);
            return true;
        } catch (DateTimeParseException e) {
            return false;
        }
    }

    public void exportToExcel(BorrowingStatistics stats, String start, String end, OutputStream outputStream)
            throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle dataStyle = createDataStyle(workbook);
            CellStyle titleStyle = createTitleStyle(workbook);
            CellStyle dateStyle = createDateStyle(workbook, dataStyle);
            CellStyle currencyStyle = createCurrencyStyle(workbook, dataStyle);

            String filterTime = "Khoảng thời gian: " + (start != null ? "Từ " + start : "")
                    + (end != null ? " Đến " + end : (start == null ? "Tất cả" : " nay"));
            String exportTime = "Ngày xuất báo cáo: "
                    + LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

            Sheet sheet1 = workbook.createSheet("Tổng quan");
            fillOverviewSheet(sheet1, stats, filterTime, exportTime, titleStyle, headerStyle, dataStyle);

            Sheet sheet2 = workbook.createSheet("Dữ liệu chi tiết");
            fillDetailSheet(sheet2, stats, filterTime, exportTime, titleStyle, headerStyle, dataStyle, dateStyle,
                    currencyStyle);

            workbook.write(outputStream);
        }
    }

    private void fillOverviewSheet(Sheet sheet, BorrowingStatistics stats, String filter, String export,
            CellStyle titleS, CellStyle headS, CellStyle dataS) {
        Row titleRow = sheet.createRow(0);
        createCell(titleRow, 0, "BÁO CÁO THỐNG KÊ TỔNG QUAN", titleS);
        sheet.createRow(1).createCell(0).setCellValue(filter);
        sheet.createRow(2).createCell(0).setCellValue(export);

        Row kpiH = sheet.createRow(4);
        createCell(kpiH, 0, "Hạng mục", headS);
        createCell(kpiH, 1, "Số liệu", headS);

        Object[][] kpiData = {
                { "Tổng số sách", stats.getTotalBooks() },
                { "Người dùng hoạt động", stats.getActiveUsers() },
                { "Tổng lượt mượn", stats.getTotalBorrows() },
                { "Sách quá hạn", stats.getOverdueBooks() }
        };

        for (int i = 0; i < kpiData.length; i++) {
            Row r = sheet.createRow(5 + i);
            createCell(r, 0, kpiData[i][0].toString(), dataS);
            Cell v = r.createCell(1);
            v.setCellValue(Double.parseDouble(kpiData[i][1].toString()));
            v.setCellStyle(dataS);
        }
        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);
    }

    private void fillDetailSheet(Sheet sheet, BorrowingStatistics stats, String filter, String export,
            CellStyle titleS, CellStyle headS, CellStyle dataS, CellStyle dateS, CellStyle currS) {
        createCell(sheet.createRow(0), 0, "DANH SÁCH CHI TIẾT MƯỢN TRẢ SÁCH", titleS);
        sheet.createRow(1).createCell(0).setCellValue(filter);
        sheet.createRow(2).createCell(0).setCellValue(export);
        sheet.createFreezePane(0, 5);

        String[] headers = { "STT", "Mã Đơn", "Thành viên", "Email", "Tên Sách", "Ngày Mượn", "Hạn Trả",
                "Ngày Trả Thực", "Trạng Thái", "Tiền Phạt" };
        Row hRow = sheet.createRow(4);
        for (int i = 0; i < headers.length; i++)
            createCell(hRow, i, headers[i], headS);

        int rowIdx = 5;
        List<BorrowingStatistics.BorrowingDetail> details = stats.getDetailedRecords();
        if (details != null) {
            for (BorrowingStatistics.BorrowingDetail d : details) {
                Row r = sheet.createRow(rowIdx++);
                createCell(r, 0, String.valueOf(rowIdx - 5), dataS);
                createCell(r, 1, "#" + d.getOrderId(), dataS);
                createCell(r, 2, d.getBorrowerName(), dataS);
                createCell(r, 3, d.getEmail() != null ? d.getEmail() : "-", dataS);
                createCell(r, 4, d.getBookTitle(), dataS);

                writeDateCell(r, 5, d.getBorrowDate(), dateS, dataS);
                writeDateCell(r, 6, d.getDueDate(), dateS, dataS);
                writeDateCell(r, 7, d.getReturnDate(), dateS, dataS);

                createCell(r, 8, d.getStatus(), dataS);
                Cell c9 = r.createCell(9);
                c9.setCellValue(d.getFineAmount());
                c9.setCellStyle(currS);
            }
            sheet.setAutoFilter(new org.apache.poi.ss.util.CellRangeAddress(4, rowIdx - 1, 0, headers.length - 1));
        }

        for (int i = 0; i < headers.length; i++) {
            sheet.autoSizeColumn(i);
            sheet.setColumnWidth(i, sheet.getColumnWidth(i) + 1000);
        }
    }

    private void writeDateCell(Row row, int col, String dateStr, CellStyle dateStyle, CellStyle fallbackStyle) {
        Cell cell = row.createCell(col);
        if (dateStr != null && !dateStr.isEmpty() && !dateStr.equals("-")) {
            try {

                LocalDate ld = LocalDate.parse(dateStr);
                cell.setCellValue(Date.from(ld.atStartOfDay(ZoneId.systemDefault()).toInstant()));
                cell.setCellStyle(dateStyle);
            } catch (Exception e) {
                cell.setCellValue(dateStr);
                cell.setCellStyle(fallbackStyle);
            }
        } else {
            cell.setCellValue("-");
            cell.setCellStyle(fallbackStyle);
        }
    }

    private void createCell(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private CellStyle createHeaderStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setColor(IndexedColors.WHITE.getIndex());
        s.setFont(f);
        s.setFillForegroundColor(IndexedColors.INDIGO.getIndex());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setAlignment(HorizontalAlignment.CENTER);
        applyBorders(s);
        return s;
    }

    private CellStyle createDataStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        applyBorders(s);
        return s;
    }

    private CellStyle createTitleStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 16);
        s.setFont(f);
        return s;
    }

    private CellStyle createDateStyle(Workbook wb, CellStyle base) {
        CellStyle s = wb.createCellStyle();
        s.cloneStyleFrom(base);
        s.setDataFormat(wb.createDataFormat().getFormat("dd/MM/yyyy"));
        s.setAlignment(HorizontalAlignment.CENTER);
        return s;
    }

    private CellStyle createCurrencyStyle(Workbook wb, CellStyle base) {
        CellStyle s = wb.createCellStyle();
        s.cloneStyleFrom(base);
        s.setDataFormat(wb.createDataFormat().getFormat("#,##0\" ₫\""));
        s.setAlignment(HorizontalAlignment.RIGHT);
        return s;
    }

    private void applyBorders(CellStyle s) {
        s.setBorderTop(BorderStyle.THIN);
        s.setBorderBottom(BorderStyle.THIN);
        s.setBorderLeft(BorderStyle.THIN);
        s.setBorderRight(BorderStyle.THIN);
    }
}