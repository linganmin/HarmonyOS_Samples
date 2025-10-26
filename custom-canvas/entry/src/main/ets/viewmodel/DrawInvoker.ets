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

import { List } from '@kit.ArkTS';
import DrawPath from './IDraw';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class DrawInvoker {
  // Draw list.
  private drawPathList: List<DrawPath> = new List<DrawPath>();
  // Redo list.
  private redoList: Array<DrawPath> = new Array<DrawPath>();

  add(command: DrawPath): void {
    try {
      this.drawPathList.add(command);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'DrawInvoker', `list add failed. code=${err.code}, message=${err.message}`);
    }
    this.redoList = [];
  }

  clear(): void {
    if (this.drawPathList.length > 0 || this.redoList.length > 0) {
      try {
        this.drawPathList.clear();
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'DrawInvoker', `list clear failed. code=${err.code}, message=${err.message}`);
      }
      this.redoList = [];
    }
  }

  undo(): void {
    if (this.drawPathList.length > 0) {
      try {
        let undo: DrawPath = this.drawPathList.get(this.drawPathList.length - 1);
        this.drawPathList.removeByIndex(this.drawPathList.length - 1);
        this.redoList.push(undo)
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'DrawInvoker', `undo failed. code=${err.code}, message=${err.message}`);
      }
    }
  }

  redo(): void {
    if (this.redoList.length > 0) {
      let redoCommand = this.redoList[this.redoList.length - 1];
      this.redoList.pop();
      try {
        this.drawPathList.add(redoCommand);
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'DrawInvoker', `list add failed. code=${err.code}, message=${err.message}`);
      }
    }
  }

  execute(context: CanvasRenderingContext2D): void {
    if (this.drawPathList !== null) {
      try {
        this.drawPathList.forEach((element: DrawPath) => {
          element.draw(context);
        });
      } catch (error) {
        let err = error as BusinessError;
        hilog.error(0x0000, 'DrawInvoker', `execute failed. code=${err.code}, message=${err.message}`);
      }
    }
  }

  canRedo(): boolean {
    return this.redoList.length > 0;
  }

  canUndo(): boolean {
    return this.drawPathList.length > 0;
  }
}