@Builder
export function Page01() {
  Navigation1()
}

@Component
export struct Navigation1 {
  @Consume('navPathStack') navPathStack: NavPathStack;

  build() {
    // [Start navigation]
    NavDestination() {
      Column() {
        Button($r('app.string.back_to_web_page'))
          .width('100%')
          .height(40)
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'WebPage' });
          })
      }

      // ...
    }
    .title('ArkTS页面')

    // [End navigation]
  }
}