import { speechRecognizer } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ICapturerInterface } from './ICapturerInterface';
import FileCapturer from './FileCapturer';
import { fileIo } from '@kit.CoreFileKit';
import AudioCapturer from './AudioCapturer'
import { promptAction } from '@kit.ArkUI';

const TAG: string = 'AsrDemo';
let asrEngine: speechRecognizer.SpeechRecognitionEngine;

@Entry
@Component
struct Index {
  @State createCount: number = 0;
  @State result: boolean = false;
  @State voiceInfo: string = "";
  @State sessionId: string = "123456";
  @State sessionId2: string = "1234567";
  @State generatedText: string = "Default Text";

  private mFileCapturer: ICapturerInterface = new FileCapturer();
  private mAudioCapturer: ICapturerInterface = new AudioCapturer();

  build() {
    Column() {
      Scroll() {
        Column() {
          Row() {
            Column() {
              Text(this.generatedText)
                .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            }
            .width('100%')
            .constraintSize({ minHeight: 100 })
            .border({ width: 1, radius: 5 })
            .backgroundColor('#d3d3d3')
            .padding(20)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20, bottom: 20 })

          Button() {
            Text("CreateEngine")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.createCount++;
            console.info(`CreateasrEngine：createCount:${this.createCount}`);
            this.createByCallback();
            promptAction.showToast({
              message: 'CreateEngine success!',
              duration: 2000
            });
          })

          Button() {
            Text("CreateEngineByPromise")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.createCount++;
            console.info(`CreateasrEngine：createCount:${this.createCount}`);
            this.createByPromise();
            promptAction.showToast({
              message: 'CreateEngineByPromise success!',
              duration: 2000
            });
          })

          Button() {
            Text("isBusy")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            console.info(TAG, "isBusy click:-->");
            let isBusy: boolean = asrEngine.isBusy();
            console.info(TAG, "isBusy: " + isBusy);
            if (isBusy) {
              promptAction.showToast({
                message: 'is busy!',
                duration: 2000
              });
            } else {
              promptAction.showToast({
                message: 'not busy',
                duration: 2000
              })
            }
          })

