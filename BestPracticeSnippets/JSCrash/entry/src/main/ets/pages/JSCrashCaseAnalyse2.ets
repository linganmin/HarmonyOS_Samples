/**
 * 最佳实践：JSCrash问题案例分析
 */

import { hidebug } from '@kit.PerformanceAnalysisKit';

// 添加SCBSceneContainerSession类型定义
interface NeedRenderTranslate {
  translateY: number;
}

interface SCBSceneContainerSession {
  needRenderTranslate: NeedRenderTranslate;
}

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State translationUpY: number = 0;
  @State translationDownY: number = 0;
  @State screenWidth: number = 0;
  @State recentScale: number = 0;
  @State multiCardsNum: number = 0;

  // [Start updateGestureValue2]
  // Update the attributes related to manual effects
  public updateGestureValue(screenWidth: number, recentScale: number,
    sceneContainerSessionList: SCBSceneContainerSession[]): void {
    // Calculation of the distance moved by the hand
    this.translationUpY = (this.multiCardsNum >= 1) ?
    sceneContainerSessionList[this.multiCardsNum - 1]?.needRenderTranslate.translateY : 0;
    this.translationDownY = (this.multiCardsNum >= 2) ?
    sceneContainerSessionList[this.multiCardsNum - 2]?.needRenderTranslate.translateY : 0;
    this.screenWidth = this.getUIContext().px2vp(screenWidth);
    this.recentScale = recentScale;
  }
  // [End updateGestureValue2]

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(()=>{
          hidebug.getPss();
          throw new Error("TEST JS ERROR")
        })

    }
    .height('100%')
    .width('100%')
  }
}