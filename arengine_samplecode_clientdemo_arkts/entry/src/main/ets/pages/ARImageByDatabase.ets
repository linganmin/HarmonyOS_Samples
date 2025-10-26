/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { arEngine, ARView, arViewController } from '@kit.AREngine';
import {
  CustomGeometry,
  Geometry,
  Image,
  Material,
  MaterialType,
  MeshResource,
  Node,
  PrimitiveTopology,
  Scene,
  SceneResourceFactory,
  Shader,
  ShaderMaterial,
  Vec3
} from '@kit.ArkGraphics3D';
import { Matrix4 } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, ReadOptions } from '@kit.CoreFileKit';
import { Logger } from '../utils/Logger';
import { calculatePoint, createImageIndex, getImageVertices } from '../utils/Utils';

@Builder
export function ARImageByDatabaseBuilder(): void {
  ARImageByDatabase();
}

let dataBase: arEngine.ARAugmentedImageDatabase;

interface Blend {
  enabled: boolean;
}

interface CustomerMaterial extends Material {
  blend: Blend;
}

@Component
struct ARImageByDatabase {
  pageInfos: NavPathStack = new NavPathStack();
  @State arContext?: arViewController.ARViewContext = undefined;
  @State context: Context = this.getUIContext().getHostContext() as Context;

  build() {
    NavDestination() {
      RelativeContainer() {
        if (this.arContext) {
          ARView({ context: this.arContext })
            .height('100%')
            .width('100%')
            .alignRules({
              center: { anchor: '__container__', align: VerticalAlign.Center },
              middle: { anchor: '__container__', align: HorizontalAlign.Center }
            })
        }
      }
    }
    .onAppear(() => {
      arEngine.createARAugmentedImageDatabase()
        .then((arDataBase) => {
          dataBase = arDataBase;

          try {
            let databaseBuffer: ArrayBuffer = ReadBuffer(this.context);
            dataBase.deserialize(databaseBuffer).then(() => {
              this.initARView();
            })
          } catch (error) {
            const err: BusinessError = error as BusinessError;
            Logger.error(`Failed to init context. Code is ${err.code}, message is ${err.message}.`);
            this.ShowDialog(this.context.resourceManager.getStringByNameSync('invalid_image_added'));
          }
        })
    })
    .onWillDisappear(async () => {
      this.stopARView();
    })
    .onShown(() => {
      this.resumeARView();
    })
    .onHidden(() => {
      this.pauseARView();
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  private initARView(): void {
    Scene.load().then(async (scene: Scene) => {
      let viewContext: arViewController.ARViewContext = new arViewController.ARViewContext();
      viewContext.scene = scene;
      viewContext.callback = new ARViewCallbackImpl();
      viewContext.config = {
        type: arEngine.ARType.IMAGE,
        planeFindingMode: arEngine.ARPlaneFindingMode.HORIZONTAL_AND_VERTICAL,
        powerMode: arEngine.ARPowerMode.NORMAL,
        semanticMode: arEngine.ARSemanticMode.NONE,
        poseMode: arEngine.ARPoseMode.GRAVITY,
        depthMode: arEngine.ARDepthMode.AUTOMATIC,
        meshMode: arEngine.ARMeshMode.DISABLED,
        focusMode: arEngine.ARFocusMode.AUTO
      }
      viewContext.init().then(() => {
        this.arContext = viewContext;
        Logger.info('Succeeded in initting ARView.');
      }).catch((err: BusinessError) => {
        Logger.error(`Failed to init ARView. Code is ${err.code}, message is ${err.message}.`);
      })
    })
  }

  private async stopARView(): Promise<void> {
    if (!this.arContext) {
      return;
    }
    try {
      await dataBase.release();
      await this.arContext?.destroy();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to stop context. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private resumeARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.resume();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to resume context. Code is ${err.code}, message is ${err.message}.`);
    }
  }

  private pauseARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.pause();
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to pause context. Code is ${err.code}, message is ${err.message}.`);
    }
  }

  ShowDialog(msg: string): void {
    this.getUIContext().showAlertDialog({
      title: $r('app.string.warning'),
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      transition: TransitionEffect.asymmetric(TransitionEffect.OPACITY
        .animation({ duration: 1000, curve: Curve.Sharp })
        .combine(TransitionEffect.scale({ x: 1.5, y: 1.5 })
          .animation({ duration: 1000, curve: Curve.Sharp })),
        TransitionEffect.OPACITY.animation({ duration: 100, curve: Curve.Smooth })
          .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })
            .animation({ duration: 100, curve: Curve.Smooth }))),
      buttons: [{
        enabled: true,
        defaultFocus: true,
        style: DialogButtonStyle.HIGHLIGHT,
        value: $r('app.string.back'),
        action: () => {
          Logger.info('Callback when the second button is clicked.');
          this.pageInfos.pop();
          return;
        }
      }]
    })
  }
}

