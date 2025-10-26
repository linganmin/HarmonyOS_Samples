/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

import { relationalStore } from '@kit.ArkData';

type PrimaryKeyType = number | string;

export interface TableApi<T> {
  /**
   * The method of inserting a data information.
   * @param { T } data data entities that need to be inserted.
   * @returns { Promise<number> } Returns primary key information for inserting data, and -1 if it fails.
   */
  insert(data: T): Promise<number>;

  /**
   * The method of batch inserting data information.
   * @param { T[] } dataList data entities List that need to be inserted.
   * @returns { Promise<number[]> } Returns rows count for inserting data, and -1 if it fails.
   */
  batchInsert(dataList: T[]): Promise<number>;

  /**
   * The method of deleting a data information.
   * @param { PrimaryKeyType } primaryKey primary key of row that need to be deleted.
   * @returns { Promise<boolean> } returns the deleted result.
   */
  delete(primaryKey: PrimaryKeyType): Promise<boolean>;

  /**
   * The method of updating a data information.
   * @param { PrimaryKeyType } primaryKey primary key of row that need to be updated.
   * @param { T } data data entities that need to be updated.
   * @returns { Promise<boolean> } returns the updated result.
   */
  update(primaryKey: PrimaryKeyType, data: T): Promise<boolean>;

  /**
   * The method of querying a data information.
   * @param { string } querySql the query sql statement that needs to be executed.
   * @returns { Promise<T[]> } returns the list of data that were queried.
   */
  query(querySql: string): Promise<T[]>;

  /**
   * The method of querying a data information by primary key.
   * @param { PrimaryKeyType } primaryKey primary key of row that need to be queried.
   * @returns { Promise<T | null> } returns the data that were queried.
   */
  queryByKey(primaryKey: PrimaryKeyType): Promise<T | null>;

  /**
   * convert entity information to a ValuesBucket type.
   * @param { T } data T entity information.
   * @param { boolean } excludePrimary Whether to exclude the conversion of the primary key.
   * @returns { relationalStore.ValuesBucket }  ValuesBucket of T.
   */
  convertEntity2ValuesBucket(data: T, excludePrimary: boolean): relationalStore.ValuesBucket;

  /**
   * convert ResultSet to entity information.
   * @param { relationalStore.ResultSet } resultSet a database result set.
   * @returns { T } T entity information.
   */
  convertResultSet2Entity(resultSet: relationalStore.ResultSet): T;
}