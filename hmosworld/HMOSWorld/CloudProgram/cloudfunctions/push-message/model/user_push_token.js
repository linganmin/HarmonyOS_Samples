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

class user_push_token {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'LongAutoIncrement');
        fieldTypeMap.set('device_id', 'String');
        fieldTypeMap.set('user_id', 'String');
        fieldTypeMap.set('push_token', 'String');
        fieldTypeMap.set('state', 'Integer');
        fieldTypeMap.set('create_time', 'String');
        fieldTypeMap.set('update_time', 'String');
        return fieldTypeMap;
    }

    getClassName() {
        return 'user_push_token';
    }

    getPrimaryKeyList() {
        let primaryKeyList = [];
        primaryKeyList.push('id');
        return primaryKeyList;
    }

    getIndexList() {
        let indexList = [];
        indexList.push('device_id');
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

    setDevice_id(device_id) {
        this.device_id = device_id;
    }

    getDevice_id() {
        return this.device_id;
    }

    setUser_id(user_id) {
        this.user_id = user_id;
    }

    getUser_id() {
        return this.user_id;
    }

    setPush_token(push_token) {
        this.push_token = push_token;
    }

    getPush_token() {
        return this.push_token;
    }

    setState(state) {
        this.state = state;
    }

    getState() {
        return this.state;
    }

    setCreate_time(create_time) {
        this.create_time = create_time;
    }

    getCreate_time() {
        return this.create_time;
    }

    setUpdate_time(update_time) {
        this.update_time = update_time;
    }

    getUpdate_time() {
        return this.update_time;
    }
}

module.exports = {user_push_token}