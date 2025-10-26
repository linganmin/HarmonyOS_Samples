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
import { window } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image2PixelMap } from './ImageUtils';
import { BusinessError } from '@kit.BasicServicesKit';

// [Start fill_triangle]
function fillTriangle(array: number[][], base: number, height: number): void {
  // i < height-10 in order to remove the round corner
  for (let i = 0; i < height - 10; i++) {
    for (let j = 0; j < base; j++) {
      if (j >= base / 2 - base / 2 * i / height && j <= base / 2 + base / 2 * i / height) {
        array[i][j] = 1;
      }
    }
  }
}

async function getTriangleMask(width: number, height: number): Promise<number[][]> {
  const maskArray: number[][] = new Array(height).fill(null).map(() => new Array(width).fill(0));
  fillTriangle(maskArray, width, height);
  return maskArray;
}
// [End fill_triangle]

// [Start fill_circle]
function fillCircle(array: number[][], x: number, y: number, radius: number): void {
  for (let i = x - radius; i <= x + radius; i++) {
    for (let j = y - radius; j <= y + radius; j++) {
      const distSquared = (i - x)**2 + (j - y)**2;
      if (distSquared <= radius**2 && i >= 0 && j >= 0 && i < array.length && j < array[0].length) {
        array[i][j] = 1;
      }
    }
  }
}

async function getCircleMask(width: number, height: number): Promise<number[][]> {
  const radius = Math.min(width, height) / 2;
  const maskArray: number[][] = new Array(height).fill(null).map(() => new Array(width).fill(0));
  fillCircle(maskArray, height / 2, width / 2, radius);
  return maskArray;
}
// [End fill_circle]

// [Start get_pic_mask]
export async function getPicMask(Context: Context,width: number, height: number, picPath: string): Promise<number[][]> {
  const maskArray: number[][] = new Array(height).fill(null).map(() => new Array(width).fill(0));
  const pixelMap: image.PixelMap = await image2PixelMap(Context, picPath, width, height);
  const pixelArrayBuffer: ArrayBuffer = new ArrayBuffer(width * height * 4);
  await pixelMap.readPixelsToBuffer(pixelArrayBuffer);
  const allPixels: number[] = [];
  const unit8Pixels: Uint8Array = new Uint8Array(pixelArrayBuffer);
  for (let i = 0, j = 0; i < unit8Pixels.length; i += 4, j++) {
    // unit8Pixels[i+3] is alpha channel of BGRA_8888
    allPixels[j] = unit8Pixels[i + 3] > 0 ? 1 : 0;
  }
  pixelMap.release()
  let k = 0;
  for (let i = 0; i < width; i++) {
    for (let j = 0; j < height; j++) {
      maskArray[i][j] = allPixels[k++];
    }
  }
  return maskArray;
}
// [End get_pic_mask]

// [Start set_window_shape]
// [Start set_window_pic_shape]
async function setWindowShape(win: window.Window, width: number,
  height: number, getMaskFunc: (w: number, h: number, picPath?: string) => Promise<number[][]>,
  picPath?: string): Promise<void> {
  const windowMask = await getMaskFunc(width, height, picPath);
  if (canIUse('SystemCapability.Window.SessionManager')) {
    try {
      win.setWindowMask(windowMask);
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(0x0000, 'Simple', `failed code=${err.code}, message=${err.message}`);
    }
  } else {
    hilog.info(0x0000, 'Simple', 'can not use SessionManager syscap');
  }
}
// [End set_window_pic_shape]

/**
 * Set the window with circle shape
 * @param win The target window
 * @param width The original window width
 * @param height The original window height
 */
export async function setWindowCircleShape(win: window.Window, width: number,
  height: number): Promise<void> {
  setWindowShape(win, width, height, getCircleMask)
}

/**
 * Set the window with triangle shape
 * @param win The target window
 * @param width The original window width
 * @param height The original window height
 */
export async function setWindowTriangleShape(win: window.Window, width: number,
  height: number): Promise<void> {
  setWindowShape(win, width, height, getTriangleMask)
}
// [End set_window_shape]

// [Start set_window_pic_shape]
/**
 * Set the window with pic shape
 * @param win The target window
 * @param width The original window width
 * @param height The original window height
 * @param picPath The pic path in rawfile
 */
export async function setWindowPicShape(win: window.Window, Context: Context, width: number,
  height: number, picPath: string): Promise<void> {
  setWindowShape(win, width, height, (w, h, picPath) => {
    return getPicMask(Context,w, h, picPath!)
  }, picPath)
}
// [End set_window_pic_shape]
