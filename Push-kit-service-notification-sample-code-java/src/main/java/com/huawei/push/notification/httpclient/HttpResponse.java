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

import java.util.HashMap;
import java.util.Map;

import static com.huawei.push.notification.utils.CheckUtils.checkNotNull;

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