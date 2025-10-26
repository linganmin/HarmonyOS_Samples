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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * NotificationData
 */
public class NotificationData {
    private Integer type;

    private String contentTitle;

    private List<RichText> contentText;

    private TextBlock firstTextBlock;

    private TextBlock lastTextBlock;

    private String spaceIcon;

    private Extend extend;

    private Long keepTime;

    private ClickAction clickAction;

    private Map<String, String> keywords = new HashMap<>();

    private NotificationData(Builder builder) {
        this.type = builder.type;
        this.contentTitle = builder.contentTitle;
        this.contentText = builder.contentText;
        this.firstTextBlock = builder.firstTextBlock;
        this.lastTextBlock = builder.lastTextBlock;
        this.spaceIcon = builder.spaceIcon;
        this.extend = builder.extend;
        this.keepTime = builder.keepTime;
        this.clickAction = builder.clickAction;
        this.keywords = builder.keywords;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Integer type;

        private String contentTitle;

        private List<RichText> contentText;

        private TextBlock firstTextBlock;

        private TextBlock lastTextBlock;

        private String spaceIcon;

        private Extend extend;

        private Long keepTime;

        private ClickAction clickAction;

        private Map<String, String> keywords = new HashMap<>();

        private Builder() {

        }
        public Builder type(Integer type) {
            this.type = type;
            return this;
        }

        public Builder contentTitle(String contentTitle) {
            this.contentTitle = contentTitle;
            return this;
        }

        public Builder contentText(List<RichText> contentText) {
            this.contentText = contentText;
            return this;
        }

        public Builder firstTextBlock(TextBlock firstTextBlock) {
            this.firstTextBlock = firstTextBlock;
            return this;
        }

        public Builder lastTextBlock(TextBlock lastTextBlock) {
            this.lastTextBlock = lastTextBlock;
            return this;
        }

        public Builder spaceIcon(String spaceIcon) {
            this.spaceIcon = spaceIcon;
            return this;
        }

        public Builder extend(Extend extend) {
            this.extend = extend;
            return this;
        }

        public Builder keepTime(Long keepTime) {
            this.keepTime = keepTime;
            return this;
        }

        public Builder clickAction(ClickAction clickAction) {
            this.clickAction = clickAction;
            return this;
        }

        public Builder keywords(Map<String, String> keywords) {
            this.keywords = keywords;
            return this;
        }

        public NotificationData build() {
            return new NotificationData(this);
        }
    }

    public Integer getType() {
        return type;
    }

    public String getContentTitle() {
        return contentTitle;
    }

    public List<RichText> getContentText() {
        return contentText;
    }

    public TextBlock getFirstTextBlock() {
        return firstTextBlock;
    }

    public TextBlock getLastTextBlock() {
        return lastTextBlock;
    }

    public String getSpaceIcon() {
        return spaceIcon;
    }

    public Extend getExtend() {
        return extend;
    }

    public Long getKeepTime() {
        return keepTime;
    }

    public ClickAction getClickAction() {
        return clickAction;
    }

    public Map<String, String> getKeywords() {
        return keywords;
    }
}
