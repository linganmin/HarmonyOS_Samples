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

class user {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'String');
        fieldTypeMap.set('username', 'String');
        fieldTypeMap.set('password', 'String');
        fieldTypeMap.set('portrait', 'Text');
        fieldTypeMap.set('description', 'String');
        fieldTypeMap.set('phone', 'String');
        fieldTypeMap.set('nickname', 'String');
        fieldTypeMap.set('union_id', 'String');
        fieldTypeMap.set('access_token', 'String');
        fieldTypeMap.set('refresh_token', 'String');
        fieldTypeMap.set('email', 'String');
        fieldTypeMap.set('user_type', 'Integer');
        return fieldTypeMap;
    }

    getClassName() {
        return 'user';
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

    setUsername(username) {
        this.username = username;
    }

    getUsername() {
        return this.username;
    }

    setPassword(password) {
        this.password = password;
    }

    getPassword() {
        return this.password;
    }

    setPortrait(portrait) {
        this.portrait = portrait;
    }

    getPortrait() {
        return this.portrait;
    }

    setDescription(description) {
        this.description = description;
    }

    getDescription() {
        return this.description;
    }

    setPhone(phone) {
        this.phone = phone;
    }

    getPhone() {
        return this.phone;
    }

    setNickname(nickname) {
        this.nickname = nickname;
    }

    getNickname() {
        return this.nickname;
    }

    setUnion_id(union_id) {
        this.union_id = union_id;
    }

    getUnion_id() {
        return this.union_id;
    }

    setAccess_token(access_token) {
        this.access_token = access_token;
    }

    getAccess_token() {
        return this.access_token;
    }

    setRefresh_token(refresh_token) {
        this.refresh_token = refresh_token;
    }

    getRefresh_token() {
        return this.refresh_token;
    }

    setEmail(email) {
        this.email = email;
    }

    getEmail() {
        return this.email;
    }

    setUser_type(user_type) {
        this.user_type = user_type;
    }

    getUser_type() {
        return this.user_type;
    }
}

module.exports = {user}