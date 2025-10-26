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

import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { avSession } from '@kit.AVSessionKit';
import { SecondBufferWalk } from './SecondBufferWalk';
import { ToneQuality, MusicPlayMode, SongItem } from '../../model/SongData';
import { ResourceConversion } from './ResourceConversion';

const TAG = 'MediaTools';

export class MediaTools {
  static resourceConversion: ResourceConversion = new ResourceConversion();

  static async getPixelMapFromResource(context: common.UIAbilityContext | undefined,
    name: resourceManager.Resource): Promise<PixelMap | undefined> {
    let pixelMap: image.PixelMap | undefined = undefined;
    try {
      let unit8Array = await context?.resourceManager?.getMediaContent(name.id);
      let imageSource = image.createImageSource(unit8Array?.buffer.slice(0, unit8Array?.buffer.byteLength));
      pixelMap = await imageSource.createPixelMap({
        desiredPixelFormat: image.PixelMapFormat.RGBA_8888
      });
      await imageSource.release();
    } catch (error) {
      hilog.error(0x0000, TAG, `getMediaContent failed, the error is: ${JSON.stringify(error)}`);
    }
    return pixelMap;
  }

  static async getPixelMapFromFile(id: string, path: string): Promise<image.PixelMap> {
    hilog.info(0x0000, TAG, 'getPixelMapFromFile id:' + id + ', path:' + path);
    return await image.createImageSource(path).createPixelMap();
  }

  static getMsFromByteLength(byteLength: number): number {
    return 1000 * (byteLength / SecondBufferWalk.getInstance().get());
  }

  static getOffsetFromTime(curMs: number) {
    return (curMs / 1000) * SecondBufferWalk.getInstance().get();
  }

  private static fill(value: number): string {
    return value.toString().padStart(2, '0');
  }

  static msToCountdownTime(ms: number): string {
    if (!ms) {
      return '00:00';
    }
    const days = Math.floor(ms / (1000 * 60 * 60 * 24));
    const hours = Math.floor((ms % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((ms % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((ms % (1000 * 60)) / 1000);
    return `${(days ? MediaTools.fill(days) + ':' : '')}${(hours ? MediaTools.fill(hours) + ':' : '')}
      ${MediaTools.fill(minutes)}:${MediaTools.fill(seconds)} `.trim();
  }

  static getSrcFromPlayMode(src: string): string {
    let playMode: number = AppStorage.get('selectToneQuality') || ToneQuality.SQ;
    playMode = playMode === ToneQuality.MASTER ? ToneQuality.SQ : playMode;
    let srcList = src.split('.');
    return srcList[0] + playMode + '.' + srcList[1];
  }

  static getMusicModeByAvSession(loopMode: avSession.LoopMode) {
    let mode = MusicPlayMode.ORDER;
    switch (loopMode) {
      case avSession.LoopMode.LOOP_MODE_SINGLE:
        mode = MusicPlayMode.SINGLE_CYCLE;
        break;
      case avSession.LoopMode.LOOP_MODE_SEQUENCE:
        mode = MusicPlayMode.ORDER;
        break;
      case avSession.LoopMode.LOOP_MODE_SHUFFLE:
        mode = MusicPlayMode.RANDOM;
        break;
      default:
        break;
    }
    return mode;
  }

  static getNextMusicIndex(playMode: number, musicIndex: number): number {
    let songList: Array<SongItem> = AppStorage.get('songList') || [];
    let playIndex = musicIndex;
    switch (playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        break;
      case MusicPlayMode.ORDER:
        if (playIndex === songList.length - 1) {
          playIndex = 0;
        } else {
          playIndex += 1;
        }
        break;
      case MusicPlayMode.RANDOM:
        playIndex = Math.round(Math.random() * (songList.length - 1));
        break;
      default:
        break;
    }
    return playIndex;
  }

  getPreviousMusicIndex(playMode: number, musicIndex: number): number {
    let songList: Array<SongItem> = AppStorage.get('songList') || [];
    let playIndex = musicIndex;
    switch (playMode) {
      case MusicPlayMode.SINGLE_CYCLE:
        break;
      case MusicPlayMode.ORDER:
        if (playIndex === 0) {
          playIndex = songList.length - 1;
        } else {
          playIndex -= 1;
        }
        break;
      case MusicPlayMode.RANDOM:
        playIndex = Math.round(Math.random() * (songList.length - 1));
        break;
      default:
        break;
    }
    return playIndex;
  }

  static getMusicIndexByMusicMode(playType: string, playMode: number, musicIndex: number) {
    let playIndex: number = 0;
    switch (playType) {
      case 'next':
        playIndex = MediaTools.getNextMusicIndex(playMode, musicIndex);
        break;
      case 'previous':
        playIndex = MediaTools.getNextMusicIndex(playMode, musicIndex);
        break;
      default:
        break;
    }
    return playIndex;
  }

  static getToastMessageByMusicMode(playMode: number) {
    return `${playMode === MusicPlayMode.ORDER ?
    MediaTools.resourceConversion.getStringValueFromResource($r('app.string.sequential_playback')) :
      playMode === MusicPlayMode.RANDOM ?
      MediaTools.resourceConversion.getStringValueFromResource($r('app.string.random_playback')) :
      MediaTools.resourceConversion.getStringValueFromResource($r('app.string.single_playback'))}`;
  }

  static fetchToneQualityTitle(quality: number): string {
    let toneQualityTitle: string = MediaTools.resourceConversion.getStringValueFromResource($r('app.string.lossless')) || '';
    switch (quality) {
      case ToneQuality.SQ:
        toneQualityTitle = MediaTools.resourceConversion.getStringValueFromResource($r('app.string.lossless')) || '';
        break;
      case ToneQuality.SPATIAL_AUDIO:
        toneQualityTitle = MediaTools.resourceConversion.getStringValueFromResource($r('app.string.hd_ultimate')) || '';
        break;
      case ToneQuality.MASTER:
        toneQualityTitle = MediaTools.resourceConversion.getStringValueFromResource($r('app.string.ultra_hd_master_tape')) || '';
        break;
      default:
        break;
    }
    return toneQualityTitle;
  }
}