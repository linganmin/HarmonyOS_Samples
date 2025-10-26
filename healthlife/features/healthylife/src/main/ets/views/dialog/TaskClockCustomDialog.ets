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

import { ComponentContent } from '@kit.ArkUI';
import { updateTaskList } from '../../viewmodel/HomeStore';
import TaskInfoApi from 'common/src/main/ets/database/tables/TaskInfoApi';
import { updateAchievementStore } from '../../viewmodel/AchievementStore';
import { TaskInfoDialogParams } from '../../viewmodel/dialog/TaskInfoDialogParams';
import { CommonConstants as Const, PromptActionClass, taskBaseInfoList } from 'common';

export function openTaskClockCustomDialog(uIContext: UIContext, params: TaskInfoDialogParams): void {
  PromptActionClass.setContext(uIContext);
  let taskInfoDialogNode = new ComponentContent(uIContext, wrapBuilder(taskClockDialogBuilder), params);
  PromptActionClass.setContentNode(taskInfoDialogNode);
  PromptActionClass.openDialog();
}

@Builder
export function taskClockDialogBuilder(params: TaskInfoDialogParams) {
  Column() {
    Text(taskBaseInfoList[params.dayTaskInfo.taskId].name)
      .fontFamily(Const.HARMONY_HEI_TI_BOLD)
      .fontWeight(FontWeight.Bold)
      .fontColor($r(`sys.color.font_on_primary`))
      .fontSize($r('app.float.default_22'))
      .width(Const.THOUSANDTH_1000)
      .margin({
        left: $r('app.float.default_12')
      })
      .position({
        y: $r('app.float.default_267')
      });

    Button() {
      Text(params.dayTaskInfo.isDone ? $r('app.string.was_done') : $r('app.string.clock_in'))
        .fontFamily(Const.HARMONY_HEI_TI)
        .fontWeight(FontWeight.Normal)
        .fontColor($r(`sys.color.font_on_primary`))
        .fontSize($r('app.float.default_20'))
        .height($r('app.float.default_42'));
    }
    .width($r('app.float.default_220'))
    .borderRadius($r('app.float.default_24'))
    .backgroundColor($r('app.color.task_clock_bg_color'))
    .onClick(async () => {
      await taskClock(params);
    });

    Text($r('app.string.got_it'))
      .fontFamily(Const.HARMONY_HEI_TI)
      .fontWeight(FontWeight.Regular)
      .fontColor($r(`sys.color.font_on_primary`))
      .fontSize($r('app.float.default_14'))
      .margin({
        top: $r('app.float.default_12')
      })
      .onClick(() => {
        PromptActionClass.closeDialog();
      });

  }
  .height($r('app.float.default_451'))
  .width($r('app.float.default_316'))
  .backgroundImage(taskBaseInfoList[params.dayTaskInfo.taskId].dialog, ImageRepeat.NoRepeat)
  .backgroundImageSize({
    width: Const.THOUSANDTH_1000,
    height: Const.THOUSANDTH_1000
  })
  .justifyContent(FlexAlign.End)
  .padding({
    bottom: $r('app.float.default_12'),
    left: $r('app.float.default_20')
  })
}

async function taskClock(params: TaskInfoDialogParams) {
  if (!params.dayTaskInfo.isDone) {
    await TaskInfoApi.clockTask(params.dayTaskInfo.date, params.dayTaskInfo.taskId);
    await updateTaskList(params.homeStore);
  }
  PromptActionClass.closeDialog();

  // After the check-in is completed, determine whether all the tasks of the day are completed and update the achievement information.
  if (!params.dayTaskInfo.isDone) {
    await updateAchievementStore(params);
  }
}