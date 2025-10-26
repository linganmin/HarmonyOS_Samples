/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { hilog } from '@kit.PerformanceAnalysisKit';
import { common2D } from '@kit.ArkGraphics2D';
import { FrameNode } from '@kit.ArkUI';
import CallbackManager from './CallBackManager';

@Component
export struct TrackNode {
  @BuilderParam closer: VoidCallback = this.defaultBuilder;
  track: Track | null = null;
  trackShadow: TrackShadow = new TrackShadow();

  @Builder
  defaultBuilder() {
  }

  build() {
    this.closer();
  }

  aboutToDisappear(): void {
    TrackManager.get().removeTrack(this.trackShadow.id);
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Track disappear: ${this.trackShadow.id}`);
  }

  // [Start on_did_build]
  // entry\src\main\ets\viewModel\TrackNode.ets
  // onDidBuild Life Cycle.
  onDidBuild(): void {
    // Construct the virtual tree of the tracing point.
    // The obtained node is the root node of the current page (row in the test case).
    let uid = this.getUniqueId();
    let node: FrameNode | null = this.getUIContext().getFrameNodeByUniqueId(uid);
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Track onDidBuild node:${node?.getNodeType()}`);
    if (node === null) {
      return;
    }
    this.trackShadow.node = node;
    this.trackShadow.id = node?.getId();
    this.trackShadow.track = this.track;
    TrackManager.get().addTrack(this.trackShadow.id, this.trackShadow);
    // The setOnVisibleAreaApproximateChange monitors and records the visible area of the tracing point component.
    node?.commonEvent.setOnVisibleAreaApproximateChange(
      { ratios: [0, 0.5, 1], expectedUpdateInterval: 500 },
      (ratioInc: boolean, ratio: number) => {
        const areaChangeCb = CallbackManager.getInstance().getAreaChangeCallback();
        areaChangeCb(node, ratio);
        this.trackShadow.visibleRatio = ratio;
        hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `ratioInc: ${ratioInc}`);
        hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `ratio: ${ratio}`);
      });

    let parent: FrameNode | null = node?.getParent();
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Parent getId: ${parent?.getId()}`);

    let attachTrackToParent: (parent: FrameNode | null) => boolean =
      (parent: FrameNode | null) => {
        while (parent !== null) {
          let parentTrack = TrackManager.get().getTrackById(parent?.getId());
          if (parentTrack !== undefined) {
            parentTrack.childIds.add(this.trackShadow.id);
            this.trackShadow.parentId = parentTrack.id;
            return true;
          }
          parent = parent.getParent();
        }
        return false;
      };
    let attached = attachTrackToParent(parent);

    if (!attached) {
      node?.commonEvent.setOnAppear(() => {
        let attached = attachTrackToParent(parent);
        if (attached) {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Track lazy attached: ${this.trackShadow.id}`);
        }
      });
    }
  }
  // [End on_did_build]
}

// [Start class_track]
// entry\src\main\ets\viewModel\TrackNode.ets
export class Track {
  public areaPercent: number = 0;
  public trackId: string = '';

  constructor() {
  }

  id(newId: string): Track {
    this.trackId = newId;
    return this;
  }
}

/**
 * Tracing point data.
 */
export class TrackShadow {
  public node: FrameNode | null = null;
  public id: string = '';
  public track: Track | null = null;
  public childIds: Set<string> = new Set();
  public parentId: string = '';
  public visibleRect: common2D.Rect = {
    left: 0,
    top: 0,
    right: 0,
    bottom: 0
  };
  public visibleRatio: number = 0;

  // Output the information about the tracing point tree through global dump.
  dump(depth: number = 0): void {
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Track Dp: ${depth}`);
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `AreaPer: ${this.track?.areaPercent}`);
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `VisibleRatio: ${this.visibleRatio}`);
    this.childIds.forEach((value: string) => {
      TrackManager.get().getTrackById(value)?.dump(depth + 1);
    });
  }
}
// [End class_track]

// [Start track_manager]
// entry\src\main\ets\viewModel\TrackNode.ets
/**
 * Tracing point data operation class
 */
export class TrackManager {
  static instance: TrackManager;
  private trackMap: Map<string, TrackShadow> = new Map();
  private rootTrack: TrackShadow | null = null;

  static get(): TrackManager {
    if (TrackManager.instance !== undefined) {
      return TrackManager.instance;
    }
    TrackManager.instance = new TrackManager();
    return TrackManager.instance;
  }

  addTrack(id: string, track: TrackShadow): void {
    if (this.trackMap.size === 0) {
      this.rootTrack = track;
    }
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Track add id: ${id}`);
    this.trackMap.set(id, track);
  }

  removeTrack(id: string): void {
    let current = this.getTrackById(id);
    if (current !== undefined) {
      this.trackMap.delete(id);
      let parent = this.getTrackById(current?.parentId);
      parent?.childIds.delete(id);
    }
  }

  getTrackById(id: string): TrackShadow | undefined {
    return this.trackMap.get(id);
  }

  dump(): void {
    this.rootTrack?.dump(0);
  }
}
// [End track_manager]