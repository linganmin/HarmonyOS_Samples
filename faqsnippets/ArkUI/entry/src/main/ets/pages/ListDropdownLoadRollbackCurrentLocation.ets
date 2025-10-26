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
* FAQ:List的下拉加载如何回滚到当前展示位置
*/

// [Start list_dropdown_load_rollback_current_location]
@Entry
@Component
struct RefreshDemo {
  @State isRefreshing: boolean = false;
  @State arr: String[] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
  // Used to control the scrolling position of the list and maintain consistency of the view after refreshing
  private listScroller: Scroller = new Scroller();

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing }) {
        List({ scroller: this.listScroller, space: 10 }) {
          ForEach(this.arr, (item: string) => {
            ListItem() {
              Text(item)
                .width('100%')
                .height(100)
                .textAlign(TextAlign.Center)
                .backgroundColor(Color.Grey)
            }
          }, (item: string) => item)
        }
        .onScrollIndex((first: number) => {
          console.info(first.toString());
        })
        .width('100%')
        .height('100%')
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.isRefreshing = false;
        }, 2000)
        let originalCount = this.arr.length;
        this.arr.unshift('11');
        this.arr.unshift('12');
        this.listScroller.scrollToIndex(this.listScroller.scrollToIndex(this.arr.length - originalCount));
      })
    }
  }
}

// [End list_dropdown_load_rollback_current_location]