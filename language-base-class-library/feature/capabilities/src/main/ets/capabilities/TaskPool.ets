/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import { taskpool } from '@kit.ArkTS'
import { customTitle } from '@ohos/common'

function functionForTasks(numberOfExecutions: number) {
  "use concurrent"
  return numberOfExecutions + 1
}

@Builder
export function TaskPoolBuilder() {
  TaskPool()
}

@Component
export struct TaskPool {
  @State numberOfExecutions: number = 0;
  @State task: taskpool.Task | null = null;
  @State msg: string = 'task ready';
  @StorageLink('selectedLabel') selectedLabel: string = '';
  public pathStack: NavPathStack = new NavPathStack();
  private isExecute = true;
  private clickAble = true;

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text($r('app.string.click_exec_add_one'))
            .margin({ top: 22 })
        }
        .width('90%')

        Column() {
          Row() {
            Text('numberOfExecutions:')
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
            Text(this.numberOfExecutions.toString())
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
          }
          .width('100%')

          Row() {
            Text('task status:')
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
            Text(this.msg)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
          }
          .width('100%')
        }
        .height(160)
        .margin({ top: 12 })
        .padding(16)
        .borderRadius(16)
        .backgroundColor($r('app.color.bg_white'))

        Blank()
          .layoutWeight(1)

        Row({ space: 20 }) {
          Button('Execute task')
            .id('execute_task')
            .type(ButtonType.Capsule)
            .width('45%')
            .fontColor($r('app.color.text_color_accent'))
            .backgroundColor($r('app.color.bg_btn_grey'))
            .onClick(async () => {
              if (!this.clickAble) {
                return;
              }
              for (let i = 0; i > -1; i++) {
                this.task = new taskpool.Task(functionForTasks, i);
                if (!this.isExecute) {
                  this.isExecute = true;
                  taskpool.cancel(this.task);
                } else {
                  this.clickAble = false;
                  this.msg = 'task is running';
                  await taskpool.execute(this.task)
                    .then((res: ESObject) => {
                      this.numberOfExecutions = Number(JSON.parse(JSON.stringify(res)));
                    });
                }
              }
            })

          Button('Cancel task')
            .id('cancel_task')
            .type(ButtonType.Capsule)
            .width('45%')
            .fontColor($r('app.color.text_color_red'))
            .backgroundColor($r('app.color.bg_btn_grey'))
            .onClick(() => {
              if (!this.clickAble) {
                this.msg = 'task cancel';
                this.clickAble = true;
                this.isExecute = !this.isExecute;
              }
            })
        }
        .width('100%')
        .margin({ top: 12, bottom: 16 })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    }
      .title(customTitle(this.selectedLabel))
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .onReady((context: NavDestinationContext) => {
        this.pathStack = context.pathStack;
      })

  }
}