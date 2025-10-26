/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
/**
 * 最佳实践：合理使用音频资源
 * 场景三：播音场景（OpenSL ES）
 */

// [Start open_sl_es]
//The foreground scene starts to play
SLPlayItfplayItf=nullptr;
(*pcmPlayerObject)->GetInterface(pcmPlayerObject,SL_IID_PLAY,&playItf);
(*playItf)->SetPlayState(playItf,SL_PLAYSTATE_PLAYING);
// Stop playing the background scene
(*playItf)->SetPlayState(playItf,SL_PLAYSTATE_STOPPED);
(*pcmPlayerObject)->Destroy(pcmPlayerObject);
(*engineObject)->Destroy(engineObject);
// [End open_sl_es]

/**
 * 最佳实践：合理使用音频资源
 * 场景四：播音场景（OHAudio）
 */

// [Start oh_audio]
//Construct the audio stream to play
OH_AudioRenderer*audioRenderer;
ret=OH_AudioStreamBuilder_GenerateRenderer(builder,&audioRenderer);

//The foreground scene starts to play
ret=OH_AudioRenderer_Start(audioRenderer);
// Stop playing the background scene
ret=OH_AudioRenderer_Stop(audioRenderer);
// [End oh_audio]