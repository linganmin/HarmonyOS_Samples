/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

/*
* FAQ:如何合并两个列表并支持懒加载
*/

// [Start merge_two_lists_and_support_lazy_loading_one]
import { MyDataSource } from './DataUtil';

@Entry
@Component
struct DoubleLazyForEach {
  private scrollerForScroll: Scroller = new Scroller();

  build() {
    Flex() {
      Scroll(this.scrollerForScroll) {
        Column() {
          Text('Scroll Area')
            .width('100%')
            .height('40%')
            .backgroundColor(0X330000FF)
            .fontSize(16)
            .textAlign(TextAlign.Center)
          ListA().height('80%')
          ListB().height('80%')
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
    .padding(20)
  }
}

@Component
struct ListA {
  private scrollerForListA: Scroller = new Scroller();
  private dataOne: MyDataSource = new MyDataSource();

  aboutToAppear() {
    for (let i = 0; i <= 20; i++) {
      this.dataOne.pushData(`Hello One ${i}`);
    }
  }

  build() {
    Column() {
      List({ space: 20, scroller: this.scrollerForListA }) {
        LazyForEach(this.dataOne, (item: string) => {
          ListItem() {
            Text('ListItem' + item)
              .width('100%')
              .height('100%')
              .borderRadius(15)
              .fontSize(16)
              .textAlign(TextAlign.Center)
              .backgroundColor(Color.White)
          }
          .width('100%')
          .height(100)
        }, (item: string) => item)
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.None)
      .friction(0.6)
      .nestedScroll({
        scrollForward: NestedScrollMode.SELF_FIRST,
        scrollBackward: NestedScrollMode.PARENT_FIRST
      })
    }
    .height('100%')
    .width('100%')
  }
}

@Component
struct ListB {
  private dataTwo: MyDataSource = new MyDataSource();
  private scrollerForListB: Scroller = new Scroller();

  aboutToAppear() {
    for (let i = 0; i <= 20; i++) {
      this.dataTwo.pushData(`Hello Two ${i}`);
    }
  }

  build() {
    Column() {
      List({ space: 20, scroller: this.scrollerForListB }) {
        LazyForEach(this.dataTwo, (item: string) => {
          ListItem() {
            MyText({ state_value: item })
          }
          .width('100%')
          .height(100)
        }, (item: string) => item)
      }
      .width('100%')
      .height('100%')
      .edgeEffect(EdgeEffect.None)
      .friction(0.6)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
  }
}

@Component
struct MyText {
  @State private state_value: string = 'Hello';

  build() {
    Text('ListItem' + this.state_value)
      .width('100%')
      .height('100%')
      .borderRadius(15)
      .fontSize(16)
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Pink)
  }
}

// [End merge_two_lists_and_support_lazy_loading_one]