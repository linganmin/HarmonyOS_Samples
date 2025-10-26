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

#ifndef LIVESTREAM_AUDIOQUEUE_H
#define LIVESTREAM_AUDIOQUEUE_H

#include <queue>
#include <mutex>
#include <condition_variable>
#include <memory>
#include <vector>
#include <cstdint>
#include <atomic>
using namespace std::chrono_literals;  // Import time unit literals
// Support PCM audio queue with flexible buffer size
class AudioBgmQueue {
public:
    AudioBgmQueue() : m_stop(true) {}
    
    // Disable copy constructor and assignment operator
    AudioBgmQueue(const AudioBgmQueue&) = delete;
    AudioBgmQueue& operator=(const AudioBgmQueue&) = delete;
    
    // Add PCM data to the queue
    void push(int16_t* data, size_t sampleCount)
    {
        if (data == nullptr || sampleCount == 0) return;
        
        std::lock_guard<std::mutex> lock(m_mutex);
        
        // Add new data to the internal buffer
        m_buffer.insert(m_buffer.end(), data, data + sampleCount);
        
        // Notify waiting consumers
        m_cv.notify_one();
    }
    
    // Fetch specified amount of PCM data from the queue (blocks until sufficient data is available or stopped)
    // Returns actual number of samples fetched; 0 indicates stopped
    size_t pop(int16_t* output, size_t requestedSamples)
    {
        if (output == nullptr || requestedSamples == 0) return 0;

        std::unique_lock<std::mutex> lock(m_mutex);
        // Wait until sufficient data is available or stop is requested
        m_cv.wait_for(lock, 2ms, [this, requestedSamples]() {
            return m_stop || m_buffer.size() >= requestedSamples;
        });
        // Return 0 if stop is requested
        if (m_stop) return 0;
        
        // Determine actual number of samples that can be provided (not exceeding requested amount)
        size_t actualSamples = std::min(requestedSamples, m_buffer.size());
        
        // Copy data to output buffer
        std::copy(m_buffer.begin(), m_buffer.begin() + actualSamples, output);
        
        // Remove copied data from internal buffer
        m_buffer.erase(m_buffer.begin(), m_buffer.begin() + actualSamples);
        
        return actualSamples;
    }

    // Start the queue
    void Start()
    {
        m_stop = false;
        m_cv.notify_all();
    }
    // Stop the queue and wake up all waiting threads
    void Stop()
    {
        m_stop = true;
        m_cv.notify_all();
    }
    // Get status
    bool IsStart()
    {
        return !m_stop;
    }
   // Clear all data in the queue
    void Clear()
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        m_buffer.clear();
        // No need to notify consumers, as clear operation does not affect waiting state
    }
    
    // Check if the queue is empty
    bool Empty() const
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_buffer.empty();
    }
    
    // Get the number of samples currently in the buffer
    size_t size() const
    {
        std::lock_guard<std::mutex> lock(m_mutex);
        return m_buffer.size();
    }
private:
    mutable std::mutex m_mutex;               // Mutex
    std::condition_variable m_cv;             // Condition variable
    std::vector<int16_t> m_buffer;            // Internal buffer
    std::atomic<bool> m_stop;                 // Stop flag
};
#endif // LIVESTREAM_AUDIOQUEUE_H
