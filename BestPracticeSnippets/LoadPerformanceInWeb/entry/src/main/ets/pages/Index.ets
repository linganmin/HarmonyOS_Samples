/**
 * 优化Web场景下的加载性能问题
 */

// [Start page_index]
// Index.ets
@Entry
@Component
struct Index {
  pageInfos: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button('加载测试页面', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin(20)
          .onClick(() => {
            // Put the NavDestination page information specified by name on the stack.
            this.pageInfos.pushPath({ name: 'pageOne' })
          })
      }
    }.title('NavIndex')
  }
}
// [End page_index]
