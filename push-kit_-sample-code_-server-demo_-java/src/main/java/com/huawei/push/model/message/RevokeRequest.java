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

package com.huawei.push.model.message;

import static com.huawei.push.utils.CheckUtils.checkArgument;
import static com.huawei.push.utils.CheckUtils.checkNotNull;

import com.huawei.push.model.message.payload.PushType;

import com.fasterxml.jackson.annotation.JsonIgnore;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Revoke request.
 */
public class RevokeRequest {
    private static final List<PushType> SUPPORT_PUSH_TYPES = Arrays.asList(PushType.ALERT, PushType.EXTENSION);

    @JsonIgnore
    private final String clientId;

    @JsonIgnore
    private final PushType pushType;

    private final Integer notifyId;

    private final List<String> token;

    private RevokeRequest(Builder builder) {
        checkArgument(SUPPORT_PUSH_TYPES.contains(builder.pushType),
            "Only supports revoking alert and extension messages");
        this.clientId = checkNotNull(builder.clientId);
        this.pushType = builder.pushType;
        this.notifyId = checkNotNull(builder.notifyId);
        this.token = builder.token;
    }

    public static Builder builder() {
        return new Builder();
    }

    public static class Builder {
        private String clientId;

        private PushType pushType;

        private Integer notifyId;

        private final List<String> token = new ArrayList<>();

        private Builder() {
        }

        public Builder clientId(String clientId) {
            this.clientId = clientId;
            return this;
        }

        public Builder pushType(PushType pushType) {
            this.pushType = pushType;
            return this;
        }

        public Builder notifyId(Integer notifyId) {
            this.notifyId = notifyId;
            return this;
        }

        public Builder addToken(String token) {
            this.token.add(checkNotNull(token));
            return this;
        }

        public RevokeRequest build() {
            return new RevokeRequest(this);
        }
    }

    public String getClientId() {
        return clientId;
    }

    public PushType getPushType() {
        return pushType;
    }

    public Integer getNotifyId() {
        return notifyId;
    }

    public List<String> getToken() {
        return token;
    }
}
