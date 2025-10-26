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

import { cloudDatabase } from '@kit.CloudFoundationKit';
import CloudDatabaseConstants from '../../common/constants/CloudDatabaseConstants';
import Logger from '../../common/utils/Logger';
import { News } from './News';

const TAG = '[NewsDB]';
const agcDataBase: cloudDatabase.DatabaseZone = cloudDatabase.zone(CloudDatabaseConstants.DEFAULT_ZONE);

class NewsDB {

  private allRecords: News[] = [];

  getNewsList() {
    return this.queryRecord(new cloudDatabase.DatabaseQuery(News).orderByDesc('pubDate'));
  }

  getNewsByNewsId(newsId: string) {
    if (!newsId) {
      return Promise.resolve(null);
    }
    return this.queryRecord(new cloudDatabase.DatabaseQuery(News).equalTo("newsId", Number(newsId)));
  }

  getNewsByNewsType(newsType: string) {
    return this.queryRecord(new cloudDatabase.DatabaseQuery(News).orderByDesc('pubDate').equalTo("newsType", newsType));
  }

  orderByViewCount() {
    return this.queryRecord(new cloudDatabase.DatabaseQuery(News).orderByDesc('viewCount'));
  }

  private queryRecord(condition: cloudDatabase.DatabaseQuery<News>): Promise<News[]> {
    return new Promise((resolve, reject) => {
      agcDataBase.query(condition).then(result => {
        Logger.showInfo(TAG, 'query success : %{public}s', JSON.stringify(result));
        this.allRecords = result;
        resolve(result);
      }).catch((err: Error) => {
        Logger.showError(TAG, 'queryRecord err %{public}s', JSON.stringify(err));
        reject([]);
      });
    })

  }

  updateNewsViewCount(item: News) {
    let viewCount: number = item.viewCount;
    viewCount++;
    item.viewCount = viewCount;

    agcDataBase.upsert(item).then(() => {
      this.allRecords = this.allRecords.map((record: News) => {
        if (record.newsId === item.newsId) {
          Logger.showInfo(TAG, 'record: %{public}s', JSON.stringify(record));
          record.viewCount = item.viewCount;
        }
        return record;
      });
    }).catch((err: Error) => {
      Logger.showError(TAG, 'upsert err %{public}s', JSON.stringify(err));
    });
  }
}

let db = new NewsDB();
export default db;