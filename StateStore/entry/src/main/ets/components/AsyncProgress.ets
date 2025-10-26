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

import { TodoItemData } from '../model/TodoListModel';
import { TodoStore } from '../store/TodoListStore';

// [Start async_progress_builder]
@CustomDialog
export struct AsyncProgressBuilder {
  controller: CustomDialogController;
  // [StartExclude async_progress_builder]
  private listScroller: ListScroller = new ListScroller();

  aboutToAppear(): void {
    TodoStore.getState().progress.setValueMonitor((value: number) => {
      this.listScroller.scrollToIndex(value, true, ScrollAlign.END);
    });
  }

  // [EndExclude async_progress_builder]

  build() {
    Column() {
      // [StartExclude async_progress_builder]
      Row() {
        Text($r('app.string.syncing'));
        Text(TodoStore.getState().percent.toString().slice(0, 5) + '%');
      }.justifyContent(FlexAlign.SpaceBetween).width('100%');

      List({ scroller: this.listScroller }) {
        ForEach(TodoStore.getState().syncTodoList, (item: TodoItemData) => {
          ListItem() {
            Row() {
              Text(item.taskDetail);
              SymbolGlyph(item.state ? $r('sys.symbol.checkmark') : $r('sys.symbol.rays'))
                .symbolEffect(new HierarchicalSymbolEffect(EffectFillStyle.ITERATIVE), true);
            }.height(25).justifyContent(FlexAlign.SpaceBetween).width('100%');
          };
        });
      }.constraintSize({
        maxHeight: 100
      }).width('100%')
      .height('auto');

      // [EndExclude async_progress_builder]
      Progress({
        value: TodoStore.getState().progress.value,
        total: TodoStore.getState().progress.total,
        type: ProgressType.Linear
      }).style({ enableSmoothEffect: true })
        .width('100%')
        .height(24);
    }
    // [StartExclude async_progress_builder]
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .height(204)
    .borderRadius(32)
    .padding($r('app.float.vp_24'));

    // [EndExclude async_progress_builder]
  }
}

// [End async_progress_builder]