/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

// [Start Step1]
import { ComponentContent, promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

export enum PopViewShowType {
  OPEN
}

interface PopViewModel {
  com: ComponentContent<object>;
  popType: PopViewShowType;
}

export class PopViewUtils {
  private static popShare: PopViewUtils;
  private infoList: PopViewModel[] = new Array<PopViewModel>();

  static shareInstance(): PopViewUtils {
    if (!PopViewUtils.popShare) {
      PopViewUtils.popShare = new PopViewUtils();
    }
    return PopViewUtils.popShare;
  }

  // [Start show_dialog]
  static showDialog<T extends object>(type: PopViewShowType, contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions):void {
    let uiContext = AppStorage.get<UIContext>('uiContext');
    if (uiContext) {
      // The promptAction object was obtained.
      let prompt = uiContext.getPromptAction();
      let componentContent = new ComponentContent(uiContext, contentView, args);
      let customOptions: promptAction.BaseDialogOptions = {
        alignment: options?.alignment || DialogAlignment.Bottom
      };
      // Open pop-ups using openCustomDialog
      prompt.openCustomDialog(componentContent, customOptions).catch((err: BusinessError) => {
        hilog.error(0x0000, 'PopViewUtils', `openCustomDialog failed. code=${err.code}, message=${err.message}`);
      });
      let infoList = PopViewUtils.shareInstance().infoList;
      let info: PopViewModel = {
        com: componentContent,
        popType: type
      };
      infoList[0] = info;
    }
  }

  // [StartExclude Step1]
  // [End show_dialog]
  // [Start close_dialog]
  static closeDialog(type: PopViewShowType): void {
    let uiContext = AppStorage.get<UIContext>('uiContext');
    if (uiContext) {
      // The promptAction object was obtained.
      let prompt = uiContext.getPromptAction();
      let sameTypeList = PopViewUtils.shareInstance().infoList.filter((model) => {
        return model.popType === type;
      })
      let info = sameTypeList[sameTypeList.length - 1];
      if (info && info.com) {
        PopViewUtils.shareInstance().infoList = PopViewUtils.shareInstance().infoList.filter((model) => {
          return model.com !== info.com;
        })
        // Close pop-ups using closeCustomDialog.
        prompt.closeCustomDialog(info.com).catch((err: BusinessError) => {
          hilog.error(0x0000, 'PopViewUtils', `closeCustomDialog failed. code=${err.code}, message=${err.message}`);
        });
      }
    }
  }

  // [End close_dialog]
  // [Start show_pop_view]
  static showPopView<T extends object>(contentView: WrappedBuilder<[T]>, args: T,
    options?: promptAction.BaseDialogOptions):void {
    PopViewUtils.showDialog(PopViewShowType.OPEN, contentView, args, options);
  }

  static closePopView():void {
    PopViewUtils.closeDialog(PopViewShowType.OPEN);
  }

  // [End show_pop_view]
  // [EndExclude Step1]
}

// [End Step1]