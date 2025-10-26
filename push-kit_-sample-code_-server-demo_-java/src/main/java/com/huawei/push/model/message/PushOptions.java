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

package com.huawei.push.model.message;

/**
 * PushOptions.
 */
public class PushOptions {
    private final Boolean testMessage;
    private final Integer ttl;
    private final String biTag;
    private final String receiptId;
    private final Integer collapseKey;

    private PushOptions(Builder builder) {
        this.testMessage = builder.testMessage;
        this.ttl = builder.ttl;
        this.biTag = builder.biTag;
        this.receiptId = builder.receiptId;
        this.collapseKey = builder.collapseKey;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private Boolean testMessage;
        private Integer ttl;
        private String biTag;
        private String receiptId;
        private Integer collapseKey;

        private Builder() {
        }

        public Builder testMessage(Boolean testMessage) {
            this.testMessage = testMessage;
            return this;
        }

        public Builder ttl(Integer ttl) {
            this.ttl = ttl;
            return this;
        }

        public Builder biTag(String biTag) {
            this.biTag = biTag;
            return this;
        }

        public Builder receiptId(String receiptId) {
            this.receiptId = receiptId;
            return this;
        }

        public Builder collapseKey(Integer collapseKey) {
            this.collapseKey = collapseKey;
            return this;
        }

        public PushOptions build() {
            return new PushOptions(this);
        }
    }

    public Boolean isTestMessage() {
        return testMessage;
    }

    public Integer getTtl() {
        return ttl;
    }

    public String getBiTag() {
        return biTag;
    }

    public String getReceiptId() {
        return receiptId;
    }

    public Integer getCollapseKey() {
        return collapseKey;
    }
}
