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
import com.huawei.push.model.message.payload.liveview.ActivityData;
import com.huawei.push.model.message.payload.liveview.CapsuleData;
import com.huawei.push.model.message.payload.liveview.Extend;
import com.huawei.push.model.message.payload.liveview.ExternalData;
import com.huawei.push.model.message.payload.liveview.LiveViewPayload;
import com.huawei.push.model.message.payload.liveview.NotificationData;
import com.huawei.push.model.message.payload.liveview.RichText;
import com.huawei.push.model.message.payload.liveview.TextBlock;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * LiveViewExamples
 */
public class LiveViewExamples {
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
     * Send a form-update message.
     */
    public PushResponse sendLiveViewMsg() throws PushException {
        TextBlock firstTextBlock = TextBlock.builder().firstLine("12:00").secondLine("Shanghai Hongqiao").build(); // Please replace the first text block value.
        TextBlock lastTextBlock = TextBlock.builder().firstLine("14:30").secondLine("Chengdu Tianfu").build(); // Please replace the last text block value.
        Map<String, String> keywords = new HashMap<String, String>();
        keywords.put("flightNo", "MU123"); // Please replace the value to real flight number.
        RichText richText = RichText.builder().text("Flight Number:{{flightNo}}").foregroundColor("#FF317AF7").build();
        List<RichText> contentText = new ArrayList<>();
        contentText.add(richText);
        Extend extend = Extend.builder().type(1).text("Flight Status").pic("extend.png").build();
        NotificationData notificationData = NotificationData.builder()
            .type(5)
            .contentTitle("Flight{{status}}")
            .contentText(contentText)
            .firstTextBlock(firstTextBlock)
            .lastTextBlock(lastTextBlock)
            .spaceIcon("spaceIcon.png")
            .extend(extend)
            .keepTime(60L)
            .clickAction(ClickAction.builder().actionType(0).build())
            .keywords(keywords)
            .build();
        CapsuleData capsuleData = CapsuleData.builder()
            .type(1)
            .status(1)
            .icon("icon.png")
            .bgColor("#FF317AF7")
            .title("Title")
            .content("Content")
            .build();
        ExternalData externalData = ExternalData.builder()
            .type(0)
            .title("Title")
            .setBody(contentText)
            .bgImage("externalDataBgImage.png")
            .build();
        ActivityData activityData = ActivityData.builder()
            .setNotificationData(notificationData)
            .setCapsuleData(capsuleData)
            .setExternalData(externalData)
            .build();
        LiveViewPayload liveViewPayload = LiveViewPayload.builder()
            .activityId(123456) // Please replace the activityId
            .operation(0) // Please replace the operation. If you want to create, operation need be set to 0. If you want to update, operation need be set to 1. If you want to finish, operation need be set to 2;
            .event("FLIGHT")
            .version(1) // For the same live view activity (that is, the activityId is the same), the version must be incremented. If the version number carried this time is not greater than the maximum version number of the device refresh, the refresh will fail.
            .status("DEPART") // Please replace the status
            .activityData(activityData)
            .build();

        Message<LiveViewPayload> message = Message.<LiveViewPayload>builder()
            .payload(liveViewPayload)
            .target(Target.builder().addToken(TOKEN).build())
            .pushOptions(PushOptions.builder().testMessage(true).build())
            .build();
        return pushClient.sendMessage(message);
    }

    public static void main(String[] args) throws PushException {
        LiveViewExamples example = new LiveViewExamples();
        System.out.println(example.sendLiveViewMsg());
    }
}
