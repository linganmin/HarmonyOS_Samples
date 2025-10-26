import { common } from '@kit.AbilityKit';
import { ringtone } from '@kit.RingtoneKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUri, picker } from '@kit.CoreFileKit';

@Entry
@Component
struct Index {
  @State isShowUIExtensionCom: boolean = false;
  private prefixUri: string = '';
  private buttonText: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  aboutToAppear(): void {
    const documentViewPicker = new picker.DocumentViewPicker(this.context);
    const documentSaveOptions = new picker.DocumentSaveOptions();
    documentSaveOptions.pickerMode = picker.DocumentPickerMode.DOWNLOAD;
    documentViewPicker.save(documentSaveOptions).then((documentSaveResult: Array<string>) => {
      let savePath = documentSaveResult[0];
      let fileUriObject = new fileUri.FileUri(savePath);
      this.prefixUri = fileUriObject.path
      console.info('documentViewPicker.save succeed and prefixUri is:' + this.prefixUri);
    }).catch((err: BusinessError) => {
      console.error(`Invoke documentViewPicker.save failed, code is ${err.code}, message is ${err.message}`);
    })
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.setting_ringtone'))
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .alignSelf(ItemAlign.Start)
          .margin({
            top: 64,
            left: 12,
            bottom: 16
          })

        TextInput({ placeholder: $r('app.string.please_enter_the_file_name') })
          .width(312)
          .height(40)
          .onChange((value: string) => {
            this.buttonText = value;
          })
      }

      Button($r('app.string.setting_ringtone'))
        .width(312)
        .height(40)
        .margin({
          bottom: 16
        })
        .onClick(async () => {
          if (this.buttonText) {
            let audioPath: string = this.prefixUri + '/' + this.buttonText;
            console.info(`audioPath:${audioPath}`);
            try {
              let fileName: string = audioPath.substring(audioPath.lastIndexOf('/') + 1, audioPath.lastIndexOf('.'));
              console.info(`fileName:${fileName}`);
              await ringtone.startRingtoneSetting(this.context, audioPath, fileName).then(res => {
                console.info(`setFlag : ${res}`);
              });
            } catch (error) {
              let err: BusinessError = error as BusinessError;
              if (err.code === ringtone.RingtoneErrors.ERROR_FILE_NOT_FOUND) {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.file_exist'),
                  duration: 2000
                });
              }
              console.error(`accessSync failed with error. message: ${err.message}, code: ${err.code}`);
            }
          } else {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.please_enter_the_file_name'),
              duration: 2000
            });
          }
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .width('100%')
    .height('100%')
  }
}