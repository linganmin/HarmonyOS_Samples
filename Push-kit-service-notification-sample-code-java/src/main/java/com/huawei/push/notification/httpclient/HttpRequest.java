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

package com.huawei.push.notification.httpclient;

import com.huawei.push.notification.utils.CheckUtils;

import java.util.HashMap;
import java.util.Map;

import static com.huawei.push.notification.utils.CheckUtils.checkNotNull;

/**
 * HttpRequest.
 */
public class HttpRequest {
    private final String url;
    private final HttpMethod method;
    private final Map<String, String> headers;
    private final String body;

    private HttpRequest(Builder builder) {
        this.url = CheckUtils.checkNotNull(builder.url);
        this.method = CheckUtils.checkNotNull(builder.method);
        this.headers = builder.headers;
        this.body = CheckUtils.checkNotNull(builder.body);
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
            this.headers.put(CheckUtils.checkNotNull(key), CheckUtils.checkNotNull(val));
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