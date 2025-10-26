/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
<template>
	<view class='privacyview'>
		<embed class="webview" tag="webview" :options="webviewparams" @webview_click_back="webviewClickBack"></embed>
	</view>
</template>

<script>
	export default {
		methods: {
			webviewClickBack(event) {
				console.info('webClickBack: ' + event.detail.webClickBack);
				// Tap the back button within a webview component.
				if (event.detail.webClickBack) {
					uni.navigateBack();
				}
			}
		}
	}
</script>

<style scoped>
	.privacyview {
		width: 100%;
		height: 100%;
		background-color: #fff;
	}

	.webview {
		width: 100%;
		height: 99%;
	}
</style>