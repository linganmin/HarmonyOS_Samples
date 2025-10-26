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

import { Matrix4 } from '@kit.ArkUI';
import { Vec3 } from '@kit.ArkGraphics3D';
import { abilityAccessCtrl } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

export function arrayBufferFloat32ToNumber(buffer: ArrayBuffer): number[] {
  let view: Float32Array = new Float32Array(buffer);
  let numberArray: number[] = Array.from(view);
  return numberArray;
}

export function arrayBufferInt32ToNumber(buffer: ArrayBuffer): number[] {
  let view: Int32Array = new Int32Array(buffer);
  let numberArray: number[] = Array.from(view);
  return numberArray;
}

/*
The mat is arranged in vertical columns and the point corresponds to (x, 0, z, 1)
 */
export function getVertices(mat: Matrix4, point: number[]): Vec3[] {
  let result: Vec3[] = [];
  for (let i = 0; i < point.length; i += 2) {
    let single: Vec3 = {
      x: (mat[2] * point[i] + mat[6] * 0
        + mat[10] * point[i + 1] + mat[14] * 1.0),
      y: mat[1] * point[i] + mat[5] * 0
        + mat[9] * point[i + 1] + mat[13] * 1.0,
      z: -(mat[0] * point[i] + mat[4] * 0
        + mat[8] * point[i + 1] + mat[12] * 1.0),
    }
    result.push(single);
  }
  return result;
}

export function getImageVertices(mat: Matrix4, point: number[]): Vec3[] {
  let result: Vec3[] = [];
  for (let i = 2; i < point.length; i += 2) {
    let single: Vec3 = {
      x: (mat[2] * point[i] + mat[6] * 0
        + mat[10] * point[i + 1] + mat[14] * 1.0),
      y: mat[1] * point[i] + mat[5] * 0
        + mat[9] * point[i + 1] + mat[13] * 1.0,
      z: -(mat[0] * point[i] + mat[4] * 0
        + mat[8] * point[i + 1] + mat[12] * 1.0),
    }
    result.push(single);
  }
  return result;
}

export function createIndex(array: Vec3[]): number[] {
  let result: number[] = [];
  if (!array) {
    return result;
  }
  for (let i = 1; i < array.length - 1; ++i) {
    result.push(0);
    result.push(i);
    result.push(i + 1);
  }
  return result;
}

export function createImageIndex(array: Vec3[]): number[] {
  let result: number[] = [];
  if (!array) {
    return result;
  }
  result.push(0, 1, 2);
  result.push(0, 2, 3);
  return result;
}

export function convertSemanticLabel(obj: number): string {
  let res: string = '';
  if (obj === 0) {
    res = 'UNKNOWN';
  } else if (obj === 1) {
    res = 'WALL';
  } else if (obj === 2) {
    res = 'FLOOR';
  } else if (obj === 3) {
    res = 'SEAT';
  } else if (obj === 4) {
    res = 'TABLE';
  } else if (obj === 5) {
    res = 'CEILING';
  } else if (obj === 6) {
    res = 'DOOR';
  } else if (obj === 7) {
    res = 'WINDOW';
  } else if (obj === 8) {
    res = 'BED';
  }
  return res;
}

/*
Export five positions of plane, corresponding to the center, upper right, lower right, lower left, and upper left
 */
export function calculatePoint(eventX: number, eventZ: number, pos: Vec3): number[] {
  let result: number[] = [];
  result.push(pos.x, pos.y, 0.5 * eventX, 0.5 * eventZ, 0.5 * eventX,
    -0.5 * eventZ, -0.5 * eventX, -0.5 * eventZ, -0.5 * eventX, 0.5 * eventZ);
  return result;
}

export function generateMeshInput(vex: Vec3[][]): Vec3[] {
  let result: Vec3[] = [];
  for (let i = 0; i < vex.length; i++) {
    let tmp: Vec3[] = vex[i];
    for (let j = 0; j < tmp.length; j++) {
      result.push(tmp[j]);
    }
  }
  return result;
}

/*
Create the meshIndex of ARWorld
Since the plane is made of triangles spliced together
Therefore, the first vertex index of each triangle on each plane is the same
 */
export function generateMeshIndex(input: Vec3[][]): number[] {
  let result: number[] = [];
  let start: number = 0;

  for (let i = 0; i < input.length; i++) {
    let len: number = input[i].length;

    for (let j = start + 1; j < start + len - 1; j++) {
      result.push(start);
      result.push(j);
      result.push(j + 1);
    }
    start += len;
  }
  return result;
}

/*
Turn the AR Engine coordinate system to the AGP coordinate system.
The process of conversion is to rotate 90 degrees around the Y axis.
 */
export function arrayToVec3(array: number[]): Vec3[] {
  let result: Vec3[] = [];
  if (!array) {
    return result;
  }

  for (let i = 0; i < array.length; i += 3) {
    let single: Vec3 = {
      x: array[i],
      y: array[i + 1],
      z: array[i + 2]
    }
    result.push(single);
  }
  return result;
}

export async function requestPermissionOnSetting(context: Context): Promise<boolean> {
  let requestResult: boolean = false;
  let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  await atManager.requestPermissionOnSetting(context, ['ohos.permission.CAMERA'])
    .then((data: abilityAccessCtrl.GrantStatus[]) => {
      Logger.info('data:' + JSON.stringify(data));
      if (data[0] === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
        requestResult = true;
      }
    })
    .catch((err: BusinessError) => {
      Logger.error('data:' + JSON.stringify(err));
    })
  return requestResult;
}
