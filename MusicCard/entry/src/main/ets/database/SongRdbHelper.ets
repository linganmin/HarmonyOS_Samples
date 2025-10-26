/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { relationalStore } from '@kit.ArkData';
import { Logger } from '../utils/Logger';
import { RdbUtils } from './RdbUtils';
import { SongItem } from '../viewmodel/SongItem';

const TAG = 'SongRdbHelper';

const SQL_CREATE_TABLE: string =
  'CREATE TABLE IF NOT EXISTS SongItemTable(' +
  'songId STRING PRIMARY KEY,' +
  'title STRING,' +
  'singer STRING,' +
  'mark STRING,' +
  'label STRING,' +
  'src STRING,' +
  'lyric STRING,' +
  'isCollected string)';

const TABLE_NAME = 'SongItemTable';
let rdbUtils: RdbUtils;

export class SongRdbHelper {
  private static instance: SongRdbHelper;

  private constructor(context: Context) {
    Logger.info(TAG, `constructor Context: ${context}`);
    rdbUtils = new RdbUtils(context, TABLE_NAME, SQL_CREATE_TABLE);
  }

  public static getInstance(context: Context): SongRdbHelper {
    if (!SongRdbHelper.instance) {
      SongRdbHelper.instance = new SongRdbHelper(context);
    }
    return SongRdbHelper.instance;
  }

  public insertSongs(songs: Array<SongItem>): Promise<number> {
    Logger.info(TAG, `insertSong songs length: ${songs.length}`);
    let valueBucketArray: relationalStore.ValuesBucket[] = [];
    songs.forEach((songItem) => {
      let valueBucket = this.generateBucket(songItem);
      valueBucketArray.push(valueBucket);
    });
    return rdbUtils.batchInsert(valueBucketArray);
  }

  public insertSong(songItem: SongItem): Promise<number> {
    Logger.info(TAG, `insertSong songItem: ${JSON.stringify(songItem)}`);
    let valueBucket = this.generateBucket(songItem);
    return rdbUtils.insertData(valueBucket);
  }

  public updateSong(songItem: SongItem): Promise<number> {
    Logger.info(TAG, `updateForm formId: ${songItem.id}`);
    let valueBucket = this.generateBucket(songItem);
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('songId', songItem.id);
    return rdbUtils.updateData(predicates, valueBucket);
  }

  public queryAllSongs(): Promise<Array<SongItem>> {
    Logger.info(TAG, 'queryAllSong');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    return this.querySong(predicates);
  }

  public async querySongById(songId: string): Promise<SongItem | undefined> {
    Logger.info(TAG, 'querySongById');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('songId', songId);
    let songs = await this.querySong(predicates);
    if (songs.length > 0) {
      return songs[0];
    } else {
      return undefined;
    }
  }

  public queryCollectedSongs(): Promise<Array<SongItem>> {
    Logger.info(TAG, 'queryCollectedSongs');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('isCollected', '1');
    return this.querySong(predicates);
  }

  public isCollected(songId: string): Promise<boolean> {
    Logger.info(TAG, 'isCollected');
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('isCollected', '1');
    predicates.equalTo('songId', songId);
    return new Promise(async (resolve) => {
      let songs = await this.querySong(predicates);
      if (songs.length > 0) {
        resolve(true);
      } else {
        resolve(false);
      }
    });
  }

  public updateCollected(songId: string, state: string): Promise<number> {
    Logger.info(TAG, `updateCollected songId: ${songId}`);
    let valueBucket: relationalStore.ValuesBucket = {
      isCollected: state,
    };
    let predicates = new relationalStore.RdbPredicates(TABLE_NAME);
    predicates.equalTo('songId', songId);
    return rdbUtils.updateData(predicates, valueBucket);
  }

  private querySong(predicates: relationalStore.RdbPredicates): Promise<Array<SongItem>> {
    Logger.info(TAG, 'querySong');
    return new Promise<Array<SongItem>>(async (resolve, reject) => {
      let songList: Array<SongItem> = [];
      let resultSet = await rdbUtils.query(predicates);
      try {
        while (resultSet.goToNextRow()) {
          let songItem: SongItem = new SongItem();
          songItem.id = resultSet.getValue(resultSet.getColumnIndex('songId')) as string;
          songItem.title = resultSet.getValue(resultSet.getColumnIndex('title')) as string;
          songItem.singer = resultSet.getValue(resultSet.getColumnIndex('singer')) as string;
          songItem.mark = resultSet.getValue(resultSet.getColumnIndex('mark')) as string;
          songItem.label = JSON.parse(resultSet.getValue(resultSet.getColumnIndex('label')) as string) as Resource;
          songItem.src = resultSet.getValue(resultSet.getColumnIndex('src')) as string;
          songItem.lyric = resultSet.getValue(resultSet.getColumnIndex('lyric')) as string;
          let isCollected = resultSet.getValue(resultSet.getColumnIndex('isCollected'))?.toString();
          songItem.isCollected = isCollected === '1';
          songList.push(songItem);
        }
        resultSet.close();
        Logger.info(TAG, `querySong songList: ${JSON.stringify(songList)}`);
        resolve(songList);
      } catch (err) {
        Logger.error(TAG, `querySong catch err: ${JSON.stringify(err)}`);
        reject(err);
      }
    });
  }

  private generateBucket(songItem: SongItem): relationalStore.ValuesBucket {
    let valueBucket: relationalStore.ValuesBucket = {
      songId: songItem.id,
      title: songItem.title,
      singer: songItem.singer,
      mark: songItem.mark,
      label: JSON.stringify(songItem.label),
      src: songItem.src,
      lyric: songItem.lyric,
      isCollected: songItem.isCollected ? '1' : '0',
    };
    return valueBucket;
  }
}
