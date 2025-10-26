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
 * RichText
 */
public class RichText {
    private String text;

    private String foregroundColor;

    private RichText(Builder builder) {
        this.text = builder.text;
        this.foregroundColor = builder.foregroundColor;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String text;

        private String foregroundColor;

        private Builder() {

        }

        public Builder text(String text) {
            this.text = text;
            return this;
        }

        public Builder foregroundColor(String foregroundColor) {
            this.foregroundColor = foregroundColor;
            return this;
        }

        public RichText build() {
            return new RichText(this);
        }
    }

    public String getText() {
        return text;
    }

    public String getForegroundColor() {
        return foregroundColor;
    }
}
