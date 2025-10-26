// DocsCode 1
// Index.ets
@Entry
@Component
struct Index {
  pageInfos: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Button('加载测试页面', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin(20)
          .onClick(() => {
            // 将name指定的NavDestination页面信息入栈
            this.pageInfos.pushPath({ name: 'pageOne' });
          })
      }
    }
    .title('NavIndex')
  }
}

// DocsCode 1