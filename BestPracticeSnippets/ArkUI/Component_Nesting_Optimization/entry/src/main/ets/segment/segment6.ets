// [Start Case5]
import { ColorMetrics } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
struct ColorMeasure {
  @Prop isSelected: boolean = false;

  build() {
    Column()
      .width('100%')
      .height(100)
      .backgroundColor(this.isSelected ? this.getBlendColor(Color.Blue, "#99000000").color : Color.Grey)
      .borderRadius(12)
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
  }

  getBlendColor(baseColor: ResourceColor, addColor: ResourceColor): ColorMetrics {
    if (!baseColor || !addColor) {
      try {
        return ColorMetrics.resourceColor(Color.Black);
      } catch (error) {
        let err = error as BusinessError;
        hilog.warn(0x000, 'testTag', `showToast failed, code=${err.code}, message=${err.message}`);
      }
    }
    let sourceColor: ColorMetrics;
    try {
      sourceColor = ColorMetrics.resourceColor(baseColor).blendColor(ColorMetrics.resourceColor(addColor));
    } catch (err) {
      let error = err as BusinessError;
      console.error(`Failed to blend color, code = ${error.code}, message =${error.message}`);
      sourceColor = ColorMetrics.resourceColor(addColor);
    }
    return sourceColor;
  }
}

@Entry
@Component
struct ColorMetricsExample {
  @State isSelected: boolean = false;

  build() {
    Scroll() {
      Column() {
        ColorMeasure({ isSelected: this.isSelected })
          .onClick(() => {
            this.isSelected = !this.isSelected;
          })
      }
    }
  }
}

// [End Case5]