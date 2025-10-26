/**
 * 最佳实践：合理使用音频资源
 * 场景六：录音场景
 */

// [Start recording_audio_capturer]
import { UIAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { audio } from '@kit.AudioKit';
// [StartExclude recording_audio_capturer]
let audioStreamInfo: audio.AudioStreamInfo = {
  samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率。
  channels: audio.AudioChannel.CHANNEL_2, // 通道。
  sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式。
  encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式。
};

let audioCapturerInfo: audio.AudioCapturerInfo = {
  source: audio.SourceType.SOURCE_TYPE_MIC, // 音源类型：Mic音频源。根据业务场景配置，参考SourceType。
  capturerFlags: 0 // 音频采集器标志。
};

let audioCapturerOptions: audio.AudioCapturerOptions = {
  streamInfo: audioStreamInfo,
  capturerInfo: audioCapturerInfo
};
let audioCapturer: audio.AudioCapturer;

audio.createAudioCapturer(audioCapturerOptions, (err, data) => {
  if (err) {
    console.error(`Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
  } else {
    console.info('Invoke createAudioCapturer succeeded.');
    let audioCapturer = data;
  }
});
// [EndExclude recording_audio_capturer]
export default class EntryAbility extends UIAbility {
  // ...

  onForeground(): void {
    //Apply for the resources required by the system, or reapply for the resources released in onBackground ()
    audio.createAudioCapturer(audioCapturerOptions, (err, data) => {
      if (err) {
        console.error(`InvokecreateAudioCapturerfailed,codeis${err.code},messageis${err.message}`);
      } else {
        console.info('InvokecreateAudioCapturersucceeded.');
      }
    });
  }

  onBackground(): void {
    //Release resources when the UI is invisible
    audioCapturer.stop((err: BusinessError) => {});
    //Or pause();
  }
}
// [End recording_audio_capturer]