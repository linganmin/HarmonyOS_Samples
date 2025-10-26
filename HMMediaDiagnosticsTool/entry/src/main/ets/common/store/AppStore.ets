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

import { SceneOption } from './Score';

export class AppStore {
  private static instance: AppStore = new AppStore();

  public static getInstance() {
    return AppStore.instance;
  }

  private pCurrentSceneIndex: number = 0;

  public set currentSceneIndex(value: number) {
    this.pCurrentSceneIndex = value;
  }

  public get currentSceneIndex(): number {
    return this.pCurrentSceneIndex;
  }

  private pCurrentStepIndex: number = 0;

  public set currentStepIndex(value: number) {
    this.pCurrentStepIndex = value;
  }

  public get currentStepIndex(): number {
    return this.pCurrentStepIndex;
  }

  private pCurrentOptionIndex: number = 0;

  public set currentOptionIndex(value: number) {
    this.pCurrentOptionIndex = value;
  }

  public get currentOptionIndex(): number {
    return this.pCurrentOptionIndex;
  }

  private pIsMultiStep: boolean = false;

  public set isMultiStep(value: boolean) {
    this.pIsMultiStep = value;
  }

  public get isMultiStep(): boolean {
    return this.pIsMultiStep;
  }

  public initSceneStatus(): void {
    this.pCurrentStepIndex = 0;
    this.pIsMultiStep = false;
  }

  private pCurrentScore: number = 0;

  public set currentScore(value: number) {
    this.pCurrentScore = value;
  }

  public get currentScore(): number {
    return this.pCurrentScore;
  }

  public optionRecord: Array<SceneOption> = [];

  private pCurrentAudioType: string | undefined = undefined;

  public get currentAudioType(): string | undefined {
    return this.pCurrentAudioType;
  }

  public set currentAudioType(audioType: string | undefined) {
    this.pCurrentAudioType = audioType;
  }
}