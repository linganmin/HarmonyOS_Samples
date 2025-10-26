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

package com.huawei.push.model.message;

import static com.huawei.push.utils.CheckUtils.checkNotNull;

/**
 * Message.
 */
public class Message<T extends Scenario> {
    private final T payload;
    private final PushOptions pushOptions;
    private final Target target;

    private Message(Builder<T> builder) {
        this.payload = checkNotNull(builder.payload);
        this.pushOptions = builder.pushOptions;
        this.target = builder.target;
    }

    public static <T extends Scenario> Builder<T> builder() {
        return new Builder<>();
    }

    public static final class Builder<T extends Scenario> {
        private T payload;
        private PushOptions pushOptions;
        private Target target;

        private Builder() {
        }

        public Builder<T> payload(T payload) {
            this.payload = payload;
            return this;
        }

        public Builder<T> pushOptions(PushOptions pushOptions) {
            this.pushOptions = pushOptions;
            return this;
        }

        public Builder<T> target(Target target) {
            this.target = target;
            return this;
        }

        public Message<T> build() {
            return new Message<>(this);
        }
    }

    public T getPayload() {
        return payload;
    }

    public PushOptions getPushOptions() {
        return pushOptions;
    }

    public Target getTarget() {
        return target;
    }
}
