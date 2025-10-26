/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';

export class PixelDataManager {
  private static instance: PixelDataManager;
  private initialPixelBuffer?: ArrayBuffer;

  private constructor() {
  }

  public static getInstance(): PixelDataManager {
    if (!PixelDataManager.instance) {
      PixelDataManager.instance = new PixelDataManager();
    }
    return PixelDataManager.instance;
  }

  public saveInitialPixelBuffer(pixelMap: image.PixelMap): void {
    this.initialPixelBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
    pixelMap.readPixelsToBuffer(this.initialPixelBuffer);
  }

  public getInitialPixelBufferCopy(): ArrayBuffer | undefined {
    return this.initialPixelBuffer?.slice(0);
  }

  public hasInitialPixelBuffer(): boolean {
    return !!this.initialPixelBuffer;
  }

  public clearInitialPixelBuffer(): void {
    this.initialPixelBuffer = undefined;
  }
}

