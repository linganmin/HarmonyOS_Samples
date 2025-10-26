import { image } from "@kit.ImageKit";
import { CommonConstants } from "../common/constants/CommonConstants";

@Component
export struct VideoSnapshotView {
  @Link imgWidth: number;
  @Link imgHeight: number;
  @Link pixmap: image.PixelMap;
  @Link showImg: boolean;
  onPreviousClick: () => void = () => {
  };
  onNextClick: () => void = () => {
  };

  build() {
    Row() {
      Column({ space: 12 }) {
        Image($r('app.media.previousFrame'))
          .width(45)
        Text($r('app.string.previousFrame'))
          .fontSize(14)
          .fontColor(Color.White)
      }
      .onClick(() => {
        this.onPreviousClick();
      })

      Image(this.pixmap)
        .width(this.imgWidth)
        .height(this.imgHeight)
        .visibility(this.showImg ? Visibility.Visible : Visibility.None)
        .onClick(() => {
          this.showImg = false;
          this.imgWidth = 0;
          this.imgHeight = 0;
        })

      Column({ space: 12 }) {
        Image($r('app.media.nextFrame'))
          .width(45)
        Text($r('app.string.nextFrame'))
          .fontSize(14)
          .fontColor(Color.White)
      }
      .onClick(() => {
        this.onNextClick();
      })
    }
    .height(CommonConstants.HEIGHT_FULL_PERCENT)
    .width(CommonConstants.WIDTH_FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .zIndex(999)
  }
}