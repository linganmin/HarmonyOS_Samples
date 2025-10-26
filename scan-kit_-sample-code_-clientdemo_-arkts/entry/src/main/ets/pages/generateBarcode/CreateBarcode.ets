import { image } from '@kit.ImageKit';
import { buffer } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { scanCore, generateBarcode } from '@kit.ScanKit';
import { StatusBar } from '../../common/StatusBar';
import { CustomLabel, CustomButton } from '../../common/CommonComponents';
import { showError, getColorType, getScanTypeVal, getErrorCorrectionLevel, showMessage } from '../../common/Utils';
import Logger from '../../common/Logger';
import { WindowService } from '../customScan/model/WindowService';

const TAG: string = 'CreateBarcode';

class ScanConstant {
  static readonly colorItems: Array<SelectOption> = [
    {
      value: 'Black'
    },
    {
      value: 'Blue'
    },
    {
      value: 'Brown'
    },
    {
      value: 'Gray'
    },
    {
      value: 'Green'
    },
    {
      value: 'Orange'
    },
    {
      value: 'Red'
    },
    {
      value: 'White'
    },
    {
      value: 'Yellow'
    }];
  static readonly errorLevelItems: Array<SelectOption> = [
    {
      value: 'LEVEL_L'
    },
    {
      value: 'LEVEL_M'
    },
    {
      value: 'LEVEL_Q'
    },
    {
      value: 'LEVEL_H'
    }];
  static readonly codeTypeItems: Array<SelectOption> = [
    {
      value: 'AZTEC_CODE'
    },
    {
      value: 'CODABAR_CODE'
    },
    {
      value: 'CODE93_CODE'
    },
    {
      value: 'CODE39_CODE'
    },
    {
      value: 'CODE128_CODE'
    },
    {
      value: 'DATAMATRIX_CODE'
    },
    {
      value: 'EAN8_CODE'
    },
    {
      value: 'EAN13_CODE'
    },
    {
      value: 'ITF14_CODE'
    },
    {
      value: 'PDF417_CODE'
    },
    {
      value: 'QR_CODE'
    },
    {
      value: 'UPC_A_CODE'
    },
    {
      value: 'UPC_E_CODE'
    }];
}

@Extend(TextInput)
function demoTextInput() {
  .caretColor(Color.Blue)
  .fontSize(14)
  .width(120)
  .height(35)
  .fontWeight(FontWeight.Bold)
  .layoutWeight(1)
}

@Extend(TextArea)
function demoTextArea() {
  .height(34)
  .caretColor(Color.Black)
  .fontSize(14)
  .fontWeight(FontWeight.Bold)
  .fontFamily('sans-serif')
  .fontStyle(FontStyle.Normal)
  .fontColor(Color.Black)
}

@Extend(Select)
function demoSelect() {
  .font({ size: 14 })
  .selectedOptionFont({ size: 14 })
  .optionFont({ size: 14 })
  .height(34)
  .backgroundColor('#eeeeee')
}

@Extend(Row)
function demoRow() {
  .margin({ bottom: 10 })
}

@Extend(Flex)
function FlexRow() {
  .margin({ bottom: 10 })
}

@Entry
@Component
struct GenerateBarcode {
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State codeInputContext: string = '123'; // Default content of the QR code.
  @State codeWidth: string = '800'; // Default barcode width, in px.
  @State codeHeight: string = '800'; // Default barcode height, in px.
  @State codeType: scanCore.ScanType = scanCore.ScanType.QR_CODE; // Default barcode type, which is QR code.
  @State codeMargin: number = 1; // Default barcode margin, in px.
  @State codeBackgroundColor: number = 0xffffff; // Default background color of the barcode image.
  @State codePixelMapColor: number = 0x000000; // Default color of the barcode image.
  @State windowService: WindowService = WindowService.getInstance();
  @State codeLevel: generateBarcode.ErrorCorrectionLevel =
    generateBarcode.ErrorCorrectionLevel.LEVEL_H; // Default error correction level of the barcode image.
  @State pixelMapWidth: number = 300;

