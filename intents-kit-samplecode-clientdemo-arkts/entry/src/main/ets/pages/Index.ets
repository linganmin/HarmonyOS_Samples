import { InsightIntentSharer } from '../utils/InsightIntentSharer';
import { Logger } from '../utils/Logger';

const TAG: string = 'Index';
let storage: LocalStorage = LocalStorage.getShared();

@Entry(storage)
@Component
struct Index {
  @LocalStorageProp('result') want: string = 'wait result';
  @State result: string = this.want;
  @State input: string = '';

  build() {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center
    }) {
      Column() {
        Text('InsightIntent Test')
          .fontSize('24fp')
          .fontWeight(FontWeight.Bold)
          .maxLines(1)
      }
      .width('100%')
      .height('5%')

      TextArea({
        placeholder: `Tap Obtain xx or enter relevant data, and tap a function button.`,
        text: this.input
      })
        .onChange((value: string) => this.input = value)
        .width('100%')
        .textAlign(TextAlign.Start)
        .width('100%')
        .height('45%')
        .border({
          radius: '4vp'
        })

      Row() {
        Button() {
          Text('Obtain insightIntents')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'refreshShareIntentMessage onclick');
          let str: string = await InsightIntentSharer.refreshShareIntentMessage(this.getUIContext().getHostContext()!);
          this.input = str;
        })

        Button() {
          Text('shareIntent')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'shareIntent onclick');
          this.result = await InsightIntentSharer.shareIntent(this.getUIContext().getHostContext()!, this.input);
        })
      }
      .width('100%')
      .height('5%')
      .margin({
        top: '4vp',
        bottom: '4vp'
      })

      Row() {
        Button() {
          Text('Obtain deleteIntent')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'refreshDeleteIntentMessage onclick');
          let str: string = await InsightIntentSharer.refreshDeleteIntentMessage(this.getUIContext().getHostContext()!);
          this.input = str;
        })

        Button() {
          Text('deleteIntent')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'deleteIntent onclick');
          this.result = await InsightIntentSharer.deleteIntent(this.getUIContext().getHostContext()!, this.input);
        })
      }
      .width('100%')
      .height('5%')
      .margin({
        top: '4vp',
        bottom: '4vp'
      })

      Row() {
        Button() {
          Text('Obtain deleteEntity')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'refreshDeleteEntityMessage onclick');
          let str: string = await InsightIntentSharer.refreshDeleteEntityMessage(this.getUIContext().getHostContext()!);
          this.input = str;
        })

        Button() {
          Text('deleteEntity')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'deleteEntity onclick');
          this.result = await InsightIntentSharer.deleteEntity(this.getUIContext().getHostContext()!, this.input);
        })
      }
      .width('100%')
      .height('5%')
      .margin({
        top: '4vp',
        bottom: '4vp'
      })

      Row() {
        Button() {
          Text('getSid')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'getSid onclick');
          this.result = await InsightIntentSharer.getSid(this.getUIContext().getHostContext()!);
        })

        Button() {
          Text('getSidRenew')
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .maxFontSize(15)
            .minFontSize(9)
        }
        .type(ButtonType.Capsule)
        .layoutWeight(1)
        .height('100%')
        .margin({
          left: '4vp',
          right: '4vp'
        })
        .backgroundColor('#0ddffb')
        .onClick(async () => {
          Logger.info(TAG, 'getSidRenew onclick');
          this.result = await InsightIntentSharer.getSidRenew(this.getUIContext().getHostContext()!);
        })
      }
      .width('100%')
      .height('5%')
      .margin({
        top: '4vp',
        bottom: '4vp'
      })

      Column() {
        Text('Result:')
          .fontSize('16fp')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)
          .width('100%')

        Text(this.result)
          .fontSize('16fp')
          .fontWeight(FontWeight.Regular)
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .height('40%')
      .width('100%')
      .margin({
        top: '8vp',
        bottom: '8vp'
      })
    }
    .margin({
      top: '8vp',
      bottom: '8vp',
      left: '20vp',
      right: '20vp'
    })
  }
}
