/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.httpclient;

import static com.huawei.serviceTimeline.utils.CheckUtils.checkNotNull;

import java.util.HashMap;
import java.util.Map;

/**
 * HttpResponse.
 */
public class HttpResponse {
    private final int statusCode;

    private final String content;

    private final Map<String, Object> headers;

    private HttpResponse(Builder builder) {
        this.statusCode = builder.statusCode;
        this.content = builder.content;
        this.headers = builder.headers;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private int statusCode;

        private String content;

        private final Map<String, Object> headers = new HashMap<>();

        private Builder() {
        }

        public Builder statusCode(int statusCode) {
            this.statusCode = statusCode;
            return this;
        }

        public Builder content(String content) {
            this.content = content;
            return this;
        }

        public Builder putHeader(String key, String val) {
            this.headers.put(checkNotNull(key), checkNotNull(key));
            return this;
        }

        public HttpResponse build() {
            return new HttpResponse(this);
        }
    }

    public int getStatusCode() {
        return statusCode;
    }

    public String getContent() {
        return content;
    }

    public Map<String, Object> getHeaders() {
        return headers;
    }

    @Override
    public String toString() {
        return "HttpResponse{" +
            "statusCode=" + statusCode +
            ", content='" + content + '\'' +
            ", headers=" + headers +
            '}';
    }
}