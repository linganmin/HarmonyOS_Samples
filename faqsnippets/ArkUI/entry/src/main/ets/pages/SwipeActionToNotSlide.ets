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
* FAQ:如何将ListItem的swipeAction滑动效果恢复至未滑动
*/

// [Start swiper_action_recover]
@Component
export struct SwiperActionRecover {
  @State arr: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  private scrollerForList: ListScroller = new ListScroller();

  @Builder
  itemEnd() {
    Row() {
      Button('Delete')
      Button('Set')
        .onClick(() => {
          this.scrollerForList.closeAllSwipeActions(); // This is the key line of code
        })
    }
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Column() {
      List({ space: 5, scroller: this.scrollerForList }) {
        ForEach(this.arr, (item: number) => {
          ListItem() {
            Text('item' + item)
              .width('100%')
              .height(100)
              .textAlign(TextAlign.Center)
              .borderRadius(10)
              .backgroundColor(0xFFFFFF)
          }
          .transition({
            type: TransitionType.Delete,
            opacity: 0
          })
          .swipeAction({
            end: {
              builder: () => {
                this.itemEnd();
              },
              onAction: () => {
                this.getUIContext().animateTo({ duration: 1000 }, () => {
                  let index = this.arr.indexOf(item);
                  this.arr.splice(index, 1);
                });
              },
              actionAreaDistance: 56
            }
          })
        }, (item: string) => item)
      }
    }
    .padding(20)
    .backgroundColor(0xDCDCDC)
    .width('100%')
    .height('100%')
  }
}
// [End swiper_action_recover]