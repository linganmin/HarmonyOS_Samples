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

import ColumnInfo from '../model/ColumnModel';

export class RdbConstants {
  // database name
  static readonly DATABASE_NAME: string = 'HealthyLife.db';
  // database table name of day info
  static readonly TABLE_OF_DAY: string = 'dayInfo';
  // database table name of task info
  static readonly TABLE_OF_TASK: string = 'taskInfo';
  // database table name of day and task info
  static readonly TABLE_OF_DAY_TASK: string = 'dayTaskInfo';
  // database table name of form info
  static readonly TABLE_OF_FORM: string = 'formInfo';
  // database table name list
  static readonly TABLE_NAME_LIST: string[] = [
    this.TABLE_OF_DAY,
    this.TABLE_OF_TASK,
    this.TABLE_OF_DAY_TASK,
    this.TABLE_OF_FORM
  ];
  // column information for database tables of day info
  static readonly COLUMNS_OF_DAY: ColumnInfo[] = [
    new ColumnInfo('date', 'text', 8, false, true, false),
    new ColumnInfo('targetTaskNum', 'integer', 2, false, false, false),
    new ColumnInfo('finTaskNum', 'integer', 2, false, false, false)
  ];
  // column information for database tables of task info
  static readonly COLUMNS_OF_TASK: ColumnInfo[] = [
    new ColumnInfo('taskId', 'integer', 2, false, true, false),
    new ColumnInfo('isOpen', 'boolean', -1, false, false, false),
    new ColumnInfo('targetValue', 'text', -1, false, false, false),
    new ColumnInfo('finValue', 'text', -1, false, false, false),
    new ColumnInfo('isDone', 'boolean', -1, false, false, false),
    new ColumnInfo('isAlert', 'boolean', -1, false, false, false),
    new ColumnInfo('alertStartTime', 'text', -1, true, false, false),
    new ColumnInfo('alertEndTime', 'text', -1, true, false, false),
    new ColumnInfo('alertFrequency', 'text', -1, true, false, false),
    new ColumnInfo('reminderId', 'integer', -1, true, false, false)
  ];
  // column information for database tables of day and task info
  static readonly COLUMNS_OF_DAY_TASK: ColumnInfo[] = [
    new ColumnInfo('id', 'integer', -1, false, true, true),
    new ColumnInfo('date', 'text', 8, false, false, false),
    new ColumnInfo('taskId', 'integer', 2, false, false, false),
    new ColumnInfo('targetValue', 'text', -1, false, false, false),
    new ColumnInfo('finValue', 'text', -1, false, false, false),
    new ColumnInfo('isDone', 'boolean', -1, false, false, false)
  ];
  // column information for database tables of day info
  static readonly COLUMNS_OF_FORM: ColumnInfo[] = [
    new ColumnInfo('formId', 'text', -1, false, true, false),
    new ColumnInfo('formName', 'text', -1, false, false, false),
    new ColumnInfo('formDimension', 'text', -1, false, false, false)
  ];
  // database tables and columns information mapping
  static readonly TABLE_COLUMNS_MAPPING: Record<string, ColumnInfo[]> = {
    'dayInfo': this.COLUMNS_OF_DAY,
    'taskInfo': this.COLUMNS_OF_TASK,
    'dayTaskInfo': this.COLUMNS_OF_DAY_TASK,
    'formInfo': this.COLUMNS_OF_FORM
  }
}