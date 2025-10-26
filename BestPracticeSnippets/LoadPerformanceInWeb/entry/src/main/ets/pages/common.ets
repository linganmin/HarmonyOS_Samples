// [Start page_common]
// Create NodeController
// common.ets
import { UIContext } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { NodeController, BuilderNode, Size, FrameNode } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

// Specific component contents of dynamic components in @Builder
// Data is a parameter encapsulation class.
class Data {
  url: string = 'https://www.example.com';
  controller: WebviewController = new webview.WebviewController();
}

@Builder
function webBuilder(data: Data) {
  Column() {
    Web({ src: data.url, controller: data.controller })
      .domStorageAccess(true)
      .zoomAccess(true)
      .fileAccess(true)
      .mixedMode(MixedMode.All)
      .width('100%')
      .height('100%')
      .onPageEnd((event) => {
        // Output Web page loading completion time
        console.info(`load page end time: ${Date.now()}`);
      })
  }
}

// Used to control and feedback the behavior of nodes on the corresponding NodeContainer, which needs to be used together with NodeContainer
export class MyNodeController extends NodeController {
  private rootNode: BuilderNode<Data[]> | null = null;
  private root: FrameNode | null = null;
  private rootWebviewController: webview.WebviewController | null = null;

  // The method that must be overridden is used to build the number of nodes and return the nodes to be mounted in the corresponding NodeContainer.
  // //Called when the corresponding NodeContainer is created, or refreshed by calling the rebuild method.
  makeNode(uiContext: UIContext): FrameNode | null {
    console.info(' uicontext is undefined : ' + (uiContext === undefined));
    try {
      if (this.rootNode != null) {
        const parent: FrameNode = this.rootNode.getFrameNode()?.getParent() as FrameNode;
        if (parent) {
          console.info(JSON.stringify(parent.getInspectorInfo()));
          parent.removeChild(this.rootNode.getFrameNode());
          this.root = null;
        }
        this.root = new FrameNode(uiContext);
        this.root.appendChild(this.rootNode.getFrameNode());
        // Returns the FrameNode node
        return this.root;
      }
      // Returns a null node that controls the dynamic component to be unbound.
      return null;
    } catch (error) {
      return null;
    }
  }
  
  // Callback when layout size changes.
  aboutToResize(size: Size): void {
    console.info('aboutToResize width : ' + size.width + ' height : ' + size.height);
  }

  // Call back when the NodeContainer corresponding to the controller is in Appear.
  aboutToAppear(): void {
    console.info('aboutToAppear');
  }

  // Call back when the NodeContainer corresponding to the controller is Disappear.
  aboutToDisappear(): void {
    console.info('aboutToDisappear');
  }

  // This function is a user-defined function and can be used as an initialization function.
  // Initialize builderNode through UIContext, and then initialize the contents in @Builder through the Build interface in BuilderNode.
  initWeb(url: string, uiContext: UIContext, control: WebviewController): void {
    if (this.rootNode != null) {
      return;
    }
    // Bind the pre-created WebviewController
    this.rootWebviewController = control;
    // Creating a node requires uiContext.
    this.rootNode = new BuilderNode(uiContext);
    // Create dynamic Web components
    this.rootNode.build(wrapBuilder<Data[]>(webBuilder), { url: url, controller: control });
  }
  
  // This function is a user-defined function and can be used as an initialization function.
  loadUrl(url: string): void {
    if (this.rootWebviewController !== null) {
      try {
        // Reuse the pre-created components and reload the url.
        this.rootWebviewController.loadUrl(url);
      } catch (error) {
        hilog.info(0x0000, 'testTag', '%{public}s', 'loadUrl fail');
      }
    }
  }
}

// Create the NodeController needed for Map saving.
let NodeMap: Map<string, MyNodeController | undefined> = new Map();
// Create WebViewController needed for Map saving.
let controllerMap: Map<string, WebviewController | undefined> = new Map();

// Initialization requires UIContext to be obtained in Ability.
export const createNWeb = (url: string, uiContext: UIContext) => {
  // Create NodeController
  let baseNode: MyNodeController = new MyNodeController();
  let controller: WebviewController = new webview.WebviewController();
  // Initialize a custom web component
  baseNode.initWeb(url, uiContext, controller);
  controllerMap.set(url, controller);
  NodeMap.set(url, baseNode);
};

// Customize to get the NodeController interface.
export const getNWeb = (url: string): MyNodeController | undefined => {
  // When loading a new Url, it is recommended to reuse pre-created Web components.
  if (!NodeMap.get(url) && NodeMap.get('about://blank')) {
    // Get pre-created Web components
    let webNode: MyNodeController = NodeMap.get('about://blank') as MyNodeController;
    // Reload url
    webNode.loadUrl(url);
    return webNode;
  }
  return NodeMap.get(url);
};
// [End page_common]