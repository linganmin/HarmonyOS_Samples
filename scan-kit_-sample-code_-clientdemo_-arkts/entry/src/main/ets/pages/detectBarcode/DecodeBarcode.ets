import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LengthMetrics } from '@kit.ArkUI';
import { detectBarcode, scanBarcode, scanCore } from '@kit.ScanKit';
import { CustomButton } from '../../common/CommonComponents';
import { checkResults, showError, showMessage } from '../../common/Utils';
import Logger from '../../common/Logger';
import { StatusBar } from '../../common/StatusBar';
import { UIContextSelf } from '../customScan/model/UIContextSelf';

const TAG: string = 'DecodeBarcode';

@Entry
@Component
struct DecodeBarcode {
  @State translateWidth: number = 1;
  @State translateHeight: number = 1;

  build() {
    RelativeContainer() {
      StatusBar()
      Column() {
        CustomButton({
          mText: $r('app.string.bitmap_api_decode_image'), mOnClick: () => {
            try {
              let photoOption = new photoAccessHelper.PhotoSelectOptions();
              photoOption.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
              photoOption.maxSelectNumber = 1;
              photoOption.isEditSupported = false;
              let photoPicker = new photoAccessHelper.PhotoViewPicker();

              photoPicker.select(photoOption).then((photoResult) => {
                Logger.info(TAG, `photoResult: ${JSON.stringify(photoResult)}.`);
                let infoW: number = 0;
                let infoH: number = 0;
                if (photoResult.photoUris[0].length > 0) {
                  try {
                    let file = fileIo.openSync(photoResult.photoUris[0], fileIo.OpenMode.READ_ONLY);
                    const imageSourceApi = image.createImageSource(file.fd);
                    try {
                      fileIo.closeSync(file);
                    } catch (error) {
                      Logger.error(TAG, `Failed to closeSync. Code: ${error?.code}.`);
                    }
                    if (imageSourceApi) {
                      imageSourceApi.getImageInfo(0, (error: BusinessError, imageInfo) => {
                        imageSourceApi.release().then(() => {
                          Logger.info(TAG, 'Succeeded in releasing the image source instance.');
                        }).catch((error: BusinessError) => {
                          Logger.error(TAG, `Failed to release the image source instance. Code: ${error.code}.`);
                        })
                        if (imageInfo == undefined) {
                          Logger.error(TAG, `Failed to obtain the image pixel map information. Code: ${error.code}.`);
                          // TODO: When an image fails to be obtained, perform compatibility or prompt processing.
                          return;
                        }
                        Logger.info(TAG, `imageInfo: ${JSON.stringify(imageInfo)}.`);
                        infoW = imageInfo.size.width;
                        infoH = imageInfo.size.height;
                      })
                    }
                  } catch (error) {
                    showError(error);
                    Logger.error(TAG, `Promise options Error. Code: ${error?.code}.`);
                    return;
                  }
                } else {
                  // TODO: TODO: When no code value can be recognized, perform prompt processing.
                  return;
                }

                try {
                  let inputImage: detectBarcode.InputImage = { uri: photoResult.photoUris[0] };
                  // Define barcode recognition input parameters.
                  let options: scanBarcode.ScanOptions = {
                    scanTypes: [scanCore.ScanType.ALL],
                    enableMultiMode: true,
                    enableAlbum: true
                  };
                  detectBarcode.decode(inputImage, options).then((result: Array<scanBarcode.ScanResult>) => {
                    if (!checkResults(result)) {
                      // TODO: When no code value can be recognized, perform prompt processing.
                      return;
                    }
                    if (result && result.length > 0) {
                      // Image decoding result processing.
                      UIContextSelf.pushUrl({
                        url: 'pages/detectBarcode/CommonCodeLayout',
                        params: {
                          result: result,
                          uri: photoResult.photoUris[0],
                          infoW: infoW,
                          infoH: infoH
                        }
                      })
                    } else {
                      showMessage($r('app.string.Scan_diaLog_not_found'));
                    }
                  }).catch((error: BusinessError) => {
                    if (photoResult.photoUris[0]) {
                      showMessage($r('app.string.Scan_diaLog_not_found'));
                      Logger.error(TAG, `Promise scan error. Code: ${error.code}, message: ${error.message}.`);
                    }
                  });
                } catch (error) {
                  showError(error);
                  Logger.error(TAG, `error by catch. Code: ${error?.code}, message: ${error?.message}.`);
                }

              }).catch((error: BusinessError) => {
                Logger.error(TAG, `Failed to select by photoPicker. Code: ${error.code}.`);
              });
            } catch (error) {
              showError(error);
              Logger.error(TAG, `Failed to select by photoPicker. Code: ${error?.code}.`);
            }
          }
        })

        CustomButton({
          mText: $r('app.string.bitmap_api_decode_pixel'), mOnClick: () => {
            UIContextSelf.pushUrl({
              url: 'pages/detectBarcode/DecodeCameraYuv',
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
      .id('columnDecodeBarcode')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('white')
  }
}
