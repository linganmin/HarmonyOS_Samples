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

import { convertTime2Date, PickerType, TaskBaseInfo, TaskInfo } from 'common';

/**
 * Task goal setting custom dialog parameters.
 */
export class TargetSettingDialogParams {
  taskInfo: TaskInfo;
  taskBaseInfo: TaskBaseInfo;
  selectedValue: string;
  startDate?: Date;
  endDate?: Date;

  constructor(taskInfo: TaskInfo, taskBaseInfo: TaskBaseInfo) {
    this.taskInfo = taskInfo;
    this.taskBaseInfo = taskBaseInfo;
    this.selectedValue = taskInfo.targetValue;
    if (taskBaseInfo.pickerType === PickerType.TIME) {
      const limitArr = taskBaseInfo.limit.split('-');
      this.startDate = convertTime2Date(limitArr[0]);
      this.endDate = convertTime2Date(limitArr[1]);
    }
  }
}