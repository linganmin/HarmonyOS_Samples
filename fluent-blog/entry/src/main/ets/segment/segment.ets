// [Start all_start]
// [Start import_start]
import { displaySync } from '@kit.ArkGraphics2D';
// [End import_start]

@Entry
@Component
struct Index {
  @State drawFirstSize: number = 25;
  @State rotateAngle: number = 1;
  @State drawSecondSize: number = 25;
  // [Start DisplaySync_start]
  private backDisplaySyncSlow: displaySync.DisplaySync | undefined = undefined;
  private backDisplaySyncFast: displaySync.DisplaySync | undefined = undefined;
  // [End DisplaySync_start]
  private isBigger30: boolean = true;

  aboutToDisappear() {
    if (this.backDisplaySyncSlow) {
      this.backDisplaySyncSlow.stop(); // DisplaySync enable off
      this.backDisplaySyncSlow = undefined; // Empty the instance
    }
    if (this.backDisplaySyncFast) {
      this.backDisplaySyncFast.stop(); // DisplaySync enable off
      this.backDisplaySyncFast = undefined; // Empty the instance
    }
  }

  CreateDisplaySyncSlow() {
    // Defining the Desired Drawing Frame Rate
    this.backDisplaySyncSlow = displaySync.create(); // Creating a DisplaySync Instance
    // [Start setExpectedFrameRateRange_start]
    let range: ExpectedFrameRateRange = {
      expected: 30,
      min: 0,
      max: 120
    };
    this.backDisplaySyncSlow.setExpectedFrameRateRange(range); // Setting the frame rate
    // [End setExpectedFrameRateRange_start]

    let draw30 = (intervalInfo: displaySync.IntervalInfo) => {
      if (this.isBigger30) {
        this.rotateAngle += 1;
      } else {
        this.rotateAngle -= 1;
        if (this.rotateAngle < 25) {
          this.isBigger30 = true;
        }
      }
    };

    this.backDisplaySyncSlow.on("frame", draw30); // Subscribing to frame events and registering subscription functions
  }

  build() {
    Column() {
      // [Start rotate_start]
      Row() {
        Image($r('app.media.avatar'))
          .height(40)
          .width(40)
      }
      .rotate({
        x: 0,
        y: 0,
        z: 1,
        centerX: '50%',
        centerY: '50%',
        angle: this.rotateAngle
      })
      // [End rotate_start]

      Row() {
        Button('Start')
          .onClick(() => {
            if (this.backDisplaySyncSlow === undefined) {
              this.CreateDisplaySyncSlow();
            }
            if (this.backDisplaySyncSlow) {
              this.backDisplaySyncSlow.start(); // DisplaySync enable off
            }
          })
      }
    }
  }
}
// [End all_start]

// [Start comment_start]
// Note the following lines
// let range : ExpectedFrameRateRange = {
//     expected: 30,
//     min: 0,
//     max: 120
// };
// this.backDisplaySyncSlow.setExpectedFrameRateRange(range);
// [End comment_start]
