package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;

import java.math.BigDecimal;
import java.sql.SQLException;

public class WalletService {

    public static final String TXN_REF_PREFIX = "WALLET-";
    public static final String SESSION_KEY_PREFIX = "walletTopUp-";

    private final UserDAO userDAO;

    public WalletService() {
        this.userDAO = new UserDAO();
    }

    public User refreshUser(long userId) throws SQLException {
        return userDAO.findById(userId);
    }

    public void creditWallet(long userId, BigDecimal amount) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be greater than zero.");
        }
        userDAO.addToWallet(userId, amount);
    }
}
