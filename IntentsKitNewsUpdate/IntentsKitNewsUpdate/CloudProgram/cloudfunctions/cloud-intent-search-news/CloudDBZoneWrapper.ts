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


import { cloud, CloudDBCollection } from '@hw-agconnect/cloud-server';
import { News } from './News';

// database zone
const ZONE_NAME = 'News';

export class CloudDbZoneWrapper {
  collection: CloudDBCollection<News>;

  constructor() {
    this.collection = cloud.database({ zoneName: ZONE_NAME }).collection(News);
  }

  searchNews(blogCategory: string = '', blogAuthor: string = '', keywords: string = '') {
    const hasCategory = !!blogCategory;
    const hasAuthor = !!blogAuthor;
    const hasKeywords = !!keywords;

    // Case 1: No parameters - return all
    if (!hasCategory && !hasAuthor && !hasKeywords) {
      return this.baseQuery().get();
    }

    // Case 2: Only category
    if (hasCategory && !hasAuthor && !hasKeywords) {
      return this.baseQuery().equalTo('newsType', blogCategory).get();
    }

    // Case 3: Only author
    if (!hasCategory && hasAuthor && !hasKeywords) {
      return this.baseQuery().equalTo('pubUserName', blogAuthor).get();
    }

    // Case 4: Only keywords
    if (!hasCategory && !hasAuthor && hasKeywords) {
      const keywordArray = keywords.split(',');
      return keywordArray.length > 1
        ? this.baseQuery().in('title', keywordArray).get()
        : this.baseQuery().contains('title', keywords).get();
    }

    // Case 5: Category + author
    if (hasCategory && hasAuthor && !hasKeywords) {
      return this.baseQuery()
        .equalTo('newsType', blogCategory)
        .equalTo('pubUserName', blogAuthor)
        .get();
    }

    // Case 6: Category + keywords
    if (hasCategory && !hasAuthor && hasKeywords) {
      const keywordArray = keywords.split(',');
      const query = this.baseQuery().equalTo('newsType', blogCategory);
      return keywordArray.length > 1
        ? query.in('title', keywordArray).get()
        : query.contains('title', keywords).get();
    }

    // Case 7: Author + keywords
    if (!hasCategory && hasAuthor && hasKeywords) {
      const keywordArray = keywords.split(',');
      const query = this.baseQuery().equalTo('pubUserName', blogAuthor);
      return keywordArray.length > 1
        ? query.in('title', keywordArray).get()
        : query.contains('title', keywords).get();
    }

    // Case 8: Category + author + keywords
    const keywordArray = keywords.split(',');
    const query = this.baseQuery()
      .equalTo('newsType', blogCategory)
      .equalTo('pubUserName', blogAuthor);

    return keywordArray.length > 1
      ? query.in('title', keywordArray).get()
      : query.contains('title', keywords).get();
  }

  // query data
  async queryNews() {
    let query = this.baseQuery().orderByDesc('pubDate');
    return await query.get();
  }

  async queryLatestNews() {
    let query = this.baseQuery().orderByDesc('pubDate').limit(1, 0);
    return await query.get();
  }

  private baseQuery() {
    return this.collection.query();
  }

  // update data
  async upsertNews(records: News[]) {
    return await this.collection.upsert(records);
  }


  // delete data
  async deleteNews(records: News[]) {
    return await this.collection.delete(records);
  }
}