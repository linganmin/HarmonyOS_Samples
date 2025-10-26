import { LengthMetrics } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanBarcode, scanCore } from '@kit.ScanKit';
import { CustomButton } from '../../common/CommonComponents';
import Logger from '../../common/Logger';
import { StatusBar } from '../../common/StatusBar';
import { showError } from '../../common/Utils';
import { UIContextSelf } from '../customScan/model/UIContextSelf';

const TAG = 'Default Scan';

@Entry
@Component
struct DefaultScan {
  @State translateWidth: number = 1;
  @State translateHeight: number = 1;

  build() {
    RelativeContainer() {
      StatusBar()
      Column() {
        CustomButton({
          mText: $r('app.string.default_view_decode'), mOnClick: () => {
            try {
              scanBarcode.startScanForResult(UIContextSelf.getHostContext(), {
                scanTypes: [scanCore.ScanType.ALL],
                enableMultiMode: true,
                enableAlbum: true
              }).then((result: scanBarcode.ScanResult) => {
                Logger.info(TAG, `Promise scan result: ${JSON.stringify(result)}`);
                UIContextSelf.pushUrl({
                  url: 'pages/resultPage/ResultPage',
                  params: {
                    originalValue: result.originalValue,
                    scanType: result.scanType
                  }
                })
              }).catch((error: BusinessError) => {
                if (error.code === scanCore.ScanErrorCode.SCAN_SERVICE_CANCELED) {
                  Logger.info(TAG, 'Disabling the Scanning Service.');
                } else {
                  Logger.error(TAG,
                    `Failed to start the scanning service. Code: ${error.code}, message: ${error.message}.`);
                  showError(error);
                }
              });
            } catch (error) {
              Logger.error(TAG,
                `Failed to start the scanning service. Code: ${error?.code}, message: ${error?.message}.`);
              showError(error);
            }
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
      .id('columnDefaultScan')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('white')
  }
}