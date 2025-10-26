/*
 * Copyright 2020. Huawei Technologies Co., Ltd. All rights reserved.

 * Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package com.huawei.hms.safetydetect.sample.sysintegrity.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.util.Base64;
import java.util.List;

/**
 * Description: JSON Web Signature
 *
 */
public class Jws {

    private JwsHeader header;

    private JwsPayload payload;

    private String signContent;

    private byte[] signature;

    private String token;

    public Jws(String jwsStr) throws IOException {
        token = jwsStr;
        String[] jwsSplit = jwsStr.split("\\.");
        ObjectMapper objectMapper = new ObjectMapper();
        header = objectMapper.readValue(Base64.getUrlDecoder().decode(jwsSplit[0]), JwsHeader.class);
        payload = objectMapper.readValue(Base64.getUrlDecoder().decode(jwsSplit[1]), JwsPayload.class);
        int index = jwsStr.lastIndexOf(".");
        signContent = jwsStr.substring(0, index);
        signature = Base64.getUrlDecoder().decode(jwsSplit[2]);
    }

    public String getToken() {
		return token;
	}

    public JwsHeader getHeader() {
        return header;
    }

    public void setHeader(JwsHeader header) {
        this.header = header;
    }

    public JwsPayload getPayload() {
        return payload;
    }

    public void setPayload(JwsPayload payload) {
        this.payload = payload;
    }

    public String getSignContent() {
        return signContent;
    }

    public void setSignContent(String signContent) {
        this.signContent = signContent;
    }

    public byte[] getSignature() {
        return signature;
    }

    public void setSignature(byte[] signature) {
        this.signature = signature;
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class JwsHeader {

        private String alg;

        private List<String> x5c;

        private String typ;

        public String getAlg() {
            return alg;
        }

        public void setAlg(String alg) {
            this.alg = alg;
        }

        public List<String> getX5c() {
            return x5c;
        }

        public void setX5c(List<String> x5c) {
            this.x5c = x5c;
        }

        public String getTyp() {
            return typ;
        }

        public void setTyp(String typ) {
            this.typ = typ;
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class JwsPayload {

        private String hapCertificateSha256;

        private String hapBundleName;

        private String appId;

        private boolean basicIntegrity;

        private List<String> detail;

        private String nonce;

        private String timestamp;

        public String getHapCertificateSha256() {
            return hapCertificateSha256;
        }

        public void setHapCertificateSha256(String hapCertificateSha256) {
            this.hapCertificateSha256 = hapCertificateSha256;
        }

        public String getHapBundleName() {
            return hapBundleName;
        }

        public void setHapBundleName(String hapBundleName) {
            this.hapBundleName = hapBundleName;
        }

        public String getAppId() {
            return appId;
        }

        public void setAppId(String appId) {
            this.appId = appId;
        }

        public boolean isBasicIntegrity() {
            return basicIntegrity;
        }

        public void setBasicIntegrity(boolean basicIntegrity) {
            this.basicIntegrity = basicIntegrity;
        }

        public List<String> getDetail() {
            return detail;
        }

        public void setDetail(List<String> detail) {
            this.detail = detail;
        }

        public String getNonce() {
            return nonce;
        }

        public void setNonce(String nonce) {
            this.nonce = nonce;
        }

        public String getTimestamp() {
            return timestamp;
        }

        public void setTimestamp(String timestamp) {
            this.timestamp = timestamp;
        }

        @Override
        public String toString() {
            try {
                return new ObjectMapper().writeValueAsString(this);
            } catch (JsonProcessingException e) {
                return "Exception encountered: JsonProcessingException";
            }
        }
    }
}
