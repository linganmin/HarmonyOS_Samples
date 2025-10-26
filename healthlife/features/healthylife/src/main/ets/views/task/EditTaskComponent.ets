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

import { HomeStore, updateTaskList } from '../../viewmodel/HomeStore';
import TaskInfoApi from 'common/src/main/ets/database/tables/TaskInfoApi';
import { openTargetSettingCustomDialog } from '../dialog/TargetSettingDialog';
import DayTaskInfoApi from 'common/src/main/ets/database/tables/DayTaskInfoApi';
import { TargetSettingDialogParams } from '../../viewmodel/dialog/TargetSettingDialogParams';
import {
  AgentUtils,
  CommonConstants as Const,
  PickerType,
  RequestAuthorization,
  TaskBaseInfo,
  taskBaseInfoList,
  TaskInfo
} from 'common';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'EditTaskComponent'

@Builder
export function editTaskBuilder(_name: string, param: TaskInfo) {
  EditTaskComponent({
    taskInfo: param,
    originalInfo: param.deepClone(),
    taskBaseInfo: taskBaseInfoList[param.taskId]
  });
}

@Extend(Text)
function targetValueStyle(isOpen: boolean, pickerType: PickerType) {
  .fontSize($r('app.float.default_16'))
  .fontColor((isOpen && pickerType !== PickerType.NONE) ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
  .padding({
    right: $r('app.float.default_6')
  })
}

@Component
export struct EditTaskComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @Provide taskInfo: TaskInfo = new TaskInfo(0, false, '', '', false, false, '', '', '', -1);
  @Provide taskBaseInfo: TaskBaseInfo = taskBaseInfoList[this.taskInfo.taskId];
  originalInfo: TaskInfo = this.taskInfo;

  async finishTaskEdit() {
    if (this.originalInfo.isTaskEqual(this.taskInfo)) {
      this.pageStack.clear(true);
      return;
    }
    const statusUnchanged =
      (this.originalInfo.isOpen && this.taskInfo.isOpen) || (!this.originalInfo.isOpen && !this.taskInfo.isOpen);
    if (statusUnchanged) {
      // the task status has not changed, and only the other information of the task needs to be updated.
      await TaskInfoApi.update(this.taskInfo.taskId, this.taskInfo);
      if (this.originalInfo.isOpen) {
        // the current task is open, need to synchronize the update day task information.
        await DayTaskInfoApi.queryKeyByDateAndTaskId(this.homeStore.currentDate, this.taskInfo.taskId)
          .then(async (key: number) => {
            await DayTaskInfoApi.update(key, this.taskInfo.convert2DayTask(this.homeStore.currentDate));
          })
        if (this.taskBaseInfo.unit === '') {
          // update agent alerts
          AgentUtils.updateAgent(this.taskInfo, this.taskBaseInfo, this.getUIContext());
          hilog.info(0x0000, TAG, `update reminderId successed, reminderId is ${this.taskInfo.reminderId}`);
        }
      }
    } else {
      // the task status has changed, need to update the task information before modifying the task status.
      this.taskInfo.isOpen = this.originalInfo.isOpen;
      if (!this.originalInfo.isTaskEqual(this.taskInfo)) {
        await TaskInfoApi.update(this.taskInfo.taskId, this.taskInfo);
      }
      if (!this.taskInfo.isOpen) {
        await TaskInfoApi.openTask(this.homeStore.currentDate, this.taskInfo.taskId);
        if (this.taskBaseInfo.unit === '') {
          let oldTaskInfo = await TaskInfoApi.queryByKey(this.taskInfo.taskId);
          if (oldTaskInfo) {
            let isRequestSuccess = await RequestAuthorization.requestNotification(this.getUIContext());
            if (isRequestSuccess) {
              let reminderId = await AgentUtils.creatAgent(this.taskInfo, this.taskBaseInfo, this.getUIContext());
              // update reminderId
              oldTaskInfo.reminderId = reminderId;
              await TaskInfoApi.update(oldTaskInfo.taskId, oldTaskInfo);
              hilog.info(0x0000, TAG, `create reminderId successed, reminderId is ${reminderId}`);
            }
          }
        }
      } else {
        await TaskInfoApi.closeTask(this.homeStore.currentDate, this.taskInfo.taskId);
        // Check the reminderId, if it exists, the proxy reminder needs to be turned off.
        if (this.taskBaseInfo.unit === '') {
          let taskInfo = await TaskInfoApi.queryByKey(this.taskInfo.taskId);
          if (taskInfo && taskInfo.reminderId !== -1) {
            AgentUtils.deleteAgent(taskInfo.reminderId);
            hilog.info(0x0000, TAG, `delete reminderId successed, reminderId is ${taskInfo.reminderId}`);
          }
        }
      }
    }
    await updateTaskList(this.homeStore);
    this.pageStack.clear(true);
  }

  build() {
    NavDestination() {
      Column({
        space: $r('app.float.default_2')
      }) {
        Row() {
          Text(this.taskBaseInfo.name)
            .fontWeight(FontWeight.Medium)
            .fontSize($r('app.float.default_20'))

          Toggle({
            type: ToggleType.Switch,
            isOn: this.taskInfo.isOpen
          })
            .width($r('app.float.default_56'))
            .height($r('app.float.default_32'))
            .onChange((isOn) => {
              this.taskInfo.isOpen = isOn;
            })
        }
        .width(Const.THOUSANDTH_940)
        .justifyContent(FlexAlign.SpaceBetween)
        .backgroundColor($r('sys.color.background_primary'))
        .height($r('app.float.default_56'))
        .borderRadius($r('app.float.default_10'))
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })

        Row() {
          Text($r('app.string.target_setting'))
            .fontWeight(FontWeight.Medium)
            .fontSize($r('app.float.default_20'))

          Blank()

          Text(this.taskInfo.targetValue)
            .targetValueStyle(this.taskInfo.isOpen, this.taskBaseInfo.pickerType)

          if (this.taskBaseInfo.unit !== '') {
            Text(this.taskBaseInfo.unit)
              .targetValueStyle(this.taskInfo.isOpen, this.taskBaseInfo.pickerType)

            Text($r('app.string.unit_pre_day'))
              .targetValueStyle(this.taskInfo.isOpen, this.taskBaseInfo.pickerType)
          }

          SymbolGlyph($r('sys.symbol.chevron_right'))
            .fontColor([$r('sys.color.icon_secondary')])
            .fontSize($r('app.float.default_28'))
        }
        .width(Const.THOUSANDTH_940)
        .height($r('app.float.default_56'))
        .borderRadius($r('app.float.default_10'))
        .backgroundColor($r('sys.color.background_primary'))
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({
          left: $r('app.float.default_12'),
          right: $r('app.float.default_12')
        })
        .enabled(true)
        .onClick(() => {
          if (this.taskInfo.isOpen && this.taskBaseInfo.pickerType !== PickerType.NONE) {
            let params = new TargetSettingDialogParams(this.taskInfo, this.taskBaseInfo);
            openTargetSettingCustomDialog(this.getUIContext(), params);
          }
        })

        Button() {
          Text($r('app.string.complete'))
            .fontSize($r('app.float.default_20'))
        }
        .width(Const.THOUSANDTH_800)
        .height($r('app.float.default_48'))
        .backgroundColor($r('sys.color.background_primary'))
        .position({
          x: Const.THOUSANDTH_100,
          y: Const.THOUSANDTH_800
        })
        .onClick(async () => {
          await this.finishTaskEdit();
        })
      }
      .width(Const.THOUSANDTH_1000)
      .justifyContent(FlexAlign.Center)
    }
    .size({
      width: Const.THOUSANDTH_1000,
      height: Const.THOUSANDTH_1000
    })
    .title($r('app.string.edit_task'))
    .backgroundColor($r('sys.color.background_secondary'))
  }
}