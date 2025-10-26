/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { addSheetBuilder } from '../components/AddSheetBuilder';
import { AsyncProgressBuilder } from '../components/AsyncProgress';
import { Icon } from '../components/IconContainer';
import { TodoItem } from '../components/TodoItem';
import { TodoItemData, TodoStoreModel } from '../model/TodoListModel';
import TodoListActions from '../store/TodoListActions';
import { TodoStore } from '../store/TodoListStore';
import { syncDatabase } from '../utils/TaskpoolUtil';

// [Start todo_list_index]
@Entry
@ComponentV2
struct Index {
  @Local viewModel: TodoStoreModel = TodoStore.getState();
  // [StartExclude todo_list_index]
  progressDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AsyncProgressBuilder(),
    autoCancel: false
  });

  @Computed
  get todoNum(): number {
    return this.viewModel.todoList.length;
  }

  // [EndExclude todo_list_index]
  aboutToAppear(): void {
    // The dispatch triggers a GetTodoList event to get the full data and update the status
    TodoStore.dispatch(TodoListActions.getTodoList);
  }

  // [StartExclude todo_list_index]
  @Builder
  todayGroupHeader() {
    Text($r('app.string.today'))
      .fontSize($r('app.float.font_lg'))
      .fontColor($r('app.color.text_primary'))
      .fontWeight(700)
      .margin({
        bottom: $r('app.float.vp_8'),
        top: $r('app.float.vp_24')
      });
  }

  @Builder
  completedGroupHeader() {
    Row() {
      Text($r('app.string.completed'))
        .fontSize($r('app.float.font_lg'))
        .fontColor($r('app.color.text_primary'))
        .fontWeight(700);
      Text($r('app.string.clear_completed'))
        .fontSize($r('app.float.font_sm'))
        .fontColor($r('app.color.text_blue'))
        .fontWeight(500)
        .enabled(this.viewModel.todoList.some(item => item.selected))
        .onClick(() => {
          TodoStore.dispatch(TodoListActions.clearCompletedTodoList);
        });
    }.width('100%')
    .alignItems(VerticalAlign.Bottom)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({
      bottom: $r('app.float.vp_8'),
      top: $r('app.float.vp_24')
    });
  }

  // [EndExclude todo_list_index]
  build() {
    Column() {
      // [StartExclude todo_list_index]
      Row({ space: 16 }) {
        Icon({ iconSrc: $r('app.media.icloud') }).onClick(async () => {
          this.progressDialogController?.open();
          await syncDatabase();
          this.progressDialogController?.close();
          this.getUIContext().getPromptAction().showToast({ message: $r('app.string.synced') });
        });

        Icon({ iconSrc: $r('app.media.plus') }).onClick(() => {
          TodoStore.dispatch(TodoListActions.showSheet);
        });
      }.direction(Direction.Rtl)
      .margin({ top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8') })
      .width('100%');

      Column() {
        Text($r('app.string.page_title'))
          .height(40)
          .fontWeight(700)
          .fontColor($r('app.color.text_primary'))
          .fontSize($r('app.float.font_page_title'));
        Text($r('app.string.to_do_num', this.todoNum))
          .fontColor($r('app.color.text_second'))
          .fontSize($r('app.float.font_sm'));
      }.margin({ top: $r('app.float.vp_12'), bottom: $r('app.float.vp_8') })
      .alignItems(HorizontalAlign.Start)
      .width('100%');

      // [EndExclude todo_list_index]
      if (this.viewModel.todoList.length > 0) {
        List({ space: 12 }) {
          if (this.viewModel.uncompletedTodoList.length > 0) {
            ListItemGroup({ header: this.todayGroupHeader(), space: 12 }) {
              ForEach(this.viewModel.uncompletedTodoList, (item: TodoItemData) => {
                ListItem() {
                  TodoItem({ itemData: item });
                };
              }, (item: TodoItemData) => item.id.toString());
            };
          }
          // [StartExclude todo_list_index]
          if (this.viewModel.completedTodoList.length > 0) {
            ListItemGroup({ header: this.completedGroupHeader(), space: 12 }) {
              ForEach(this.viewModel.completedTodoList, (item: TodoItemData) => {
                ListItem() {
                  TodoItem({ itemData: item });
                };
              }, (item: TodoItemData) => item.id.toString());
            };
          }
          // [EndExclude todo_list_index]
        }.width('100%')
        .height('100%')
        .layoutWeight(1);

        // [StartExclude todo_list_index]
      }
    }
    .width('100%')
    .height('100%')
    .padding({
      left: $r('app.float.vp_16'),
      right: $r('app.float.vp_16')
    })
    .backgroundColor($r('app.color.page_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet($$this.viewModel.isShow, addSheetBuilder(), {
      height: '80%',
      title: { title: $r('app.string.sheet_title') },
      showClose: true,
      backgroundColor: $r('app.color.page_background'),
      keyboardAvoidMode: SheetKeyboardAvoidMode.RESIZE_ONLY,
      onWillDismiss: () => {
        TodoStore.dispatch(TodoListActions.hideSheet);
      }
    });

    // [EndExclude todo_list_index]
  }
}

// [End todo_list_index]