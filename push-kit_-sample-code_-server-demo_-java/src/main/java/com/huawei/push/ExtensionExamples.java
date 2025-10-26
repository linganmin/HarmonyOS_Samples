/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
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

package com.huawei.push;

import com.huawei.push.entry.PushClient;
import com.huawei.push.httpclient.URLConnectionHttpClient;
import com.huawei.push.model.message.Message;
import com.huawei.push.model.message.PushException;
import com.huawei.push.model.message.PushOptions;
import com.huawei.push.model.message.PushResponse;
import com.huawei.push.model.message.Target;
import com.huawei.push.model.message.payload.ClickAction;
import com.huawei.push.model.message.payload.ExtensionPayload;
import com.huawei.push.model.message.payload.Notification;

/**
 * Extension examples.
 */
public class ExtensionExamples {
    /**
     * Please replace the push token.
     */
    private static final String TOKEN = "MAAA*********************************************************************************************************Lgj";

    private final URLConnectionHttpClient httpClient = URLConnectionHttpClient.builder()
        .connectTimeout(3000)
        // .proxy(new Proxy(Proxy.Type.HTTP, new InetSocketAddress("xxx.com", 8080))) // If necessary, use a proxy.
        .readTimeout(3000).build();

    private final PushClient pushClient = PushClient.builder()
        .httpClient(httpClient)
        .build();

    /**
     * Send an extension message.
     */
    public PushResponse sendExtensionMsg() throws PushException {
        ExtensionPayload payload = ExtensionPayload.builder()
            .notification(Notification.builder()
            .category(Notification.Category.PLAY_VOICE)
            .title("Title")
            .body("Body")
            .clickAction(ClickAction.builder().actionType(0).build())
            .build())
            .extraData("xxxxxx")
            .build();

        Message<ExtensionPayload> message = Message.<ExtensionPayload>builder()
            .payload(payload)
            .target(Target.builder().addToken(TOKEN).build())
            .pushOptions(PushOptions.builder().testMessage(true).build())
            .build();

        return pushClient.sendMessage(message);
    }

    public static void main(String[] args) throws PushException {
        ExtensionExamples example = new ExtensionExamples();
        System.out.println(example.sendExtensionMsg());
    }
}
