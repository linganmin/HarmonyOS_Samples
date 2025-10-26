// [Start Case1]
// constant declaration
const animationDuration: number = 500; // Move animation duration
const opacityChangeValue: number = 0.1; // The value of each change in opacity
const opacityChangeRange: number = 1; // Range of opacity changes
const translateYChangeValue: number = 180; // The value of translateY each time it changes
const translateYChangeRange: number = 250; // The range in which translateY changes
const scaleXChangeValue: number = 0.6; // The value of scaleX for each change
const scaleXChangeRange: number = 0.8; // The value of scaleX for each change

// Style Attribute Classes
class UIStyle {
  public translateX: number = 0;
  public translateY: number = 0;
  public scaleX: number = 0.3;
  public scaleY: number = 0.3;
}

@Component
struct ComponentA {
  @Link uiStyle: UIStyle; // Properties of uiStyle used by multiple components

  build() {
    Column() {
      // Components that use state variables
      SpecialImage({ specialImageUiStyle: this.uiStyle })
      Column() {
        // 需要替换为开发者所需的图像资源文件
        Image($r('app.media.startIcon'))
          .height('150vp')
          .width('150vp')
          .scale({
            x: this.uiStyle.scaleX,
            y: this.uiStyle.scaleY
          })
        Text('Hello World')
          .fontWeight(FontWeight.Bold)
      }
      .translate({
        x: this.uiStyle.translateX,
        y: this.uiStyle.translateY
      })
      .width('95%')
      .height('200vp')
      .margin({
        top: '10vp',
        left: '15vp',
        right: '15vp'
      })
      .borderRadius('16vp')
      .backgroundColor(Color.White)
      // Modify the value of a state variable via a button click callback, causing the corresponding component to refresh.
      Column() {
        Button('Move')
          .width('80%')
          .onClick(() => {
            this.getUIContext().animateTo({ duration: animationDuration }, () => {
              this.uiStyle.translateY = (this.uiStyle.translateY + translateYChangeValue) % translateYChangeRange;
            })
          })
        Button('Scale')
          .width('80%')
          .onClick(() => {
            this.uiStyle.scaleX = (this.uiStyle.scaleX + scaleXChangeValue) % scaleXChangeRange;
          })
          .margin({
            top: '10vp',
            left: '15vp',
            right: '15vp'
          })
      }
      .height('35%')
      .justifyContent(FlexAlign.End)
      .width('100%')
    }
  }
}

@Component
struct SpecialImage {
  @Link specialImageUiStyle: UIStyle;
  private opacityNum: number = 0.5; // Default transparency

  private isRenderSpecialImage(): number {
    // Image transparency increases by 0.1 each time it is rendered, cycling between 0 and 1.
    this.opacityNum = (this.opacityNum + opacityChangeValue) % opacityChangeRange;
    return this.opacityNum;
  }

  build() {
    Column() {
      // 需要替换为开发者所需的图像资源文件
      Image($r('app.media.startIcon'))
        .size({ width: 78, height: 78 })
        .scale({
          x: this.specialImageUiStyle.scaleX,
          y: this.specialImageUiStyle.scaleY
        })
        .opacity(this.isRenderSpecialImage())
      Text("SpecialImage")
        .fontWeight(FontWeight.Bold)
    }
    .width('95%')
    .margin({
      top: '10vp',
      left: '15vp',
      right: '15vp'
    })
    .borderRadius('16vp')
    .height('200vp')
    .backgroundColor(Color.White)
  }
}


@Entry
@Component
struct DFXStateBeforeOptimization {
  @State uiStyle: UIStyle = new UIStyle();

  build() {
    Column() {
      ComponentA({
        uiStyle: this.uiStyle
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}

// [End Case1]