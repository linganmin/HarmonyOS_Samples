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

import { media } from '@kit.MediaKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import connection from '@ohos.net.connection';
import { customToast } from '../common/utils/CommonUtils';
import { AVPlayerConstants, CommonConstants, ViewConstants } from '../common/CommonConstants';
import Logger from '../common/utils/Logger';
import { CustomConfigs } from '../common/CustomConfigs';
import { VideoInfoModel } from '../model/VideoInfoModel';

@Observed
export class AVPlayerController {
  private avPlayer: media.AVPlayer | undefined = undefined;
  private surfaceID: string = '';
  private playbackCallbackInterval: number = 0;
  private netCheckInterval: number = 0;
  private weakNetCheckInterval: number = 0;
  private bitrateUpCheckInterval: number = 0;
  private isSeeking: boolean = false;
  private isResumePlay: boolean = false;
  private isWeakNet: boolean = false;
  private isBitrateUpAvailable: boolean = true;
  private currentBitrateIndex: number | undefined = undefined;
  private maxBufferValueList: Array<number> = [];
  private recentDownRates: Array<number> = [];
  private downloadRate: number = 0;
  private maxDownloadRate: number = 0;
  private source: media.MediaSource | undefined = undefined;
  private strategy: media.PlaybackStrategy | undefined = undefined;
  @Track isPlaying: boolean = false;
  @Track bitrateList: Array<number> = [];
  @Track currentResolutionIndex: number | undefined = undefined;
  @Track durationTime: number = 0;
  @Track currentTime: number = 0;
  @Track videoInfo: VideoInfoModel = new VideoInfoModel();

  constructor() {
  }

  // [Start UsePreferredBufferSize]
  // entry/src/main/ets/viewmodel/AVPlayerController.ets
  public async initAVPlayer(id: string, source: media.MediaSource, strategy: media.PlaybackStrategy) {
    // [StartExclude UsePreferredBufferSize]
    try {
      this.avPlayer = await media.createAVPlayer();
      this.surfaceID = id;
      this.setStatusChangeCallback(this.avPlayer);
      this.setCustomCallback(this.avPlayer);
      // [EndExclude UsePreferredBufferSize]
      this.source = source;
      this.strategy = strategy;
      this.avPlayer.setMediaSource(this.source, this.strategy);
    } catch (error) {
      Logger.error(`initAVPlayer error: ${JSON.stringify(error)}`);
    }
  }

  // [End UsePreferredBufferSize]

  public play() {
    // Use isResumePlay to disable the active playback function.
    if (!this.avPlayer || this.isResumePlay) {
      return;
    }
    try {
      if (this.avPlayer.state === 'prepared' || this.avPlayer.state === 'paused' ||
        this.avPlayer.state === 'completed') {
        this.avPlayer.play();
      }
    } catch (error) {
      Logger.error(`AVPlayer play error: ${JSON.stringify(error)}`);
    }
  }

  public pause() {
    if (!this.avPlayer) {
      return;
    }
    try {
      if (this.avPlayer.state === 'playing') {
        this.avPlayer.pause();
      }
    } catch (error) {
      Logger.error(`AVPlayer pause error: ${JSON.stringify(error)}`);
    }
  }

  /**
   * Jumps to the specified playback position
   * @param timeInMs -- Playback position to jump in [0, duration]
   */
  public seek(timeInMs: number) {
    if (!this.avPlayer) {
      return;
    }

    if (this.avPlayer.state === 'prepared' || this.avPlayer.state === 'playing' ||
      this.avPlayer.state === 'paused' || this.avPlayer.state === 'completed') {
      const seekTime = Math.min(
        Math.max(timeInMs, AVPlayerConstants.MIN_SEEK_TIME_MS), this.durationTime * CommonConstants.SECOND_TO_MS);
      this.isSeeking = true;
      this.avPlayer.seek(seekTime, media.SeekMode.SEEK_CLOSEST);
    }
  }

