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
* FAQ:如何实现List/Swiper/Grid嵌套滚动的下拉刷新和上拉加载更多
*/
@Component
struct PullDownPullUp {
  @State isRefreshing: string = ''

  @Builder searchBarBuilder() {}
  @Builder bannerBuilder() {}
  @Builder quickBuilder() {}
  @Builder flashBuilder() {}
  @Builder productsBuilder() {}
  @Builder footerLoadingBuilder() {}

  // [Start list_wiper_grid_pull_down_pull_up]
  build() {
    Column() {
      // Search box at the top
      this.searchBarBuilder()
      // Pull down refresh component
      Refresh({ refreshing: $$this.isRefreshing }) {
        // List component as long list layout
        List({ space: 10 }) {
          // ListItem Customize the Swiper carousel module
          ListItem() {
            this.bannerBuilder()
          }
          // ListItem Custom Grid Quick Access Module
          ListItem() {
            this.quickBuilder()
          }
          // ListItem Custom Column Flash Sale Module
          ListItem() {
            this.flashBuilder()
          }
          // ListItemGroup Product Classification List
          this.productsBuilder()
          // 最后ListItem Customize bottom loading for more
          ListItem() {
            this.footerLoadingBuilder()
          }.height(50).width('100%').backgroundColor(0xeeeeee)
        }
        .sticky(StickyStyle.Header)
        .height('100%')
        // List component hits bottom to simulate network requests
        .onReachEnd(() => {
          // Load more data logic
        })
      }
      // Pull down refresh simulation network request
      .onRefreshing(() => {
        // Data refresh logic
      })
      .layoutWeight(1)
      .width('100%')
    }
  }
  // [End list_wiper_grid_pull_down_pull_up]
}