/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
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

#include <queue>
#include <hilog/log.h>
#include <algorithm>
#include <fstream>
#include <unistd.h>
#include <cstring>
#include <stdexcept>
#include <map>
#include "AVCodecSampleError.h"
#include "multimedia/player_framework/native_avbuffer.h"
#include "Summary.h"

#undef LOG_TAG
#define LOG_TAG "summary"

namespace {
constexpr double SUMMARY_DOUBLE_TWO = 0.02;
constexpr int SUMMARY_ZERO = 0;
constexpr int SUMMARY_ONE = 1;
constexpr int SUMMARY_TWO = 2;
constexpr int SUMMARY_THREE = 3;
constexpr int SUMMARY_FOUR = 4;
constexpr int SUMMARY_FIVE = 5;
constexpr int SUMMARY_SIX = 6;
constexpr int SUMMARY_SEVEN = 7;
constexpr int SUMMARY_EIGHT = 8;
constexpr int SUMMARY_NINE = 9;
constexpr int SUMMARY_TEN = 10;
constexpr int SUMMARY_ELEVEN = 11;
constexpr int SUMMARY_AMR_SAMPLING_1 = 8000;
constexpr int SUMMARY_AMR_CODERATE_1 = 10200;
constexpr int SUMMARY_AMR_SAMPLING_2 = 16000;
constexpr int SUMMARY_AMR_CODERATE_2 = 23050;
constexpr int SUMMARY_MP3_SAMPLING_1 = 16000;
constexpr int SUMMARY_MP3_CODERATE_1 = 48000;
constexpr int SUMMARY_MP3_CODERATE_2 = 80000;
constexpr int SUMMARY_MP3_SAMPLING_2 = 22050;
constexpr int SUMMARY_MP3_CODERATE_3 = 64000;
constexpr int SUMMARY_MP3_SAMPLING_3 = 24000;
constexpr int SUMMARY_MP3_CODERATE_4 = 96000;
constexpr int SUMMARY_MP3_SAMPLING_4 = 32000;
constexpr int SUMMARY_MP3_SAMPLING_5 = 44100;
constexpr int SUMMARY_MP3_CODERATE_5 = 128000;
constexpr int SUMMARY_MP3_SAMPLING_6 = 48000;
constexpr int SUMMARY_MP3_CODERATE_6 = 160000;
constexpr int SUMMARY_G711MU_CODERATE_1 = 64000;
constexpr int SUMMARY_AAC_SAMPLING_1 = 8000;
constexpr int SUMMARY_AAC_CODERATE_1 = 24000;
constexpr int SUMMARY_AAC_CODERATE_2 = 32000;
constexpr int SUMMARY_AAC_SAMPLING_2 = 12000;
constexpr int SUMMARY_AAC_CODERATE_3 = 48000;
constexpr int SUMMARY_AAC_SAMPLING_3 = 16000;
constexpr int SUMMARY_AAC_CODERATE_4 = 96000;
constexpr int SUMMARY_AAC_SAMPLING_4 = 22050;
constexpr int SUMMARY_AAC_CODERATE_5 = 128000;
constexpr int SUMMARY_AAC_SAMPLING_5 = 24000;
constexpr int SUMMARY_AAC_CODERATE_6 = 48000;
constexpr int SUMMARY_AAC_CODERATE_7 = 80000;
constexpr int SUMMARY_AAC_SAMPLING_6 = 32000;
constexpr int SUMMARY_AAC_CODERATE_8 = 56000;
constexpr int SUMMARY_AAC_SAMPLING_7 = 44100;
constexpr int SUMMARY_AAC_SAMPLING_8 = 48000;
constexpr int SUMMARY_AAC_CODERATE_9 = 256000;
constexpr int SUMMARY_AAC_SAMPLING_9 = 64000;
constexpr int SUMMARY_AAC_CODERATE_10 = 128000;
constexpr int SUMMARY_AAC_CODERATE_11 = 160000;
constexpr int SUMMARY_AAC_CODERATE_12 = 192000;
constexpr int SUMMARY_AAC_SAMPLING_10 = 88200;
constexpr int SUMMARY_AAC_SAMPLING_11 = 96000;
constexpr int SUMMARY_AAC_SAMPLING_12 = 11025;
constexpr int SUMMARY_BURDEN_ONE = -1;
using namespace std::chrono_literals;
} // namespace