  /**
   * Set bitrate to specified value from on('availableBitrates')
   * @param bitrate
   */
  public setBitrate(bitrate: number) {
    if (!this.avPlayer || !this.isValidVideoStream()) {
      return;
    }

    if (this.avPlayer.state === 'prepared' || this.avPlayer.state === 'playing' ||
      this.avPlayer.state === 'paused' || this.avPlayer.state === 'completed') {
      this.avPlayer.setBitrate(bitrate);
    }
  }

  /**
   * Set bitrate and weak net tag according to net scene
   * @param netScene
   */
  public weakNetCallback(netScene: string) {
    // For non-streaming playback resources or resume playback scenarios, exit directly.
    if (!this.avPlayer || !this.isValidVideoStream() || this.isResumePlay) {
      return;
    }

    if (netScene === 'congestion' || netScene === 'weakSignal') {
      // Maintain a weak network state and avoid repeated pop-up prompts.
      if (this.isWeakNet) {
        clearInterval(this.weakNetCheckInterval);
        return;
      }

      // When first entering a weak network state, adjust the bitrate and show a pop-up prompt.
      this.isWeakNet = true;
      this.setBitrate(this.bitrateList[0]);
      if (this.currentResolutionIndex! > 0) {
        customToast($r('app.string.weak_net'), ViewConstants.TOAST_TIME_MS);
      } else {
        customToast($r('app.string.weak_net_lowest_bitrate'), ViewConstants.TOAST_TIME_MS);
      }
    } else if (netScene === 'normal') {
      // When in a non-weak network state (entering normal state), no follow-up operations are required.
      if (!this.isWeakNet) {
        return;
      }

      // After transitioning from a weak network state to a normal network scenario, wait for a period before exiting
      // the weak network state, making conservative adjustments to avoid frequent switching.
      this.weakNetCheckInterval = setTimeout(() => {
        this.isWeakNet = false;
      }, AVPlayerConstants.WEAK_NET_CHECK_INTERVAL);
    } else if (netScene === 'frequentHandover') {
      // In scenarios with frequent community (network) switching, no processing is performed for now.
      this.isWeakNet = false;
      Logger.warn(`Frequent handover scene`);
    } else {
      Logger.error(`Unknown net scene`);
    }
  }

  public setCurrentTime(timeInSecond: number) {
    this.currentTime = timeInSecond;
  }

  public setSeekStatus(isSeeking: boolean) {
    if (!this.avPlayer) {
      return;
    }

    if (this.avPlayer.state === 'prepared' || this.avPlayer.state === 'playing' ||
      this.avPlayer.state === 'paused' || this.avPlayer.state === 'completed') {
      this.isSeeking = isSeeking;
    } else {
      this.isSeeking = false;
    }
  }

  public clearAllCallback() {
    if (!this.avPlayer) {
      return;
    }
    clearInterval(this.playbackCallbackInterval);
    clearInterval(this.netCheckInterval);
    clearInterval(this.weakNetCheckInterval);
    this.avPlayer.off('availableBitrates');
    this.avPlayer.off('bitrateDone');
    this.avPlayer.off('videoSizeChange');
    this.avPlayer.off('bufferingUpdate');
    this.avPlayer.off('seekDone');
    this.avPlayer.off('timeUpdate');
    this.avPlayer.off('error');
    this.avPlayer.off('stateChange');
  }

  private isValidVideoStream() {
    if (this.bitrateList.length === 0 || this.currentBitrateIndex === undefined) {
      Logger.warn('Bitrate list does not exist, maybe invalid video stream');
      return false;
    } else {
      return true;
    }
  }

  private isDownloading() {
    return this.downloadRate !== 0;
  }

  private isNewResolutionCaching() {
    return this.currentBitrateIndex !== this.currentResolutionIndex;
  }

  private setScreenKeepOnStatus(status: boolean) {
    const windowClass = AppStorage.get<window.Window>('windowClass');
    if (!windowClass) {
      Logger.error('Invalid windowClass');
      return;
    }
    try {
      windowClass.setWindowKeepScreenOn(status);
    } catch (error) {
      Logger.error(`setWindowKeepScreenOn error: ${JSON.stringify(error)}`);
    }
  }

