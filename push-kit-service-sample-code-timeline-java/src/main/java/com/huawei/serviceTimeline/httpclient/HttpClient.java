/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.httpclient;

import java.io.Closeable;
import java.io.IOException;

/**
 * HttpClient.
 */
public interface HttpClient extends Closeable {
    HttpResponse execute(HttpRequest httpRequest) throws IOException;
}
