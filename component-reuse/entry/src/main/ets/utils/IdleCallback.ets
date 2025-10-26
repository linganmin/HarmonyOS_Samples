/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { FrameCallback } from "@kit.ArkUI";
import { ItemData } from "../model/ItemData";
import { systemDateTime } from "@kit.BasicServicesKit";
import { hiTraceMeter } from "@kit.PerformanceAnalysisKit";
import { NodePool } from "./BuilderNodePool";
import { listItemWrapper } from "../view/TabContentView";

// [Start prebuild2]
export class IdleCallback extends FrameCallback {
  private uiContext: UIContext;
  // Pre build component index, start from 0
  private todoCount: number = 0;
  private dataArray: ItemData[] = [];

  constructor(context: UIContext, preBuildData: ItemData[]) {
    super();
    this.uiContext = context;
    this.dataArray = preBuildData;
  }

  onIdle(idleTimeInNano: number): void {
    if (this.todoCount >= this.dataArray.length) {
      // All pre build completed
      return;
    }
    let cur: number = systemDateTime.getTime(true);
    let timeLeft = idleTimeInNano;
    // if the build time for a single component is 1000000 ns
    while (timeLeft >= 1000000) {
      hiTraceMeter.startTrace('onIdle_prebuild', 1);
      // prebuild the component
      NodePool.getInstance().preBuild('reuse_type_', this.dataArray[this.todoCount], listItemWrapper, this.uiContext);
      hiTraceMeter.finishTrace('onIdle_prebuild', 1);
      // update the idle time
      let now = systemDateTime.getTime(true);
      timeLeft = timeLeft - (now - cur);
      cur = now;
      this.todoCount++;
      if (this.todoCount >= this.dataArray.length) {
        // All pre build completed
        return;
      }
      if (this.todoCount < this.dataArray.length) {
        // Pre build not completed, proceed to the next frame
        this.uiContext.postFrameCallback(this);
      }
    }
  }
}
// [End prebuild2]