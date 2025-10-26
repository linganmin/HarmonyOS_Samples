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

package com.huawei.push.notification.entry;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.huawei.push.notification.httpclient.HttpClient;
import com.huawei.push.notification.httpclient.HttpMethod;
import com.huawei.push.notification.httpclient.HttpRequest;
import com.huawei.push.notification.httpclient.HttpResponse;
import com.huawei.push.notification.model.Config;
import com.huawei.push.notification.model.auth.ServiceAccount;
import com.huawei.push.notification.model.message.PushException;
import com.huawei.push.notification.model.message.PushResponse;
import com.huawei.push.notification.model.message.ServiceNotificationMessage;

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.MessageFormat;
import java.time.Duration;

import static com.huawei.push.notification.utils.CheckUtils.checkNotNull;

/**
 * The entrance of push demo. Help send messages easily by its public method {@link #sendMessage}.
 */
public class ServiceNotificationClient {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper()
            .disable(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES)
            .setSerializationInclusion(JsonInclude.Include.NON_NULL);

    private static final String HTTPS = "https://";

    private static final String MESSAGE_SEND_URL_PATTERN = HTTPS + "{0}/v1/{1}/service_notification/send";

    private final HttpClient httpClient;

    private final String messageUrl;

    private final JWTSupplier jwtSupplier;

    private ServiceNotificationClient(Builder builder) {
        ServiceAccount serviceAccount = loadServiceAccount();
        this.httpClient = checkNotNull(builder.httpClient);
        String projectId = serviceAccount.getProjectId();
        Config config = loadConfig();
        this.messageUrl = MessageFormat.format(MESSAGE_SEND_URL_PATTERN, config.getPushServerDomain(), projectId);
        this.jwtSupplier = new JWTSupplier(serviceAccount, Duration.ofHours(1));
    }

    private Config loadConfig() {
        URL url = ServiceNotificationClient.class.getClassLoader().getResource("config.json");
        String path = checkNotNull(url, "config doesn't exist.").getPath();
        try {
            return OBJECT_MAPPER.readValue(new File(path), Config.class);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to read config, " + e.getMessage());
        }
    }

    private ServiceAccount loadServiceAccount() {
        URL url = ServiceNotificationClient.class.getClassLoader().getResource("service_account.json");
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
    public PushResponse sendMessage(ServiceNotificationMessage message) throws PushException {
        try {
            HttpRequest httpRequest = HttpRequest.builder()
                    .method(HttpMethod.POST)
                    .body(OBJECT_MAPPER.writeValueAsString(message))
                    .url(messageUrl)
                    .putHeader("Content-Type", "application/json; charset=UTF-8")
                    .putHeader("Authorization", "Bearer " + jwtSupplier.get())
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

    public static final class Builder {
        private HttpClient httpClient;

        private Builder() {
        }

        public Builder httpClient(HttpClient httpClient) {
            this.httpClient = httpClient;
            return this;
        }

        public ServiceNotificationClient build() {
            return new ServiceNotificationClient(this);
        }
    }
}