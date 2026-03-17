package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.dao.WalletTransactionDAO;
import com.lbms.model.User;
import com.lbms.model.WalletTransaction;

import java.math.BigDecimal;
import java.sql.SQLException;

public class WalletService {

    public static final String TXN_REF_PREFIX = "WALLET-";
    public static final String SESSION_KEY_PREFIX = "walletTopUp-";
    public static final String TRANSACTION_TYPE_TOPUP = "TOPUP";
    private static final int DEFAULT_HISTORY_LIMIT = 6;

    private final UserDAO userDAO;
    private final WalletTransactionDAO transactionDAO;

    public WalletService() {
        this.userDAO = new UserDAO();
        this.transactionDAO = new WalletTransactionDAO();
    }

    public User refreshUser(long userId) throws SQLException {
        return userDAO.findById(userId);
    }

    public void creditWallet(long userId, BigDecimal amount, String source, String description, String reference)
            throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be greater than zero.");
        }
        userDAO.addToWallet(userId, amount);
        WalletTransaction transaction = new WalletTransaction();
        transaction.setUserId(userId);
        transaction.setAmount(amount);
        transaction.setType(TRANSACTION_TYPE_TOPUP);
        transaction.setSource(source != null ? source : "LBMS Wallet");
        transaction.setDescription(description);
        transaction.setReference(reference);
        transactionDAO.save(transaction);
    }

    public java.util.List<WalletTransaction> getRecentTransactions(long userId) throws SQLException {
        return transactionDAO.findRecentForUser(userId, DEFAULT_HISTORY_LIMIT);
    }
}
