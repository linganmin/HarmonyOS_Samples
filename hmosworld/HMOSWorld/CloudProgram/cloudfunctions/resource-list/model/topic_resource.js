/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

class topic_resource {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'String');
        fieldTypeMap.set('resource_id', 'String');
        fieldTypeMap.set('topic_id', 'String');
        fieldTypeMap.set('type', 'String');
        return fieldTypeMap;
    }

    getClassName() {
        return 'topic_resource';
    }

    getPrimaryKeyList() {
        let primaryKeyList = [];
        primaryKeyList.push('id');
        return primaryKeyList;
    }

    getIndexList() {
        let indexList = [];
        return indexList;
    }

    getEncryptedFieldList() {
        let encryptedFieldList = [];
        return encryptedFieldList;
    }

    setId(id) {
        this.id = id;
    }

    getId() {
        return this.id;
    }

    setResource_id(resource_id) {
        this.resource_id = resource_id;
    }

    getResource_id() {
        return this.resource_id;
    }

    setTopic_id(topic_id) {
        this.topic_id = topic_id;
    }

    getTopic_id() {
        return this.topic_id;
    }

    setType(type) {
        this.type = type;
    }

    getType() {
        return this.type;
    }
}

module.exports = {topic_resource}