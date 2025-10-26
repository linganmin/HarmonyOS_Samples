import { textToSpeech } from '@kit.CoreSpeechKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { UuidBasic } from './UuidBasic';
import { promptAction } from '@kit.ArkUI';

const TAG: string = 'TtsDemo';
let ttsEngine: textToSpeech.TextToSpeechEngine;

@Entry
@Component
struct Index {
  @State createCount: number = 0;
  @State result: boolean = false;
  @State voiceInfo: string = "";
  @State text: string = "";
  @State textContent: string = "";
  @State utteranceId: string = "123456";
  @State originalText: string = "\n\t\tThe ancients had no strength in learning, and the young were old and old. \n\t\t"
    + "They finally felt shallow on paper. They knew that this matter had to be done.\n\t\t";
  @State illegalText: string = "";

  build() {
    Column() {
      Scroll() {
        Column() {
          TextArea({ placeholder: 'Please enter tts original text', text: `${this.originalText}` })
            .margin(20)
            .focusable(false)
            .border({ width: 5, color: 0x317AE7, radius: 10, style: BorderStyle.Dotted })
            .onChange((value: string) => {
              this.originalText = value;
              hilog.info(0x0000, TAG, "original text: " + this.originalText);
            })

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
            console.log(`createByCallback：createCount:${this.createCount}`);
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
            console.log(`createByPromise：createCount:${this.createCount}`);
            this.createByPromise();
            promptAction.showToast({
              message: 'CreateEngineByPromise success!',
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
            console.log(`createOfErrorLanguage：createCount:${this.createCount}`);
            this.createOfErrorLanguage();
            promptAction.showToast({
              message: 'createOfErrorLanguage success!',
              duration: 2000
            });
          })

          Button() {
            Text("createOfErrorPerson")
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
            console.log(`createOfErrorPerson：createCount:${this.createCount}`);
            this.createOfErrorPerson();
            promptAction.showToast({
              message: 'createOfErrorPerson success!',
              duration: 2000
            });
          })

          Button() {
            Text("speak")
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
            console.log(`speak：createCount:${this.createCount}`)
            this.speak();
            promptAction.showToast({
              message: 'start speaking',
              duration: 2000
            });
          })

          Button() {
            Text("SpeakIllegalText")
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
            console.log(`illegalSpeak：createCount:${this.createCount}`)
            this.illegalSpeak();
            promptAction.showToast({
              message: 'SpeakIllegalText!',
              duration: 2000
            });
          })

          Button() {
            Text("listVoicesCallback")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.listVoicesCallback();
            promptAction.showToast({
              message: 'listVoicesCallback success!',
              duration: 2000
            });
          })

