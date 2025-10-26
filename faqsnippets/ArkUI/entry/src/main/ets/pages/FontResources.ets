/**
 * FAQ:自定义字体的注册方式是什么，如何从资源存放路径中取出字体资源？
 */
import { font } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  aboutToAppear(): void {
    // [Start set_font]
    this.getUIContext().getFont().registerFont({
      familyName: 'Gealova',
      familySrc: $rawfile('font/gealova.otf')
    })
    // [End set_font]
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
    }
    .height('100%')
    .width('100%')
  }
}