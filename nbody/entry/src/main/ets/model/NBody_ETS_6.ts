/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import Constants from '../utils/Constants';

/**
 * Class Body
 */
class Body {
  x: number;
  y: number;
  z: number;
  vx: number;
  vy: number;
  vz: number;
  mass: number;

  constructor(x: number, y: number, z: number, vx: number, vy: number, vz: number, mass: number) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.vx = vx;
    this.vy = vy;
    this.vz = vz;
    this.mass = mass;
  }
}

const jupiter: Body = new Body(Constants.JUPITER_X, Constants.JUPITER_Y, Constants.JUPITER_Z, Constants.JUPITER_VX,
                               Constants.JUPITER_VY, Constants.JUPITER_VZ, Constants.JUPITER_MASS);
const saturn: Body = new Body(Constants.SATURN_X, Constants.SATURN_Y, Constants.SATURN_Z, Constants.SATURN_VX,
                              Constants.SATURN_VY, Constants.SATURN_VZ, Constants.SATURN_MASS);
const uranus: Body = new Body(Constants.URANUS_X, Constants.URANUS_Y, Constants.URANUS_Z, Constants.URANUS_VX,
                              Constants.URANUS_VY, Constants.URANUS_VZ, Constants.URANUS_MASS);
const neptune: Body = new Body(Constants.NEPTUNE_X, Constants.NEPTUNE_Y, Constants.NEPTUNE_Z, Constants.NEPTUNE_VX,
                               Constants.NEPTUNE_VY, Constants.NEPTUNE_VZ, Constants.NEPTUNE_MASS);
const sun: Body = new Body(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Constants.SOLAR_MASS);

const bodies: Body[] = Array(sun, jupiter, saturn, uranus, neptune);

/**
 * Adjust the speed of the sun to ensure the conservation of the isolated system
 */
export function offsetMomentum(): void {
  // p is the abbreviation of momentum, which means: momentum, which is equal to mass multiplied by velocity p=mv
  let px: number = 0;
  let py: number = 0;
  let pz: number = 0;

  // Accumulate and calculate the momentum of each celestial body in the three-dimensional vector direction in the entire system
  for (let i: number = 0; i < bodies.length; i++) {
    const body: Body = bodies[i];
    const mass: number = body.mass;
    px += body.vx * mass;
    py += body.vy * mass;
    pz += body.vz * mass;
  }

  // The preset speed of the sun is 0. Through the law of conversation of momentum, the speed of each vector direction of the sun can be inferred.
  const body: Body = bodies[0];
  body.vx = -px / Constants.SOLAR_MASS;
  body.vy = -py / Constants.SOLAR_MASS;
  body.vz = -pz / Constants.SOLAR_MASS;
}

/**
 * Update the position information of celestial bodies after they change according to the specified time
 * @param dt - delta time Time changes
 */
export function advance(dt: number): void {
  const size = bodies.length;

  // Calculate the instantaneous velocity of each celestial body by pairing them together
  for (let i = 0; i < size; i++) {
    const iBody = bodies[i];
    let vxi: number = iBody.vx;
    let vyi: number = iBody.vy;
    let vzi: number = iBody.vz;
    for (let j: number = i + 1; j < size; j++) {
      const jBody: Body = bodies[j];

      // The distance difference between celestial bodies
      const dx: number = iBody.x - jBody.x;
      const dy: number = iBody.y - jBody.y;
      const dz: number = iBody.z - jBody.z;

      const d2: number = dx * dx + dy * dy + dz * dz;
      const mag: number = dt / (d2 * Math.sqrt(d2));

      // Calculate the mutual influence of gravity on velocity from the distance of celestial bodies
      const jMass: number = jBody.mass;
      vxi -= dx * jMass * mag;
      vyi -= dy * jMass * mag;
      vzi -= dz * jMass * mag;

      const iMass: number = iBody.mass;
      jBody.vx += dx * iMass * mag;
      jBody.vy += dy * iMass * mag;
      jBody.vz += dz * iMass * mag;
    }
    iBody.vx = vxi;
    iBody.vy = vyi;
    iBody.vz = vzi;
  }

  // Update the position information of celestial bodies
  for (let i: number = 0; i < size; i++) {
    const body: Body = bodies[i];
    body.x += dt * body.vx; // Position = Time * Speed
    body.y += dt * body.vy;
    body.z += dt * body.vz;
  }
}

/**
 * Called at the beginning and end of the program to check the correctness of the program by calculating the mechanical energy and judging whether the mechanical energy is conserved
 * @returns Return system mechanical energy
 */
export function energy(): number {
  let energy: number = 0.0;
  const size: number = bodies.length;

  // Calculate the sum of the mechanical energy of each celestial body. The mechanical energy formula is: Mechanical energy = Kinetic energy + Potential energy
  for (let i: number = 0; i < size; i++) {
    const iBody: Body = bodies[i];

    // Add up the kinetic energy of each celestial body. The kinetic energy formula is: Kinetic energy = 1/2 × mass of the object × square of the speed of movement
    energy += 0.5 * iBody.mass * (iBody.vx * iBody.vx + iBody.vy * iBody.vy + iBody.vz * iBody.vz);

    // Calculate the potential energy between the currently traversed celestial body and other celestial bodies. The potential energy formula is: gravitational potential energy = -G*physical A mass*physical B mass/distance
    for (let j: number = i + 1; j < size; j++) {
      const jBody: Body = bodies[j];
      const dx: number = iBody.x - jBody.x;
      const dy: number = iBody.y - jBody.y;
      const dz: number = iBody.z - jBody.z;

      const distance: number = Math.sqrt(dx * dx + dy * dy + dz * dz);
      energy -= (iBody.mass * jBody.mass) / distance;
    }
  }
  return energy;
}
