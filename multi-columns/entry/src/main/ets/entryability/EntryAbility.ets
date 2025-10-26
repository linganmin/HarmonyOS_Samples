/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { UIAbility, AbilityConstant, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UIContext, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

// [Start screen_rotation]
export default class EntryAbility extends UIAbility {
  private windowObj?: window.Window;
  private uiContext?: UIContext;
  // [StartExclude screen_rotation]
  private onWindowSizeChange: (windowSize: window.Size) => void = (windowSize: window.Size) => {
    let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
    let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();

    AppStorage.setOrCreate('currentWidthBreakpoint',
      widthBp === 0 ? 'xs' : widthBp === 1 ? 'sm' : widthBp === 2 ? 'md' : widthBp === 3 ? 'lg' : 'xl');
    AppStorage.setOrCreate('currentHeightBreakpoint',
      heightBp === 0 ? 'sm' : heightBp === 1 ? 'md' : heightBp === 2 ? 'md' : 'lg');

    // Application adaptation for horizontal and vertical screen switching.
    this.windowObj?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((err: BusinessError) => {
      hilog.error(0x00, 'testTag', `setPreferredOrientation failed, code = ${err.code}, message = ${err.message}`);
    });
  };
  public onAvoidAreaChange: (avoidArea: window.AvoidAreaOptions) => void = (avoidArea: window.AvoidAreaOptions) => {
    if (avoidArea.type === window.AvoidAreaType.TYPE_CUTOUT) {
      AppStorage.setOrCreate('cutout', avoidArea);
    }
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  // [EndExclude screen_rotation]
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // [StartExclude screen_rotation]
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.getMainWindow().then((windowObj) => {
      this.windowObj = windowObj;
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', 'Failed to obtain the main window. Cause: %{public}s', JSON.stringify(err) ?? '');
    });
    // [EndExclude screen_rotation]
    windowStage.loadContent('pages/Index', (err, data) => {
      // [StartExclude screen_rotation]
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');

      // Immersive Adaptation
      this.immersionFuc(windowStage);

      try {
        let uiContext: UIContext | undefined = windowStage.getMainWindowSync().getUIContext();
        AppStorage.setOrCreate('uiContext', uiContext);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'testTag', `getUIContext failed, code = ${err.code}, message = ${err.message}`);
      }

      // [EndExclude screen_rotation]
      try {
        this.uiContext = this.windowObj!.getUIContext();
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x00, 'testTag', `getUIContext failed, code = ${err.code}, message = ${err.message}`);
      }
      // Application adaptation for horizontal and vertical screen switching.
      this.windowObj?.setPreferredOrientation(window.Orientation.AUTO_ROTATION_RESTRICTED).catch((err: BusinessError) => {
        hilog.error(0x00, 'testTag', `setPreferredOrientation failed, code = ${err.code}, message = ${err.message}`);
      });
      // [StartExclude screen_rotation]
      // The system interface depends on UIContext and needs to be invoked after the page is loaded. It needs to be written in the loadContent callback function.
      windowStage.getMainWindow().then((data: window.Window) => {
        let widthBp: WidthBreakpoint = this.uiContext!.getWindowWidthBreakpoint();
        let heightBp: HeightBreakpoint = this.uiContext!.getWindowHeightBreakpoint();
        AppStorage.setOrCreate('currentWidthBreakpoint',
          widthBp === 0 ? 'xs' : widthBp === 1 ? 'sm' : widthBp === 2 ? 'md' : widthBp === 3 ? 'lg' : 'xl');
        AppStorage.setOrCreate('currentHeightBreakpoint',
          heightBp === 0 ? 'sm' : heightBp === 1 ? 'md' : heightBp === 2 ? 'md' : 'lg');
        data.on('windowSizeChange', this.onWindowSizeChange);

        // Monitor changes in the location of the cutout area.
        try {
          let avoidArea: window.AvoidArea = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_CUTOUT);
          this.onAvoidAreaChange({ type: window.AvoidAreaType.TYPE_CUTOUT, area: avoidArea });
          data.on('avoidAreaChange', this.onAvoidAreaChange);
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x00, 'testTag', `getWindowAvoidArea failed, code = ${err.code}, message = ${err.message}`);
        }


        // Window size acquisition and monitoring.
        try {
          let properties = data.getWindowProperties();
          AppStorage.setOrCreate('windowHeight', properties.windowRect.height);
          AppStorage.setOrCreate('windowWidth', properties.windowRect.width);
        } catch (error) {
          let err = error as BusinessError;
          hilog.error(0x00, 'testTag', `getWindowProperties failed, code = ${err.code}, message = ${err.message}`);
        }

      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', '%{public}s',
          `Failed to obtain the main window. Cause code: ${err.code}, message: ${err.message}`);
      });
      // [EndExclude screen_rotation]
    });
  }

  // [StartExclude screen_rotation]
  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  /**
   * Page immersion.
   */
  immersionFuc(windowStage: window.WindowStage): void {
    try {
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.setWindowLayoutFullScreen(true).catch((err: BusinessError) => {
        hilog.error(0x00, 'testTag', `setWindowLayoutFullScreen failed, code = ${err.code}, message = ${err.message}`);
      });
      let navigationBarArea: window.AvoidArea =
        windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      AppStorage.setOrCreate<number>('naviIndicatorHeight',
        windowClass.getUIContext().px2vp(navigationBarArea.bottomRect.height));
      AppStorage.setOrCreate<number>('statusBarHeight', windowClass.getUIContext().px2vp(area.topRect.height));
      AppStorage.setOrCreate<window.Window>('windowClass', windowClass);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'testTag', `getMainWindowSync failed, code = ${err.code}, message = ${err.message}`);
    }

  }

  // [EndExclude screen_rotation]
}

// [End screen_rotation]