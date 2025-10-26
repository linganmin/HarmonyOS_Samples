import { common, OpenLinkOptions, Want } from '@kit.AbilityKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import Logger from '../utils/Logger';

let logger = Logger.getLogger('[ShareUIPage]');

@Entry
@Component
struct SystemShare {
  localStorage = this.getUIContext().getSharedLocalStorage();

  @State message: ResourceStr = $r('app.string.target_app');
  @State textContent: string = '';
  @State htmlLink: string = '';
  @State imageUri: string = '';
  @State videoUri: string = '';
  @State pixelMap: image.PixelMap | null = null;
  private want: Want | undefined = this.localStorage?.get<Want>('ShareUIAbilityWant');

  aboutToAppear(): void {
    systemShare.getSharedData(this.want).then((data: systemShare.SharedData) => {
      let records: systemShare.SharedRecord[] = data.getRecords();
      records.forEach(async (record: systemShare.SharedRecord) => {
        switch (record.utd) {
          case utd.UniformDataType.TEXT:
            record.content && (this.textContent = record.content);
            break;
          case utd.UniformDataType.HYPERLINK:
            record.content && (this.htmlLink = record.content);
            break;
          default:
            break;
        }
      });
    }).catch((error: BusinessError) => {
      logger.error(`getSharedData error. Code: ${error?.code}, message: ${error?.message}`);
    });
  }

  @Builder
  ShareContent() {
    Text($r('app.string.share_content'))
      .fontSize(28)
      .margin({ top: 20 })

    if (this.textContent) {
      Text(this.textContent)
        .fontSize(20)
        .margin({ top: 20 })
    }

    if (this.htmlLink) {
      Text(this.htmlLink)
        .fontSize(20)
        .margin({ top: 20 })
        .onClick(() => {
          const uiContext: UIContext = this.getUIContext();
          const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
          let openLinkOptions: OpenLinkOptions = {
            appLinkingOnly: false
          };
          context.openLink(this.htmlLink, openLinkOptions)
            .then(() => {
              logger.info('open link success.');
            }).catch((err: BusinessError) => {
              logger.error(`open link failed. Code is ${err.code}, message is ${err.message}`);
            })
        })
    }

    if (this.imageUri) {
      Image(this.imageUri)
        .width(200)
        .height(200)
    }

    if (this.videoUri) {
      Video({
        src: this.videoUri,
        previewUri: this.pixelMap
      })
        .width(200)
        .height(200)
    }
  }

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)

        this.ShareContent();

        Button() {
          Text($r('app.string.action_back'))
            .fontSize(25)
            .fontColor($r('sys.color.comp_background_list_card'))
            .fontWeight(FontWeight.Bold)
        }
        .type(ButtonType.Capsule)
        .margin({ top: 20 })
        .backgroundColor('#0D9FFB')
        .width('40%')
        .height('5%')
        .onClick(() => {
          const uiContext: UIContext = this.getUIContext();
          const context: common.UIAbilityContext = uiContext.getHostContext() as common.UIAbilityContext;
          context.terminateSelf().catch((error: BusinessError) => {
            logger.error(`context.terminateSelf error. Code: ${error?.code}, message: ${error?.message}`);
          })
        })
      }
      .width('100%')
    }
    .height('100%')
  }
}