// Read local files into buffer
function ReadBuffer(context: Context): ArrayBuffer {
  let filesDir: string = context.filesDir;
  let srcFile: fileIo.File = fileIo.openSync(
    filesDir + '/test.bin', fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
  const fileStat: fileIo.Stat = fileIo.statSync(srcFile.fd);
  // Read the contents of the source file and write it to the destination file
  let readSize: number = 0;
  let buf: ArrayBuffer = new ArrayBuffer(fileStat.size);
  let readOptions: ReadOptions = {
    offset: readSize,
    length: fileStat.size
  }
  let readLen: number = fileIo.readSync(srcFile.fd, buf, readOptions);
  Logger.info(`The length of buffer is: ${readLen}.`);
  fileIo.closeSync(srcFile);
  return buf;
}

class ARViewCallbackImpl extends arViewController.ARViewCallback {
  geoArr: Geometry[] = [];
  scene: Scene | null = null;
  shader: Shader | null = null;
  material: ShaderMaterial | null = null;
  image: Image | null = null;
  currentGeometry: Geometry | undefined = undefined;

  clearAllNode(): void {
    let childrenNum: number | undefined = this.scene?.root?.children.count();
    if (childrenNum) {
      for (let i = 0; i < childrenNum; i++) {
        let node: Node | null | undefined = this.scene?.root?.children.get(i);
        if (node?.name === 'ARImage') {
          this.scene?.root?.children.remove(node);
          node?.destroy();
        }
      }
    }
  }

  onAnchorAdd(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  onAnchorUpdate(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  async onFrameUpdate(ctx: arViewController.ARViewContext, sysBootTs: number): Promise<void> {
    if (!ctx.session || !dataBase) {
      return;
    }

    let session: arEngine.ARSession = ctx.session;
    this.scene = ctx.scene;

    try {
      let imageNumber: number = dataBase.getImageCount();
      Logger.info(`The number of images in the database is ${imageNumber}.`);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to got image count. Code is ${err.code}, message is ${err.message}.`);
    }

    let imageCapacity: number = dataBase.getCapacity();
    Logger.info(`The dataBase image capacity = ${imageCapacity}.`);

    let trackables: arEngine.ARTrackable[] = session.getAllTrackables(arEngine.ARTrackableType.AUGMENTED_IMAGE);

    // The target image color is controlled by the file plane.shader
    let rf: SceneResourceFactory = ctx.scene.getResourceFactory();
    this.material = await rf.createMaterial({ name: 'CustomMaterial' }, MaterialType.SHADER);
    this.shader = await rf.createShader({ name: 'CustomShader', uri: $rawfile('shaders/custom_shader/plane.shader') });
    this.material.colorShader = this.shader;
    (this.material as CustomerMaterial).blend = { enabled: true };

    Logger.info(`The image trackable size: ${trackables.length}.`);
    let validImage: number = 0;
    for (let i = 0; i < trackables.length; ++i) {
      if (trackables[i].type === arEngine.ARTrackableType.AUGMENTED_IMAGE) {
        let arimage: arEngine.ARAugmentedImage = trackables[i] as arEngine.ARAugmentedImage;
        if (arEngine.ARTrackingState.TRACKING !== arimage.state) {
          continue;
        }
        validImage++;
        let centerPose: arEngine.ARPose = arimage.getPose();
        let modelMat: Matrix4 = centerPose.getMatrix();
        let pos: Vec3 = centerPose.translation;
        let drawPos: number[] = calculatePoint(arimage.extendX, arimage.extendZ, pos);

        Logger.info(`The image width: ${arimage.extendX}, height: ${arimage.extendZ}.`);

        if (ctx?.scene) {
          let mesh: CustomGeometry = new CustomGeometry();
          mesh.topology = PrimitiveTopology.TRIANGLE_LIST;
          mesh.vertices = getImageVertices(modelMat, drawPos);
          mesh.indices = createImageIndex(mesh.vertices);

          let meshRes: MeshResource = await rf.createMesh({ name: 'resource' }, mesh);
          let geometry: Geometry = await rf.createGeometry({ name: 'ARImage' }, meshRes);
          meshRes.destroy();
          let len: number = this.geoArr.length;

          // The node from the previous frame needs to be cleared
          for (let index = len - 1; index >= 0; index--) {
            let geo: Geometry | undefined = this.geoArr.pop();
            if (geo) {
              ctx.scene.root?.children.remove(geo);
              geo.destroy();
            }
          }

          // Adding a Plane to a Node
          ctx.scene?.root?.children.append(geometry);
          this.geoArr.push(geometry);
          this.currentGeometry = geometry;
          this.currentGeometry.mesh.materialOverride = this.material as ShaderMaterial;
        }
      }
    }
    if (validImage === 0) {
      // Clean up all ARImage nodes
      this.clearAllNode();
    }
  }
}
