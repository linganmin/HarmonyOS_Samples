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

package com.huawei.push.model.message.payload;

import com.huawei.push.model.message.Scenario;

/**
 * AlertPayload.
 */
public class AlertPayload implements Scenario {
    private final Notification notification;

    private AlertPayload(Builder builder) {
        this.notification = builder.notification;
    }

    public static Builder builder() {
        return new Builder();
    }

    @Override
    public int pushType() {
        return PushType.ALERT.getVal();
    }

    public static final class Builder {
        private Notification notification;

        public Builder notification(Notification notification) {
            this.notification = notification;
            return this;
        }

        public AlertPayload build() {
            return new AlertPayload(this);
        }
    }

    public Notification getNotification() {
        return notification;
    }
}
