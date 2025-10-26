import { LengthMetrics } from '@kit.ArkUI';
import { UIContextSelf } from '../pages/customScan/model/UIContextSelf';
import { WindowService } from '../pages/customScan/model/WindowService';

@Component
export struct StatusBar {
  @State windowService: WindowService = WindowService.getInstance();
  @Prop title: string | Resource = '';
  @Prop isBackToHome: boolean = false;

  build() {
    Row() {
      Image($rawfile('scan_back.svg'))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .responseRegion({
          x: '-50%',
          y: '-50%',
          width: '200%',
          height: '200%'
        })
        .draggable(false)
        .fillColor(Color.Black)
      Text(this.title)
        .fontSize(20)
        .fontColor($r('sys.color.black'))
        .margin({ start: LengthMetrics.vp(15) })
    }
    .margin({ start: LengthMetrics.vp(16) })
    .zIndex(10)
    .position({ start: LengthMetrics.vp(15) })
    .onClick(async () => {
      if (this.isBackToHome) {
        UIContextSelf.getRouter().clear();
        UIContextSelf.replaceUrl({
          url: 'pages/Index'
        });
      } else {
        UIContextSelf.getRouter().back();
      }
    })
    .height(56 + this.windowService.topAvoidHeight)
    .width('100%')
    .alignRules({
      top: { anchor: '__container__', align: VerticalAlign.Top },
      left: { anchor: '__container__', align: HorizontalAlign.Start }
    })
    .id('statusBar')
  }
}