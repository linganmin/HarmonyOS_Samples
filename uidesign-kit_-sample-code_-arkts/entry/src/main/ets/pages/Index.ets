import { router } from '@kit.ArkUI'

@Entry
@Component
struct Index {
  build() {
    Column() {
      Row() {
        Button($r('app.string.process_layered_icon'))
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/GetHdsLayeredIcon' })
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .margin({ top: 30, bottom: 30 })

      Row() {
        Button($r('app.string.process_single_layer_icon'))
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/GetHdsIcon' })
          })
      }
      .justifyContent(FlexAlign.Center)
      .width('100%')
      .margin({ top: 30, bottom: 30 })
    }
  }
}