  private getRecentDownRate(newDownRate: number) {
    if (!this.isPlaying) {
      return 0;
    }

    this.recentDownRates.push(newDownRate);
    const rateCount = this.recentDownRates.length;
    if (rateCount > AVPlayerConstants.RECENT_DOWNLOAD_LIST_LENGTH) {
      this.recentDownRates.shift();
      return this.recentDownRates.reduce((acc, curr) => acc + curr, 0) / AVPlayerConstants.RECENT_DOWNLOAD_LIST_LENGTH;
    } else {
      return 0;
    }
  }

  private clearDownloadRate() {
    this.downloadRate = 0;
    this.recentDownRates = [];
  }

  // [Start GetDownloadRate]
  // entry/src/main/ets/viewmodel/AVPlayerController.ets
  private setPlaybackInfoInterval(avPlayer: media.AVPlayer) {
    this.playbackCallbackInterval = setInterval(async () => {
      avPlayer.getPlaybackInfo().then((playbackInfo: media.PlaybackInfo) => {
        // Timing to obtain the current average video download rate, 1-second download rate, recent download rate, and
        // recent peak download rate.
        this.videoInfo.averageDownloadRate = Number(playbackInfo[media.PlaybackInfoKey.AVG_DOWNLOAD_RATE]);
        this.videoInfo.downloadRate = Number(playbackInfo[media.PlaybackInfoKey.DOWNLOAD_RATE]);
        this.downloadRate = this.getRecentDownRate(this.videoInfo.downloadRate);
        this.maxDownloadRate = Math.max(this.downloadRate, this.maxDownloadRate);
      });
    }, AVPlayerConstants.PLAYBACK_INTERVAL_MS);
  }

  // [End GetDownloadRate]

  private setNetCheckInterval(avPlayer: media.AVPlayer) {
    this.netCheckInterval = setInterval(() => {
      try {
        const netHandle = connection.getDefaultNetSync();
        if (!netHandle || netHandle.netId === 0) {
          return;
        }
        const netCapability = connection.getNetCapabilitiesSync(netHandle);
        const netCap = netCapability.networkCap ?? [];

        // When the network is available, avPlayer enters the prepared state.
        if (netCap.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
          avPlayer.prepare();
          clearInterval(this.netCheckInterval);
        }
      } catch (error) {
        Logger.error(`setNetCheckInterval error: ${JSON.stringify(error)}`);
      }
    }, AVPlayerConstants.NET_CHECK_INTERVAL_MS);
  }

