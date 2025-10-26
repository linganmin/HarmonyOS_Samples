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

package com.huawei.push.httpclient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.Proxy;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.List;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSocketFactory;

/**
 * This is an example based on {@link HttpURLConnection}.
 * You can replace your preferred third-party httpclient for request sending and personalized settings.
 */
public class URLConnectionHttpClient implements HttpClient {
    private static final List<HttpMethod> DO_OUT_PUT_METHODS = Arrays.asList(HttpMethod.PUT, HttpMethod.POST, HttpMethod.PATCH, HttpMethod.DELETE);
    private final int connectTimeout;
    private final int readTimeout;
    private final SSLSocketFactory sslSocketFactory;
    private final Proxy proxy;

    private URLConnectionHttpClient(Builder builder) {
        this.connectTimeout = builder.connectTimeout;
        this.readTimeout = builder.readTimeout;
        this.sslSocketFactory = builder.sslSocketFactory;
        this.proxy = builder.proxy;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private int connectTimeout = -1;
        private int readTimeout = -1;
        private SSLSocketFactory sslSocketFactory;
        private Proxy proxy;

        private Builder() {
        }

        public Builder connectTimeout(int connectTimeOut) {
            this.connectTimeout = connectTimeOut;
            return this;
        }

        public Builder readTimeout(int readTimeout) {
            this.readTimeout = readTimeout;
            return this;
        }

        public Builder sslContext(SSLSocketFactory sslSocketFactory) {
            this.sslSocketFactory = sslSocketFactory;
            return this;
        }

        public Builder proxy(Proxy proxy) {
            this.proxy = proxy;
            return this;
        }

        public URLConnectionHttpClient build() {
            return new URLConnectionHttpClient(this);
        }
    }

    @Override
    public HttpResponse execute(HttpRequest httpRequest) throws IOException {
        HttpURLConnection connection = null;
        try {
            URL pushServiceUrl = new URL(httpRequest.getUrl());
            if (proxy != null) {
                connection = (HttpURLConnection) pushServiceUrl.openConnection(proxy);
            } else {
                connection = (HttpURLConnection) pushServiceUrl.openConnection();
            }

            if (sslSocketFactory != null) {
                ((HttpsURLConnection) connection).setSSLSocketFactory(sslSocketFactory);
            }

            connection.setRequestMethod(httpRequest.getMethod().name());
            httpRequest.getHeaders().forEach(connection::setRequestProperty);
            if (readTimeout >= 0) {
                connection.setReadTimeout(readTimeout);
            }
            if (connectTimeout >= 0) {
                connection.setConnectTimeout(connectTimeout);
            }

            connection.setDoInput(true);
            if (httpRequest.getMethod() == HttpMethod.POST) {
                connection.setInstanceFollowRedirects(false);
            }

            if (httpRequest.getBody() != null && DO_OUT_PUT_METHODS.contains(httpRequest.getMethod())) {
                connection.setDoOutput(true);
                OutputStream out = connection.getOutputStream();
                out.write(httpRequest.getBody().getBytes(StandardCharsets.UTF_8));
                out.flush();
                out.close();
            }

            connection.connect();

            HttpResponse.Builder responseBuilder = HttpResponse.builder().statusCode(connection.getResponseCode());
            StringBuilder contentBuilder = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    contentBuilder.append(line);
                }
            }
            return responseBuilder.content(contentBuilder.toString()).build();
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }

    @Override
    public void close() {
        // One-time connection, no need to close
    }
}
