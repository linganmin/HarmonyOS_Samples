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

class News {
    newsId: number;
    title: string = '';
    content: string = '';
    newsType: string = '图文';
    pubUserName: string;
    pubUserAvatar: string;
    pubDate: Date;
    viewCount: number;

    constructor() {
    }

    getFieldTypeMap():  Map<string, string> {
        let fieldTypeMap = new Map<string, string>();
        fieldTypeMap.set('newsId', 'LongAutoIncrement');
        fieldTypeMap.set('title', 'String');
        fieldTypeMap.set('content', 'Text');
        fieldTypeMap.set('newsType', 'String');
        fieldTypeMap.set('pubUserName', 'String');
        fieldTypeMap.set('pubUserAvatar', 'String');
        fieldTypeMap.set('pubDate', 'Date');
        fieldTypeMap.set('viewCount', 'Integer');
        return fieldTypeMap;
    }

    getClassName(): string {
        return 'News';
    }

    getPrimaryKeyList(): string[] {
        let primaryKeyList: string[] = [];
        primaryKeyList.push('newsId');
        return primaryKeyList;
    }

    getIndexList(): string[] {
        let indexList: string[] = [];
        indexList.push('viewCount');
        indexList.push('newsId');
        indexList.push('pubDate');
        return indexList;
    }

    getEncryptedFieldList(): string[] {
        let encryptedFieldList: string[] = [];
        return encryptedFieldList;
    }

    setNewsId(newsId: number): void {
        this.newsId = newsId;
    }

    getNewsId(): number  {
        return this.newsId;
    }

    setTitle(title: string): void {
        this.title = title;
    }

    getTitle(): string  {
        return this.title;
    }

    setContent(content: string): void {
        this.content = content;
    }

    getContent(): string  {
        return this.content;
    }

    setNewsType(newsType: string): void {
        this.newsType = newsType;
    }

    getNewsType(): string  {
        return this.newsType;
    }

    setPubUserName(pubUserName: string): void {
        this.pubUserName = pubUserName;
    }

    getPubUserName(): string  {
        return this.pubUserName;
    }

    setPubUserAvatar(pubUserAvatar: string): void {
        this.pubUserAvatar = pubUserAvatar;
    }

    getPubUserAvatar(): string  {
        return this.pubUserAvatar;
    }

    setPubDate(pubDate: Date): void {
        this.pubDate = pubDate;
    }

    getPubDate(): Date  {
        return this.pubDate;
    }

    setViewCount(viewCount: number): void {
        this.viewCount = viewCount;
    }

    getViewCount(): number  {
        return this.viewCount;
    }

    static parseFrom(inputObject: any): News {
        let result = new News();
        if (!inputObject) {
            return result;
        }
        if (inputObject.newsId) {
            result.newsId = inputObject.newsId;
        }
        if (inputObject.title) {
            result.title = inputObject.title;
        }
        if (inputObject.content) {
            result.content = inputObject.content;
        }
        if (inputObject.newsType) {
            result.newsType = inputObject.newsType;
        }
        if (inputObject.pubUserName) {
            result.pubUserName = inputObject.pubUserName;
        }
        if (inputObject.pubUserAvatar) {
            result.pubUserAvatar = inputObject.pubUserAvatar;
        }
        if (inputObject.pubDate) {
            result.pubDate = new Date(inputObject.pubDate);
        }
        if (inputObject.viewCount) {
            result.viewCount = inputObject.viewCount;
        }
        return result;
    }
}

export { News };