import { BreakpointConstants } from '../../customScan/constants/BreakpointConstants';
import { CommonConstants } from '../../customScan/constants/CommonConstants';
import { BreakpointType } from '../../customScan/model/BreakpointType';
import { ScanLayout } from '../model/ScanLayout';

const LOADING_OFFSET_Y: number = -36;

@Extend(LoadingProgress)
function loadingIcon() {
  .color($r('sys.color.ohos_id_color_progress'))
  .width(72)
  .height(72)
}

@Extend(Text)
function loadingText() {
  .fontFamily('HarmonyHeiTi')
  .fontSize($r('sys.float.Body_M'))
  .fontWeight(FontWeight.Regular)
  .textAlign(TextAlign.Center)
  .fontColor($r('sys.color.ohos_id_color_text_secondary_dark'))
  .lineHeight(19)
  .margin({
    top: 16
  })
}

@ComponentV2
export struct ScanLoading {
  @Local scanLayout: ScanLayout = ScanLayout.getInstance();

  build() {
    Column() {
      Column() {
        LoadingProgress().loadingIcon()
        Text($r('app.string.Scan_album_loading')).loadingText()
          .maxFontSize(CommonConstants.SCAN_FONT_SIZE_SCALE_LIMIT_SYMBOL_TEXT)
      }
      .height(new BreakpointType(BreakpointConstants.LOADING_HEIGHT_SM,
        BreakpointConstants.LOADING_HEIGHT_MD,
        BreakpointConstants.LOADING_HEIGHT_LG).getValue(this.scanLayout.widthBreakpoint))
      .offset({
        y: LOADING_OFFSET_Y
      })
    }
    .justifyContent(FlexAlign.End)
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }
}