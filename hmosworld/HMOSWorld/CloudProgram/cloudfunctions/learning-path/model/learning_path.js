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

class learning_path {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'String');
        fieldTypeMap.set('zone', 'String');
        fieldTypeMap.set('tag', 'String');
        fieldTypeMap.set('title', 'String');
        fieldTypeMap.set('url', 'String');
        fieldTypeMap.set('brief', 'Text');
        return fieldTypeMap;
    }

    getClassName() {
        return 'learning_path';
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

    setZone(zone) {
        this.zone = zone;
    }

    getZone() {
        return this.zone;
    }

    setTag(tag) {
        this.tag = tag;
    }

    getTag() {
        return this.tag;
    }

    setTitle(title) {
        this.title = title;
    }

    getTitle() {
        return this.title;
    }

    setUrl(url) {
        this.url = url;
    }

    getUrl() {
        return this.url;
    }

    setBrief(brief) {
        this.brief = brief;
    }

    getBrief() {
        return this.brief;
    }
}

module.exports = {learning_path}