  build() {
    Column() {
      RelativeContainer() {
        StatusBar({ title: $r('app.string.generate_QR_code') })
      }
      .height(60)

      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap,
        alignItems: ItemAlign.Center,
        justifyContent: FlexAlign.Center
      }) {
        Flex({
          direction: FlexDirection.Row,
          wrap: FlexWrap.Wrap,
          alignItems: ItemAlign.Center,
          justifyContent: FlexAlign.Center
        }) {
          Flex({
            wrap: FlexWrap.NoWrap,
          }) {
            CustomLabel({
              text: $r('app.string.barcode_content')
            })
              .margin({ left: 5 })

            TextArea({ placeholder: this.codeInputContext })
              .demoTextArea()
              .onChange((value: string) => {
                this.codeInputContext = value;
              })
          }.FlexRow()

          Flex({
            wrap: FlexWrap.NoWrap,
            justifyContent: FlexAlign.SpaceBetween
          }) {
            Flex({
              wrap: FlexWrap.NoWrap,
            }) {
              CustomLabel({
                text: $r('app.string.barcode_width')
              })

              TextInput({ placeholder: '800' }).demoTextInput()
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.codeWidth = value;
                }).width('100%')
            }.width('48%')

            Flex({
              wrap: FlexWrap.NoWrap,
            }) {
              CustomLabel({
                text: $r('app.string.barcode_height')
              })
              TextInput({ placeholder: '800' }).demoTextInput()
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.codeHeight = value;
                }).width('100%')
            }.width('50%')
          }.FlexRow()

          Row() {
            Row() {
              CustomLabel({
                text: $r('app.string.barcode_type')
              })
              Select(ScanConstant.codeTypeItems)
                .value('QR_CODE')
                .selected(10)
                .demoSelect()
                .onSelect((_: number, value?: string) => {
                  this.codeType = getScanTypeVal(value);
                })
                .width(this.windowService.width <= 480 ? '60%' : '80%')

            }.width('50%').demoRow()

            Row() {
              CustomLabel({
                text: $r('app.string.barcode_margin')
              })
              TextInput({ placeholder: '1' }).demoTextInput()
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.codeMargin = Number.parseInt(value);
                }).width(this.windowService.width <= 480 ? '60%' : '80%')
            }.width('50%').demoRow()
          }

          Row() {
            Row() {
              CustomLabel({
                text: $r('app.string.barcode_color')
              })
              Select(ScanConstant.colorItems)
                .selected(0)
                .value('Black')
                .demoSelect()
                .onSelect((_: number, value?: string) => {
                  this.codePixelMapColor = getColorType(value);
                })
                .width(this.windowService.width <= 480 ? '60%' : '80%')

            }.width('50%').demoRow()

            Row() {
              CustomLabel({
                text: $r('app.string.barcode_background_color')
              })
              Select(ScanConstant.colorItems)
                .selected(7)
                .value('White')
                .demoSelect()
                .onSelect((_: number, value?: string) => {
                  this.codeBackgroundColor = getColorType(value);
                })
                .align(Alignment.Center)
                .width(this.windowService.width <= 480 ? '60%' : '80%')
            }.width('50%').demoRow()
          }

          Row() {
            Row() {
              CustomLabel({
                text: $r('app.string.barcode_error_level')
              })
              Select(ScanConstant.errorLevelItems)
                .align(Alignment.Center)
                .width(this.windowService.width <= 480 ? '60%' : '80%')
                .selected(3)
                .value('LEVEL_H')
                .demoSelect()
                .onSelect((_: number, value?: string) => {
                  this.codeLevel = getErrorCorrectionLevel(value);
                })

            }.width('50%').demoRow()

            Row() {
            }.width('50%').demoRow()
          }
        }.padding(16)
        .height(255)

        Column() {
          CustomButton({
            mText: $r('app.string.generate_barcode'), mOnClick: () => {
              this.pixelMap = undefined;
              let content = this.codeInputContext;
              let options: generateBarcode.CreateOptions = {
                scanType: this.codeType,
                height: Number(this.codeHeight),
                width: Number(this.codeWidth),
                margin: Number(this.codeMargin),
                level: this.codeLevel,
                backgroundColor: this.codeBackgroundColor,
                pixelMapColor: this.codePixelMapColor,
              };

              try {
                generateBarcode.createBarcode(content, options).then((result: image.PixelMap) => {
                  this.pixelMap = result;
                  Logger.info(TAG, 'Succeeded in creating barCode.');
                }).catch((error: BusinessError) => {
                  showError(error);
                  Logger.error(TAG, `Failed to create barCode. Code: ${error.code}, message: ${error.message}`);
                })
              } catch (error) {
                showError(error);
                Logger.error(TAG, `Failed to create barCode. Code: ${error?.code}, message: ${error?.message}`);
              }
            }
          })

          CustomButton({
            mText: $r('app.string.generate_trip_barcode'), mOnClick: () => {
              this.pixelMap = undefined;
              let content = this.codeInputContext;
              let pattern = /^[0-9a-fA-F]+$/;
              if (content && !pattern.test(content)) {
                showMessage($r('app.string.trip_barcode_tip'));
                return;
              }
              if (content.length % 2 !== 0) {
                content = '0' + content;
              }
              let contentBuffer: ArrayBuffer = buffer.from(content, 'hex').buffer;
              let options: generateBarcode.CreateOptions = {
                scanType: this.codeType,
                height: Number(this.codeHeight),
                width: Number(this.codeWidth),
                margin: Number(this.codeMargin),
                level: this.codeLevel,
                backgroundColor: this.codeBackgroundColor,
                pixelMapColor: this.codePixelMapColor,
              };

              try {
                generateBarcode.createBarcode(contentBuffer, options).then((result: image.PixelMap) => {
                  this.pixelMap = result;
                  Logger.info(TAG, 'Succeeded in creating barCode.');
                }).catch((error: BusinessError) => {
                  showError(error);
                  Logger.error(TAG, `Failed to create barCode. Code: ${error.code}, message: ${error.message}`);
                });
              } catch (error) {
                showError(error);
                Logger.error(TAG, `Failed to create barCode. Code: ${error?.code}, message: ${error?.message}`);
              }
            }
          })
        }
        .height(100)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')

      Column() {
        if (this.pixelMap) {
          Image(this.pixelMap).width(this.pixelMapWidth).height(this.pixelMapWidth).objectFit(ImageFit.Contain)
        }
      }
      .width('100%')
      .margin(10)
      .layoutWeight(1)
      .onAreaChange((_: Area, newValue: Area) => {
        let min = Math.min(newValue.width as number, newValue.height as number);
        if (min < 320) {
          this.pixelMapWidth = min - 20;
        }
      })
    }
    .width('100%')
    .height('100%')
  }
}




