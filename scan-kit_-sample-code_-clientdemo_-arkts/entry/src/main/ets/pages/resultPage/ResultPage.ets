import { LengthMetrics } from '@kit.ArkUI';
import { scanBarcode } from '@kit.ScanKit';
import { StatusBar } from '../../common/StatusBar';
import { getScanTypeKey } from '../../common/Utils'
import { UIContextSelf } from '../customScan/model/UIContextSelf';
import { WindowService } from '../customScan/model/WindowService';

@Extend(Text)
function labelText() {
  .fontSize(20)
  .textAlign(TextAlign.Start)
  .fontColor($r('sys.color.black'))
}

@Extend(Text)
function valueText() {
  .margin({
    top: 4,
  })
  .fontSize(16)
  .textAlign(TextAlign.Start)
  .fontColor($r('sys.color.mask_secondary'))
}

@Entry
@Component
struct ResultPage {
  @State result: scanBarcode.ScanResult = UIContextSelf.getRouter().getParams() as scanBarcode.ScanResult;
  @State windowService: WindowService = WindowService.getInstance();

  build() {
    Stack() {
      Column() {
        Column() {
          Text($r('app.string.code_format'))
            .labelText()
          Text(getScanTypeKey(this.result.scanType))
            .valueText()

          Text($r('app.string.result_content'))
            .margin({
              top: 18,
            })
            .labelText()
          Text(this.result.originalValue)
            .valueText()

          if (this.result.scanCodeRect) {
            Text($r('app.string.code_rect'))
              .margin({
                top: 18,
              })
              .labelText()
            Text('left: ' + (this.result.scanCodeRect?.left || 0) + '  top: ' + (this.result.scanCodeRect?.top || 0) +
              '  right: ' + (this.result.scanCodeRect?.right || 0) + '  bottom: ' +
              (this.result.scanCodeRect?.bottom || 0))
              .valueText()
          }
        }
        .backgroundColor('#0a000000')
        .borderRadius(12)
        .width(this.windowService.width <= 480 ? '85%' : '60%')
        .alignItems(HorizontalAlign.Start)
        .padding(24)
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')

      StatusBar({ title: $r('app.string.result_content') })
        .position({ start: LengthMetrics.vp(-15) })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('white')
  }
}