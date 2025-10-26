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
 * CapsuleData
 */
public class CapsuleData {
    private Integer type;

    private Integer status;

    private String icon;

    private String bgColor;

    private String title;

    private String content;

    private CapsuleData(Builder builder) {
        this.type = builder.type;
        this.status = builder.status;
        this.icon = builder.icon;
        this.bgColor = builder.bgColor;
        this.title = builder.title;
        this.content = builder.content;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Integer type;

        private Integer status;

        private String icon;

        private String bgColor;

        private String title;

        private String content;

        private Builder() {
        }

        public Builder type(Integer type) {
            this.type = type;
            return this;
        }

        public Builder status(Integer status) {
            this.status = status;
            return this;
        }

        public Builder icon(String icon) {
            this.icon = icon;
            return this;
        }

        public Builder bgColor(String bgColor) {
            this.bgColor = bgColor;
            return this;
        }

        public Builder title(String title) {
            this.title = title;
            return this;
        }

        public Builder content(String content) {
            this.content = content;
            return this;
        }

        public CapsuleData build() {
            return new CapsuleData(this);
        }
    }

    public Integer getType() {
        return type;
    }

    public Integer getStatus() {
        return status;
    }

    public String getIcon() {
        return icon;
    }

    public String getBgColor() {
        return bgColor;
    }

    public String getTitle() {
        return title;
    }

    public String getContent() {
        return content;
    }
}
