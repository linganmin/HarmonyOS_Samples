import { window } from '@kit.ArkUI';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { CommonConstants } from '../constants/CommonConstants';
import { ScanLayout } from './ScanLayout';
import { XComponentService } from './XComponentService';
import Logger from '../../../common/Logger';
import { DeviceService } from './DeviceService';
import { UIContextSelf } from './UIContextSelf';

const TAG: string = 'WindowService';
const WINDOW_SIZE_MOCK: window.Size = {
  width: 1080,
  height: 1920
};

@Observed
export class WindowService {
  public windowObj?: window.Window;
  private static instance?: WindowService;
  public topAvoidHeight: number = 0;
  public windowSizePX: window.Size = {
    width: 0,
    height: 0
  }; // Pixel density x Window width/height (vp) = Window width/height (px)
  public width: number = 0; // Window width, in vp.
  public height: number = 0; // Window height, in vp.
  public isCustomScanPage: boolean = false;

  static getInstance(): WindowService {
    WindowService.instance ||= new WindowService();
    return WindowService.instance;
  }

  // Open the custom barcode scanning page.
  enterCustomScanPage(): void {
    this.isCustomScanPage = true;
    DeviceService.refreshDisplayInfoAndSelectSuitableRatio();
    this.refreshLayoutByDensityPixels(DeviceService.densityPixels);
    Logger.info(TAG, `enter CustomScanPage. isCustomScanPage: ${this.isCustomScanPage}`);
  }

  // Leave the custom barcode scanning page.
  leaveCustomScanPage(): void {
    this.isCustomScanPage = false;
    Logger.info(TAG, `leave CustomScanPage. isCustomScanPage: ${this.isCustomScanPage}`);
  }

  refreshLayoutByDensityPixels(densityPixels: number): void {
    if (densityPixels > 0) {
      this.width = this.windowSizePX.width / densityPixels;
      this.height = this.windowSizePX.height / densityPixels;
      ScanLayout.getInstance().refreshLayout(this.width, this.height);
      XComponentService.getInstance().setScanXComponentSize();
      Logger.info(TAG, `refreshLayoutByDensityPixels, width: ${this.width}, height: ${this.height}.`);
    }
  }

  initWindowObj(window: window.Window): void {
    this.windowObj = window;
    this.setTopAvoidHeight();
    this.setWindowSize();
    this.onAvoidAreaChange();
    this.onWindowSizeChange();
    this.setWindowLayoutFullScreen();
  }

  public onWindowSizeChange(): void {
    if (this.windowObj) {
      try {
        this.windowObj.on('windowSizeChange', (window: window.Size) => {
          Logger.info(TAG, 'windowSizeChange triggered.');
          this.emitWindowSize(window);
        })
        Logger.info(TAG, 'Succeeded in on windowSizeChange by windowObj');
      } catch (error) {
        Logger.error(TAG, `Failed to on windowSizeChange by windowObj. Code: ${error?.code}`);
      }
    }
  }

  public onAvoidAreaChange(): void {
    if (this.windowObj) {
      try {
        this.windowObj.on('avoidAreaChange', (data) => {
          let topAvoidHeight: number = UIContextSelf.uiContext.px2vp(data.area.topRect.height + data.area.topRect.top);
          if (data.type === window.AvoidAreaType.TYPE_SYSTEM && topAvoidHeight !== this.topAvoidHeight) {
            Logger.info(TAG, `topAvoidHeight has changed, topAvoidHeight: ${topAvoidHeight}`);
            this.topAvoidHeight = topAvoidHeight;
            if (this.isCustomScanPage) {
              ScanLayout.getInstance().setTopLayout();
            }
          }
        });
        Logger.info(TAG, 'Succeeded in on avoidAreaChange by windowObj');
      } catch (error) {
        Logger.error(TAG, `Failed to on avoidAreaChange by windowObj. Code: ${error?.code}`);
      }
    }
  }

  public offAvoidAreaChange(): void {
    if (this.windowObj) {
      try {
        this.windowObj.off('avoidAreaChange');
        Logger.info(TAG, 'Succeeded in off avoidAreaChange by windowObj');
      } catch (error) {
        Logger.error(TAG, `Failed to off avoidAreaChange by windowObj. Code: ${error?.code}`);
      }
    }
  }

  public offWindowSizeChange(): void {
    if (this.windowObj) {
      try {
        this.windowObj.off('windowSizeChange');
        Logger.info(TAG, 'Succeeded in off windowSizeChange by windowObj');
      } catch (error) {
        Logger.error(TAG, `Failed to off windowSizeChange by windowObj. Code: ${error?.code}`);
      }
    }
  }

  public setTopAvoidHeight(): void {
    if (this.windowObj) {
      try {
        let avoidArea: window.AvoidArea = this.windowObj.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
        this.topAvoidHeight = UIContextSelf.uiContext.px2vp(avoidArea.topRect.height + avoidArea.topRect.top);
        Logger.info(TAG,
          `Succeeded in getting topAvoidHeight by windowObj. topAvoidHeight: ${this.topAvoidHeight}`);
      } catch (error) {
        // If the value fails to be obtained, use the default value of the top avoid area height.
        this.topAvoidHeight = CommonConstants.TOP_AVOID_HEIGHT_DEFAULT;
        Logger.error(TAG, `Failed to getWindowAvoidArea by windowObj. Code: ${error?.code}`);
      }
    }
  }

  public setWindowSize(): void {
    if (this.windowObj) {
      try {
        let windowRect: window.Rect = this.windowObj.getWindowProperties().windowRect;
        Logger.info(TAG,
          `Succeeded in getting windowRect by windowObj. width: ${windowRect.width}, height: ${windowRect.height}`);
        this.emitWindowSize({
          width: windowRect.width,
          height: windowRect.height
        })
      } catch (error) {
        Logger.error(TAG, `Failed to windowRect by windowObj and set the default windowSize. Code: ${error?.code}`);
        this.emitWindowSize(WINDOW_SIZE_MOCK)
      }
    }
  }

  public emitWindowSize(window: window.Size): void {
    if (window && (window.width !== this.windowSizePX.width || window.height !== this.windowSizePX.height)) {
      // Update the window width and height.
      this.windowSizePX = window;
      this.width = UIContextSelf.uiContext.px2vp(window.width);
      this.height = UIContextSelf.uiContext.px2vp(window.height);
      ScanLayout.getInstance().refreshBreakpoint(this.width, this.height);
      if (window.height > 0 && window.width > 0 && this.isCustomScanPage) {
        ScanLayout.getInstance().refreshScanLayout(this.width, this.height);
        XComponentService.getInstance().setScanXComponentSize();
        // Send a notification if the dimensions change.
        let eventData: emitter.EventData = {
          data: {
            width: this.width,
            height: this.height
          }
        };
        Logger.info(TAG, `emitWindowSize, width: ${this.width}, height: ${this.height}`);
        emitter.emit({ eventId: CommonConstants.WINDOW_SIZE_CHANGE }, eventData);
      }
    }
  }

  public setWindowLayoutFullScreen(): void {
    if (this.windowObj) {
      try {
        this.windowObj.setWindowLayoutFullScreen(true).then(() => {
          Logger.info(TAG, `setWindowLayoutFullScreen end`);
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `Failed to setWindowLayoutFullScreen. Code: ${error.code}`);
        })
      } catch (error) {
        Logger.error(TAG, `Failed to setWindowLayoutFullScreen. Code: ${error?.code}`);
      }
    }
  }
}