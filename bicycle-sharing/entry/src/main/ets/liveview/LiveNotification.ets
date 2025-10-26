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

import { liveViewManager } from '@kit.LiveViewKit';
import { LiveViewContext } from './LiveViewContext';
import { LiveViewEnvironment } from './LiveViewEnvironment';

type LiveViewData = liveViewManager.LiveViewData;
type LiveView = liveViewManager.LiveView;

export class LiveNotification {
  public context: LiveViewContext;
  public env: LiveViewEnvironment;

  constructor(context: LiveViewContext, env: LiveViewEnvironment) {
    this.context = context;
    this.env = env;
  }

  public static rebuild(context: LiveViewContext, liveView: LiveView): LiveNotification {
    const env: LiveViewEnvironment = {
      id: liveView.id,
      event: liveView.event
    };
    return new LiveNotification(context, env);
  }

  public static from(context: LiveViewContext, env: LiveViewEnvironment): LiveNotification {
    return new LiveNotification(context, env);
  }

  public async create(liveViewData: LiveViewData): Promise<liveViewManager.LiveViewResult> {
    if (!LiveNotification.isLiveViewEnabled()) {
      throw new Error('Live view is disabled.');
    }
    // create liveView
    const liveView: LiveView = {
      id: this.env.id,
      event: this.env.event,
      liveViewData,
    };
    return await liveViewManager.startLiveView(liveView);
  }

  public async update(liveViewData: LiveViewData): Promise<liveViewManager.LiveViewResult> {
    // check live Views disabled
    if (!LiveNotification.isLiveViewEnabled()) {
      throw new Error('Live view is disabled.');
    }
    const liveView: LiveView = {
      id: this.env.id,
      event: this.env.event,
      liveViewData,
    };
    return await liveViewManager.updateLiveView(liveView);
  }

  public async stop(liveViewData: LiveViewData): Promise<liveViewManager.LiveViewResult> {
    // check liveView is disabled
    if (!LiveNotification.isLiveViewEnabled()) {
      throw new Error('Live view is disabled.');
    }
    const liveView: LiveView = {
      id: this.env.id,
      event: this.env.event,
      liveViewData,
    };
    return await liveViewManager.stopLiveView(liveView);
  }

  private static async isLiveViewEnabled(): Promise<boolean> {
    return await liveViewManager.isLiveViewEnabled();
  }
}
