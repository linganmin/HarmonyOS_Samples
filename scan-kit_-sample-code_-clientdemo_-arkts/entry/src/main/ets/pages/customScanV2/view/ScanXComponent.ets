import Logger from '../../../common/Logger';
import { XComponentService } from '../model/XComponentService';

const TAG = 'ScanXComponentV2';

@ComponentV2
export struct ScanXComponent {
  @Local xComponentService: XComponentService = XComponentService.getInstance();
  private mXComponentController: XComponentController = new XComponentController();
  @Event public startCustomScan: () => void = () => {
  };

  build() {
    XComponent({
      id: 'componentId',
      type: XComponentType.SURFACE,
      controller: this.mXComponentController
    })
      .onLoad(async () => {
        this.xComponentService.surfaceId = this.mXComponentController.getXComponentSurfaceId();
        Logger.info(TAG,
          `Succeeded in loading XComponent, getXComponentSurfaceId: ${this.xComponentService.surfaceId}.`);
        this.startCustomScan();
      })
      .onDestroy(() => {
        this.xComponentService.surfaceId = '';
        Logger.info(TAG, 'Succeeded in destroying XComponent.');
      })
      .height(this.xComponentService.height)
      .width(this.xComponentService.width)
      .position({ x: this.xComponentService.offsetX, y: this.xComponentService.offsetY })
      .clip(true)
  }
}