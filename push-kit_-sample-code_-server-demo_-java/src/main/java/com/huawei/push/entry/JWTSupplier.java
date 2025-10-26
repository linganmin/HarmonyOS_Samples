/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.huawei.push.entry;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.huawei.push.model.auth.ServiceAccount;
import com.huawei.push.utils.JWTSignUtils;

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
