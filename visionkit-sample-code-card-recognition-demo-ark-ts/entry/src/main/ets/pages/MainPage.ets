import { CardDemoPage } from './CardDemoPage'

@Entry
@Component
struct MainPage {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === 'cardRecognition') {
      CardDemoPage()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Button('CardRecognition', { stateEffect: true, type: ButtonType.Capsule })
        .width('50%')
        .height(40)
        .onClick(() => {
          this.pathStack.pushPath({ name: 'cardRecognition' })
        })
    }.title('Card recognition demo').navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}
