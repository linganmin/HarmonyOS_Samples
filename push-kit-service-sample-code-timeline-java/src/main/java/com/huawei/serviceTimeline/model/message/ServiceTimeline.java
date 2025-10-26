/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model.message;

import static com.huawei.serviceTimeline.utils.CheckUtils.checkNotNull;

/**
 * ServiceTimeline.
 * Package class, including the core information and content.
 */
public class ServiceTimeline<T> {
    private String appId;

    private String toOpenId;

    private String sceneId;

    private String subSceneId;

    private String code;

    private final T content;

    private ServiceTimeline(Builder<T> builder) {
        this.appId = builder.appId;
        this.toOpenId = builder.toOpenId;
        this.sceneId = builder.sceneId;
        this.subSceneId = builder.subSceneId;
        this.code = builder.code;
        this.content = checkNotNull(builder.content);
    }

    public static <T> Builder<T> builder() {
        return new Builder<>();
    }

    public static final class Builder<T> {
        private String appId;

        private String toOpenId;

        private String sceneId;

        private String subSceneId;

        private String code;

        private T content;

        private Builder() {
        }

        public Builder<T> appId(String appId) {
            this.appId = appId;
            return this;
        }

        public Builder<T> toOpenId(String toOpenId) {
            this.toOpenId = toOpenId;
            return this;
        }

        public Builder<T> sceneId(String sceneId) {
            this.sceneId = sceneId;
            return this;
        }

        public Builder<T> subSceneId(String subSceneId) {
            this.subSceneId = subSceneId;
            return this;
        }

        public Builder<T> code(String code) {
            this.code = code;
            return this;
        }

        public Builder<T> content(T content) {
            this.content = content;
            return this;
        }

        public ServiceTimeline<T> build() {
            return new ServiceTimeline<>(this);
        }
    }

    public String getAppId() {
        return appId;
    }

    public void setAppId(String appId) {
        this.appId = appId;
    }

    public String getToOpenId() {
        return toOpenId;
    }

    public void setToOpenId(String toOpenId) {
        this.toOpenId = toOpenId;
    }

    public String getSceneId() {
        return sceneId;
    }

    public void setSceneId(String sceneId) {
        this.sceneId = sceneId;
    }

    public String getSubSceneId() {
        return subSceneId;
    }

    public void setSubSceneId(String subSceneId) {
        this.subSceneId = subSceneId;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public T getContent() {
        return content;
    }
}
