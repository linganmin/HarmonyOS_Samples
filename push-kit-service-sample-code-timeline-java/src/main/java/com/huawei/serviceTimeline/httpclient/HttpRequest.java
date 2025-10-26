/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.httpclient;
import static com.huawei.serviceTimeline.utils.CheckUtils.checkNotNull;

import java.util.HashMap;
import java.util.Map;

/**
 * HttpRequest.
 */
public class HttpRequest {
    private final String url;
    private final HttpMethod method;
    private final Map<String, String> headers;
    private final String body;

    private HttpRequest(Builder builder) {
        this.url = checkNotNull(builder.url);
        this.method = checkNotNull(builder.method);
        this.headers = builder.headers;
        this.body = checkNotNull(builder.body);
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String url;
        private HttpMethod method;
        private final Map<String, String> headers = new HashMap<>();
        private String body;

        private Builder() {
        }

        public Builder url(String url) {
            this.url = url;
            return this;
        }

        public Builder method(HttpMethod method) {
            this.method = method;
            return this;
        }

        public Builder putHeader(String key, String val) {
            this.headers.put(checkNotNull(key), checkNotNull(val));
            return this;
        }

        public Builder body(String body) {
            this.body = body;
            return this;
        }

        public HttpRequest build() {
            return new HttpRequest(this);
        }


    }

    public String getBody() {
        return body;
    }

    public String getUrl() {
        return url;
    }

    public HttpMethod getMethod() {
        return method;
    }

    public Map<String, String> getHeaders() {
        return headers;
    }
}