Summary::~Summary() { Summary::StartRelease(); }

int32_t Summary::CreateAudioDecoder()
{
    OH_LOG_INFO(LOG_APP, "audio mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    int32_t ret = audioDecoder_->Create(sampleInfo_.audioCodecMime);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio decoder failed, mime:%{public}s", sampleInfo_.audioCodecMime.c_str());
    } else {
        audioDecContext_ = new CodecUserData;
        ret = audioDecoder_->Config(sampleInfo_, audioDecContext_);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_ERROR(LOG_APP, "Audio Decoder config failed, ret: %{public}d", ret);
            return ret;
        }
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

void Summary::CodeSampleInfo()
{
    sampleInfo_.audioSampleOutRate  = sampleInfo_.audioSampleRate;
    sampleInfo_.audioChannelOutCount  = sampleInfo_.audioChannelCount;
    if (sampleInfo_.audioChannelOutCount  == SUMMARY_ONE) {
        sampleInfo_.audioChannelOutLayout = OH_AudioChannelLayout::CH_LAYOUT_MONO;
    } else if (sampleInfo_.audioChannelOutCount  == SUMMARY_TWO) {
        sampleInfo_.audioChannelOutLayout = OH_AudioChannelLayout::CH_LAYOUT_STEREO;
    }
    sampleInfo_.audioMaxInputOutSize = sampleInfo_.audioSampleOutRate *
                                        SUMMARY_DOUBLE_TWO * sampleInfo_.audioChannelOutCount  * sizeof(short);
    if (sampleInfo_.audioMime == "AMR" && sampleInfo_.audioSampleOutRate == SUMMARY_AMR_SAMPLING_1) {
        sampleInfo_.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AMR_NB;
        sampleInfo_.audioBitRate = SUMMARY_AMR_CODERATE_1;
    } else if (sampleInfo_.audioMime == "AMR" && sampleInfo_.audioSampleOutRate == SUMMARY_AMR_SAMPLING_2) {
        sampleInfo_.audioCodecMime_ = OH_AVCODEC_MIMETYPE_AUDIO_AMR_WB;
        sampleInfo_.audioBitRate = SUMMARY_AMR_CODERATE_2;
    }
    SetAudioBitRate();
}

void Summary::SetAudioBitRate()
{
    if (sampleInfo_.audioMime == "MP3" && sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_1
                && sampleInfo_.audioChannelOutCount  == SUMMARY_ONE) {
        sampleInfo_.audioBitRate = SUMMARY_MP3_CODERATE_1;
    } else if (sampleInfo_.audioMime == "MP3" && sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_1
                && sampleInfo_.audioChannelOutCount  == SUMMARY_TWO) {
        sampleInfo_.audioBitRate = SUMMARY_MP3_CODERATE_2;
    } else if (sampleInfo_.audioMime == "MP3" && sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_2) {
        sampleInfo_.audioBitRate = SUMMARY_MP3_CODERATE_3;
    } else if (sampleInfo_.audioMime == "MP3" &&  sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_3) {
        sampleInfo_.audioBitRate = SUMMARY_MP3_CODERATE_4;
    } else if (sampleInfo_.audioMime == "MP3" && (sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_4 ||
                sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_5)) {
        sampleInfo_.audioBitRate = SUMMARY_MP3_CODERATE_5;
    } else if (sampleInfo_.audioMime == "MP3" && sampleInfo_.audioSampleOutRate == SUMMARY_MP3_SAMPLING_6) {
        sampleInfo_.audioBitRate = SUMMARY_MP3_CODERATE_6;
    } else if (sampleInfo_.audioMime == "G711mu") {
        sampleInfo_.audioBitRate = SUMMARY_G711MU_CODERATE_1;
    }
}

