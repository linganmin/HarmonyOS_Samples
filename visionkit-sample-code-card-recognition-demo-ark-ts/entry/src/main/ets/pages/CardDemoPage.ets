import { CardRecognition, CallbackParam, CardType } from "@kit.VisionKit"
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG: string = 'CardRecognitionPage'

/**
 * Card identification page, which is used to load uiExtensionAbility.
 *
 * @since 2024-02-27
 */
@Component
export struct CardDemoPage {
  @State cardDataSource: Record<string, string>[] = []
  @Consume('pathStack') pathStack: NavPathStack

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Top }) {
        Stack() {
          this.cardDataShowBuilder()
        }
        .width('80%')
        .height('80%')

        CardRecognition({
          // Here, select the Bank card type as an example.
          supportType: CardType.CARD_BANK,
          callback: ((params: CallbackParam) => {
            hilog.info(0x0001, TAG, `params code: ${params.code}`)
            if (params.code === -1) {
              this.pathStack.pop()
            }
            hilog.info(0x0001, TAG, `params cardType: ${params.cardType}`)
            if (params.cardInfo?.front !== undefined) {
              this.cardDataSource.push(params.cardInfo?.front)
            }

            if (params.cardInfo?.back !== undefined) {
              this.cardDataSource.push(params.cardInfo?.back)
            }

            if (params.cardInfo?.main !== undefined) {
              this.cardDataSource.push(params.cardInfo?.main)
            }
            hilog.info(0x0001, TAG, `params cardInfo front: ${JSON.stringify(params.cardInfo?.front)}`)
            hilog.info(0x0001, TAG, `params cardInfo back: ${JSON.stringify(params.cardInfo?.back)}`)
          })
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .hideTitleBar(true)
  }

  @Builder
  cardDataShowBuilder() {
    List() {
      ForEach(this.cardDataSource, (cardData: Record<string, string>) => {
        ListItem() {
          Column() {
            Image(cardData.uri)
              .objectFit(ImageFit.Contain)
              .width(100)
              .height(100)

            Text(JSON.stringify(cardData))
              .width('100%')
              .fontSize(12)
          }
        }
      })
    }
    .listDirection(Axis.Vertical)
    .alignListItem(ListItemAlign.Center)
    .margin({
      top: 50
    })
    .width('100%')
    .height('100%')
  }
}