          Button() {
            Text("startRecording")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.startRecording();
            promptAction.showToast({
              message: 'start Recording!',
              duration: 2000
            });
          })

          Button() {
            Text("audioToText")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.writeAudio();
            promptAction.showToast({
              message: 'audioToText!',
              duration: 2000
            });
          })

          Button() {
            Text("queryLanguagesCallback")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.queryLanguagesCallback();
            promptAction.showToast({
              message: 'queryLanguagesCallback success!',
              duration: 2000
            });
          })

          Button() {
            Text("queryLanguagesPromise")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.queryLanguagesPromise();
            promptAction.showToast({
              message: 'queryLanguagesPromise success!',
              duration: 2000
            });
          })

          Button() {
            Text("finish")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(async () => {
            console.info("finish click:-->");
            await this.mFileCapturer.stop();
            asrEngine.finish(this.sessionId);
            promptAction.showToast({
              message: 'finish!',
              duration: 2000
            });
          })

          Button() {
            Text("cancel")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            console.info("cancel click:-->");
            asrEngine.cancel(this.sessionId);
            promptAction.showToast({
              message: 'cancel',
              duration: 2000
            });
          })

          Button() {
            Text("shutdown")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AA7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            asrEngine.shutdown();
            promptAction.showToast({
              message: 'shutdown!',
              duration: 2000
            });
          })

          Button() {
            Text("createOfErrorLanguage")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.createCount++;
            console.info(`CreateasrEngine：createCount:${this.createCount}`);
            this.createOfErrorLanguage();
            promptAction.showToast({
              message: 'createOfErrorLanguage success!',
              duration: 2000
            });
          })

          Button() {
            Text("createOfErrorOnline")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.createCount++;
            console.info(`CreateasrEngine：createCount:${this.createCount}`);
            this.createOfErrorOnline();
            promptAction.showToast({
              message: 'createOfErrorOnline success!',
              duration: 2000
            });
          })

        }
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

    }
  }

  // Create an engine, which is returned in callback mode.
  private createByCallback() {
    // Setting Engine Creation Parameters
    let extraParam: Record<string, Object> = { "locate": "CN", "recognizerMode": "short" };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };

    try {
      // Invoke the createEngine method.
      speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          console.info(TAG, 'createEngine is success');
          // Receive an instance of the creation engine
          asrEngine = speechRecognitionEngine;
        } else {
          console.error("errCode: " + err.code + " errMessage: " + JSON.stringify(err.message));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`createEngine failed, error code: ${code}, message: ${message}.`)
    }
  }

  // Create an engine, which is returned in promise mode.
  private createByPromise() {
    // Setting Engine Creation Parameters
    let extraParam: Record<string, Object> = { "locate": "CN", "recognizerMode": "short" };
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: extraParam
    };

    // Invoke the createEngine method.
    speechRecognizer.createEngine(initParamsInfo)
      .then((speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
        asrEngine = speechRecognitionEngine;
        console.info('result:' + JSON.stringify(speechRecognitionEngine));
      })
      .catch((err: BusinessError) => {
        console.error('result' + JSON.stringify(err));
      });
  }

  // Queries the language information, which is returned in callback mode.
  private queryLanguagesCallback() {
    // Set query-related parameters.
    let languageQuery: speechRecognizer.LanguageQuery = {
      sessionId: this.sessionId
    };
    // Invoke the listLanguages method.
    try {
      console.info(TAG, 'listLanguages  start');
      asrEngine.listLanguages(languageQuery, (err: BusinessError, languages: Array<string>) => {
        if (!err) {
          // Receive the information about the currently supported languages.
          console.info(TAG, 'listLanguages  result: ' + JSON.stringify(languages));
        } else {
          console.error("errCode is " + JSON.stringify(err));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`listLanguages failed, error code: ${code}, message: ${message}.`)
    }

  };

  // Queries the language information and returns the information in promise mode.
  private queryLanguagesPromise() {
    // Set query-related parameters.
    let languageQuery: speechRecognizer.LanguageQuery = {
      sessionId: this.sessionId
    };
    // Invoke the listLanguages method.
    asrEngine.listLanguages(languageQuery).then((res: Array<string>) => {
      console.info('voiceInfo:' + JSON.stringify(res));
    }).catch((err: BusinessError) => {
      console.error('error' + JSON.stringify(err));
    });
  }

  // Recording to text
  private async startRecording() {
    this.setListener();
    // Set the parameters related to the start of identification.
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
    let extraParam: Record<string, Object> = {
      "recognitionMode": 0,
      "vadBegin": 2000,
      "vadEnd": 3000,
      "maxAudioDuration": 20000
    }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: audioParam,
      extraParams: extraParam
    }
    // Invoke the start recognition method.
    console.info(TAG, 'startListening start');
    asrEngine.startListening(recognizerParams);

    // Recording Obtaining Audio
    let data: ArrayBuffer;
    this.mFileCapturer = this.mAudioCapturer;
    console.info(TAG, 'create capture success');
    this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
      console.info(TAG, 'start write');
      console.info(TAG, 'ArrayBuffer ' + JSON.stringify(dataBuffer));
      data = dataBuffer
      let uint8Array: Uint8Array = new Uint8Array(data);
      console.info(TAG, 'ArrayBuffer uint8Array ' + JSON.stringify(uint8Array));
      // Writing Audio Streams
      asrEngine.writeAudio(this.sessionId, uint8Array);
    });
  };

  // Audio to text
  private async writeAudio() {
    this.setListener();
    // Set the parameters related to the start of identification.
    let audioParam: speechRecognizer.AudioInfo = { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 }
    let recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId2,
      audioInfo: audioParam
    }
    // Invoke the start recognition method.
    asrEngine.startListening(recognizerParams);

    // Get Audio from File
    let data: ArrayBuffer;
    let ctx = getContext(this);
    let filenames: string[] = fileIo.listFileSync(ctx.resourceDir);
    if (filenames.length <= 0) {
      console.error('length is null');
      return;
    }
    let filePath: string = ctx.resourceDir + '/' + filenames[0];
    (this.mFileCapturer as FileCapturer).setFilePath(filePath);
    this.mFileCapturer.init((dataBuffer: ArrayBuffer) => {
      data = dataBuffer
      let uint8Array: Uint8Array = new Uint8Array(data);
      asrEngine.writeAudio(this.sessionId2, uint8Array);
    });
    await this.mFileCapturer.start();
    await this.mFileCapturer.release();
  }

  // Setting callbacks
  private setListener() {
    // Creating a Callback Object
    let setListener: speechRecognizer.RecognitionListener = {
      // Callback for successful recognition start
      onStart: (sessionId: string, eventMessage: string) => {
        this.generatedText = '';
        console.info(TAG, "setListener onStart sessionId: " + sessionId + "eventMessage: " + eventMessage);
      },
      // Event callback
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        console.info(TAG, "setListener onEvent sessionId: " + sessionId + "eventMessage: " + eventCode + "eventMessage: " + eventMessage);
      },
      // Identification result callback, including intermediate results and final results.
      onResult: (sessionId: string, res: speechRecognizer.SpeechRecognitionResult) => {
        let isFinal: boolean = res.isFinal;
        let isLast: boolean = res.isLast;
        let result: string = res.result;
        this.generatedText = result;
        console.info('setListener onResult: ' + 'sessionId: ' + sessionId + ' isFinal: ' + isFinal + ' isLast: ' + isLast + ' result: ' + result);
      },
      // Recognition completion callback
      onComplete(sessionId: string, eventMessage: string) {
        console.info(TAG, "setListener onComplete sessionId: " + sessionId + "eventMessage: " + eventMessage);
      },
      // Error callback. The error code is returned by this method.
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        console.error(TAG, "setListener onError sessionId: " + sessionId + "errorCode: " + errorCode + "errorMessage: " + errorMessage);
      }
    }
    // Invoke the callback method.
    asrEngine.setListener(setListener);
  };

  // When an engine is created in an unsupported language, the error code 1002200001 is returned. The language is not supported.
  private createOfErrorLanguage() {
    // Setting Engine Creation Parameters
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      // The language is not supported
      language: 'zh-CNX',
      online: 1
    };
    try {
      // Invoke the createEngine method.
      speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          console.info(TAG, 'createEngine is success');
          // Accept the instance of the creation engine
          asrEngine = speechRecognitionEngine;
        } else {
          // Error code 1002200001 is returned. The language is not supported. Initialization fails.
          console.error("errCode: " + err.code + " errMessage: " + JSON.stringify(err.message));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`createEngine failed, error code: ${code}, message: ${message}.`)
    }
  }

  // When an unsupported mode is used to create an engine, error code 1002200001 is returned,
  // indicating that the mode does not support initialization failure.
  private createOfErrorOnline() {
    // Setting Engine Creation Parameters
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 2
    };
    try {
      // Invoke the createEngine method.
      speechRecognizer.createEngine(initParamsInfo, (err: BusinessError, speechRecognitionEngine: speechRecognizer.SpeechRecognitionEngine) => {
        if (!err) {
          console.info(TAG, 'createEngine is success');
          // Accept the instance of the creation engine
          asrEngine = speechRecognitionEngine;
        } else {
          // Error code 1002200001 is returned. The mode is not supported. Initialization fails.
          console.error("errCode: " + err.code + " errMessage: " + JSON.stringify(err.message));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`createEngine failed, error code: ${code}, message: ${message}.`)
    }
  }
}