void Summary::CodeAacSampleInfo()
{
    const std::map<int, int> bitRates = {
        {SUMMARY_AAC_SAMPLING_1, SUMMARY_AAC_CODERATE_1},
        {SUMMARY_AAC_SAMPLING_2, SUMMARY_AAC_CODERATE_2},
        {SUMMARY_AAC_SAMPLING_3, SUMMARY_AAC_CODERATE_4},
        {SUMMARY_AAC_SAMPLING_4, SUMMARY_AAC_CODERATE_5},
        {SUMMARY_AAC_SAMPLING_5, SUMMARY_AAC_CODERATE_6},
        {SUMMARY_AAC_SAMPLING_6, SUMMARY_AAC_CODERATE_8},
        {SUMMARY_AAC_SAMPLING_7, SUMMARY_AAC_CODERATE_6},
        {SUMMARY_AAC_SAMPLING_8, SUMMARY_AAC_CODERATE_9},
        {SUMMARY_AAC_SAMPLING_9, SUMMARY_AAC_CODERATE_10},
        {SUMMARY_AAC_SAMPLING_10, SUMMARY_AAC_CODERATE_11},
        {SUMMARY_AAC_SAMPLING_11, SUMMARY_AAC_CODERATE_12}
    };
    if (sampleInfo_.audioMime == "AAC") {
        auto it = bitRates.find(sampleInfo_.audioSampleOutRate);
        if (it != bitRates.end()) {
            switch (sampleInfo_.audioChannelOutCount) {
                case SUMMARY_ONE: sampleInfo_.audioBitRate = it->second; break;
                case SUMMARY_TWO: sampleInfo_.audioBitRate = it->second; break;
                default:
                    break;
            }
        }
    }
}

int32_t Summary::Init(SampleInfo &sampleInfo)
{
    std::unique_lock<std::mutex> lock(mutex_);
    if (isStarted_ || !isReleased_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isStopped_ = false;
    isInputEOS_ = false;
    if (!(demuxer_ == nullptr && audioDecoder_ == nullptr)) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    sampleInfo_ = sampleInfo;
    int32_t ret = InitDecoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create video decoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    CodeSampleInfo();
    CodeAacSampleInfo();
    ret = InitEncoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create video encoder failed");
        doneCond_.notify_all();
        lock.unlock();
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

// [Start init_decoder]
int32_t Summary::InitDecoder()
{
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (!(demuxer_ == nullptr && audioDecoder_ == nullptr)) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }

    audioDecoder_ = std::make_unique<AudioDecoder>();
    demuxer_ = std::make_unique<Demuxer>();
    isReleased_ = false;
    int32_t ret = demuxer_->Create(sampleInfo_);
    if (ret == AVCODEC_SAMPLE_ERR_OK) {
        ret = CreateAudioDecoder();
    } else {
        OH_LOG_ERROR(LOG_APP, "Create audio decoder failed");
    }
    return ret;
}
// [End init_decoder]

int32_t Summary::CreateAudioEncoder()
{
    int32_t ret = audioEncoder_->Create(sampleInfo_.audioCodecMime_);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio encoder(%{public}s) failed", sampleInfo_.audioCodecMime_.c_str());
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "Create audio encoder(%{public}s)", sampleInfo_.audioCodecMime_.c_str());

    audioEncContext_ = new CodecUserData;
    ret = audioEncoder_->Config(sampleInfo_, audioEncContext_);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Encoder config failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    return AVCODEC_SAMPLE_ERR_OK;
}

