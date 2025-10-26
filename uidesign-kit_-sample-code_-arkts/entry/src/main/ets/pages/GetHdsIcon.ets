import { LayeredDrawableDescriptor, DrawableDescriptor, UIContext } from '@kit.ArkUI';
import { hdsDrawable } from '@kit.UIDesignKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';

@Entry
@Component
struct GetHdsIcon {
  bundleName: string = 'com.example.uidesignkit';
  resManager: resourceManager.ResourceManager | undefined = undefined;
  layeredDrawableDescriptor: LayeredDrawableDescriptor | undefined = undefined;
  drawableDescriptor: DrawableDescriptor | undefined = undefined;
  @State iconsResult: Array<hdsDrawable.ProcessedIcon> = [];
  @State iconAsyncResult: image.PixelMap | null = null;

  build() {
    Column() {
      Column() {
        Text('getHdsIcon')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .margin(5)

        Image(this.getHdsIconWithBorder())
          .width(48)
          .height(48)
      }
      .margin({
        top: 20
      })

      Column() {
        Text('getHdsIconAsync')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .margin(5)

        Image(this.iconAsyncResult)
          .width(48)
          .height(48)
      }
      .margin(20)

      Text('getHdsIcons')
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
        .margin(5)

      List() {
        ForEach(this.iconsResult,
          (item: hdsDrawable.ProcessedIcon, index?: number) => {
            ListItem() {
              Column() {
                Text(item.bundleName)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                  .margin(5)

                Image(item.pixelMap)
                  .width(48)
                  .height(48)
              }
              .margin(15)
            }
            .width('100%')
          }, (item: string) => item.toString())
      }
      .scrollBar(BarState.On)
      .height('60%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    this.resManager = this.getUIContext().getHostContext()?.resourceManager;
    if (!this.resManager) {
      return;
    }

    this.layeredDrawableDescriptor = (this.resManager.getDrawableDescriptor($r('app.media.drawable')
      .id)) as LayeredDrawableDescriptor;

    this.drawableDescriptor =
      (this.resManager?.getDrawableDescriptor($r('app.media.normal_icon'))) as DrawableDescriptor;

    this.getHdsIcons();
    this.getHdsIconAsync();
  }

  private getHdsIconWithBorder(): image.PixelMap | null {
    try {
      return hdsDrawable.getHdsIcon(this.bundleName, this.drawableDescriptor?.getPixelMap(), 48,
        this.layeredDrawableDescriptor?.getMask().getPixelMap(), true);
    } catch (err) {
      let message = (err as BusinessError).message;
      let code = (err as BusinessError).code;
      console.error(`getHdsIcon failed, code: ${code}, message: ${message}`);
      return null;
    }
  }

  private getHdsIconAsync(): void {
    try {
      hdsDrawable.getHdsIconAsync(this.bundleName, this.drawableDescriptor?.getPixelMap(), 48,
        this.layeredDrawableDescriptor?.getMask().getPixelMap(), true)
        .then((data: image.PixelMap) => {
          this.iconAsyncResult = data;
        })
        .catch((err: BusinessError) => {
          this.iconAsyncResult = null;
          console.error(`getHdsIconAsync return error, code: ${err.code}, msg: ${err.message}`);
        });
    } catch (err) {
      this.iconAsyncResult = null;
      let message = (err as BusinessError).message;
      let code = (err as BusinessError).code;
      console.error(`getHdsIconAsync failed, code: ${code}, message: ${message}`);
    }
  }

  getHdsIcons(): void {
    if (!this.drawableDescriptor) {
      console.error(`getHdsIcons drawableDescriptor is undefined.`);
      return;
    }

    if (!this.layeredDrawableDescriptor) {
      console.error(`getHdsIcons layeredDrawableDescriptor is undefined.`);
      return;
    }

    let options: hdsDrawable.Options = {
      size: 48,
      hasBorder: true,
      parallelNumber: 4
    };

    let icons: Array<hdsDrawable.Icon> = [];
    for (let i = 0; i < 10; i++) {
      icons.push({
        bundleName: `${this.bundleName}-${i}`,
        pixelMap: this.drawableDescriptor.getPixelMap()
      })
    }

    try {
      hdsDrawable.getHdsIcons(icons, this.layeredDrawableDescriptor.getMask().getPixelMap(), options)
        .then((data: Array<hdsDrawable.ProcessedIcon>) => {
          console.info(`getHdsIcons data size: ${data.length}`);
          this.iconsResult = data;
        })
        .catch((err: BusinessError) => {
          console.error(`getHdsIcons error, code: ${err.code}, msg: ${err.message}`);
        });
    } catch (err) {
      let message = (err as BusinessError).message;
      let code = (err as BusinessError).code;
      console.error(`getHdsIcons callback failed: ${message}, code: ${code}`);
    }
  }
}