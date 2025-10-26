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

package com.huawei.push;

import com.huawei.push.entry.PushClient;
import com.huawei.push.httpclient.URLConnectionHttpClient;
import com.huawei.push.model.message.Message;
import com.huawei.push.model.message.PushException;
import com.huawei.push.model.message.PushOptions;
import com.huawei.push.model.message.PushResponse;
import com.huawei.push.model.message.Target;
import com.huawei.push.model.message.payload.AlertPayload;
import com.huawei.push.model.message.payload.Badge;
import com.huawei.push.model.message.payload.ClickAction;
import com.huawei.push.model.message.payload.Notification;
import com.huawei.push.model.message.payload.PushType;

/**
 * Notification examples。
 */
public class NotificationExamples {
    /**
     * Please replace the push token.
     */
    private static final String TOKEN = "MAAA*********************************************************************************************************Lgj";

    private final URLConnectionHttpClient httpClient = URLConnectionHttpClient.builder()
            .connectTimeout(3000)
//            .proxy(new Proxy(Proxy.Type.HTTP, new InetSocketAddress("xxx.com", 8080))) // If necessary, use a proxy.
            .readTimeout(3000).build();

    private final PushClient pushClient = PushClient.builder()
            .httpClient(httpClient)
            .build();

    /**
     * Send a simple notification.
     */
    public PushResponse sendNotification() throws PushException {
        AlertPayload alertPayload = AlertPayload.builder()
                .notification(Notification.builder()
                        .category(Notification.Category.MARKETING)
                        .title("Title")
                        .body("Body")
                        .clickAction(ClickAction.builder().actionType(0).build())
                        .build()).build();
        Message<AlertPayload> message = Message.<AlertPayload>builder()
                .payload(alertPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();
        return pushClient.sendMessage(message);
    }

    /**
     * Send a notification with a click action jump to the first page of APP.
     */
    public PushResponse sendNotificationWithClickActionJumpTo1stPage() throws PushException {
        AlertPayload alertPayload = AlertPayload.builder().notification(Notification.builder()
                .category(Notification.Category.MARKETING)
                .title("Title")
                .body("Body")
                .clickAction(ClickAction.builder().actionType(0).putData("key", "value").build())
                .build()).build();
        Message<AlertPayload> message = Message.<AlertPayload>builder()
                .payload(alertPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();
        return pushClient.sendMessage(message);
    }

    /**
     * Send a notification with a click action jump to a specific inner page of APP.
     */
    public PushResponse sendNotificationWithClickActionJumpToInnerPage() throws PushException {
        AlertPayload alertPayload = AlertPayload.builder()
                .notification(Notification.builder()
                        .category(Notification.Category.MARKETING)
                        .title("Title")
                        .body("Body")
                        .clickAction(ClickAction.builder()
                                .actionType(1)
                                .action("com.test.action")
                                .uri("https:***")
                                .putData("testKey", "testValue")
                                .build())
                        .build()).build();
        Message<AlertPayload> message = Message.<AlertPayload>builder()
                .payload(alertPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();
        return pushClient.sendMessage(message);
    }

    /**
     * Send a notification with a badge.
     */
    public PushResponse sendNotificationWithBadge() throws PushException {
        AlertPayload alertPayload = AlertPayload.builder()
                .notification(Notification.builder()
                        .category(Notification.Category.MARKETING)
                        .title("Title")
                        .body("Body")
                        .badge(Badge.builder().addNum(1).build())
                        .clickAction(ClickAction.builder().actionType(0).build())
                        .build()).build();
        Message<AlertPayload> message = Message.<AlertPayload>builder()
                .payload(alertPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();
        return pushClient.sendMessage(message);
    }

    /**
     * Send a notification with a image icon.
     */
    public PushResponse sendNotificationWithImageIcon() throws PushException {
        AlertPayload alertPayload = AlertPayload.builder()
                .notification(Notification.builder()
                        .category(Notification.Category.MARKETING)
                        .title("Title")
                        .body("Body")
                        .image("https://***.png")
                        .clickAction(ClickAction.builder().actionType(0).build())
                        .build()).build();
        Message<AlertPayload> message = Message.<AlertPayload>builder()
                .payload(alertPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();
        return pushClient.sendMessage(message);
    }

    /**
     * Send a notification with multi-line text.
     */
    public PushResponse sendNotificationWithMultiLineText() throws PushException {
        AlertPayload alertPayload = AlertPayload.builder()
                .notification(Notification.builder()
                        .category(Notification.Category.MARKETING)
                        .title("Title")
                        .body("Body")
                        .style(3)
                        .addInboxContent("1.***")
                        .addInboxContent("2.***")
                        .addInboxContent("3.***")
                        .clickAction(ClickAction.builder().actionType(0).build())
                        .build()).build();
        Message<AlertPayload> message = Message.<AlertPayload>builder()
                .payload(alertPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();
        return pushClient.sendMessage(message);
    }

    public static void main(String[] args) throws PushException {
        NotificationExamples example = new NotificationExamples();
        System.out.println(example.sendNotification());
//        System.out.println(example.sendNotificationWithClickActionJumpTo1stPage());
//        System.out.println(example.sendNotificationWithClickActionJumpToInnerPage());
//        System.out.println(example.sendNotificationWithBadge());
//        System.out.println(example.sendNotificationWithImageIcon());
//        System.out.println(example.sendNotificationWithMultiLineText());
    }
}
