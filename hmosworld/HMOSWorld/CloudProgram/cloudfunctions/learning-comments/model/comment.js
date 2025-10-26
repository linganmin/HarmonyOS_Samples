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

class comment {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'LongAutoIncrement');
        fieldTypeMap.set('path_id', 'String');
        fieldTypeMap.set('username', 'String');
        fieldTypeMap.set('create_time', 'String');
        fieldTypeMap.set('path_name', 'String');
        fieldTypeMap.set('comment', 'Text');
        fieldTypeMap.set('score', 'Integer');
        return fieldTypeMap;
    }

    getClassName() {
        return 'comment';
    }

    getPrimaryKeyList() {
        let primaryKeyList = [];
        primaryKeyList.push('id');
        return primaryKeyList;
    }

    getIndexList() {
        let indexList = [];
        indexList.push('create_time');
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

    setPath_id(path_id) {
        this.path_id = path_id;
    }

    getPath_id() {
        return this.path_id;
    }

    setUsername(username) {
        this.username = username;
    }

    getUsername() {
        return this.username;
    }

    setCreate_time(create_time) {
        this.create_time = create_time;
    }

    getCreate_time() {
        return this.create_time;
    }

    setPath_name(path_name) {
        this.path_name = path_name;
    }

    getPath_name() {
        return this.path_name;
    }

    setComment(comment) {
        this.comment = comment;
    }

    getComment() {
        return this.comment;
    }

    setScore(score) {
        this.score = score;
    }

    getScore() {
        return this.score;
    }
}

module.exports = {comment}