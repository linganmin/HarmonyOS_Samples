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

import com.huawei.push.model.message.payload.ClickAction;

/**
 * Extend
 */
public class Extend {
    private Integer type;

    private String text;

    private String pic;

    private ClickAction clickAction;

    private Extend(Builder builder) {
        this.type = builder.type;
        this.text = builder.text;
        this.pic = builder.pic;
        this.clickAction = builder.clickAction;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Integer type;

        private String text;

        private String pic;

        private ClickAction clickAction;

        private Builder() {

        }

        public Builder type(Integer type) {
            this.type = type;
            return this;
        }

        public Builder text(String text) {
            this.text = text;
            return this;
        }

        public Builder pic(String pic) {
            this.pic = pic;
            return this;
        }

        public Builder clickAction(ClickAction clickAction) {
            this.clickAction = clickAction;
            return this;
        }

        public Extend build() {
            return new Extend(this);
        }
    }

    public Integer getType() {
        return type;
    }

    public String getText() {
        return text;
    }

    public String getPic() {
        return pic;
    }

    public ClickAction getClickAction() {
        return clickAction;
    }
}
