/**
 * FAQ:如何禁用Refresh组件的下拉刷新
 */

// [Start disable_pull_down_refresh]
@Entry
@Component
struct Index {
  @State isRefreshing: boolean = false;
  @State arr: String[] = ['0', '1', '2', '3', '4', '5'];
  @State downRatio: number = 1;

  build() {
    Column() {
      Refresh({ refreshing: $$this.isRefreshing }) {
        Column() {
          Row({ space: 10 }) {
            Button('不允许下拉刷新')
              .onClick(() => {
                this.downRatio = 0;
              })
            Button('允许下拉刷新')
              .onClick(() => {
                this.downRatio = 1;
              })
          }

          List() {
            ForEach(this.arr, (item: string) => {
              ListItem() {
                Text('' + item)
                  .width('70%')
                  .height(80)
                  .fontSize(16)
                  .margin(10)
                  .textAlign(TextAlign.Center)
                  .borderRadius(10)
                  .backgroundColor(0xFFFFFF)
              }
            }, (item: string) => item)
          }
          .onScrollIndex((first: number) => {
            console.info(first.toString());
          })
          .width('100%')
          .height('100%')
          .alignListItem(ListItemAlign.Center)
          .scrollBar(BarState.Off)
        }
      }
      .onRefreshing(() => {
        setTimeout(() => {
          this.isRefreshing = false;
        }, 2000)
        console.info('onRefreshing test');
      })
      .pullDownRatio(this.downRatio)
      .backgroundColor(0x89CFF0)
      .refreshOffset(64)
      .pullToRefresh(true)
    }
  }
}

// [End disable_pull_down_refresh]