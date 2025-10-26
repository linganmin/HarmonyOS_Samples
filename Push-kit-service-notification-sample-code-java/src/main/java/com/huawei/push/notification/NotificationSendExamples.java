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

package com.huawei.push.notification;

import com.huawei.push.notification.entry.ServiceNotificationClient;
import com.huawei.push.notification.httpclient.URLConnectionHttpClient;
import com.huawei.push.notification.model.message.ClickAction;
import com.huawei.push.notification.model.message.PushException;
import com.huawei.push.notification.model.message.PushResponse;
import com.huawei.push.notification.model.message.ServiceNotificationMessage;

import java.util.HashMap;
import java.util.Map;

class NotificationSendExamples {

    private final URLConnectionHttpClient httpClient = URLConnectionHttpClient.builder()
            .connectTimeout(3000)
//            .proxy(new Proxy(Proxy.Type.HTTP, new InetSocketAddress("xxx.com", 8080))) // If necessary, use a proxy.
            .readTimeout(3000).build();
    private final ServiceNotificationClient pushClient = ServiceNotificationClient.builder()
            .httpClient(httpClient)
            .build();

    public static void main(String[] args) throws PushException {
        NotificationSendExamples examples = new NotificationSendExamples();
        System.out.println(examples.sendServiceNotification());
    }

    PushResponse sendServiceNotification() throws PushException {
        Map<String, String> templateParams = new HashMap<>();
        // Please use your template params to replace templateParams Map .
        // When setting templateParams, ensure that all selected template parameters of the metaservice collection template are entered.
        templateParams.put("thing_0", "N0001"); // Please replace the param with your template param , if it is not selected, delete it.
        templateParams.put("time_1", "2024年4月27日 22:22"); // Please replace the param with your template param , if it is not selected, delete it.
        templateParams.put("thing_2", "软件大道101号"); // Please replace the param with your template param , if it is not selected, delete it.
        templateParams.put("phone_number_0", "+86-025-85697456"); // Please replace the param with your template param , if it is not selected, delete it.
        templateParams.put("car_number_0", "粤A8Z888挂"); // Please replace the param with your template param , if it is not selected, delete it.
        ServiceNotificationMessage message = ServiceNotificationMessage.builder()
                .msgId("****************") // Please replace the msgId.
                .appId("*******************") // Please replace the appId.
                .toOpenId("**********************") // Please replace the toOpenId.
                .templateId("1***********0") // Please replace the templateId.
                .templateParams(templateParams)
                .clickAction(ClickAction.builder()
                        .actionType(1)
                        .action("com.test.action")
                        .uri("https:***")
                        .putData("testKey", "testValue")
                        .build())
                .build();
        return pushClient.sendMessage(message);
    }
}