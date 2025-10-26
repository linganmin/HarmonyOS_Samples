// [Start orientation]
import { display, window } from '@kit.ArkUI';

const TAG = 'foo';
const ORIENTATION: Array<string> = ['垂直', '平', '反向垂直', '反向水平'];

@Entry
@Component
struct OrientationPage {
  @State rotation: number = 0;
  @State message: string = ORIENTATION[this.rotation];
  @Watch('setWindowLayOut') @State isLandscape: boolean = false;

  aboutToAppear() {
    this.setOrientation(1);
    let callback = async () => {
      let getDefaultDisplay = display.getDefaultDisplaySync();
      this.rotation = getDefaultDisplay.rotation;
      this.message = ORIENTATION[this.rotation];
    };
    try {
      display.on('change', callback);
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to register callback. Code: ' + JSON.stringify(exception));
    }
  }

  setOrientation(type: number) {
    try {
      window.getLastWindow(getContext(this), (err, data) => {
        //获取window实例
        if (err.code) {
          hilog.error(0x0000, TAG, 'Failed to obtain the top window. Cause: ' + JSON.stringify(err));
          return;
        }
        let windowClass = data;
        hilog.info(0x0000, TAG, 'Succeeded in obtaining the top window. Data: ' + JSON.stringify(data));
        let orientation: number;
        if (type === 1) {
          orientation = window.Orientation.AUTO_ROTATION;
        } else {
          orientation = window.Orientation.UNSPECIFIED;
        }
        try {
          windowClass.setPreferredOrientation(orientation, (err) => {
            if (err.code) {
              hilog.error(0x0000, TAG, 'Failed to set window orientation. Cause: ' + JSON.stringify(err));
              return;
            }
            hilog.info(0x0000, 'Succeeded in setting window orientation.');
          });
        } catch (exception) {
          hilog.error(0x0000, TAG, 'Failed to set window orientation. Cause: ' + JSON.stringify(exception));
        }
      });
    } catch (exception) {
      hilog.error(0x0000, TAG, 'Failed to obtain the top window. Cause: ' + JSON.stringify(exception));
    }
  }

  setWindowLayOut() {
    window.getLastWindow(getContext(this)).then((windowClass) => {
      if (this.isLandscape) {
        hilog.info(0x0000, 'OrientationPage', '设置屏幕横屏');
        windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION_LANDSCAPE);
      } else {
        hilog.info(0x0000, 'OrientationPage', '设置屏幕竖屏');
        windowClass.setPreferredOrientation(window.Orientation.AUTO_ROTATION_PORTRAIT);
      }
    });
  }

  build() {
    Row() {
      Column() {
        Text(`${this.rotation}`)
          .fontSize(25)
        Text(`${this.message}`)
          .fontSize(25)
        Button('全屏')
          .width(140)
          .onClick(() => {
            this.isLandscape = !this.isLandscape;
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End orientation]
