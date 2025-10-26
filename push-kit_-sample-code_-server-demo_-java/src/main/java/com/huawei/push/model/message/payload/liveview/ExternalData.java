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

import java.util.List;

/**
 * ExternalData
 */
public class ExternalData {
    private String title;

    private List<RichText> body;

    private Integer bgColor;

    private String bgImage;

    private Integer type;

    private ExternalData(Builder builder) {
        this.title = builder.title;
        this.body = builder.body;
        this.bgColor = builder.bgColor;
        this.bgImage = builder.bgImage;
        this.type = builder.type;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String title;

        private List<RichText> body;

        private Integer bgColor;

        private String bgImage;

        private Integer type;

        private Builder() {

        }
        public Builder title(String title) {
            this.title = title;
            return this;
        }

        public Builder setBody(List<RichText> body) {
            this.body = body;
            return this;
        }

        public Builder bgColor(Integer bgColor) {
            this.bgColor = bgColor;
            return this;
        }

        public Builder bgImage(String bgImage) {
            this.bgImage = bgImage;
            return this;
        }

        public Builder type(Integer type) {
            this.type = type;
            return this;
        }

        public ExternalData build() {
            return new ExternalData(this);
        }
    }

    public String getTitle() {
        return title;
    }

    public List<RichText> getBody() {
        return body;
    }

    public Integer getBgColor() {
        return bgColor;
    }

    public String getBgImage() {
        return bgImage;
    }

    public Integer getType() {
        return type;
    }
}
