import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { Logger } from './Logger';
import { BackgroundUtil } from './BackgroundUtil';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';

const TAG = 'AudioCapturerController';

export class AudioCapturerController {
  public audioCapturer: audio.AudioCapturer | undefined = undefined;
  private context: common.UIAbilityContext | undefined = AppStorage.get('context');

  public static getInstance(): AudioCapturerController {
    let audioCapturerController: AudioCapturerController | undefined = AppStorage.get('AudioCapturerController');
    if (!audioCapturerController) {
      audioCapturerController = new AudioCapturerController();
      AppStorage.setOrCreate<AudioCapturerController>('AudioCapturerController', audioCapturerController);
    }
    return audioCapturerController;
  }

  public async initAudioCapturer() {
    if (this.audioCapturer) {
      return;
    }
    let audioStreamInfo: audio.AudioStreamInfo = {
      samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000,
      channels: audio.AudioChannel.CHANNEL_2,
      sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE,
      encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
    };

    let audioCapturerInfo: audio.AudioCapturerInfo = {
      source: audio.SourceType.SOURCE_TYPE_MIC,
      capturerFlags: 0
    };

    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: audioStreamInfo,
      capturerInfo: audioCapturerInfo
    };
    try {
      if (!this.context) {
        Logger.error(TAG, `context is undefined.`);
        return;
      }
      this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);
      this.setOnReadCallBack();
      Logger.info(TAG, 'Invoke createAudioCapturer succeeded.');
    } catch (err) {
      Logger.error(TAG, `Invoke createAudioCapturer failed, code is ${err.code}, message is ${err.message}`);
    }
  }

  private setOnReadCallBack() {
    if (!this.audioCapturer) {
      Logger.error(TAG, `audioCapturer is undefined.`);
      return;
    }
    let bufferSize: number = 0;

    class Options {
      offset?: number;
      length?: number;
    }

    if (!this.context) {
      Logger.error(TAG, `context is undefined.`);
      return;
    }
    let path = this.context.cacheDir;
    let filePath = path + '/StarWars10s-2C-48000-4SW.pcm';
    let file: fileIo.File = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let readDataCallback = (buffer: ArrayBuffer) => {
      let options: Options = {
        offset: bufferSize,
        length: buffer.byteLength
      };
      fileIo.writeSync(file.fd, buffer, options);
      bufferSize += buffer.byteLength;
    };
    this.audioCapturer.on('readData', readDataCallback);
  }

  public async start() {
    await this.initAudioCapturer();
    if (!this.audioCapturer) {
      Logger.error(TAG, `audioCapturer is undefined.`);
      return;
    }
    try {
      BackgroundUtil.startContinuousTask(this.context, backgroundTaskManager.BackgroundMode.AUDIO_RECORDING);
      await this.audioCapturer.start();
      AppStorage.setOrCreate('isCapturering', true);
      Logger.info(TAG, `audioCapturer start successed.`);
    } catch (error) {
      Logger.error(TAG, `audioCapturer start failed.`);
    }
  }

  public async stop() {

    if (!this.audioCapturer) {
      Logger.error(TAG, `audioCapturer is undefined.`);
      return;
    }
    try {
      await this.audioCapturer.stop();
      AppStorage.setOrCreate('isCapturering', false);
      BackgroundUtil.stopContinuousTask(this.context!);
      Logger.info(TAG, `audioCapturer stop successed.`);
    } catch (error) {
      Logger.error(TAG, `audioCapturer stop failed.`);
    }
  }

  public async release() {
    if (!this.audioCapturer) {
      Logger.error(TAG, `audioCapturer is undefined.`);
      return;
    }
    try {
      await this.audioCapturer.release();
      AppStorage.delete('isCapturering');
      Logger.info(TAG, `audioCapturer release successed.`);
      BackgroundUtil.stopContinuousTask(this.context!);
      AppStorage.delete('AudioCapturerController')
    } catch (error) {
      Logger.error(TAG, `audioCapturer release failed.`);
    }
  }
}