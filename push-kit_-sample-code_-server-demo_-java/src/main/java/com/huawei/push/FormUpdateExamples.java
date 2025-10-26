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
import com.huawei.push.model.message.payload.FormImage;
import com.huawei.push.model.message.payload.FormPayload;
import com.huawei.push.model.message.payload.PushType;

/**
 * FormUpdate examples.
 */
public class FormUpdateExamples {
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
     * Send a form-update message.
     */
    public PushResponse sendFormUpdateMsg() throws PushException {
        FormPayload formPayload = FormPayload.builder()
                .putFormData("key1", "value1")
                .putFormData("key2", "value2")
                .version(1) // For the same form (that is, the formId is the same), the version must be incremented. If the version number carried this time is not greater than the maximum version number of the device refresh, the refresh will fail.
                .addImage(FormImage.builder()
                        .keyName("image")
                        .url("https://***.png")
                        .require(1)
                        .build())
                .formId(423434262L) // Please replace the formId
                .formName("widget")
                .moduleName("entry")
                .abilityName("FormAbility")
                .build();

        Message<FormPayload> formMessage = Message.<FormPayload>builder()
                .payload(formPayload)
                .target(Target.builder().addToken(TOKEN).build())
                .pushOptions(PushOptions.builder().testMessage(true).build())
                .build();

        return pushClient.sendMessage(formMessage);
    }

    public static void main(String[] args) throws PushException {
        FormUpdateExamples example = new FormUpdateExamples();
        System.out.println(example.sendFormUpdateMsg());
    }
}
