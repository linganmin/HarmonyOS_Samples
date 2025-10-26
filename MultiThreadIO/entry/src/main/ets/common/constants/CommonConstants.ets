/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export class CommonConstants {
  /**
   * Toast duration time.
   */
  static readonly DURATION_TIME: number = 2000;
  /**
   * File name.
   */
  static readonly FILE_NAME: string = 'test.txt';
  /**
   * Encoding.
   */
  static readonly ENCODING: string = 'utf-8';
  /**
   * Create SQL.
   */
  static readonly SQL_CREATE: string =
    'CREATE TABLE IF NOT EXISTS EMPLOYEE (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, AGE INTEGER, ' +
      'SALARY REAL)';
  /**
   * File suffix.
   */
  static readonly FILE_SUFFIX: string = '.txt';
  /**
   * File prefix.
   */
  static readonly FILE_PREFIX: string = '/file';
}