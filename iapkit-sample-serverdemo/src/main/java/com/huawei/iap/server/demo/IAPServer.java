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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

/**
 * IAPServer
 *
 * @author iap
 * @since 2024-09-26
 */
public class IAPServer {

    /**
     * IAP Server Root Url
     */
    public static final String URL_ROOT = "https://iap.cloud.huawei.com";

    private static final int CONNECT_TIMEOUT = 5000; // TODO: Need to replace it with the actual business logic.

    private static final int READ_TIMEOUT = 5000; // TODO: Need to replace it with the actual business logic.

    private static final String WHITE_SPACE = " ";

    public static String httpPost(String httpUrl, String jsonData) throws Exception {
        HttpURLConnection urlConnection = (HttpURLConnection) new URL(httpUrl).openConnection();
        urlConnection.setRequestMethod("POST");
        urlConnection.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        String jwt = JWTGenerator.genJwt(jsonData);
        urlConnection.setRequestProperty("Authorization", "Bearer" + WHITE_SPACE + jwt);
        urlConnection.setDoOutput(true);
        urlConnection.setDoInput(true);
        urlConnection.setConnectTimeout(CONNECT_TIMEOUT);
        urlConnection.setReadTimeout(READ_TIMEOUT);

        // TODO: Under Java 8, need to close the resource in the finally block.
        try (OutputStream output = urlConnection.getOutputStream()) {
            output.write(jsonData.getBytes(StandardCharsets.UTF_8));
            output.flush();
        }

        int responseCode = urlConnection.getResponseCode();
        if (responseCode == HttpURLConnection.HTTP_OK) {
            return readResponse(urlConnection);
        } else if (responseCode == HttpURLConnection.HTTP_UNAUTHORIZED) {
            // TODO: JWT authentication error. Need to replace it with the actual business logic.
            throw new Exception("jwt authentication error:" + urlConnection.getContent());
        } else {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception("request failed with error message: " + urlConnection.getContent());
        }
    }

    private static String readResponse(HttpURLConnection connection) throws IOException {
        // TODO: Under Java 8, need to close the resource in the finally block.
        try (BufferedReader reader = new BufferedReader(
            new InputStreamReader(connection.getInputStream(), StandardCharsets.UTF_8))) {
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
            return response.toString();
        }
    }

}
