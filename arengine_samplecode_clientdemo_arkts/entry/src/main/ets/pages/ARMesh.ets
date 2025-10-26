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
  CubeGeometry,
  CustomGeometry,
  Geometry,
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
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from '../utils/Logger';
import { arrayBufferFloat32ToNumber, arrayBufferInt32ToNumber, arrayToVec3 } from '../utils/Utils';

@Builder
export function ARMeshBuilder(): void {
  ARMesh();
}

let frame: arEngine.ARFrame;
let statusBarHeight: number = 0;
let isDisplayCube: boolean = false;
let isStopFrameUpdate: boolean = false;
let hitPoseList: Vec3[] = [];
let planeVertices: number[] = [];
let vertexNormals: number[] = [];
let triangleIndices: number[] = [];
let planeGeoArr: Geometry[] = [];
let cubeGeoArr: Geometry[] = [];
let hitAnchorList: arEngine.ARAnchor[] = [];

interface Blend {
  enabled: boolean;
}

interface CustomerMaterial extends Material {
  blend: Blend;
}

@Component
struct ARMesh {
  @State arContext?: arViewController.ARViewContext = undefined;
  @State context: Context = this.getUIContext().getHostContext() as Context;

  build(): void {
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
            .onClick((event) => {
              this.objectCollisionDetection(event);
            })
        }
      }
    }
    .onAppear(() => {
      this.initARView();
      this.getAvoidArea();
    })
    .onWillDisappear(() => {
      this.stopARView();
    })
    .onShown(() => {
      this.resumeARView();
    })
    .onHidden(() => {
      this.pauseARView();
    })
    .hideTitleBar(true)
    .hideBackButton(true)
    .hideToolBar(true)
  }

  private objectCollisionDetection(event: ClickEvent): void {
    let x: number = this.getUIContext().vp2px(event.windowX);
    let y: number = this.getUIContext().vp2px(event.windowY) - statusBarHeight;
    Logger.info(`Get onclick position, x: ${x} y: ${y}.`);

    try {
      let result: arEngine.ARHitResult[] = frame.hitTest(x, y);
      Logger.info(`The hitresult size is: ${result.length}.`);
      if (!result) {
        return;
      }

      for (let i = 0; i < result.length; i++) {
        let hitResult: arEngine.ARHitResult = result[i];
        let distance: number = hitResult.distance;
        Logger.info(`The hitresult distance is: ${distance}.`);

        if (distance <= 0) {
          continue;
        }

        let hitAnchor: arEngine.ARAnchor = hitResult.createAnchor();
        let pos: Vec3 = hitAnchor.getPose().translation;

        hitPoseList.push(pos);
        hitAnchorList.push(hitAnchor);

        if (hitPoseList.length > 10) {
          hitPoseList.splice(0, 1);
          hitAnchorList.splice(0, 1);
        }
      }
      Logger.info('Succeeded in getting hit result.');
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to get hitResults. Code is ${err.code}, message is ${err.message}`);
    }
  }

  private initARView(): void {
    Scene.load().then(async (scene: Scene) => {
      let viewContext: arViewController.ARViewContext = new arViewController.ARViewContext();
      viewContext.scene = scene;
      viewContext.callback = new ARViewCallbackImpl();
      viewContext.config = {
        type: arEngine.ARType.WORLD,
        planeFindingMode: arEngine.ARPlaneFindingMode.HORIZONTAL_AND_VERTICAL,
        powerMode: arEngine.ARPowerMode.NORMAL,
        semanticMode: arEngine.ARSemanticMode.NONE,
        poseMode: arEngine.ARPoseMode.GRAVITY,
        depthMode: arEngine.ARDepthMode.AUTOMATIC,
        meshMode: arEngine.ARMeshMode.ENABLE,
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

  private getAvoidArea(): void {
    let avoidAreaType: window.AvoidAreaType = window.AvoidAreaType.TYPE_SYSTEM;
    window.getLastWindow(this.context).then((data) => {
      // Get the top status bar height
      let avoidArea1: window.AvoidArea = data.getWindowAvoidArea(avoidAreaType);
      statusBarHeight = avoidArea1.topRect.height;
      Logger.info(`The statusBarHeight is ${statusBarHeight}.`);
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to obtain the window. Code is ${err.code}, message is ${err.message}.`);
    })
  }

  private stopARView(): void {
    if (!this.arContext) {
      return;
    }
    try {
      this.arContext.destroy();
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
      isStopFrameUpdate = false;
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
      isStopFrameUpdate = true;
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to pause context. Code is ${err.code}, message is ${err.message}.`);
    }
  }
}

class ARViewCallbackImpl extends arViewController.ARViewCallback {
  private nodeKey: number = 0;
  scene: Scene | null = null;
  shader: Shader | null = null;
  material: ShaderMaterial | null = null;

  onAnchorAdd(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  onAnchorUpdate(ctx: arViewController.ARViewContext, node: Node, anchor: arEngine.ARAnchor): void {
  }

  async onFrameUpdate(ctx: arViewController.ARViewContext, sysBootTs: number): Promise<void> {
    if (!ctx.session) {
      return;
    }

    let session: arEngine.ARSession | undefined = ctx.session;

    // The mesh color is controlled by the file mesh.shader
    let rf: SceneResourceFactory = ctx.scene.getResourceFactory();
    this.material = await rf.createMaterial({ name: 'CustomMaterial' }, MaterialType.SHADER);
    this.shader = await rf.createShader({ name: 'CustomShader', uri: $rawfile('shaders/custom_shader/mesh.shader') });
    this.material.colorShader = this.shader;
    (this.material as CustomerMaterial).blend = { enabled: true };

    try {
      frame = session.getFrame();
      let camera: arEngine.ARCamera = frame.getCamera();

      if (camera.state === arEngine.ARTrackingState.TRACKING) {
        planeVertices = arrayBufferFloat32ToNumber(frame.acquireSceneMesh().getVertices());
        triangleIndices = arrayBufferInt32ToNumber(frame.acquireSceneMesh().getTriangleIndices());
        vertexNormals = arrayBufferFloat32ToNumber(frame.acquireSceneMesh().getVertexNormals());
        isDisplayCube = true;
      } else {
        planeVertices = [];
        triangleIndices = [];
        vertexNormals = [];
        isDisplayCube = false;
      }

      // Draw Mesh
      let geometry: Geometry | null = null;
      if (ctx.scene && !isStopFrameUpdate && planeVertices.length > 0) {
        let mesh: CustomGeometry = new CustomGeometry();
        mesh.topology = PrimitiveTopology.TRIANGLE_LIST;
        mesh.vertices = arrayToVec3(planeVertices);
        mesh.indices = triangleIndices;
        mesh.normals = arrayToVec3(vertexNormals);

        let meshRes: MeshResource = await rf.createMesh({ name: 'resource' }, mesh);
        geometry = await rf.createGeometry({ name: 'mesh' }, meshRes);
        meshRes.destroy();

        geometry.mesh.materialOverride = this.material as ShaderMaterial;
      }

      // The node from the previous frame needs to be cleared
      if (ctx?.scene) {
        // mesh
        let len: number = planeGeoArr.length;
        for (let index = len - 1; index >= 0; index--) {
          let geo: Geometry = planeGeoArr[index];
          ctx.scene.root?.children.remove(geo);
          geo.destroy();
          planeGeoArr.splice(index, 1);
        }

        // cube
        len = cubeGeoArr.length;
        for (let index = len - 1; index >= 0; index--) {
          let geo: Geometry = cubeGeoArr[index];

          // Limit the scene to display up to 10 cubes
          if (this.nodeKey > 10 && geo?.name === (`cube_${this.nodeKey - 11}`)) {
            ctx.scene.root?.children.remove(geo);
            geo.destroy();
            cubeGeoArr.splice(index, 1);
            hitAnchorList.splice(0, 1);
            continue;
          }

          // Control cube display and hidden
          if (isDisplayCube && !geo.visible && !isStopFrameUpdate &&
            hitAnchorList[index].trackingState === arEngine.ARTrackingState.TRACKING) {
            geo.visible = true;
          }
          if ((!isDisplayCube || isStopFrameUpdate ||
            hitAnchorList[index].trackingState !== arEngine.ARTrackingState.TRACKING) && geo.visible) {
            geo.visible = false;
          }
        }
      }

      // Adding a Plane to a Node
      if (geometry) {
        ctx.scene?.root?.children.append(geometry);
        planeGeoArr.push(geometry);
      }

      // Draw Cube and Adding to a Node
      let pos: Vec3 | undefined = hitPoseList.pop();
      if (!pos) {
        return;
      }

      // Create a cube at the point of hit
      let cubeGeom: CubeGeometry = new CubeGeometry();
      cubeGeom.size = { x: 0.1, y: 0.1, z: 0.1 };
      let meshRes: MeshResource = await rf.createMesh({ name: 'resource name not used at the moment' }, cubeGeom);
      let cubeGeometry: Geometry = await rf.createGeometry({ name: 'cuubio' + this.nodeKey }, meshRes);
      this.nodeKey += 1;
      this.scene?.root?.children.append(cubeGeometry);
      cubeGeoArr.push(cubeGeometry);

      cubeGeometry.visible = isDisplayCube;
      cubeGeometry.position.x = pos.z;
      cubeGeometry.position.y = pos.y;
      cubeGeometry.position.z = -pos.x;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to acquire depth information. Code is ${err.code}, message is ${err.message}.`);
    }
  }
}
