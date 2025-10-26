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

import static com.huawei.push.utils.CheckUtils.checkNotNull;

import com.huawei.push.model.message.Scenario;
import com.huawei.push.model.message.payload.PushType;

/**
 * LiveViewPayload
 */
public class LiveViewPayload implements Scenario {
    private Integer activityId;

    private Integer operation;

    private String event;

    private Integer version;

    private String status;

    private ActivityData activityData;

    private LiveViewPayload(Builder builder) {
        this.activityId = checkNotNull(builder.activityId);
        this.operation = checkNotNull(builder.operation);
        this.event = checkNotNull(builder.event);
        this.version = builder.version;
        this.status = checkNotNull(builder.status);
        this.activityData = checkNotNull(builder.activityData);
    }
    @Override
    public int pushType() {
        return PushType.LIVE_VIEW.getVal();
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder{
        private Integer activityId;

        private Integer operation;

        private String event;

        private Integer version;

        private String status;

        private ActivityData activityData;

        private Builder() {
        }

        public Builder activityId(Integer activityId) {
            this.activityId = activityId;
            return this;
        }

        public Builder operation(Integer operation) {
            this.operation = operation;
            return this;
        }

        public Builder event(String event) {
            this.event = event;
            return this;
        }

        public Builder version(Integer version) {
            this.version = version;
            return this;
        }

        public Builder status(String status) {
            this.status = status;
            return this;
        }

        public Builder activityData(ActivityData activityData) {
            this.activityData = activityData;
            return this;
        }

        public LiveViewPayload build() {
            return new LiveViewPayload(this);
        }
    }

    public Integer getActivityId() {
        return activityId;
    }

    public Integer getOperation() {
        return operation;
    }

    public String getEvent() {
        return event;
    }

    public Integer getVersion() {
        return version;
    }

    public String getStatus() {
        return status;
    }

    public ActivityData getActivityData() {
        return activityData;
    }
}
