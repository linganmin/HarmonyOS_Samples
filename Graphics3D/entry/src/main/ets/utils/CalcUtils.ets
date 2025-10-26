/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { Vec3, Quaternion, Node } from '@kit.ArkGraphics3D';

export class CalcUtils {
  static sub(l: Vec3, r: Vec3): Vec3 {
    return { x: l.x - r.x, y: l.y - r.y, z: l.z - r.z };
  }

  static dot(l: Vec3, r: Vec3): number {
    return l.x * r.x + l.y * r.y + r.z * l.z;
  }

  static normalize(l: Vec3): Vec3 {
    let d = Math.sqrt(CalcUtils.dot(l, l));
    return { x: l.x / d, y: l.y / d, z: l.z / d };
  }

  static cross(l: Vec3, r: Vec3): Vec3 {
    return { x: (l.y * r.z - l.z * r.y), y: (l.z * r.x - l.x * r.z), z: (l.x * r.y - l.y * r.x) };
  }

  static mul(l: Quaternion, d: number): Quaternion {
    return {
      x: l.x * d,
      y: l.y * d,
      z: l.z * d,
      w: l.w * d
    };
  }

  static lookAt(cam: Node, eye: Vec3, center: Vec3, up: Vec3) {
    let t: number;
    let q: Quaternion = {
      x: 0.0,
      y: 0.0,
      z: 0.0,
      w: 0.0
    };
    let f = CalcUtils.normalize(CalcUtils.sub(center, eye));
    let m0 = CalcUtils.normalize(CalcUtils.cross(f, up));
    let m1 = CalcUtils.cross(m0, f);
    let m2: Vec3 = { x: -f.x, y: -f.y, z: -f.z };
    if (m2.z < 0) {
      if (m0.x > m1.y) {
        t = 1.0 + m0.x - m1.y - m2.z;
        q = {
          x: t,
          y: m0.y + m1.x,
          z: m2.x + m0.z,
          w: m1.z - m2.y
        };
      } else {
        t = 1.0 - m0.x + m1.y - m2.z;
        q = {
          x: m0.y + m1.x,
          y: t,
          z: m1.z + m2.y,
          w: m2.x - m0.z
        };
      }
    } else {
      if (m0.x < -m1.y) {
        t = 1.0 - m0.x - m1.y + m2.z;
        q = {
          x: m2.x + m0.z,
          y: m1.z + m2.y,
          z: t,
          w: m0.y - m1.x
        };
      } else {
        t = 1.0 + m0.x + m1.y + m2.z;
        q = {
          x: m1.z - m2.y,
          y: m2.x - m0.z,
          z: m0.y - m1.x,
          w: t
        };
      }
    }
    cam.position = eye;
    cam.rotation = CalcUtils.mul(q, 0.5 / Math.sqrt(t));
  }

  static genRandom(): number {
    return Math.random() * 2 - 1;
  }
}