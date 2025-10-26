/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
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

import static com.huawei.push.utils.CheckUtils.checkNotNull;

import com.huawei.push.httpclient.HttpClient;
import com.huawei.push.httpclient.HttpMethod;
import com.huawei.push.httpclient.HttpRequest;
import com.huawei.push.httpclient.HttpResponse;
import com.huawei.push.model.Config;
import com.huawei.push.model.auth.ServiceAccount;
import com.huawei.push.model.message.Message;
import com.huawei.push.model.message.PushException;
import com.huawei.push.model.message.PushResponse;
import com.huawei.push.model.message.RevokeRequest;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.MessageFormat;
import java.time.Duration;

/**
 * The entrance of push demo. Help send messages easily by its public method {@link #sendMessage}.
 */
public class PushClient {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
            .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
            .setSerializationInclusion(JsonInclude.Include.NON_NULL);

    private static final String HTTPS = "https://";

    private static final String MESSAGE_SEND_URL_PATTERN = HTTPS + "{0}/v3/{1}/messages:send";

    private static final String MESSAGE_REVOKE_URL_PATTERN = HTTPS + "{0}/v1/{1}/messages:revoke";

    private final HttpClient httpClient;

    private final String messageUrl;

    private final String revokeUrl;

    private final JWTSupplier jwtSupplier;

    private PushClient(Builder builder) {
        this.httpClient = checkNotNull(builder.httpClient);
        ServiceAccount serviceAccount = loadServiceAccount();
        String projectId = serviceAccount.getProjectId();
        Config config = loadConfig();
        this.messageUrl = MessageFormat.format(MESSAGE_SEND_URL_PATTERN, config.getPushServerDomain(), projectId);
        this.revokeUrl = MessageFormat.format(MESSAGE_REVOKE_URL_PATTERN, config.getPushServerDomain());
        this.jwtSupplier = new JWTSupplier(serviceAccount, Duration.ofHours(1));
    }

    private Config loadConfig() {
        URL url = PushClient.class.getClassLoader().getResource("config.json");
        String path = checkNotNull(url, "config doesn't exist.").getPath();
        try {
            return OBJECT_MAPPER.readValue(new File(path), Config.class);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read config, " + e.getMessage());
        }
    }

    private ServiceAccount loadServiceAccount() {
        URL url = PushClient.class.getClassLoader().getResource("service_account.json");
        String path = checkNotNull(url, "Service Account file doesn't exist.").getPath();
        try {
            // For the convenience of demonstration, read the Service Account from the json here.
            // Please do not access plaintext directly in production environment.
            return OBJECT_MAPPER.readValue(new File(path), ServiceAccount.class);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read Service Account file, " + e.getMessage());
        }
    }

    public static Builder builder() {
        return new Builder();
    }

    /**
     * Send a message.
     *
     * @param message To be sent.
     * @return The push response.
     * @throws PushException The PushException.
     */
    public PushResponse sendMessage(Message<?> message) throws PushException {
        try {
            HttpRequest httpRequest = HttpRequest.builder()
                    .method(HttpMethod.POST)
                    .body(OBJECT_MAPPER.writeValueAsString(message))
                    .url(messageUrl)
                    .putHeader("Content-Type", "application/json; charset=UTF-8")
                    .putHeader("Authorization", "Bearer " + jwtSupplier.get())
                    .putHeader("push-type", String.valueOf(message.getPayload().pushType()))
                    .build();

            HttpResponse httpResponse = httpClient.execute(httpRequest);

            if (httpResponse.getStatusCode() == HttpURLConnection.HTTP_OK) {
                return OBJECT_MAPPER.readValue(httpResponse.getContent(), PushResponse.class);
            }
            return PushResponse.fromHttpFailure(String.valueOf(httpResponse.getStatusCode()), httpResponse.getContent());
        } catch (Throwable e) {
            throw new PushException("Send message failed, " + e.getMessage());
        }
    }

    /**
     * Revoke a message.
     *
     * @param revokeRequest A revoke request.
     * @return The push response.
     * @throws PushException The PushException.
     */
    public PushResponse revokeMessage(RevokeRequest revokeRequest) throws PushException {
        try {
            String finalRevokeUrl = MessageFormat.format(revokeUrl, null, revokeRequest.getClientId());
            HttpRequest httpRequest = HttpRequest.builder()
                .method(HttpMethod.POST)
                .body(OBJECT_MAPPER.writeValueAsString(revokeRequest))
                .url(finalRevokeUrl)
                .putHeader("Content-Type", "application/json; charset=UTF-8")
                .putHeader("Authorization", "Bearer " + jwtSupplier.get())
                .putHeader("push-type", String.valueOf(revokeRequest.getPushType().getVal()))
                .build();

            HttpResponse httpResponse = httpClient.execute(httpRequest);

            if (httpResponse.getStatusCode() == HttpURLConnection.HTTP_OK) {
                return OBJECT_MAPPER.readValue(httpResponse.getContent(), PushResponse.class);
            }
            return PushResponse.fromHttpFailure(String.valueOf(httpResponse.getStatusCode()), httpResponse.getContent());
        } catch (Throwable e) {
            throw new PushException("Revoke message failed, " + e.getMessage());
        }
    }

    public static final class Builder {
        private HttpClient httpClient;

        private Builder() {
        }

        public Builder httpClient(HttpClient httpClient) {
            this.httpClient = httpClient;
            return this;
        }

        public PushClient build() {
            return new PushClient(this);
        }
    }
}
