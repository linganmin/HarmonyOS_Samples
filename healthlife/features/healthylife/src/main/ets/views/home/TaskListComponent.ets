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

import { HomeStore } from '../../viewmodel/HomeStore';
import { AchievementStore } from '../../viewmodel/AchievementStore';
import TaskInfoApi from 'common/src/main/ets/database/tables/TaskInfoApi';
import { openTaskClockCustomDialog } from '../dialog/TaskClockCustomDialog';
import { TaskInfoDialogParams } from '../../viewmodel/dialog/TaskInfoDialogParams';
import { CommonConstants as Const, DayTaskInfo, taskBaseInfoList } from 'common';

@Component
export struct TaskListComponent {
  @Consume('pathStack') pageStack: NavPathStack;
  @Consume homeStore: HomeStore;
  @Consume achievementStore: AchievementStore;

  build() {
    if (this.homeStore.taskList.length > 0) {
      Column() {
        ForEach(this.homeStore.taskList, (item: DayTaskInfo, index: number) => {
          this.taskCardBuilder(item, index)
        }, (item: DayTaskInfo, index: number) => index + JSON.stringify(item))
      }
      .width(Const.THOUSANDTH_1000)
      .padding({
        top: Const.THOUSANDTH_15,
        right: Const.THOUSANDTH_33,
        left: Const.THOUSANDTH_33
      })
    } else {
      Column() {
        Image($r('app.media.ic_no_data'))
          .width($r('app.float.default_132'))
          .height($r('app.float.default_100'))
          .margin({
            bottom: $r('app.float.default_8')
          })

        Text($r('app.string.no_task'))
          .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
          .fontWeight(FontWeight.Regular)
          .fontColor($r(`sys.color.font_secondary`))
          .fontSize($r('app.float.default_14'))
      }
      .width(Const.THOUSANDTH_1000)
      .margin({
        top: $r('app.float.default_48')
      })
    }
  }

  @Builder
  taskCardBuilder(item: DayTaskInfo, _index: number) {
    Row() {
      Image(taskBaseInfoList[item.taskId].icon)
        .width($r('app.float.default_36'))
        .height($r('app.float.default_36'))
        .objectFit(ImageFit.Contain)
        .margin({
          right: $r('app.float.default_8')
        })

      Text(taskBaseInfoList[item.taskId].name)
        .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
        .fontWeight(FontWeight.Regular)
        .fontColor($r(`sys.color.font_primary`))
        .fontSize($r('app.float.default_16'))

      Blank()

      this.targetValueBuilder(item)
    }
    .width(Const.THOUSANDTH_1000)
    .height($r('app.float.default_62'))
    .borderRadius($r('app.float.default_24'))
    .padding({
      left: Const.THOUSANDTH_50,
      right: Const.THOUSANDTH_50
    })
    .backgroundColor($r('sys.color.background_primary'))
    .margin({
      bottom: $r('app.float.default_12')
    })
    .onClick(() => {
      if (this.homeStore.checkCurrentDay()) {
        let params = new TaskInfoDialogParams(item, this.homeStore, this.achievementStore, this.getUIContext());
        openTaskClockCustomDialog(this.getUIContext(), params);
      }
    })
    .gesture(LongPressGesture().onAction(async () => {
      if (this.homeStore.checkCurrentDay()) {
        let taskInfo = await TaskInfoApi.queryByKey(item.taskId);
        this.pageStack.pushPath({ name: 'EditTaskComponent', param: taskInfo });
      }
    }))
  }

  @Builder
  targetValueBuilder(item: DayTaskInfo) {
    if (item.isDone) {
      this.taskValueBuilder($r('app.string.was_done'), $r(`sys.color.font_primary`))
    } else {
      Row() {
        this.taskValueBuilder((item.finValue || `--`), $r(`sys.color.font_secondary`))

        this.taskValueBuilder(` / ${item.targetValue} `, $r(`sys.color.font_primary`))

        this.taskValueBuilder(taskBaseInfoList[item.taskId].unit, $r(`sys.color.font_primary`))
      }
    }
  }

  @Builder
  taskValueBuilder(content: ResourceStr, fontColor: Resource) {
    Text(content)
      .fontFamily(Const.HARMONY_HEI_TI_MEDIUM)
      .fontWeight(FontWeight.Regular)
      .fontColor(fontColor)
      .fontSize($r('app.float.default_16'))
  }
}