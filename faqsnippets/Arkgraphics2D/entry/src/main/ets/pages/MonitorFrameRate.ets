
/*
* FAQ:应用帧率如何监控，运行时如何获取应用的帧率、渲染帧的耗时
 */

// [Start MonitorFrameRate]
import { displaySync } from '@kit.ArkGraphics2D';

@Entry
@Component
struct Index {
  @State backDisplaySync: displaySync.DisplaySync = displaySync.create();
  private passframeInfo: Array<displaySync.IntervalInfo> = []
  @State fps: number = 0

  aboutToAppear(): void {
    let callback = (frameInfo: displaySync.IntervalInfo) => {
      this.passframeInfo.push(frameInfo);
      if (this.passframeInfo.length >= 2) {
        let tmp = this.passframeInfo[1].timestamp - this.passframeInfo[0].timestamp;
        let result = 1000000000 / Number.parseInt(tmp.toString());
        this.fps = result;
        this.passframeInfo.shift();
      }
    };
    // Register subscription function
    this.backDisplaySync?.on("frame", callback);
  }

  build() {
    Column() {
      Row() {
        Text('Start')
          .fontSize(50)
          .onClick(() => [
            this.backDisplaySync?.start()
          ])
      }

      Row() {
        Text(this.fps.toString())
          .fontSize(50)
      }

      Row() {
        Text('End')
          .fontSize(50)
          .onClick(() => [
            this.backDisplaySync?.stop()
          ])
      }
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
  }
}
// [End MonitorFrameRate]