// [Start init_encoder]
int32_t Summary::InitEncoder()
{
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (!(muxer_ == nullptr && audioEncoder_ == nullptr)) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    audioEncoder_ = std::make_unique<AudioEncoder>();
    muxer_ = std::make_unique<Muxer>();
    int32_t ret = muxer_->Create(sampleInfo_.outputFd, sampleInfo_.audioEncapsulationFormat);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create muxer with fd(%{public}d) failed", sampleInfo_.outputFd);
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = muxer_->Config(sampleInfo_);
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create audio encoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = CreateAudioEncoder();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Create video encoder failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    OH_LOG_INFO(LOG_APP, "Succeed");
    return AVCODEC_SAMPLE_ERR_OK;
}

// [Start start_transcoding]
int32_t Summary::Start()
{
    std::unique_lock<std::mutex> lock(mutex_);
    int32_t ret;
    if (isStarted_) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    if (demuxer_ == nullptr) {
        OH_LOG_ERROR(LOG_APP, "Already started.");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    
    ret = audioDecoder_->Start();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Video Decoder start failed");
        lock.unlock();
        StartRelease();
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = muxer_->Start();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Muxer start failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    ret = audioEncoder_->Start();
    if (ret != AVCODEC_SAMPLE_ERR_OK) {
        OH_LOG_ERROR(LOG_APP, "Audio Encoder start failed");
        return AVCODEC_SAMPLE_ERR_ERROR;
    }
    isStarted_ = true;
    isStopped_ = false;
    isInputEOS_ = false;
    audioDecInputThread_ = std::make_unique<std::thread>(&Summary::AudioDecInputThread, this);
    audioDecOutputThread_ = std::make_unique<std::thread>(&Summary::AudioDecOutputThread, this);
    audioEncInputThread_ = std::make_unique<std::thread>(&Summary::AudioEncInputThread, this);
    audioEncOutputThread_ = std::make_unique<std::thread>(&Summary::AudioEncOutputThread, this);

    OH_LOG_INFO(LOG_APP, "Succeed");
    doneCond_.notify_all();
    return AVCODEC_SAMPLE_ERR_OK;
}
// [End start_transcoding]

void Summary::Stop()
{
    StartRelease();
}

void Summary::StartRelease()
{
    if (!isReleased_) {
        isStopped_ = true;
        Release();
    }
    isReleased_ = true;
    OH_LOG_INFO(LOG_APP, "StartRelease Done");
}

void Summary::Context()
{
    if (audioDecContext_) {
        audioDecContext_->inputCond.notify_all();
        audioDecContext_->outputCond.notify_all();
    }
    if (audioEncContext_) {
        audioEncContext_->inputCond.notify_all();
        audioEncContext_->outputCond.notify_all();
    }
}

void Summary::DeleteContext()
{
    if (audioEncContext_) {
        delete audioEncContext_;
        audioEncContext_ = nullptr;
    }
    if (audioDecContext_) {
        delete audioDecContext_;
        audioDecContext_ = nullptr;
    }
    isStopped_ = false;
    isReleased_ = true;
    isInputEOS_ = false;
}

void Summary::ReleaseCallback()
{
    if (sampleInfo_.playDoneCallback) {
        auto callback = sampleInfo_.playDoneCallback;
        auto callbackData = sampleInfo_.playDoneCallbackData;
        callback(callbackData);
    }
}

void Summary::JoinThreads()
{
    auto safe_join = [](std::unique_ptr<std::thread>& thread, const char* name) {
        if (thread && thread->joinable()) {
            if (thread->get_id() != std::this_thread::get_id()) {
                thread->join();
            } else {
                thread->detach();
            }
            thread.reset();
        }
    };
    safe_join(audioEncOutputThread_, "Encoder Output");
    safe_join(audioEncInputThread_, "Encoder Input");
    safe_join(audioDecOutputThread_, "Decoder Output");
    safe_join(audioDecInputThread_, "Decoder Input");
}

void Summary::Release()
{
    std::unique_lock<std::mutex> lock(mutex_);
    isStopped_ = true;
    isStarted_ = false;
    pcmCond_.notify_all();
    doneCond_.notify_all();
    Context();
    JoinThreads();
    auto safe_release = [](auto& component, const char* name) {
        if (component) {
            OH_LOG_INFO(LOG_APP, "Releasing %s...", name);
            component->Release();
            component.reset();
        }
    };
    safe_release(muxer_, "Muxer");
    safe_release(audioEncoder_, "Audio Encoder");
    safe_release(audioDecoder_, "Audio Decoder");
    safe_release(demuxer_, "Demuxer");
    {
        std::lock_guard<std::mutex> pcmLock(pcmMutex_);
        std::queue<uint8_t> empty;
        std::swap(pcmQueue_, empty);
    }
    DeleteContext();
    ReleaseCallback();
}

// [Start start_decoder_input_thread]
void Summary::AudioDecInputThread()
{
    while (true) {
        if (!isStarted_) {
            OH_LOG_INFO(LOG_APP, "Decoder input thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(audioDecContext_->inputMutex);
        bool condRet = audioDecContext_->inputCond.wait_for(
            lock, 100ms, [this]() { return !isStarted_ || !audioDecContext_->inputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            OH_LOG_INFO(LOG_APP, "Work done, thread out");
            break;
        }
        if (audioDecContext_->inputBufferInfoQueue.empty()) {
            OH_LOG_INFO(LOG_APP, "Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }
        
        CodecBufferInfo bufferInfo = audioDecContext_->inputBufferInfoQueue.front();
        audioDecContext_->inputBufferInfoQueue.pop();
        audioDecContext_->inputFrameCount++;
        lock.unlock();

        demuxer_->ReadSample(demuxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer),
                             bufferInfo.attr);

        int32_t ret = audioDecoder_->PushInputBuffer(bufferInfo);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_INFO(LOG_APP, "Push data failed, thread out, ret: %{public}d", ret);
            break;
        }
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            OH_LOG_INFO(LOG_APP, "Catch EOS, thread out");
            isInputEOS_ = true;
            break;
        }
    }
}

// [Start start_decoder_output_thread]
void Summary::AudioDecOutputThread()
{
    while (true) {
        if (!isStarted_) {
            OH_LOG_INFO(LOG_APP, "Decoder output thread out");
            break;
        }
        std::unique_lock<std::mutex> lock(audioDecContext_->outputMutex);
        bool condRet = audioDecContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioDecContext_->outputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            OH_LOG_INFO(LOG_APP, "Decoder output thread out");
            break;
        }
        if (audioDecContext_->outputBufferInfoQueue.empty()) {
            OH_LOG_INFO(LOG_APP, "Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }
        CodecBufferInfo bufferInfo = audioDecContext_->outputBufferInfoQueue.front();
        audioDecContext_->outputBufferInfoQueue.pop();
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            OH_LOG_INFO(LOG_APP, "Catch EOS, thread out");
            isInputEOS_ = true;
            pcmCond_.notify_all();
            break;
        }
        audioDecContext_->outputFrameCount++;
        OH_LOG_INFO(LOG_APP, "Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}ld",
                    audioDecContext_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags,
                    bufferInfo.attr.pts);
        uint8_t *source = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        int32_t pcmSize = bufferInfo.attr.size;
        
        // Put the decoded PMC data into the queue
        {
            std::lock_guard<std::mutex> pcmLock(pcmMutex_);
            for (int i = SUMMARY_ZERO; i < pcmSize; i++) {
                pcmQueue_.push(source[i]);
            }
            pcmCond_.notify_one();
        }
        
        lock.unlock();

        int32_t ret = audioDecoder_->FreeOutputBuffer(bufferInfo.bufferIndex);
        if (ret != AVCODEC_SAMPLE_ERR_OK) {
            OH_LOG_INFO(LOG_APP, "Decoder output thread out");
            break;
        }
    }
    isInputEOS_ = true;
    pcmCond_.notify_one();
    OH_LOG_INFO(LOG_APP, "Decode thread exited");
}

void Summary::AudioEncInputThread()
{
    while (true) {
        if (!isStarted_) break;
        std::unique_lock<std::mutex> lock(audioEncContext_->inputMutex);
        bool condRet = audioEncContext_->inputCond.wait_for(lock, 5s, [this]() {
            return !isStarted_ || (!audioEncContext_->inputBufferInfoQueue.empty());
        });
        if (!isStarted_) break;
        if (audioEncContext_->inputBufferInfoQueue.empty()) {
            OH_LOG_ERROR(LOG_APP, "Audio Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }
        CodecBufferInfo bufferInfo = audioEncContext_->inputBufferInfoQueue.front();
        audioEncContext_->inputBufferInfoQueue.pop();
        audioEncContext_->inputFrameCount++;
        uint8_t *inputBufferAddr = OH_AVBuffer_GetAddr(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer));
        audioEncContext_->ReadCache(inputBufferAddr, sampleInfo_.audioMaxInputOutSize);
        lock.unlock();
        int32_t bytesToCopy = sampleInfo_.audioMaxInputOutSize;
        {
            std::unique_lock<std::mutex> pcmLock(pcmMutex_);
            
            auto status = pcmCond_.wait_for(pcmLock, 100ms, [this, bytesToCopy]() {
                return isStopped_ || pcmQueue_.size() >= bytesToCopy ||
                        (isInputEOS_ && !pcmQueue_.empty());
            });
            if (isStopped_) break;
            if (!status) continue;
            int32_t actualBytes = std::min(bytesToCopy, static_cast<int32_t>(pcmQueue_.size()));
            if (actualBytes > 0) {
                auto* buffer = inputBufferAddr;
                for (int i = 0; i < actualBytes; ++i) {
                    *buffer++ = pcmQueue_.front();
                    pcmQueue_.pop();
                }
                bufferInfo.attr.size = actualBytes;
            }
        }
        int32_t ret = audioEncoder_->PushInputData(bufferInfo);
        if (ret != AVCODEC_SAMPLE_ERR_OK) break;
        if (isInputEOS_ && pcmQueue_.empty()) {
            bufferInfo.attr.flags = AVCODEC_BUFFER_FLAGS_EOS;
            bufferInfo.attr.size = 0;
            audioEncoder_->PushInputData(bufferInfo);
            break;
        }
    }
    OH_LOG_INFO(LOG_APP, "Encode thread exited");
}
// [Start start_Encoder_output_thread]
void Summary::AudioEncOutputThread()
{
    while (true) {
        if (!isStarted_) break;
        std::unique_lock<std::mutex> lock(audioEncContext_->outputMutex);
        audioEncContext_->outputCond.wait_for(
            lock, 5s, [this]() { return !isStarted_ || !audioEncContext_->outputBufferInfoQueue.empty(); });
        if (!isStarted_) break;
        if (audioEncContext_->outputBufferInfoQueue.empty()) continue;
        CodecBufferInfo bufferInfo = audioEncContext_->outputBufferInfoQueue.front();
        audioEncContext_->outputBufferInfoQueue.pop();
        audioEncContext_->outputFrameCount++;
        OH_LOG_INFO(LOG_APP,
                    "Audio Out buffer count: %{public}u, size: %{public}d, flag: %{public}u, pts: %{public}ld",
                    audioEncContext_->outputFrameCount, bufferInfo.attr.size,
                    bufferInfo.attr.flags, bufferInfo.attr.pts);
        muxer_->WriteSample(muxer_->GetAudioTrackId(), reinterpret_cast<OH_AVBuffer*>(bufferInfo.buffer),
                            bufferInfo.attr);
        OH_LOG_INFO(LOG_APP, "bufferInfo.bufferIndex = %{public}d", bufferInfo.bufferIndex);
        int32_t ret = audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
        if (ret != AVCODEC_SAMPLE_ERR_OK) break;
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            isInputEOS_ = true;
            audioEncoder_->FreeOutputData(bufferInfo.bufferIndex);
            break;
        }
    }
    OH_LOG_INFO(LOG_APP, "Exit, frame count: %{public}u", audioEncContext_->outputFrameCount);
    StartRelease();
}
// [End start_Encoder_output_thread]