  // [Start BasicCallback]
  // [Start CustomBitrateRule]
  // entry/src/main/ets/viewmodel/AVPlayerController.ets
  private setCustomCallback(avPlayer: media.AVPlayer) {
    // [StartExclude CustomBitrateRule]
    avPlayer.on('availableBitrates', (bitrateList: Array<number>) => {
      // [StartExclude BasicCallback]
      const bitrateListLength = bitrateList.length;
      if (bitrateListLength === 0) {
        Logger.warn(`No available bitrate`);
        return;
      }
      // [EndExclude BasicCallback]
      // Obtain the list of optional bitrates, sort them in ascending order, and save them.
      this.bitrateList = bitrateList.sort((a, b) => (a - b));
      // [StartExclude BasicCallback]
      bitrateList.forEach((element) => {
        this.maxBufferValueList.push(CustomConfigs.PREFERRED_BUFFER_SIZE * CommonConstants.MB_TO_BIT / element *
        CommonConstants.SECOND_TO_MS);
      });

      // [EndExclude BasicCallback]
      // Preset a bitrate, block AVPlayer's adaptive logic, and reset the peak download rate.
      this.setBitrate(this.bitrateList[bitrateListLength - 1]);
      // [StartExclude BasicCallback]
      Logger.info(`Available bitrates: ${this.bitrateList}`);
      // [EndExclude BasicCallback]
    });
    avPlayer.on('bitrateDone', (bitrate: number) => {
      // [StartExclude BasicCallback]
      Logger.info(`AVPlayer set bitrate done, bitrate: ${bitrate}`);
      // Reset the peak download rate.
      this.maxDownloadRate = 0;
      // [EndExclude BasicCallback]
      // When the bitrate is set successfully, record the current bitrate with the index value recorded here.
      this.currentBitrateIndex = this.bitrateList.findIndex((value) => value === bitrate);
    });
    avPlayer.on('videoSizeChange', (width: number, height: number) => {
      // [StartExclude BasicCallback]
      Logger.info(`AVPlayer video size changed, resolution ${width} x ${height}`);

      // When the video is first prepared and no active setBitrate is triggered, the index is undefined, and the
      // resolution is automatically matched to obtain the corresponding bitrate.
      this.currentBitrateIndex =
        Array.from(CustomConfigs.SELECTABLE_RESOLUTIONS.keys()).findIndex((value) => value === height);

      // After completing a resolution adjustment, the bitrate can only be increased after a certain period of time.
      this.isBitrateUpAvailable = false;
      clearInterval(this.bitrateUpCheckInterval);
      this.bitrateUpCheckInterval = setTimeout(() => {
        this.isBitrateUpAvailable = true;
      }, AVPlayerConstants.BITRATE_UP_CHECK_INTERVAL);

      // [EndExclude BasicCallback]
      // If the resolution switching is successful, record the current resolution. Here, record the index value, which
      // is consistent with the current bitrate.
      this.currentResolutionIndex = this.currentBitrateIndex;
      // [StartExclude BasicCallback]
      customToast($r('app.string.resolution_changed'), ViewConstants.TOAST_TIME_MS);
      // [EndExclude BasicCallback]
    });
    // [EndExclude CustomBitrateRule]
    // [StartExclude BasicCallback]
    avPlayer.on('bufferingUpdate', (infoType: media.BufferingInfoType, value: number) => {
      // [StartExclude CustomBitrateRule]
      this.videoInfo.currentBufferInfoType = infoType;
      this.videoInfo.currentBufferInfoValue = value;

      // The bitrate adjustment will not be performed if any one of the following five situations is met:
      // 1. The infoType is not CACHED_DURATIONS.
      // 2. The playback environment is determined to be in a weak network, so it is automatically adjusted to the
      //    lowest bitrate, and the adaptive logic here is blocked.
      // 3. The video is not in an effective download state (i.e., not downloading, or downloading but the obtained
      //    download rate is 0).
      // 4. The video is in the seeking period.
      // 5. The video source cannot normally obtain bitrate information.
      if (infoType !== media.BufferingInfoType.CACHED_DURATION || this.isWeakNet || !this.isDownloading() ||
      this.isSeeking || !this.isValidVideoStream()) {
        return;
      }
      // [EndExclude CustomBitrateRule]
      // When the playable duration of the video cache is less than the set threshold, adjust the bitrate according to
      // the current download rate.
      if (value < CustomConfigs.CACHED_PERCENT_THRESHOLD * this.maxBufferValueList[this.currentBitrateIndex!]) {
        // Match the bitrate lower than the current download rate; if no match is found, select the lowest bitrate.
        const targetBitrate = this.findTargetBitrate();
        if (targetBitrate < this.bitrateList[this.currentBitrateIndex!]) {
          this.autoReduceBitrate(targetBitrate);
        }
      } else {
        // The bitrate shall be increased by one level when all the following five conditions are simultaneously met:
        // 1. The current bitrate is not the maximum bitrate.
        // 2. The playable duration of the video cache at the current bitrate reaches the maximum playable duration of
        //    the cache corresponding to the next higher bitrate.
        // 3. The recent peak network download rate is greater than the next higher bitrate.
        // 4. The system is not currently in the state of resolution switching.
        // 5. No resolution adjustment has occurred within a recent certain period, indicating relatively stable network
        //    conditions.
        const nextBitrateIndex = this.currentBitrateIndex! + 1;
        if (nextBitrateIndex < this.bitrateList.length && value > this.maxBufferValueList[nextBitrateIndex] &&
          this.maxDownloadRate >= this.bitrateList[nextBitrateIndex] &&
          !this.isNewResolutionCaching() && this.isBitrateUpAvailable) {
          this.autoIncreaseBitrate(this.bitrateList[nextBitrateIndex]);
        }
      }
    });
    // [StartExclude CustomBitrateRule]
    avPlayer.on('seekDone', (seekDoneTime: number) => {
      Logger.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
      // Seek done.
      this.isSeeking = false;
      this.currentTime = Math.ceil(avPlayer.currentTime / CommonConstants.SECOND_TO_MS);
    });
    avPlayer.on('timeUpdate', (timeInMs: number) => {
      if (this.isPlaying && !this.isSeeking) {
        this.currentTime = Math.ceil(timeInMs / CommonConstants.SECOND_TO_MS);
      }
    });
    avPlayer.on('error', (err: BusinessError) => {
      Logger.error(`Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`);
    });
    // [EndExclude BasicCallback]
    // [EndExclude CustomBitrateRule]
  }

