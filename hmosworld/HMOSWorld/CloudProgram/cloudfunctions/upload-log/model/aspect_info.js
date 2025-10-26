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

class aspect_info {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('versionName', 'String');
        fieldTypeMap.set('methodClassName', 'String');
        fieldTypeMap.set('methodName', 'String');
        fieldTypeMap.set('params', 'String');
        fieldTypeMap.set('type', 'String');
        fieldTypeMap.set('createTime', 'Date');
        fieldTypeMap.set('id', 'IntAutoIncrement');
        fieldTypeMap.set('time', 'String');
        fieldTypeMap.set('isStatic', 'Boolean');
        return fieldTypeMap;
    }

    getClassName() {
        return 'aspect_info';
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

    setVersionName(versionName) {
        this.versionName = versionName;
    }

    getVersionName() {
        return this.versionName;
    }

    setMethodClassName(methodClassName) {
        this.methodClassName = methodClassName;
    }

    getMethodClassName() {
        return this.methodClassName;
    }

    setMethodName(methodName) {
        this.methodName = methodName;
    }

    getMethodName() {
        return this.methodName;
    }

    setParams(params) {
        this.params = params;
    }

    getParams() {
        return this.params;
    }

    setType(type) {
        this.type = type;
    }

    getType() {
        return this.type;
    }

    setCreateTime(createTime) {
        this.createTime = createTime;
    }

    getCreateTime() {
        return this.createTime;
    }

    setId(id) {
        this.id = id;
    }

    getId() {
        return this.id;
    }

    setTime(time) {
        this.time = time;
    }

    getTime() {
        return this.time;
    }

    setIsStatic(isStatic) {
        this.isStatic = isStatic;
    }

    getIsStatic() {
        return this.isStatic;
    }
}

module.exports = {aspect_info}