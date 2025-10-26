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
 * TextBlock
 */
public class TextBlock {
    private String firstLine;

    private String secondLine;

    private TextBlock(Builder builder) {
        this.firstLine = builder.firstLine;
        this.secondLine = builder.secondLine;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String firstLine;

        private String secondLine;

        private Builder() {

        }

        public Builder firstLine(String firstLine) {
            this.firstLine = firstLine;
            return this;
        }

        public Builder secondLine(String secondLine) {
            this.secondLine = secondLine;
            return this;
        }

        public TextBlock build() {
            return new TextBlock(this);
        }
    }

    public String getFirstLine() {
        return firstLine;
    }

    public String getSecondLine() {
        return secondLine;
    }
}
