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
import { window } from "@kit.ArkUI";
import { hilog } from "@kit.PerformanceAnalysisKit";

export default class Constants {
  /**
   * Routes
   */
  static readonly ROUTES: Route[] = [
    {
      text: 'A+B+C', to: 'application/MailBox'
    },
    {
      text: 'A+C', to: 'application/PhotoAlbum'
    },
    {
      text: 'B+C', to: 'application/Settings'
    }
  ];
}

/**
 * Route type define
 */
export interface Route {
  text: string,
  to: string
}

export function getTop(avoidArea: window.AvoidAreaOptions | undefined): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.topRect.height) {
      avoidArea.area.topRect.top + avoidArea.area.topRect.height > 0 ?
        avoidArea.area.topRect.top + avoidArea.area.topRect.height : 0;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get TopSafeAreaPixel, avoidArea visible false');
  }
  return result;
}

export function getBottom(avoidArea: window.AvoidAreaOptions | undefined, windowHeight: number): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.bottomRect.height) {
      result = windowHeight - avoidArea.area.bottomRect.top > 0 ? windowHeight - avoidArea.area.bottomRect.top : 0;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get BottomSafeAreaPixel, avoidArea visible false');
  }
  return result;
}

export function getLeft(avoidArea: window.AvoidAreaOptions | undefined): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.leftRect.width) {
      result = avoidArea.area.leftRect.left + avoidArea.area.leftRect.width > 0 ?
        avoidArea.area.leftRect.left + avoidArea.area.leftRect.width : 0;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get LeftSafeAreaPixel, avoidArea visible false');
  }
  return result;
}

export function getRight(avoidArea: window.AvoidAreaOptions | undefined, windowWidth: number): number {
  let result: number = 0;
  if (avoidArea !== undefined) {
    if (avoidArea.area.rightRect.width) {
      result = windowWidth - avoidArea.area.rightRect.left > 0 ? windowWidth - avoidArea.area.rightRect.left :
        avoidArea.area.rightRect.width * 1.5;
    }
  } else {
    hilog.error(0x0000, '3D', 'Can not get RightSafeAreaPixel, avoidArea visible false');
  }
  return result;
}