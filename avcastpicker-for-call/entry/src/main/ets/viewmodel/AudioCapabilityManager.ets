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

import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { avSession } from '@kit.AVSessionKit';
import { resourceManager } from '@kit.LocalizationKit';
import { emitter, BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Logger from '../common/utils/Logger';
import { Constants } from '../common/constants/Constants';

const TAG: string = Constants.AUDIO_CAPABILITY_TAG;

class Options {
  public offset: number = 0;
  public length: number = 0;
}

export default class AudioCapabilityManager {
  public deviceDesc: audio.AudioDeviceDescriptors | undefined = undefined;
  private session: avSession.AVSession | undefined = undefined;
  private audioRenderer: audio.AudioRenderer | undefined = undefined;
  private audioManager: audio.AudioManager | undefined = undefined;
  private audioRoutingManager: audio.AudioRoutingManager | undefined = undefined;
  private audioSource: string = Constants.ANALOG_CALL_AUDIO;
  private audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION,
    rendererFlags: 0
  };
  private audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
    channels: audio.AudioChannel.CHANNEL_2,
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
  };
  private audioRendererOption: audio.AudioRendererOptions = {
    streamInfo: this.audioStreamInfo,
    rendererInfo: this.audioRendererInfo
  };
  private appContext: UIContext;
  private file: resourceManager.RawFileDescriptor;
  private bufferSize: number;
  private writeDataCallback = (buffer: ArrayBuffer) => {
    let curLength = buffer.byteLength;
    if (this.bufferSize >= this.file.length + this.file.offset) {
      this.bufferSize = this.file.offset;
    } else if (this.bufferSize + buffer.byteLength > this.file.length + this.file.offset) {
      curLength = this.file.length + this.file.offset - this.bufferSize;
    }
    let options: Options = {
      offset: this.bufferSize,
      length: curLength
    };
    fileIo.readSync(this.file.fd, buffer, options);
    this.bufferSize += buffer.byteLength;
  };

  constructor() {
    this.appContext = AppStorage.get("context") as UIContext;
    this.file = this.appContext.getHostContext()!.resourceManager.getRawFdSync(this.audioSource);
    this.bufferSize = this.file.offset;
  }

  async init() {
    try {
      if (!this.appContext) {
        this.appContext = AppStorage.get("context") as UIContext;
      }
      this.session = await avSession.createAVSession(this.appContext.getHostContext()!, 'VOIP', 'voice_call');
      await this.observerDevices();
      await this.initRenderer();
    } catch (error) {
      hilog.error(0x0000, TAG, `init catch error, code: ${error.code}, message: ${error.message}`);
      return;
    }
  }

  //observer the audio playback devices
  async observerDevices() {
    try {
      this.audioManager = audio.getAudioManager();
      if (!this.audioManager) {
        Logger.error(TAG, 'get audioManager failed');
        return;
      }
      this.audioRoutingManager = this.audioManager.getRoutingManager();

      this.deviceDesc = this.audioRoutingManager.getPreferredOutputDeviceForRendererInfoSync(this.audioRendererInfo);
      this.audioRoutingManager.on('preferOutputDeviceChangeForRendererInfo', this.audioRendererInfo, () => {
        if (!this.audioRoutingManager) {
          return;
        }
        this.deviceDesc = this.audioRoutingManager.getPreferredOutputDeviceForRendererInfoSync(this.audioRendererInfo);
        let innerEventRefreshing: emitter.InnerEvent = {
          eventId: 1,
          priority: emitter.EventPriority.HIGH
        };
        emitter.emit(innerEventRefreshing);
        if (this.deviceDesc) {
          Logger.info(TAG, `device change to: ${this.deviceDesc[0].deviceType}`);
        } else {
          Logger.info(TAG, `device change state undefine`);
        }
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `observerDevices catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  async cancelObserverDevices() {
    try {
      if (!this.audioRoutingManager) {
        this.audioRoutingManager = audio.getAudioManager().getRoutingManager();
      }
      this.audioRoutingManager.off('preferOutputDeviceChangeForRendererInfo');
    } catch (error) {
      hilog.error(0x0000, TAG, `cancelObserverDevices catch error, code: ${error.code}, message: ${error.message}`);
      return;
    }
  }

  //Initialize audioRenderer
  async initRenderer() {
    if (this.audioRenderer !== undefined) {
      return;
    }
    audio.createAudioRenderer(this.audioRendererOption, (err, renderer) => {
      if (err) {
        Logger.error(TAG, `audioRenderer create : Error: ${JSON.stringify(err)}`);
        return;
      }
      this.audioRenderer = renderer;
      if (this.audioRenderer !== undefined) {
        this.audioRenderer.on('writeData', this.writeDataCallback);
      }
    });
  }

  //start the AudioRenderer
  async startRenderer() {
    if (!this.audioRenderer) {
      return;
    }
    await this.audioRenderer.start();
  }

  //stop the AudioRenderer
  async stopRenderer() {
    if (!this.audioRenderer) {
      return;
    }
    await this.audioRenderer.stop();
  }

  //release the AudioRenderer
  async releaseRenderer(): Promise<void> {
    if (this.audioRenderer) {
      await this.audioRenderer.release();
      this.closeResource(this.audioSource);
      this.audioRenderer = undefined;
    }
  }

  //release resource
  async closeResource(fileName: string): Promise<void> {
    if (this.appContext) {
      let mgr = this.appContext.getHostContext()!.resourceManager;
      await mgr.closeRawFd(fileName).then(() => {
        Logger.info(TAG, 'case closeRawFd success fileName: ' + fileName);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'case closeRawFd err: ' + error);
      });
    }
  }

  //destroy the AVSession
  async destroySession() {
    try {
      if (this.session) {
        await this.session?.destroy();
      }
    } catch (error) {
      Logger.error(TAG, 'case closeRawFd err: ' + error);
    }
  }
}