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

export class DayTaskInfo {
  id: number;
  date: string;
  taskId: number;
  targetValue: string;
  finValue: string;
  isDone: boolean;

  constructor(id: number, date: string, taskId: number, targetValue: string, finValue: string, isDone: boolean) {
    this.id = id;
    this.date = date;
    this.taskId = taskId;
    this.targetValue = targetValue;
    this.finValue = finValue;
    this.isDone = isDone;
  }

  toString(): string {
    return `DayTaskInfo[` +
      `id: ${this.id}, ` +
      `date: ${this.date}, ` +
      `taskId: ${this.taskId}, ` +
      `targetValue: ${this.targetValue}, ` +
      `finValue: ${this.finValue}, ` +
      `isDone: ${this.isDone}` +
      `]`;
  }
}