package com.lbms.config;

import org.mindrot.jbcrypt.BCrypt;

public class TestHash {
    public static void main(String[] args) {
        String hash = BCrypt.hashpw("123456", BCrypt.gensalt(10));
        System.out.println(hash);
    }
}