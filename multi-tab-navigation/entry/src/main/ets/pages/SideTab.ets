/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { initSideData } from '../viewmodel/TabViewModel';
import { ClassifyModel } from '../viewmodel/TabItem';

@Component
struct ClassifyItem {
  @Prop isSelected: boolean = false;
  classifyName?: string | Resource;
  onClickAction = (): void => {
  }

  build() {
    Text(this.classifyName)
      .fontSize(14)
      .fontColor(this.isSelected ? '#182431' : '#99182431')
      .fontFamily(this.isSelected ? $r('app.string.hei_ti_medium') : $r('app.string.hei_ti'))
      .fontWeight(this.isSelected ? FontWeight.Medium : FontWeight.Normal)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.isSelected ? '#FFFFFF' : '')
      .width('100%')
      .height(52)
      .onClick(this.onClickAction)
  }
}

@Entry
@Component
struct SideTab {
  @State currentClassify: number = 0;
  @State ClassifyArray: Array<ClassifyModel> = initSideData();
  private classifyScroller: Scroller = new Scroller();
  private scroller: Scroller = new Scroller();

  classifyChangeAction(index: number, isClassify: boolean): void {
    if (this.currentClassify !== index) {
      this.currentClassify = index;
      if (isClassify) {
        this.scroller.scrollToIndex(index);
      } else {
        this.classifyScroller.scrollToIndex(index);
      }
    }
  }

  build() {
    Row() {
      // [Start Side_tab_list]
      List({ scroller: this.classifyScroller }) {
        ForEach(this.ClassifyArray, (item: ClassifyModel, index?: number) => {
          ListItem() {
            ClassifyItem({
              classifyName: item.classifyName,
              isSelected: this.currentClassify === index,
              onClickAction: () => {
                if (index !== undefined) {
                  this.classifyChangeAction(index, true);
                }
              }
            })
          }
        }, (item: ClassifyModel, index: number) => JSON.stringify(item) + index)
      }
      .height('110%')
      .width('27.8%')
      .backgroundColor($r('app.color.side_background_color'))
      .scrollBar(BarState.Off)
      .margin({ top: 74 })

      Column() {
        ForEach(this.ClassifyArray, (item: ClassifyModel, index: number) => {
          Text(this.currentClassify === index ? item.classifyName : '')
            .fontSize(30)
        },(item: ClassifyModel, index: number) => JSON.stringify(item) + index)
      }
      .width('72.2%')
      // [End Side_tab_list]
    }
    .backgroundColor($r('app.color.side_content_color'))
  }
}