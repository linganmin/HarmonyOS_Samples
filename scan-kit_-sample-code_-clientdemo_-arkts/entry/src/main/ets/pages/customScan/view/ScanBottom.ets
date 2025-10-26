import { IconPress } from './IconPress'
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../model/BreakpointType';
import { ScanService } from '../model/ScanService';
import { ScanLayout } from '../model/ScanLayout';
import { LengthMetrics } from '@kit.ArkUI';

@Extend(Column)
function componentColumnContainer(currentBreakpoint: string) {
  .width('100%')
  .height('100%')
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.End)
  .padding({
    left: new BreakpointType($r('app.float.container_horizontal_padding_sm'),
      $r('app.float.container_horizontal_padding_md'),
      $r('app.float.container_horizontal_padding_lg')).getValue(currentBreakpoint),
    right: new BreakpointType($r('app.float.container_horizontal_padding_sm'),
      $r('app.float.container_horizontal_padding_md'),
      $r('app.float.container_horizontal_padding_lg')).getValue(currentBreakpoint)
  })
}

@Extend(Row)
function componentRowContainer(currentBreakpoint: string) {
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.End)
  .alignItems(VerticalAlign.Center)
  .padding({
    left: new BreakpointType($r('app.float.container_horizontal_padding_sm'),
      $r('app.float.container_horizontal_padding_md'),
      $r('app.float.container_horizontal_padding_lg')).getValue(currentBreakpoint),
    right: new BreakpointType($r('app.float.container_horizontal_padding_sm'),
      $r('app.float.container_horizontal_padding_md'),
      $r('app.float.container_horizontal_padding_lg')).getValue(currentBreakpoint)
  })
}

@Extend(SymbolGlyph)
function lightIcon() {
  .fontColor([$r('sys.color.font_on_primary')])
  .fontWeight(FontWeight.Regular)
  .fontSize('24vp')
}

@Extend(Text)
function lightText() {
  .fontColor($r('sys.color.icon_on_primary'))
  .textAlign(TextAlign.Center)
  .fontFamily('HarmonyHeiTi')
  .height(16)
  .lineHeight(16)
}

@Component
export struct FlashLight {
  @State scanService: ScanService = ScanService.getInstance();
  @Prop isLargeScreen: boolean

  build() {
    Column() {
      SymbolGlyph(this.scanService.isFlashlight ? $r('sys.symbol.flashlight_on') : $r('sys.symbol.flashlight_off'))
        .lightIcon()
        .margin({ bottom: 6 })
        .stateStyles({
          pressed: {
            .opacity(0.4)
          },
          normal: {
            .opacity(1)
          }
        })
      Text(this.scanService.isFlashlight ? $r('app.string.Scan_light_to_off') : $r('app.string.Scan_light_to_on'))
        .lightText()
        .fontSize($r('sys.float.Body_S'))
        .maxFontSize(CommonConstants.SCAN_FONT_SIZE_SCALE_LIMIT_SYMBOL_TEXT)
    }
    .height(CommonConstants.FLASH_HEIGHT)
    .padding({
      top: 3,
      bottom: 3
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.scanService.changeFlashlight();
    })
  }
}

@Component
export struct ScanBottom {
  @State scanService: ScanService = ScanService.getInstance();
  @State scanLayout: ScanLayout = ScanLayout.getInstance();
  @Prop enableAlbum: boolean = false;
  public openPicker: () => void = () => {
  };

  @Builder
  IsIconPress() {
    if (this.enableAlbum) {
      IconPress({
        url: $r('sys.symbol.picture'),
        text: $r('app.string.Scan_gallery'),
        iconId: 'scan_page_openPicker',
        imageClick: () => {
          this.openPicker();
        }
      })
    }
  }

  @Builder
  SMBuilder() {
    Column() {
      // Flash light.
      FlashLight({
        isLargeScreen: false
      })
        .margin({
          bottom: this.scanLayout.flashToGallery
        })
        .visibility((this.scanService.isFlashlight || this.scanService.isSensorLight)
          && this.scanLayout.isFlashShow ? Visibility.Visible : Visibility.Hidden)

      // Image button area.
      Row() {
        this.IsIconPress()
      }
      .height(this.scanLayout.heightBreakpoint === BreakpointConstants.BREAKPOINT_SM ||
        this.scanLayout.heightBreakpoint === BreakpointConstants.BREAKPOINT_MD ? CommonConstants.ICON_PRESS_HEIGHT :
      CommonConstants.ICON_PRESS_TEXT_HEIGHT)
      .width('100%')
      .margin({
        bottom: this.scanLayout.galleryMarginBottom
      })
      .justifyContent(FlexAlign.Center)
    }
    .componentColumnContainer(this.scanLayout.widthBreakpoint)
  }

  @Builder
  NotSMBuilder() {
    Row() {
      FlashLight({
        isLargeScreen: true
      })
        .margin({
          end: LengthMetrics.vp(this.scanLayout.flashToGallery)
        })
        .visibility((this.scanService.isFlashlight || this.scanService.isSensorLight)
          && this.scanLayout.isFlashShow ? Visibility.Visible : Visibility.Hidden)

      Column() {
        this.IsIconPress()
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width(this.scanLayout.galleryAreaWidth)
    }
    .componentRowContainer(this.scanLayout.widthBreakpoint)
  }

  build() {
    if (this.scanLayout.widthBreakpoint === BreakpointConstants.BREAKPOINT_SM) {
      this.SMBuilder()
    } else {
      this.NotSMBuilder()
    }
  }
}
