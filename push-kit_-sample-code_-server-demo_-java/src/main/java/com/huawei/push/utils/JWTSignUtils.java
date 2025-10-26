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

package com.huawei.push.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.huawei.push.model.auth.ServiceAccount;
import io.jsonwebtoken.*;
import io.jsonwebtoken.lang.Maps;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.interfaces.RSAPrivateKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;
import java.util.Map;

/**
 * Help sign JWT.
 */
public class JWTSignUtils {
    private static final String KEY_PREFIX = "-----BEGIN PRIVATE KEY-----\n";
    private static final String KEY_SUFFIX = "\n-----END PRIVATE KEY-----\n";

    public static String sign(ServiceAccount serviceAccount, long iat, long exp) throws NoSuchAlgorithmException, InvalidKeySpecException, JsonProcessingException {
        String rawKeyStr = serviceAccount.getPrivateKey();
        String pureKeyStr = rawKeyStr.substring(KEY_PREFIX.length(), rawKeyStr.length() - KEY_SUFFIX.length());
        RSAPrivateKey privateKey = (RSAPrivateKey) generatePrivateKey(pureKeyStr);

        Map<String, Object> header = Maps.<String, Object>of(JwsHeader.KEY_ID, serviceAccount.getKeyId())
                .and(JwsHeader.TYPE, JwsHeader.JWT_TYPE)
                .and(JwsHeader.ALGORITHM, SignatureAlgorithm.PS256.getValue())
                .build();

        Map<String, Object> payload = Maps.<String, Object>of(Claims.ISSUER, serviceAccount.getSubAccount())
                .and(Claims.ISSUED_AT, iat)
                .and(Claims.EXPIRATION, exp)
                .and(Claims.AUDIENCE, serviceAccount.getTokenURI())
                .build();
        return Jwts.builder()
                .setHeader(header)
                .setPayload(new ObjectMapper().writeValueAsString(payload))
                .signWith(privateKey, SignatureAlgorithm.PS256)
                .compact();
    }

    private static PrivateKey generatePrivateKey(String base64Key) throws NoSuchAlgorithmException, InvalidKeySpecException {
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(Base64.getDecoder().decode(base64Key.getBytes(StandardCharsets.UTF_8)));
        KeyFactory keyFactory = KeyFactory.getInstance("RSA");
        return keyFactory.generatePrivate(keySpec);
    }
}