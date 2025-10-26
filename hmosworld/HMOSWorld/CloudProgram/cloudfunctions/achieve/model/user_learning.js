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

class user_learning {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'String');
        fieldTypeMap.set('user_id', 'String');
        fieldTypeMap.set('path_id', 'String');
        fieldTypeMap.set('learned_time', 'Date');
        return fieldTypeMap;
    }

    getClassName() {
        return 'user_learning';
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

    setUser_id(user_id) {
        this.user_id = user_id;
    }

    getUser_id() {
        return this.user_id;
    }

    setPath_id(path_id) {
        this.path_id = path_id;
    }

    getPath_id() {
        return this.path_id;
    }

    setLearned_time(learned_time) {
        this.learned_time = learned_time;
    }

    getLearned_time() {
        return this.learned_time;
    }
}

module.exports = {user_learning}