import { imageFeaturePicker } from '@kit.Penkit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Row() {
          Button() {
            Text('Call GlobalColorPicker from ets side')
              .fontSize(18)
              .fontWeight(FontWeight.Normal)
          }
          .width('50%')
          .height('60vp')
          .align(Alignment.Center)
          .onClick((event) => {
            imageFeaturePicker.pickForResult(event.displayX, event.displayY)
              .then((colorInfo: imageFeaturePicker.PickedColorInfo) => {
                if (colorInfo) {
                  console.info('colorInfo=' + JSON.stringify(colorInfo));
                }
              }).catch((err: BusinessError) => {
              console.error(`pickForResult failed. Code is ${err.code}, message is ${err.message}`)
            })
          })
        }
      }
      .align(Alignment.Center)
    }
    .width('100%')
    .height('100%')
  }
}