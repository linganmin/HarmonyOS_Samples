/*
 * Copyright 2024. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 */

package com.huawei.iap.server.demo;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.KeyFactory;
import java.security.interfaces.ECPrivateKey;
import java.security.spec.PKCS8EncodedKeySpec;
import java.time.Duration;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.codec.digest.DigestUtils;

/**
 * JWTGenerator
 *
 * @author iap
 * @since 2024-09-26
 */
public class JWTGenerator {

    /**
     * Private key file path.
     */
    private static final String JWT_PRI_KEY_PATH = "/path/to/key/priKey.p8"; // TODO: Need to replace it with the actual value.

    /**
     * JWT validity period, which is a UTC timestamp in seconds. The validity period cannot exceed 1 hour.
     */
    private static final long ACTIVE_TIME_SECOND = 3600;  // TODO: Need to replace it with the actual value.

    private static final Map<String, Object> JWT_HEADER = new HashMap<>();

    private static final Map<String, Object> JWT_PAYLOAD = new HashMap<>();

    static {
        // Algorithm type. The value is always ES256.
        JWT_HEADER.put("alg", "ES256");
        // Token type. The value is always JWT.
        JWT_HEADER.put("typ", "JWT");
        // Key ID.
        JWT_HEADER.put("kid", "Key ID");  // TODO: Need to replace it with the actual value.

        // Key issuer ID.
        JWT_PAYLOAD.put("iss", "Issuer ID");  // TODO: Need to replace it with the actual value.
        // Expected receiver of the JWT. The value is fixed at iap-v1.
        JWT_PAYLOAD.put("aud", "iap-v1");
        // Time when the JWT is issued. The value is a UTC timestamp, in seconds.
        // Re-put the value in the genJwt method.
        JWT_PAYLOAD.put("iat", 0);
        // Time when the JWT expires. The value is a UTC timestamp, in seconds. exp-iat indicates the validity period of the JWT, which cannot exceed one hour.
        // Re-put the value in the genJwt method.
        JWT_PAYLOAD.put("exp", 0);
        // App ID.
        JWT_PAYLOAD.put("aid", "App ID");  // TODO: Need to replace it with the actual value.
        // Hash value of the request body (JSON character string), which is used to verify the integrity of the body. The algorithm is SHA-256.
        JWT_PAYLOAD.put("digest", "");
    }

    public static String genJwt(String bodyStr) throws Exception {
        try {
            // Fetch the Private Key Content in PEM format.
            Path filePath = Paths.get(JWT_PRI_KEY_PATH);
            String fileString = new String(Files.readAllBytes(filePath), StandardCharsets.UTF_8);
            String privateKey = fileString.replace("-----BEGIN PRIVATE KEY-----", "")
                .replaceAll("\\R+", "")
                .replace("-----END PRIVATE KEY-----", "");

            KeyFactory keyFactory = KeyFactory.getInstance("EC");
            byte[] privateKeyBytes = Base64.getDecoder().decode(privateKey);
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(privateKeyBytes);
            ECPrivateKey ecPrivateKey = (ECPrivateKey) keyFactory.generatePrivate(keySpec);

            Map<String, Object> jwtPayload = new HashMap<>(JWT_PAYLOAD);
            long signTime = System.currentTimeMillis() / Duration.ofSeconds(1).toMillis();
            String digest = DigestUtils.sha256Hex(bodyStr);
            jwtPayload.put("iat", signTime);
            jwtPayload.put("exp", signTime + ACTIVE_TIME_SECOND);
            jwtPayload.put("digest", digest);

            return JWT.create().withHeader(JWT_HEADER).withPayload(jwtPayload).sign(Algorithm.ECDSA256(ecPrivateKey));
        } catch (Exception e) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception(e);
        }
    }

}
