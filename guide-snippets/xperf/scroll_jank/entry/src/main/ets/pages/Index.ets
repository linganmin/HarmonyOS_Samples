@Entry
@Component
// [Start hiAppEvent_scrollJank_case]
struct Index {
  private arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
  build() {
    List({ space: 10 }) {
      ForEach(this.arr, (item: number) => {
        ListItem() {
          Text(`${item}`)
            .width('100%')
            .height(100)
            .fontSize(20)
            .fontColor(Color.White)
            .textAlign(TextAlign.Center)
            .borderRadius(10)
            .backgroundColor(0x007DFF)
        }
      })
    }
    .onScrollIndex((firstIndex: number) => {
      let i = 1;
      while (i<20000) { // 在列表滑动事件中做一些耗时操作
        console.log("do something");
        i++;
      }
    })
  }
}
// [End hiAppEvent_scrollJank_case]