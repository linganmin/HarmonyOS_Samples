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

/**
 * 最佳实践: 音乐播放场景低功耗规则
 */

// [Start setAudioEffectMode]
// [Start audioStreamInfo]
import { audio } from '@kit.AudioKit';
// [End audioStreamInfo]
import { BusinessError } from '@kit.BasicServicesKit';
// [End setAudioEffectMode]
// [Start setListener]
import { avSession } from '@kit.AVSessionKit';

// [End setListener]
import { hilog } from '@kit.PerformanceAnalysisKit';

let audioRenderer: audio.AudioRenderer | undefined = undefined;
// [Start setAudioEffectMode]
audioRenderer!.setAudioEffectMode(audio.AudioEffectMode.EFFECT_NONE, (err: BusinessError) => {
  if (err) {
    hilog.error(0x0000, 'Sample', `Failed to set params, code is ${err.code}, message is ${err.message}`);
    return;
  } else {
    hilog.info(0x0000, 'Sample', 'Callback invoked to indicate a successful audio effect mode setting.');
  }
});
// [End setAudioEffectMode]

// [Start audioStreamInfo]
let audioStreamInfo: audio.AudioStreamInfo = {
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
  channels: audio.AudioChannel.CHANNEL_1,
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
};
let audioRendererInfo: audio.AudioRendererInfo = {
  usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
  rendererFlags: 0
};
let audioRendererOptions: audio.AudioRendererOptions = {
  streamInfo: audioStreamInfo,
  rendererInfo: audioRendererInfo
};
audio.createAudioRenderer(audioRendererOptions, (err, data) => {
  if (err) {
    hilog.error(0x0000, 'Sample', `Invoke createAudioRenderer failed, code is ${err.code}, message is ${err.message}`);
    return;
  } else {
    hilog.info(0x0000, 'Sample', 'Invoke createAudioRenderer succeeded.');
    let audioRenderer = data;
  }
});
// [End audioStreamInfo]

// [Start setListener]
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context: Context = uiContext?.getHostContext()!;

async function setListener(): Promise<void> {
  // Assuming that a session has been created, see the previous example for how to create a session
  let type: avSession.AVSessionType = 'audio';
  let session: avSession.AVSession = await avSession.createAVSession(context, 'SESSION_NAME', type);

  // Set the duration of the property
  let metadata: avSession.AVMetadata = {
    assetId: '0',
    title: 'TITLE',
    mediaImage: 'IMAGE',
    duration: 23000, // The duration of the resource, measured in milliseconds
  };
  session.setAVMetadata(metadata).then(() => {
    hilog.info(0x0000, 'Sample', `SetAVMetadata successfully`);
  }).catch((err: BusinessError) => {
    hilog.error(0x0000, 'Sample', `Failed to set AVMetadata. Code: ${err.code}, message: ${err.message}`);
  });

  // Set Status: Playback Status, Progress Position, Playback Speed, Cache Time
  let playbackState: avSession.AVPlaybackState = {
    state: avSession.PlaybackState.PLAYBACK_STATE_PLAY, // Playback status
    position: {
      elapsedTime: 1000, // The position that has been played, in ms
      updateTime: new Date().getTime(), // The timestamp of when the app updated the current location, in ms
    },
    speed: 1.0, // Optional, the default is 1.0, the speed of playback, set according to the speed supported in the app, the system does not do verification
    bufferedTime: 14000, // Optional, the time for which the resource is cached, in ms
  };
  session.setAVPlaybackState(playbackState, (err) => {
    if (err) {
      hilog.error(0x0000, 'Sample', `Failed to set AVPlaybackState. Code: ${err.code}, message: ${err.message}`);
    } else {
      hilog.info(0x0000, 'Sample', `SetAVPlaybackState successfully`);
    }
  });
}

// [End setListener]