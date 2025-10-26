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

package com.huawei.push.notification.model.message;

import com.huawei.push.notification.utils.CheckUtils;

import java.util.HashMap;
import java.util.Map;

/**
 * ClickAction.
 */
public class ClickAction {
    private final Integer actionType;
    private final String action;
    private final String uri;
    private final Map<String, Object> data;

    private ClickAction(Builder builder) {
        this.actionType = CheckUtils.checkNotNull(builder.actionType);
        this.action = builder.action;
        this.uri = builder.uri;
        this.data = builder.data;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Integer actionType;
        private String action;
        private String uri;
        private Map<String, Object> data;

        private Builder() {
        }

        public Builder actionType(Integer actionType) {
            this.actionType = actionType;
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

        public Builder putData(String key, Object val) {
            CheckUtils.checkNotNull(key);
            CheckUtils.checkNotNull(val);
            if (data == null) {
                data = new HashMap<>();
            }
            data.put(key, val);
            return this;
        }

        public ClickAction build() {
            return new ClickAction(this);
        }
    }

    public Integer getActionType() {
        return actionType;
    }

    public String getAction() {
        return action;
    }

    public String getUri() {
        return uri;
    }

    public Map<String, Object> getData() {
        return data;
    }
}