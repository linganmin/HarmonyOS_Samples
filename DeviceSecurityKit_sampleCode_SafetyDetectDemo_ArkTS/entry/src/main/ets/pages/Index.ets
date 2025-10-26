import safetyDetectModel from '../model/SafetyDetectModel';

@Entry
@Component
struct Index {
  @State DisplayText: string = '';
  @State TitleText: string = 'Display Content';

  build() {
    Column() {
      Text($r('app.string.EntryAbility_head'))
        .width('100%')
        .height(100)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ left: '30vp'})

      Column() {
        Text(this.TitleText)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
          .margin({ top: '30vp', left: '24vp', bottom: '9.5vp' })
      }
      .width('100%')
      .height('60vp')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Column() {
          Scroll() {
            Text(this.DisplayText)
              .fontColor($r('sys.color.font_primary'))
              .fontSize($r('sys.float.ohos_id_text_size_body1'))
              .lineHeight('19vp')
              .textAlign(TextAlign.Start)
              .width('100%')
          }
          .margin({ top: '8vp', left: '16vp', right: '16vp', bottom: '21vp' })
        }
        .height('350vp')
        .backgroundColor($r('sys.color.comp_background_list_card'))
        .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
        .margin({ left: '12vp', right: '12vp' })
        .align(Alignment.TopStart)
      }
      .width('100%')
      .height('139vp')
      .alignItems(HorizontalAlign.Center)

      Row() {
        Column() {
          Button('SysIntegrity', { type: ButtonType.Capsule, stateEffect: true })
            .fontSize(12)
            .borderRadius(8)
            .backgroundColor(0x317aff)
            .width('45%')
            .height('7%')
            .margin({ top: '10vp', left: '10vp', right: '6vp', bottom: '21vp' })
            .onClick(() => {
              this.TitleText = 'CheckSysIntegrity';
              safetyDetectModel.checkSysIntegrity((result: string) => {
                this.DisplayText = result;
              })
            })
          Button('SysIntegrityEnhanced', { type: ButtonType.Capsule, stateEffect: true })
            .fontSize(12)
            .borderRadius(8)
            .backgroundColor(0x317aff)
            .width('45%')
            .height('7%')
            .margin({ top: '10vp', left: '10vp', right: '6vp', bottom: '21vp' })
            .onClick(() => {
              this.TitleText = 'CheckSysIntegrityEnhanced';
              safetyDetectModel.checkSysIntegrityEnhanced((result: string) => {
                this.DisplayText = result;
              })
            })
        }
        Column() {
          Button('UrlThreat', { type: ButtonType.Capsule, stateEffect: true })
            .fontSize(12)
            .borderRadius(8)
            .backgroundColor(0x317aff)
            .width('45%')
            .height('7%')
            .margin({ top: '10vp', left: '6vp', right: '16vp', bottom: '21vp' })
            .onClick(() => {
              this.TitleText = 'CheckUrlThreat';
              safetyDetectModel.checkUrlThreat((result: string) => {
                this.DisplayText = result;
              })
            })
          Button('SysIntegrityOnLocal', { type: ButtonType.Capsule, stateEffect: true })
            .fontSize(12)
            .borderRadius(8)
            .backgroundColor(0x317aff)
            .width('45%')
            .height('7%')
            .margin({ top: '10vp', left: '6vp', right: '16vp', bottom: '21vp' })
            .onClick(() => {
              this.TitleText = 'CheckSysIntegrityOnLocal';
              safetyDetectModel.checkSysIntegrityOnLocal((result: string) => {
                this.DisplayText = result;
              })
            })
        }
      }
      .height('600vp')
      .width('100%')
    }
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}