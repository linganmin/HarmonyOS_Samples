import Logger from '../../../common/Logger';
import { BreakpointConstants } from '../../customScan/constants/BreakpointConstants';
import { CommonConstants } from '../../customScan/constants/CommonConstants';
import { BREAK_POINT_TYPE_MARGIN_VP } from '../../customScan/model/BreakpointType';
import { ScanLayout } from '../model/ScanLayout';

@Extend(Text)
function scanTitle(color: ResourceColor, fontWeight: FontWeight) {
  .textAlign(TextAlign.Center)
  .fontFamily('HarmonyHeiTi')
  .fontWeight(fontWeight)
  .fontColor(color)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

const TAG = 'ScanTitleV2';

@ComponentV2
export struct ScanTitle {
  @Local scanLayout: ScanLayout = ScanLayout.getInstance();
  @Require @Param scanResultSize: number = 0;

  @Computed
  get isSMOrMDBreakpoint() {
    return this.scanLayout.heightBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
      this.scanLayout.heightBreakpoint === BreakpointConstants.BREAKPOINT_MD;
  }

  build() {
    Column() {
      Text(this.scanResultSize > 1 ? $r('app.string.Scan_barcode_tips_callback') : $r('app.string.Scan_barcode'))
        .scanTitle($r('sys.color.ohos_id_color_primary_contrary'), FontWeight.Regular)
        .fontSize($r('sys.float.Subtitle_L'))
        .maxFontSize(CommonConstants.SCAN_FONT_SIZE_SCALE_LIMIT_TITLE_TEXT)
        .width(this.isSMOrMDBreakpoint ? `calc(100% - 80vp - 16vp)` : '100%')
        .constraintSize({
          maxWidth: this.isSMOrMDBreakpoint ? `calc(100% - 80vp - 16vp)` : 460
        })
    }
    .onSizeChange((oldValue: SizeOptions, newValue: SizeOptions) => {
      Logger.info(TAG,
        `title height has changed, oldTitleHeight: ${oldValue.height}, newTitleHeight: ${newValue.height}`);
      let titleHeight: number = Number(newValue.height);
      if (Math.abs(this.scanLayout.titleHeight - titleHeight) > 1) {
        this.scanLayout.setTopLayout(titleHeight);
      }
    })
    .id('scan_scan_title_v2')
    .alignItems(HorizontalAlign.Center)
    .margin({
      top: this.scanLayout.titleMarginTop
    })
    .padding({
      left: BREAK_POINT_TYPE_MARGIN_VP.getValue(this.scanLayout.widthBreakpoint),
      right: BREAK_POINT_TYPE_MARGIN_VP.getValue(this.scanLayout.widthBreakpoint)
    })
    .width('100%')
  }
}