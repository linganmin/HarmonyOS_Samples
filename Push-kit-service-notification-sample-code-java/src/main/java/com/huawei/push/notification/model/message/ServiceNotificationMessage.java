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

package com.huawei.push.notification.model.message;

import java.util.Map;


/**
 * Message.
 */
public class ServiceNotificationMessage {
    private String msgId;

    private String toOpenId;

    private String appId;

    private String templateId;

    private Map<String, String> templateParams;

    private ClickAction clickAction;

    private ServiceNotificationMessage(Builder builder) {
        this.msgId = builder.msgId;
        this.toOpenId = builder.toOpenId;
        this.appId = builder.appId;
        this.templateId = builder.templateId;
        this.templateParams = builder.templateParams;
        this.clickAction = builder.clickAction;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String msgId;
        private String toOpenId;
        private String appId;
        private String templateId;
        private Map<String, String> templateParams;
        private ClickAction clickAction;

        public Builder() {
        }

        public Builder msgId(String msgId) {
            this.msgId = msgId;
            return this;
        }

        public Builder toOpenId(String toOpenId) {
            this.toOpenId = toOpenId;
            return this;
        }

        public Builder appId(String appId) {
            this.appId = appId;
            return this;
        }

        public Builder templateId(String templateId) {
            this.templateId = templateId;
            return this;
        }

        public Builder templateParams(Map<String, String> templateParams) {
            this.templateParams = templateParams;
            return this;
        }

        public Builder clickAction(ClickAction clickAction) {
            this.clickAction = clickAction;
            return this;
        }

        public ServiceNotificationMessage build() {
            return new ServiceNotificationMessage(this);
        }
    }

    public String getMsgId() {
        return msgId;
    }

    public String getToOpenId() {
        return toOpenId;
    }

    public String getAppId() {
        return appId;
    }

    public String getTemplateId() {
        return templateId;
    }

    public Map<String, String> getTemplateParams() {
        return templateParams;
    }

    public ClickAction getClickAction() {
        return clickAction;
    }
}