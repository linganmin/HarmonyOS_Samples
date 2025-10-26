import { ForEachListPage } from './ForEachListPage';
import { LazyForEachListPage } from './LazyForEachListPage';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string, param: object) {
    NavDestination() {
      if (name === 'ForEachListPage') {
        ForEachListPage()
      } else if (name === 'LazyForEachListPage') {
        LazyForEachListPage()
      }
    }
    .hideTitleBar(true)
  }

  build() {
    Navigation(this.pageStack) {
      Row() {
        Column() {
          Button('ForEach')
            .width(200)
            .margin(10)
            .onClick(() => {
              this.pageStack.pushPathByName('ForEachListPage', '');
            })
          Button('LazyForEach')
            .width(200)
            .margin(10)
            .onClick(() => {
              this.pageStack.pushPathByName('LazyForEachListPage', '');
            })
        }
        .width('100%')
      }
      .height('100%')
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
  }
}