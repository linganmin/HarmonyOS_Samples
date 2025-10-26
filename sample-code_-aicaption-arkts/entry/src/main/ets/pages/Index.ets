/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { AICaptionComponent, AICaptionOptions, AICaptionController, AudioData } from '@kit.SpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'AI_CAPTION_DEMO'

class Logger {
  static info(...msg: string[]) {
    hilog.info(0x0000, TAG, msg.join())
  }

  static error(...msg: string[]) {
    hilog.error(0x0000, TAG, msg.join())
  }
}

@Entry
@Component
struct Index {
  private captionOption?: AICaptionOptions;
  private controller: AICaptionController = new AICaptionController();
  @State isShown: boolean = false;
  isReading: boolean = false;

  aboutToAppear(): void {
    // Initialization parameter, which is used to set the opacity of subtitles.
    this.captionOption = {
      initialOpacity: 1,
      onPrepared: () => {
        Logger.info('onPrepared')
      },
      onError: (error: BusinessError) => {
        Logger.error(`AICaption component error. Error code: ${error.code}, message: ${error.message}`)
      }
    }
  }

  async readPcmAudio() {
    this.isReading = true;
	const fileData: Uint8Array | undefined =
      await this.getUIContext()?.getHostContext()?.resourceManager.getMediaContent($r('app.media.chineseAudio').id);
    if (fileData === undefined){
      return;
    }

    const bufferSize = 640;
    const byteLength = fileData.byteLength;
    let offset = 0;
    Logger.info(`Pcm data total bytes: ${byteLength.toString()}`)
    let startTime = new Date().getTime();
    while (offset < byteLength) {
      // Simulate the actual situation, reading files is faster than returning streams from the recorder, so it takes a while to wait.
      let nextOffset = offset + bufferSize
      if (offset > byteLength) {
        this.isReading = false;
        return
      }
      const arrayBuffer = fileData.buffer.slice(offset, nextOffset);
      let data = new Uint8Array(arrayBuffer);
      const audioData: AudioData = {
        data: data
      }

      if (this.controller) {
        this.controller.writeAudio(audioData)
      }
      offset = offset + bufferSize;
      const waitTime = bufferSize / 32
      await this.sleep(waitTime)
    }
    let endTime = new Date().getTime()
    this.isReading = false;
    Logger.info(`Audio play time: ${JSON.stringify(endTime - startTime)}`)
  }

  sleep(time: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, time))
  }

  build() {
    Column({ space: 20 }) {
      Button('Toggle subtitle display status:' + (this.isShown ? 'Show' : 'Hide'))
        .backgroundColor('#B8BDA0')
        .width(200)
        .onClick(() => {
          this.isShown = !this.isShown;
        })
      Button('Read PCM Audio')
        .backgroundColor('#B8BDA0')
        .width(200)
        .onClick(() => {
          if (!this.isReading) {
            this.readPcmAudio()
          }
        })
      Divider()
      // Invoke the AICaptionComponent to initialize the AI caption.
      AICaptionComponent({
        isShown: this.isShown,
        controller: this.controller,
        options: this.captionOption
      })
        .width('100%')
        .height(100)
      Divider()
      if (this.isShown) {
        Text('Above is the subtitle area.')
          .fontColor(Color.White)
      }
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor('#7A7D6A')
  }
}