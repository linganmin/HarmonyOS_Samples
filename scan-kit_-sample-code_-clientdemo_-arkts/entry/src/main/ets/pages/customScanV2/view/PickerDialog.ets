import { ConfigurationConstant } from '@kit.AbilityKit';
import { curves } from '@kit.ArkUI';
import { funcDelayer } from '../../../common/Utils';
import { CommonConstants } from '../../customScan/constants/CommonConstants';
import { UIContextSelf } from '../../customScan/model/UIContextSelf';
import { ConfigStorage } from '../model/ConfigStorage';
import { WindowServiceV2 } from '../model/WindowService';

@Extend(Text)
function textClass(color: ResourceColor, textAlign: TextAlign) {
  .fontWeight(FontWeight.Regular)
  .fontColor(color)
  .fontFamily('HarmonyHeiTi')
  .textAlign(textAlign)
  .lineHeight(22)
  .opacity(0.9)
}

@Extend(Column)
function componentContainer() {
  .width('100%')
  .height('100%')
  .padding({ left: 16, right: 16 })
  .backgroundColor($r('sys.color.ohos_id_color_mask_thin'))
  .justifyContent(FlexAlign.End)
  .position({
    x: 0, y: 0
  })
}

@Extend(Column)
function dialogBoxContainer(color: ResourceColor) {
  .padding({
    left: 16,
    top: 24,
    right: 16,
    bottom: 16
  })
  .backgroundColor(color)
  .borderRadius($r('sys.float.ohos_id_corner_radius_dialog'))
}

@Extend(Column)
function dialogContentContainer() {
  .margin({
    left: 8,
    right: 8,
    bottom: 8
  })
}

@ComponentV2
export struct PickerDialog {
  @Local configStorage: ConfigStorage = ConfigStorage.getInstance();
  @Local windowService: WindowServiceV2 = WindowServiceV2.getInstance();
  @Local dialogWidth: number = 368;
  @Local dialogScale: number = 0.85;
  @Require @Param text: Resource;
  @Event cancel: () => void = () => {
  };

  @Computed
  get isColorDarkMode() {
    return this.configStorage.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  @Builder
  DialogText() {
    Text(this.text)
      .textClass(this.isColorDarkMode ? $r('sys.color.ohos_id_color_text_primary_dark') :
        $r('sys.color.ohos_id_color_text_primary'), TextAlign.Center)
      .fontSize($r('sys.float.Body_L'))
      .maxFontSize(CommonConstants.SCAN_FONT_SIZE_SCALE_LIMIT_DIALOG_TEXT)

  }

  @Builder
  DialogButton() {
    Button($r('app.string.Scan_diaLog_got_it'), { buttonStyle: ButtonStyleMode.TEXTUAL })
      .width('100%')
      .height(40)
      .onClick(() => {
        UIContextSelf.uiContext.animateTo({
          duration: 250,
          curve: Curve.Friction,
          delay: 0,
          iterations: 1,
          playMode: PlayMode.Alternate,
        }, () => {
          this.dialogScale = 0.85;
          funcDelayer(() => {
            this.cancel();
          }, 100);
        });
      })
  }

  appearAnimation() {
    UIContextSelf.uiContext.animateTo({
      duration: 250,
      curve: curves.cubicBezierCurve(0.38, 1.33, 0.6, 1),
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Alternate,
    }, () => {
      this.dialogScale = 1;
    });
  }

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Column() {
          Column() {
            this.DialogText()
          }.dialogContentContainer()

          this.DialogButton()
        }
        .dialogBoxContainer(
            this.isColorDarkMode ? $r('sys.color.ohos_id_blur_style_component_ultra_thick_color_dark') :
            $r('sys.color.ohos_id_blur_style_component_ultra_thick_color')
        )
        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK, {
          colorMode: this.isColorDarkMode ? ThemeColorMode.DARK : ThemeColorMode.LIGHT,
          adaptiveColor: AdaptiveColor.DEFAULT,
        })
        .onAreaChange((_: Area, newArea: Area) => {
          this.dialogWidth = Number(newArea.width);
        })
        .scale({ x: this.dialogScale, y: this.dialogScale })
        .width(this.windowService.width >= 400 ? 400 : '100%')
      }
      .width('100%')
    }
    .componentContainer()
    .onAppear(() => {
      this.appearAnimation();
    })
  }
}