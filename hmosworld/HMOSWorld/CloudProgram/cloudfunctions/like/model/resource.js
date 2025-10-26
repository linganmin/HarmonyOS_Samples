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

class resource {
    getFieldTypeMap() {
        let fieldTypeMap = new Map();
        fieldTypeMap.set('id', 'String');
        fieldTypeMap.set('title', 'String');
        fieldTypeMap.set('brief', 'String');
        fieldTypeMap.set('type', 'String');
        fieldTypeMap.set('web_url', 'Text');
        fieldTypeMap.set('tag', 'Integer');
        fieldTypeMap.set('media_src', 'Text');
        fieldTypeMap.set('header_src', 'Text');
        fieldTypeMap.set('banner_src', 'Text');
        fieldTypeMap.set('publish_date', 'Date');
        fieldTypeMap.set('views_count', 'Integer');
        fieldTypeMap.set('likes_count', 'Integer');
        fieldTypeMap.set('collect_count', 'Integer');
        fieldTypeMap.set('related', 'String');
        fieldTypeMap.set('topics', 'String');
        return fieldTypeMap;
    }

    getClassName() {
        return 'resource';
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

    setTitle(title) {
        this.title = title;
    }

    getTitle() {
        return this.title;
    }

    setBrief(brief) {
        this.brief = brief;
    }

    getBrief() {
        return this.brief;
    }

    setType(type) {
        this.type = type;
    }

    getType() {
        return this.type;
    }

    setWeb_url(web_url) {
        this.web_url = web_url;
    }

    getWeb_url() {
        return this.web_url;
    }

    setTag(tag) {
        this.tag = tag;
    }

    getTag() {
        return this.tag;
    }

    setMedia_src(media_src) {
        this.media_src = media_src;
    }

    getMedia_src() {
        return this.media_src;
    }

    setHeader_src(header_src) {
        this.header_src = header_src;
    }

    getHeader_src() {
        return this.header_src;
    }

    setBanner_src(banner_src) {
        this.banner_src = banner_src;
    }

    getBanner_src() {
        return this.banner_src;
    }

    setPublish_date(publish_date) {
        this.publish_date = publish_date;
    }

    getPublish_date() {
        return this.publish_date;
    }

    setViews_count(views_count) {
        this.views_count = views_count;
    }

    getViews_count() {
        return this.views_count;
    }

    setLikes_count(likes_count) {
        this.likes_count = likes_count;
    }

    getLikes_count() {
        return this.likes_count;
    }

    setCollect_count(collect_count) {
        this.collect_count = collect_count;
    }

    getCollect_count() {
        return this.collect_count;
    }

    setRelated(related) {
        this.related = related;
    }

    getRelated() {
        return this.related;
    }

    setTopics(topics) {
        this.topics = topics;
    }

    getTopics() {
        return this.topics;
    }
}

module.exports = {resource}