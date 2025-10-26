// [Start segment4_start]
// [StartExclude segment4_start]
import { BuilderNode, FrameNode, NodeController } from '@kit.ArkUI';

class Params {
  text: string = 'Hello World';

  constructor(text: string) {
    this.text = text;
  }
}

@Builder
function testBuilder(params: Params) {
  Column() {
    Text(params.text)
      .fontSize(50)
      .fontWeight(FontWeight.Bold)
      .margin({ bottom: 36 })
  }
}

class TextNodeController extends NodeController {
  private textNode: BuilderNode<[Params]> | null = null;
  private message: string = '';

  constructor(message: string) {
    super();
    this.message = message;
  }

  makeNode(context: UIContext): FrameNode | null {
    // Creating a BuilderNode instance
    this.textNode = new BuilderNode(context);
    // Set the selfIdealSize property
    // this.textNode = new BuilderNode(context, {selfIdealSize: {width: 100, height :100}});
    // Build the component tree using the build method
    this.textNode.build(wrapBuilder<[Params]>(testBuilder), new Params(this.message));
    // Returns the node to be displayed
    return this.textNode.getFrameNode();
  }
}
// [EndExclude segment4_start]
@Entry
@Component
struct Index {
  @State message: string = "hello";
  @State isShow: boolean = true;
  private textNodeController: TextNodeController = new TextNodeController(this.message);

  build() {
    Row() {
      Column() {
        if (this.isShow) {
          NodeContainer(this.textNodeController)
            .width('100%')
            .height(100)
            .backgroundColor('#FFF0F0F0')
        }
        Button('isShow')
          .onClick(() => {
            this.isShow = false;
          })
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
  }
}
// [End segment4_start]