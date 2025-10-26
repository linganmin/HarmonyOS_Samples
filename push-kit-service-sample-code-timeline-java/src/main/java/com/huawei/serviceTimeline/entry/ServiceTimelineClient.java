/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.entry;

import static com.huawei.serviceTimeline.utils.CheckUtils.checkNotNull;

import com.huawei.serviceTimeline.httpclient.HttpClient;
import com.huawei.serviceTimeline.httpclient.HttpMethod;
import com.huawei.serviceTimeline.httpclient.HttpRequest;
import com.huawei.serviceTimeline.httpclient.HttpResponse;
import com.huawei.serviceTimeline.model.Config;
import com.huawei.serviceTimeline.model.auth.ServiceAccount;
import com.huawei.serviceTimeline.model.message.ServiceTimeline;
import com.huawei.serviceTimeline.model.message.ServiceTimelineException;
import com.huawei.serviceTimeline.model.message.ServiceTimelineResponse;

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
 * The entrance of service timeline demo. Help send messages easily by its public method {@link #sendMessage}.
 */
public class ServiceTimelineClient {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper().disable(
        DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES).setSerializationInclusion(JsonInclude.Include.NON_NULL);

    private static final String HTTPS = "https://";

    private static final String MESSAGE_SEND_URL_PATTERN = HTTPS + "{0}/v1/{1}/service_timeline/send";

    private final HttpClient httpClient;

    private final String messageUrl;

    private final JWTSupplier jwtSupplier;

    private ServiceTimelineClient(Builder builder) {
        this.httpClient = checkNotNull(builder.httpClient);
        Config config = checkNotNull(builder.config);
        this.messageUrl = MessageFormat.format(MESSAGE_SEND_URL_PATTERN, config.getServiceTimelineServerDomain(),
            config.getProjectId());
        this.jwtSupplier = new JWTSupplier(loadServiceAccount(), Duration.ofHours(1));
    }

    private ServiceAccount loadServiceAccount() {
        URL url = ServiceTimelineClient.class.getClassLoader().getResource("service_account.json");
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
     * @return The serviceTimeline response.
     * @throws ServiceTimelineException The ServiceTimelineException.
     */
    public ServiceTimelineResponse sendMessage(ServiceTimeline<?> message) throws ServiceTimelineException {
        try {
            HttpRequest httpRequest = HttpRequest.builder()
                .method(HttpMethod.POST)
                .url(messageUrl)
                .putHeader("Content-Type", "application/json; charset=UTF-8")
                .putHeader("Authorization", "Bearer " + jwtSupplier.get())
                .body(OBJECT_MAPPER.writeValueAsString(message))
                .build();

            HttpResponse httpResponse = httpClient.execute(httpRequest);

            if (httpResponse.getStatusCode() == HttpURLConnection.HTTP_OK) {
                return OBJECT_MAPPER.readValue(httpResponse.getContent(), ServiceTimelineResponse.class);
            }
            return ServiceTimelineResponse.fromHttpFailure(String.valueOf(httpResponse.getStatusCode()),
                httpResponse.getContent());
        } catch (Throwable e) {
            throw new ServiceTimelineException("Send message failed, " + e.getMessage());
        }
    }

    public static final class Builder {
        private HttpClient httpClient;

        private Config config;

        private Builder() {
        }

        public Builder httpClient(HttpClient httpClient) {
            this.httpClient = httpClient;
            return this;
        }

        public Builder config(Config config) {
            this.config = config;
            return this;
        }

        public ServiceTimelineClient build() {
            return new ServiceTimelineClient(this);
        }
    }
}