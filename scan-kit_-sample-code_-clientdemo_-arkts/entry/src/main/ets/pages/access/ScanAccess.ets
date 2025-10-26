import { LengthMetrics } from '@kit.ArkUI';
import { CustomButton } from '../../common/CommonComponents';
import { StatusBar } from '../../common/StatusBar';
import { UIContextSelf } from '../customScan/model/UIContextSelf';

@Entry
@Component
struct ScanAccess {
  @State translateWidth: number = 1;
  @State translateHeight: number = 1;

  build() {
    RelativeContainer() {
      StatusBar({ isBackToHome: true })

      Column() {
        Text($r('app.string.welcome_to_access'))
          .id('AccessMessage')
          .fontSize(25)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 50 })
          .textAlign(TextAlign.Center)

        CustomButton({
          mText: $r('app.string.access_integration_process'), mOnClick: () => {
            UIContextSelf.pushUrl({
              url: 'pages/access/ScanDetail'
            })
          }
        })
      }
      .width('100%')
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Center },
        left: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .markAnchor({
        top: LengthMetrics.vp(this.translateHeight),
        start: LengthMetrics.vp(this.translateWidth),
      })
      .onSizeChange((_: SizeOptions, newValue: SizeOptions) => {
        if (newValue && typeof newValue.width === 'number' && typeof newValue.height === 'number') {
          this.translateWidth = newValue.width / 2;
          this.translateHeight = newValue.height / 2;
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}