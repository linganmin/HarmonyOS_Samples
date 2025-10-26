/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model.message.delivery;

/**
 * button
 */
public class ClickButton {
    private Integer type;

    private String text;

    private String action;

    private String uri;

    private ClickButton(Builder builder) {
        this.type = builder.type;
        this.text = builder.text;
        this.action = builder.action;
        this.uri = builder.uri;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Integer type;

        private String text;

        private String action;

        private String uri;

        public Builder type(Integer type) {
            this.type = type;
            return this;
        }

        public Builder text(String text) {
            this.text = text;
            return this;
        }

        public Builder action(String action) {
            this.action = action;
            return this;
        }

        public Builder uri(String uri) {
            this.uri = uri;
            return this;
        }

        public ClickButton build() {
            return new ClickButton(this);
        }
    }

    public Integer getType() {
        return type;
    }

    public void setType(Integer type) {
        this.type = type;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getUri() {
        return uri;
    }

    public void setUri(String uri) {
        this.uri = uri;
    }
}
