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

package com.huawei.push.model.message.payload;

import com.huawei.push.model.message.Scenario;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.huawei.push.utils.CheckUtils.checkNotNull;

/**
 * FormPayload.
 */
public class FormPayload implements Scenario {
    private final Long formId;
    private final Integer version;
    private final List<FormImage> images;
    private final String moduleName;
    private final String formName;
    private final String abilityName;
    private final Map<String, Object> formData;

    private FormPayload(Builder builder) {
        this.formId = checkNotNull(builder.formId);
        this.version = checkNotNull(builder.version);
        this.images = builder.images;
        this.moduleName = checkNotNull(builder.moduleName);
        this.formName = checkNotNull(builder.formName);
        this.abilityName = checkNotNull(builder.abilityName);
        this.formData = builder.formData;
    }

    public static Builder builder() {
        return new Builder();
    }

    @Override
    public int pushType() {
        return PushType.FORM.getVal();
    }

    public static final class Builder {
        private Long formId;
        private Integer version;
        private final List<FormImage> images = new ArrayList<>();
        private String moduleName;
        private String formName;
        private String abilityName;
        private final Map<String, Object> formData = new HashMap<>();

        private Builder() {
        }

        public Builder formId(Long formId) {
            this.formId = formId;
            return this;
        }

        public Builder version(Integer version) {
            this.version = version;
            return this;
        }

        public Builder addImage(FormImage image) {
            this.images.add(image);
            return this;
        }

        public Builder moduleName(String moduleName) {
            this.moduleName = moduleName;
            return this;
        }

        public Builder formName(String formName) {
            this.formName = formName;
            return this;
        }

        public Builder abilityName(String abilityName) {
            this.abilityName = abilityName;
            return this;
        }

        public Builder putFormData(String key, Object val) {
            this.formData.put(checkNotNull(key), checkNotNull(val));
            return this;
        }

        public FormPayload build() {
            return new FormPayload(this);
        }
    }

    public Long getFormId() {
        return formId;
    }

    public Integer getVersion() {
        return version;
    }

    public List<FormImage> getImages() {
        return images;
    }

    public String getModuleName() {
        return moduleName;
    }

    public String getFormName() {
        return formName;
    }

    public String getAbilityName() {
        return abilityName;
    }

    public Map<String, Object> getFormData() {
        return formData;
    }
}