          Button() {
            Text("listVoicesPromise")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            this.listVoicesPromise();
            promptAction.showToast({
              message: 'listVoicesPromise success!',
              duration: 2000
            });
          })


          Button() {
            Text("stop")
              .fontColor(Color.White)
              .fontSize(20)
          }
          .type(ButtonType.Capsule)
          .backgroundColor("#0x317AE7")
          .width("80%")
          .height(50)
          .margin(10)
          .onClick(() => {
            hilog.info(0x0000, TAG, "isSpeaking click:-->");
            ttsEngine.stop();
            promptAction.showToast({
              message: 'stop!',
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
            hilog.info(0x0000, TAG, "isSpeaking click:-->");
            this.setListener();
            let isBusy: boolean = ttsEngine.isBusy();
            console.log('isBusy :' + isBusy);
            if (isBusy){
              promptAction.showToast({
                message: 'is busy!',
                duration: 2000
              });
            } else {
              promptAction.showToast({
                message: 'not busy',
                duration: 2000
              });
            }
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
            ttsEngine.shutdown();
            promptAction.showToast({
              message: 'shutdown success!',
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

  /*
  Create an engine, which is returned in callback mode
  If the engine does not exist, engine resources do not exist, or initialization times out,
  the error code 1002300005 is returned, indicating that the engine fails to be created
   */

  private createByCallback() {
    // Setting Engine Creation Parameters
    let extraParam: Record<string, Object> = { "style": 'interaction-broadcast', "locate": 'CN', "name": 'EngineName' }
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };
    try {
      // Invoke the createEngine method
      textToSpeech.createEngine(initParamsInfo, (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
        if (!err) {
          console.log('createEngine is success');
          // Receive an instance of the creation engine
          ttsEngine = textToSpeechEngine;
        } else {
          /*
          When an engine fails to be created, the error code 1002300005 is returned.
          The possible causes are as follows: The engine does not exist, the resource does not exist,
          or the engine creation times out.
           */
          console.error("errCode is " + JSON.stringify(err.code));
          console.error("errMessage is " + JSON.stringify(err.message));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`createEngine failed, error code: ${code}, message: ${message}.`)
    }
  }

  // Create an engine, which is returned in promise mode
  private createByPromise() {
    // Setting Engine Creation Parameters
    let extraParam: Record<string, Object> = { "style": 'interaction-broadcast', "locate": 'CN', "name": 'EngineName' }
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      person: 0,
      online: 1,
      extraParams: extraParam
    };

    // Invoke the createEngine method.
    textToSpeech.createEngine(initParamsInfo).then((res: textToSpeech.TextToSpeechEngine) => {
      ttsEngine = res;
      console.log('result:' + JSON.stringify(res));
    }).catch((res: Object) => {
      console.log('result' + JSON.stringify(res));
    });

  }

  /*
  Invoke the speak broadcast method.
  When the speak method is invoked before the engine is initialized,
  the error code 1002300007 is returned, indicating that the synthesis and playback fail.
   */
  private async speak() {
    // Set broadcast-related parameters.
    let extraParam: Record<string, Object> = {
      "queueMode": 0,
      "speed": 1,
      "volume": 2,
      "pitch": 1,
      "languageContext": 'zh-CN',
      "audioType": "pcm",
      "soundChannel": 1,
      "playType": 1
    }
    let speakParams: textToSpeech.SpeakParams = {
      requestId: UuidBasic.createUUID(),
      extraParams: extraParam
    }
    // Setting callbacks
    this.setListener();
    // Invoke the speak broadcast method.
    ttsEngine.speak(this.originalText, speakParams);
  }

  // This interface is used to query the timbre information of a language. The information is returned in callback mode.
  private listVoicesCallback() {
    // Set query-related parameters.
    let voicesQuery: textToSpeech.VoiceQuery = {
      requestId: UuidBasic.createUUID(),
      online: 1
    }

    // Invoke the listVoices method and return it as callback.
    ttsEngine.listVoices(voicesQuery, (err: BusinessError, voiceInfo: textToSpeech.VoiceInfo[]) => {
      if (!err) {
        // Receives information such as the timbre of the currently supported language.
        this.voiceInfo = JSON.stringify(voiceInfo);
        console.log('voiceInfo is ' + JSON.stringify(voiceInfo));
      } else {
        console.error("error is " + JSON.stringify(err));
      }
    });

  };

  // This interface is used to query the timbre information of a language. The information is returned in promise mode.
  private listVoicesPromise() {
    // Set query-related parameters.
    let voicesQuery: textToSpeech.VoiceQuery = {
      requestId: UuidBasic.createUUID(),
      online: 1
    }
    // Invoke the listVoice method.
    ttsEngine.listVoices(voicesQuery).then((res: textToSpeech.VoiceInfo[]) => {
      console.log('voiceInfo:' + JSON.stringify(res));
    }).catch((res: Object) => {
      console.error('error is ' + JSON.stringify(res));
    });
  }

  private setListener() {
    let speakListener: textToSpeech.SpeakListener = {
      // Start broadcast callback
      onStart(utteranceId: string, response: textToSpeech.StartResponse) {
        console.log('speakListener onStart: ' + ' utteranceId: ' + utteranceId + ' response: ' + JSON.stringify(response));
      },
      // Complete broadcast callback
      onComplete(utteranceId: string, response: textToSpeech.CompleteResponse) {
        console.log('speakListener onComplete: ' + ' utteranceId: ' + utteranceId + ' response: ' + JSON.stringify(response));
      },
      // Callback for stopping playback completion. This callback is triggered when the stop method is invoked and completed.
      onStop(utteranceId: string, response: textToSpeech.StopResponse) {
        console.log('speakListener onStop: ' + ' utteranceId: ' + utteranceId + ' response: ' + JSON.stringify(response));
      },
      // Return Audio Stream
      onData(utteranceId: string, audio: ArrayBuffer, response: textToSpeech.SynthesisResponse) {
        console.log('speakListener onData: ' + ' utteranceId: ' + utteranceId + ' sequence: ' + JSON.stringify(response) + ' audio: ' + audio);
      },
      /*
      Error callback. This callback is triggered when an error occurs during playback.
      Error code 1002300007 is returned when the speak method is invoked when no engine is created,
      indicating that synthesis and playback fail.
      Invoke speak twice consecutively. If speak is invoked for the second time,
      the error code 1002300006 is returned, indicating that the service is busy.
       */
      onError(utteranceId: string, errorCode: number, errorMessage: string) {
        console.error('speakListener onError: ' + ' utteranceId: ' + utteranceId + ' errorCode: ' + errorCode + ' errorMessage: ' + errorMessage);
      }
    };
    // Setting callbacks
    ttsEngine.setListener(speakListener);
  }

  // When an engine is created in an unsupported language, the error code 1002300002 is returned,
  // indicating that the language is not supported.
  private createOfErrorLanguage() {
    // Setting Engine Creation Parameters
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      // The language is not supported.
      language: 'ZH-CN',
      person: 0,
      online: 1
    };
    try {
      // Invoke the createEngine method.
      textToSpeech.createEngine(initParamsInfo, (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
        if (!err) {
          console.log('createEngine is success');
          // Receive an instance of the creation engine
          ttsEngine = textToSpeechEngine;
        } else {
          // The error code 1002300002 is returned. The language is not supported.
          console.error("errCode is " + JSON.stringify(err.code));
          console.error("errMessage is " + JSON.stringify(err.message));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`createEngine failed, error code: ${code}, message: ${message}.`)
    }
  }

  // When an engine is created in an unsupported language, the error code 1002300003 is returned,
  // indicating that the timbre is not supported.
  private createOfErrorPerson() {
    // Setting Engine Creation Parameters
    let initParamsInfo: textToSpeech.CreateEngineParams = {
      language: 'zh-CN',
      // Unsupported timbre
      person: 1,
      online: 1
    };
    try {
      // Invoke the createEngine method.
      textToSpeech.createEngine(initParamsInfo, (err: BusinessError, textToSpeechEngine: textToSpeech.TextToSpeechEngine) => {
        if (!err) {
          console.log('createEngine is success');
          // Receive an instance of the creation engine
          ttsEngine = textToSpeechEngine;
        } else {
          // The error code 1002300003 is returned, indicating that the timbre is not supported.
          console.error("errCode is " + JSON.stringify(err.code));
          console.error("errMessage is " + JSON.stringify(err.message));
        }
      });
    } catch (error) {
      let message = (error as BusinessError).message;
      let code = (error as BusinessError).code;
      console.error(`createEngine failed, error code: ${code}, message: ${message}.`)
    }
  }

  // When invalid text is used, the speak broadcast method is invoked, and 1002300001 is returned.
  // The text length is invalid.
  private illegalSpeak() {
    this.setListener();
    // Set broadcast-related parameters.
    let extraParam: Record<string, Object> = { "speed": 1, "volume": 1, "pitch": 1, "audioType": "pcm" }
    let speakParams: textToSpeech.SpeakParams = {
      requestId: UuidBasic.createUUID(),
      extraParams: extraParam
    }
    // Invoke the speak broadcast method.
    ttsEngine.speak(this.illegalText, speakParams);
  }
}
