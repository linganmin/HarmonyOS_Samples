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

package com.huawei.push.model.message.payload.liveview;

/**
 * ActivityData
 */
public class ActivityData {
    private NotificationData notificationData;

    private CapsuleData capsuleData;

    private ExternalData externalData;

    private ActivityData(Builder builder) {
        this.notificationData = builder.notificationData;
        this.capsuleData = builder.capsuleData;
        this.externalData = builder.externalData;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private NotificationData notificationData;

        private CapsuleData capsuleData;

        private ExternalData externalData;

        private Builder() {

        }

        public Builder setNotificationData(NotificationData notificationData) {
            this.notificationData = notificationData;
            return this;
        }

        public Builder setCapsuleData(CapsuleData capsuleData) {
            this.capsuleData = capsuleData;
            return this;
        }

        public Builder setExternalData(ExternalData externalData) {
            this.externalData = externalData;
            return this;
        }

        public ActivityData build() {
            return new ActivityData(this);
        }
    }

    public NotificationData getNotificationData() {
        return notificationData;
    }

    public CapsuleData getCapsuleData() {
        return capsuleData;
    }

    public ExternalData getExternalData() {
        return externalData;
    }
}
