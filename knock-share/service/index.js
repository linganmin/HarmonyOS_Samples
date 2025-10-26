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

const videoSources = [
	'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/pura-x/video/kv-popup.mp4',
	'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/mate-xt-ultimate-design/videos/hero/brand-ambassador-video.mp4',
	'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/ah-pro-plus/video/kv-intro-pop.mp4',
	'https://consumer.huawei.com/content/dam/huawei-cbg-site/cn/mkt/pdp/phones/nova13-pro/video/camera-intro-popup.mp4'
];

// Get params from url
let urlSearchParams = new URLSearchParams(window.location.search);
let videoIndex = urlSearchParams.get('videoIndex');
if (!videoIndex) {
	videoIndex = 0;
}


function toAppgallery() {
	// Replace with a real usable application market app linking link.
	window.location.href = 'https://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.books';
}

window.onload = function() {
	const video = document.getElementById("myVideo");
	const buttonContainer = document.getElementById("button-container");

	for (let i = 0; i < videoSources.length; i++) {
		const div = document.createElement("div");
		div.className = "video-item";
		div.textContent = `${i + 1}`;
		div.dataset.index = i;
		div.onclick = () => playVideo(i);
		buttonContainer.appendChild(div);
	}

	if (videoSources.length > 0 && videoSources.length > videoIndex) {
		playVideo(videoIndex);
	}

	function playVideo(index) {
		console.info("video play index " + index);
		const items = document.querySelectorAll(".video-item");
		items.forEach(item => {
			item.classList.remove("active");
			item.innerHTML = item.textContent;
		});

		const currentDiv = items[index];
		currentDiv.classList.add("active");
		currentDiv.innerHTML = currentDiv.textContent + ' <i class="fas fa-check"></i>';

		const src = videoSources[index];
		video.src = src;
		video.load();
		video.play();
	}
}