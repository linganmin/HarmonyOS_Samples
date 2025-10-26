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

/**
 * Badge.
 */
public class Badge {
    private final Integer addNum;

    private Badge(Builder builder) {
        this.addNum = builder.addNum;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Integer addNum;

        private Builder() {
        }

        public Builder addNum(Integer addNum) {
            this.addNum = addNum;
            return this;
        }

        public Badge build() {
            return new Badge(this);
        }
    }

    public Integer getAddNum() {
        return addNum;
    }
}
