// [Start segment6_start]
// [StartExclude segment6_start]
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
  replaceBuilderNode(arg0: BuilderNode<[Params]>) {
    throw new Error('Method not implemented.');
  }

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
// [EndExclude segment6_start]
@Entry
@Component
struct Index {
  @State message: string = "hello";
  @State isShow: boolean = true;
  private textNodeController: TextNodeController = new TextNodeController(this.message);
  // private count = 0;

  build() {
    Row() {
      Column() {
        if (this.isShow) {
          NodeContainer(this.textNodeController)
            .width('100%')
            .height(100)
            .backgroundColor('#FFF0F0F0')
        }
        Button('replaceNode')
          .onClick(() => {
            this.textNodeController.replaceBuilderNode(this.buildNewNode());
          })
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
  }

  buildNewNode(): BuilderNode<[Params]> {
    let uiContext: UIContext = this.getUIContext();
    let message = 'newNode';
    let textNode = new BuilderNode<[Params]>(uiContext);
    textNode.build(wrapBuilder<[Params]>(testBuilder), new Params(message))
    return textNode;
  }
}
// [End segment6_start]