  // [End BasicCallback]
  // [End CustomBitrateRule]

  /**
   * Set avPlayer status callback
   * @param avPlayer
   */
  private setStatusChangeCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('stateChange', (state: string, reason: media.StateChangeReason) => {
      if (state === 'playing') {
        this.isPlaying = true;
        this.setScreenKeepOnStatus(true);
      } else {
        this.isPlaying = false;
        this.clearDownloadRate();
        this.setScreenKeepOnStatus(false);
      }

      switch (state) {
        case 'idle':
          Logger.info('AVPlayer state idle called.');
          avPlayer.url = CustomConfigs.URL;
          break;
        case 'initialized':
          Logger.info('AVPlayer state initialized called.');
          avPlayer.surfaceId = this.surfaceID;
          this.setNetCheckInterval(avPlayer);
          break;
        case 'prepared':
          Logger.info('AVPlayer state prepared called.');
          this.setPlaybackInfoInterval(avPlayer);
          this.durationTime = Math.ceil(avPlayer.duration / CommonConstants.SECOND_TO_MS);
          if (this.isResumePlay) {
            this.seek(this.currentTime * CommonConstants.SECOND_TO_MS);
            avPlayer.play(() => {
              this.isResumePlay = false;
            });
          }
          break;
        case 'playing':
          Logger.info('AVPlayer state playing called.');
          break;
        case 'paused':
          Logger.info('AVPlayer state paused called.');
          break;
        case 'completed':
          Logger.info('AVPlayer state completed called.');
          break;
        case 'stopped':
          Logger.info('AVPlayer state stopped called.');
          break;
        case 'released':
          Logger.info('AVPlayer state released called.');
          break;
        case 'error':
          Logger.error(`AVPlayer state error called, reason: ${reason}`);
          customToast($r('app.string.error_info'), ViewConstants.TOAST_TIME_MS);
          this.isResumePlay = true;
          avPlayer.reset();
          break;
        default:
          Logger.info('AVPlayer state unknown called.');
          break;
      }
    });
  }

  private findTargetBitrate() {
    const bitrateListLength = this.bitrateList.length;
    const downloadBitrate = this.downloadRate;
    if (downloadBitrate > this.bitrateList[bitrateListLength - 1]) {
      return this.bitrateList[bitrateListLength - 1];
    } else {
      const targetBitrate = this.bitrateList.find((_value, index) =>
      index < bitrateListLength - 1 &&
        this.bitrateList[index] <= downloadBitrate &&
        this.bitrateList[index + 1] > downloadBitrate
      ) ?? this.bitrateList[0];
      return targetBitrate;
    }
  }

  private autoReduceBitrate(targetBitrate: number) {
    customToast($r('app.string.resolution_auto_reducing'), ViewConstants.TOAST_TIME_MS);
    this.setBitrate(targetBitrate);
  }

  private autoIncreaseBitrate(targetBitrate: number) {
    customToast($r('app.string.resolution_auto_increasing'), ViewConstants.TOAST_TIME_MS);
    this.setBitrate(targetBitrate);
  }
}