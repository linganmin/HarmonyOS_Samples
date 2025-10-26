import { mediaquery, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';

// [Start Media]
@Entry
@Component
struct MediaQueryPage {
  @State color: string = '#DB7093';
  @State text: string = 'Portrait';
  // The condition is true when the device is in landscape orientation
  listener: mediaquery.MediaQueryListener =
    this.getUIContext().getMediaQuery().matchMediaSync('(orientation: landscape)');
  // When the media query conditions are met, a callback is triggered
  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    if (mediaQueryResult.matches as boolean) {
      // If the device is in landscape orientation, change the corresponding page layout
      this.color = '#FFD700';
      this.text = 'Landscape';
    } else {
      this.color = '#DB7093';
      this.text = 'Portrait';
    }
  }
  aboutToAppear() {
    // Bind the current application instance
    // Bind a callback function
    this.listener.on('change', (mediaQueryResult: mediaquery.MediaQueryResult) => {
      this.onPortrait(mediaQueryResult)
    });
  }
  aboutToDisappear() {
    // Unbind the callback function registered in the listener
    this.listener.off('change');
  }

  // Change the horizontal and vertical screen status functions of the device
  private changeOrientation(isLandscape: boolean) {
    // Obtain the context of the UIAbility instance
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    // Call this API to manually change the horizontal and vertical screen status of the device
    window.getLastWindow(context).then((lastWindow) => {
      lastWindow.setPreferredOrientation(isLandscape ? window.Orientation.LANDSCAPE : window.Orientation.PORTRAIT)
    });
  }

  build() {
    Column({ space: 50 }) {
      Text(this.text)
        .fontSize(50)
        .fontColor(this.color)
      Text('Landscape')
        .fontSize(50)
        .fontColor(this.color)
        .backgroundColor(Color.Orange)
        .onClick(() => {
          this.changeOrientation(true);
        })
      Text('Portrait')
        .fontSize(50)
        .fontColor(this.color)
        .backgroundColor(Color.Orange)
        .onClick(() => {
          this.changeOrientation(false);
        })
    }
    .width('100%')
    .height('100%')
  }
}

// [End Media]
