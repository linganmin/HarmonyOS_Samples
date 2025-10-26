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

import { DayTaskInfo } from './DayTaskInfo';

export class TaskInfo {
  taskId: number;
  isOpen: boolean;
  targetValue: string;
  finValue: string;
  isDone: boolean;
  isAlert: boolean;
  alertStartTime: string;
  alertEndTime: string;
  alertFrequency: string;
  reminderId: number;

  constructor(taskId: number, isOpen: boolean, targetValue: string, finValue: string, isDone: boolean, isAlert: boolean,
    alertStartTime: string, alertEndTime: string, alertFrequency: string, reminderId: number) {
    this.taskId = taskId;
    this.isOpen = isOpen;
    this.targetValue = targetValue;
    this.finValue = finValue;
    this.isDone = isDone;
    this.isAlert = isAlert;
    this.alertStartTime = alertStartTime;
    this.alertEndTime = alertEndTime;
    this.alertFrequency = alertFrequency;
    this.reminderId = reminderId
  }

  toString(): string {
    return `TaskInfo[` +
      `taskId: ${this.taskId}, ` +
      `isOpen: ${this.isOpen}, ` +
      `targetValue: ${this.targetValue}, ` +
      `finValue: ${this.finValue}, ` +
      `isDone: ${this.isDone}, ` +
      `isAlert: ${this.isAlert}, ` +
      `alertStartTime: ${this.alertStartTime}, ` +
      `alertEndTime: ${this.alertEndTime}, ` +
      `alertFrequency: ${this.alertFrequency}, ` +
      `reminderId: ${this.reminderId}` +
      `]`;
  }

  deepClone(): TaskInfo {
    return new TaskInfo(
      this.taskId,
      this.isOpen,
      this.targetValue,
      this.finValue,
      this.isDone,
      this.isAlert,
      this.alertStartTime,
      this.alertEndTime,
      this.alertFrequency,
      this.reminderId
    );
  }

  isTaskEqual(otherTask: TaskInfo): boolean {
    return this.taskId === otherTask.taskId
      && this.isOpen === otherTask.isOpen
      && this.targetValue === otherTask.targetValue
      && this.finValue === otherTask.finValue
      && this.isDone === otherTask.isDone
      && this.isAlert === otherTask.isAlert
      && this.alertStartTime === otherTask.alertStartTime
      && this.alertEndTime === otherTask.alertEndTime
      && this.alertFrequency === otherTask.alertFrequency
      && this.reminderId === otherTask.reminderId
  }

  convert2DayTask(date: string): DayTaskInfo {
    return new DayTaskInfo(0, date, this.taskId, this.targetValue, this.finValue, this.isDone);
  }

  convert2DefaultDayTask(date: string): DayTaskInfo {
    return new DayTaskInfo(0, date, this.taskId, this.targetValue, '', false);
  }
}

export const defaultTaskInfoList: TaskInfo[] = [
  new TaskInfo(0, false, '08:00', '', false, false, '', '', '', -1),
  new TaskInfo(1, false, '1', '', false, false, '', '', '', -1),
  new TaskInfo(2, false, '1', '', false, false, '', '', '', -1),
  new TaskInfo(3, false, '1', '', false, false, '', '', '', -1),
  new TaskInfo(4, false, '1', '', false, false, '', '', '', -1),
  new TaskInfo(5, false, '23:00', '', false, false, '', '', '', -1)
];