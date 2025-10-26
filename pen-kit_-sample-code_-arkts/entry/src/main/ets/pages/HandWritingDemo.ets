import { HandwriteController,HandwriteComponent, PenHspInfo, PenType } from '@kit.Penkit';

@Entry
@Component
struct HandWritingComponent {
  controller: HandwriteController = new HandwriteController();
  // Obtain the path for storing handwritten files based on the application storage rules. The following is for reference only.
  initPath: string = this.getUIContext().getHostContext()?.filesDir + '/aa';
  penWidth: number = 5;
  ballpointPenWidth: number = 6;

  aboutToAppear() {
    // Set the callback after the save operation is complete during loading.
    this.controller.onLoad(this.callback);
  }

  // Callback after the handwritten file content is loaded and rendered on the screen. It notifies the access user. You can customize the behavior here.
  callback = () => {
    // User-defined behavior, for example, displaying a user operation guide after a file is loaded
  }

  aboutToDisappear() {
  }

  build() {
    Row() {
      Stack({ alignContent: Alignment.TopStart }) {
        HandwriteComponent({
          handwriteController: this.controller,
          defaultPenType: PenType.PENCIL,
          defaultPenInfo: [{ penType: PenType.PEN, penWidth: this.penWidth },
            { penType: PenType.BALLPOINT_PEN, penWidth: this.ballpointPenWidth }] as PenHspInfo[],
          widthRatio: 1,
          heightRatio: 1,
          onInit: () => {
            // Callback when canvas initialization is complete. In this case, you can call the interface to load and display the note content.
            this.controller?.load(this.initPath);
          },
          onScale: (scale: number) => {
            // Callback method for scaling the canvas. The scaling ratio of the current handwriting control is returned. You can customize the behavior here.
          }
        })
        Button("save")
          .onClick(async () => {
            // Obtain the path for storing handwritten files based on the application storage rules. The following is for reference only.
            const path = this.getUIContext().getHostContext()?.filesDir + '/aa';
            await this.controller?.save(path).then().catch((error: Error) => {
              console.info("err：" + error);
            })
            this.controller.getThumbnail(this.controller?.getContentRange())?.then((pixelMap: PixelMap) => {
              if (pixelMap) {
                pixelMap.release()
                console.info('getThumbnail success')
              }
            })
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}