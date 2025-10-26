import { LengthMetrics } from '@kit.ArkUI';
import { CustomButton } from '../../common/CommonComponents'
import { StatusBar } from '../../common/StatusBar';
import { UIContextSelf } from './model/UIContextSelf';

@Entry
@Component
struct CustomPage {
  @State translateWidth: number = 1;
  @State translateHeight: number = 1;

  build() {
    RelativeContainer() {
      StatusBar()
      Column() {
        CustomButton({
          mText: $r('app.string.customized_view_decode'), mOnClick: () => {
            UIContextSelf.pushUrl({
              url: "pages/customScan/pages/ScanPage"
            })
          }
        })

        CustomButton({
          mText: $r('app.string.customized_view_decode_v2'), mOnClick: () => {
            UIContextSelf.pushUrl({
              url: "pages/customScanV2/pages/ScanPage"
            })
          }
        })
      }
      .alignItems(HorizontalAlign.Center)
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
      .id('columnCustomPage')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('white')
  }
}