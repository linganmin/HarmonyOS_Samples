/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package com.huawei.serviceTimeline.model.auth;

import static com.huawei.serviceTimeline.utils.CheckUtils.checkNotNull;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Key configuration for Service Account-based Authentication.
 * Service Account-based Authentication.
 */
public class ServiceAccount {
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
        this.keyId = checkNotNull(builder.keyId);
        this.privateKey = checkNotNull(builder.privateKey);
        this.subAccount = checkNotNull(builder.subAccount);
        this.tokenURI = checkNotNull(builder.tokenURI);
    }

    public static Builder builder() {
        return new Builder();
    }

    public static final class Builder {
        private String keyId;

        private String privateKey;

        private String subAccount;

        private String tokenURI;

        private Builder() {
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
