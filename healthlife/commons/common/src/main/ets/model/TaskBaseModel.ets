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

import { CommonConstants as Const, PickerType } from '../constants/CommonConstants';

export class TaskBaseInfo {
  id: number;
  name: Resource;
  icon: Resource;
  dialog: Resource;
  unit: ResourceStr;
  step: number;
  limit: string;
  pickerType: PickerType;
  pickerRange: string[];

  constructor(id: number, name: Resource, icon: Resource, dialog: Resource, unit: ResourceStr, step: number,
    range: string, pickerType: PickerType, pickerRange: string[]) {
    this.id = id;
    this.name = name;
    this.icon = icon;
    this.dialog = dialog;
    this.unit = unit;
    this.step = step;
    this.limit = range;
    this.pickerType = pickerType;
    this.pickerRange = pickerRange;
  }
}

// default
export const taskBaseInfoList: TaskBaseInfo[] = [
  new TaskBaseInfo(0, $r('app.string.task_getup'), $r('app.media.ic_task_getup'),
    $r('app.media.ic_dialog_getup'), '', 0, '06:00 - 09:00', PickerType.TIME, []),
  new TaskBaseInfo(1, $r('app.string.task_drink'), $r('app.media.ic_task_drink'),
    $r('app.media.ic_dialog_drink'), $r('app.string.unit_liter'), 0.5, '', PickerType.TEXT, Const.PICKER_RANGE_DRINK),
  new TaskBaseInfo(2, $r('app.string.task_apple'), $r('app.media.ic_task_apple'),
    $r('app.media.ic_dialog_apple'), $r('app.string.unit_number'), 1, '', PickerType.TEXT, Const.PICKER_RANGE_APPLE),
  new TaskBaseInfo(3, $r('app.string.task_smile'), $r('app.media.ic_task_smile'),
    $r('app.media.ic_dialog_smile'), $r('app.string.unit_times'), 0, '', PickerType.NONE, []),
  new TaskBaseInfo(4, $r('app.string.task_brush'), $r('app.media.ic_task_brush'),
    $r('app.media.ic_dialog_brush'), $r('app.string.unit_times'), 0, '', PickerType.NONE, []),
  new TaskBaseInfo(5, $r('app.string.task_sleep'), $r('app.media.ic_task_sleep'),
    $r('app.media.ic_dialog_sleep'), '', 0, '20:00 - 23:00', PickerType.TIME, [])
]