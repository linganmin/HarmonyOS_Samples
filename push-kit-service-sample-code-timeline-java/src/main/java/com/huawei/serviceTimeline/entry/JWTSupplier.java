/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.entry;

import com.huawei.serviceTimeline.model.auth.ServiceAccount;
import com.huawei.serviceTimeline.utils.JWTSignUtils;

import com.fasterxml.jackson.core.JsonProcessingException;

import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.time.Duration;

/**
 * JWT supplier.
 */
public class JWTSupplier {
    private static final Duration TOLERANCE = Duration.ofSeconds(10);
    private final ServiceAccount serviceAccount;
    private final Duration validityPeriod;
    private volatile String token;
    private volatile long expireTimeOfSecond = -1;

    public JWTSupplier(ServiceAccount serviceAccount, Duration validityPeriod) {
        this.serviceAccount = serviceAccount;
        this.validityPeriod = validityPeriod;
    }

    public String get() throws NoSuchAlgorithmException, InvalidKeySpecException, JsonProcessingException {
        if (isInvalid()) {
            synchronized (this) {
                if (isInvalid()) {
                    long iat = System.currentTimeMillis() / 1000;
                    long exp = iat + validityPeriod.getSeconds();
                    this.token = JWTSignUtils.sign(serviceAccount, iat, exp);
                    this.expireTimeOfSecond = exp;
                }
            }
        }
        return this.token;
    }

    private boolean isInvalid() {
        long current = System.currentTimeMillis() / 1000;
        return expireTimeOfSecond == -1 || current >= expireTimeOfSecond || expireTimeOfSecond - current < TOLERANCE.getSeconds();
    }
}
