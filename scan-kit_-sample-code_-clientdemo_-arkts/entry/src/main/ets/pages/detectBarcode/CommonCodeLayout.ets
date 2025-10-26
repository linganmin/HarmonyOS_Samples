import { display } from '@kit.ArkUI';
import { scanBarcode } from '@kit.ScanKit';
import Logger from '../../common/Logger';
import { DeviceService } from '../customScan/model/DeviceService';
import { UIContextSelf } from '../customScan/model/UIContextSelf';
import { WindowService } from '../customScan/model/WindowService';

const TAG: string = 'CodeLayout';

@Entry
@Component
struct CodeLayout {
  private result: Array<object> = [];
  private uri: string = '';
  private infoW: number = 0;
  private infoH: number = 0;
  @State displayHeight: number = 1412;
  @State displayWidth: number = 720;
  @State layTop: number = 226;
  @State layLeft: number = 0;
  @State screen: number = 1;
  @State codeLocation: Array<Array<number>> = [];
  public scroller: Scroller = new Scroller();
  @State windowService: WindowService = WindowService.getInstance();

  aboutToAppear() {
    this.codeLocation = [];
    this.setDisplay();
    Logger.info(TAG, 'aboutToAppear CodeLayout');
    let params =
      UIContextSelf.getRouter().getParams() as Record<string, number | string | Array<scanBarcode.ScanResult>>;
    this.result = params.result as Array<scanBarcode.ScanResult>;
    this.uri = params.uri as string;
    this.infoW = params.infoW as number;
    this.infoH = params.infoH as number;
    Logger.info(TAG, `uri: ${this.uri}, infoW: ${this.infoW}, infoH: ${this.infoH}`);
    this.calculate();
    if (DeviceService.isFolding) {
      try {
        display.on('foldDisplayModeChange', async (foldStatus: display.FoldDisplayMode) => {
          // 1: unfolded 2: folded
          if (foldStatus === 1 || foldStatus === 2) {
            setTimeout(() => {
              this.codeLocation = [];
              this.setDisplay();
              this.calculate();
            }, 300)
          }
        });
      } catch (error) {
        Logger.error(TAG, `Failed to on foldDisplayModeChange. Code: ${error?.code}.`);
      }
    }
  }

  setDisplay(): void {
    Logger.info(TAG, 'setDisplay start');
    let displayClass: display.Display | null = null;
    try {
      displayClass = display.getDefaultDisplaySync();
      Logger.info(TAG, `width: ${displayClass.width}, height: ${displayClass.height}.`);
    } catch (error) {
      Logger.error(TAG, `Failed to getDefaultDisplaySync. Code: ${error?.code}.`);
    }

    if (displayClass !== null) {
      displayClass.height = displayClass.height - UIContextSelf.uiContext.vp2px(this.windowService.topAvoidHeight);
      this.displayHeight = Math.round(UIContextSelf.uiContext.px2lpx(displayClass.height));
      this.displayWidth = Math.round(UIContextSelf.uiContext.px2lpx(displayClass.width));
      Logger.info(TAG, `setDisplay,displayWidth: ${this.displayWidth}, displayHeight: ${this.displayHeight}.`);
    }
  }

  calculate() {
    if (this.infoW && this.infoH && this.displayHeight && this.displayWidth) {
      if (this.infoW / this.infoH > this.displayWidth / this.displayHeight) {
        this.screen = this.displayWidth / this.infoW;
        this.layTop = (this.displayHeight - this.displayWidth * this.infoH / this.infoW) / 2;
        this.layLeft = 0;
      } else {
        this.layTop = 0;
        this.layLeft = (this.displayWidth - this.displayHeight * this.infoW / this.infoH) / 2;
        this.screen = this.displayHeight / this.infoH;
      }
    }
    for (let i = 0; i < this.result.length; i++) {
      let rx = Math.round(this.result[i]['scanCodeRect']['left'] * this.screen + this.layLeft);
      let ry = Math.round(this.result[i]['scanCodeRect']['top'] * this.screen + this.layTop);
      let rw =
        Math.round((this.result[i]['scanCodeRect']['right'] - this.result[i]['scanCodeRect']['left']) * this.screen);
      let rh =
        Math.round((this.result[i]['scanCodeRect']['bottom'] - this.result[i]['scanCodeRect']['top']) * this.screen);
      this.codeLocation.push([rx, ry, rw, rh])
    }
  }

  build() {
    Stack() {
      Image($rawfile('scan_back.svg'))
        .fillColor(Color.Black)
        .width(30)
        .height(30)
        .objectFit(ImageFit.Contain)
        .position({ x: 15, y: 0 })
        .zIndex(10)
        .onClick(() => {
          UIContextSelf.getRouter().back();
        })
        .margin({
          top: this.windowService.topAvoidHeight
        })
      Column() {
        Image(this.uri)
          .objectFit(ImageFit.Contain)
          .width('100%')
          .height('100%')
        ForEach(this.codeLocation, (item: Array<number>, index: number) => {
          Image($rawfile('scan_selected.svg'))
            .width(40)
            .height(40)
            .markAnchor({ x: 20, y: 20 })
            .position({
              x: item[0] + item[2] / 2 + 'lpx',
              y: item[1] + item[3] / 2 + 'lpx',
            })
            .onClick(() => {
              UIContextSelf.pushUrl({
                url: 'pages/resultPage/ResultPage',
                params: this.result[index]
              })
            })
        }, (item: Array<number>, _: number) => item[0] + item[1] + item[2] + item[3] + 'codeLocation')
      }
      .padding({
        top: this.windowService.topAvoidHeight
      })
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}