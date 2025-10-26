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

package com.huawei.push.model.auth;

import com.fasterxml.jackson.annotation.JsonProperty;

import static com.huawei.push.utils.CheckUtils.checkNotNull;

/**
 * Key configuration for Service Account-based Authentication.
 * Service Account-based Authentication.
 */
public class ServiceAccount {
    @JsonProperty("project_id")
    private String projectId;
    @JsonProperty("key_id")
    private String keyId;
    @JsonProperty("private_key")
    private String privateKey;
    @JsonProperty("sub_account")
    private String subAccount;
    @JsonProperty("token_uri")
    private String tokenURI;

    public ServiceAccount() {
    }

    private ServiceAccount(Builder builder) {
        this.projectId = checkNotNull(builder.projectId);
        this.keyId = checkNotNull(builder.keyId);
        this.privateKey = checkNotNull(builder.privateKey);
        this.subAccount = checkNotNull(builder.subAccount);
        this.tokenURI = checkNotNull(builder.tokenURI);
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String projectId;
        private String keyId;
        private String privateKey;
        private String subAccount;
        private String tokenURI;

        private Builder() {
        }

        public Builder projectId(String projectId) {
            this.projectId = projectId;
            return this;
        }

        public Builder keyId(String keyId) {
            this.keyId = keyId;
            return this;
        }

        public Builder privateKey(String privateKey) {
            this.privateKey = privateKey;
            return this;
        }

        public Builder subAccount(String subAccount) {
            this.subAccount = subAccount;
            return this;
        }

        public Builder tokenURI(String tokenURI) {
            this.tokenURI = tokenURI;
            return this;
        }

        public ServiceAccount build() {
            return new ServiceAccount(this);
        }
    }

    public String getProjectId() {
        return projectId;
    }

    public void setProjectId(String projectId) {
        this.projectId = projectId;
    }

    public String getKeyId() {
        return keyId;
    }

    public void setKeyId(String keyId) {
        this.keyId = keyId;
    }

    public String getPrivateKey() {
        return privateKey;
    }

    public void setPrivateKey(String privateKey) {
        this.privateKey = privateKey;
    }

    public String getSubAccount() {
        return subAccount;
    }

    public void setSubAccount(String subAccount) {
        this.subAccount = subAccount;
    }

    public String getTokenURI() {
        return tokenURI;
    }

    public void setTokenURI(String tokenURI) {
        this.tokenURI = tokenURI;
    }
}
