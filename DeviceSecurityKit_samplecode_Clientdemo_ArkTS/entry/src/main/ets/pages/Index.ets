import devCertMangerModel from '../model/DevCertManagerModel';

@Entry
@Component
struct Index {
  @State devCertInfo: string = '';

  build() {
    Scroll() {
      Column() {
        Text($r('app.string.EntryAbility_head'))
          .width('100%')
          .height(100)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: '30vp'})
          .textAlign(TextAlign.Start)

        Column() {
          Text('Token information')
            .fontColor(Color.Gray)
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .margin({ top: '30vp', left: '24vp', bottom: '9.5vp' })
        }
        .width('100%')
        .height('60vp')
        .alignItems(HorizontalAlign.Start)

        Column() {
          Column() {
            Scroll() {
              Text(this.devCertInfo)
                .fontColor($r('sys.color.black'))
                .fontSize($r('sys.float.ohos_id_text_size_body1'))
                .lineHeight('19vp')
                .textAlign(TextAlign.Start)
                .width('100%')
            }
            .margin({ top: '8vp', left: '16vp', right: '16vp', bottom: '21vp' })
          }
          .height('350vp')
          .backgroundColor($r('sys.color.white'))
          .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
          .margin({ left: '12vp', right: '12vp' })
          .align(Alignment.TopStart)
        }
        .width('100%')
        .height('139vp')
        .alignItems(HorizontalAlign.Center)

        Row() {
          Button('GetDeviceToken', { type: ButtonType.Capsule, stateEffect: true })
            .borderRadius(8)
            .backgroundColor($r('sys.color.ohos_id_color_floating_button_bg_normal'))
            .height('7%')
            .margin({ top: '10vp', left: '16vp', right: '16vp', bottom: '21vp' })
            .onClick(() => {
              devCertMangerModel.displayDeviceToken((result: string) => {
                this.devCertInfo = result;
              })
            })
        }
        .height('600vp')
        .width('100%')
      }
      .backgroundColor($r('sys.color.ohos_toggle_bg'))
    }
    .height('100%')
  }
}