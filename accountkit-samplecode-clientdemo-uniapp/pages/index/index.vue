/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
<template>
	<view class="homeview">
		<embed class="homecomponent" tag="homecomponent" :options="homeparams"
			@on_get_anonymous_phone="getAnonymousPhone"></embed>
	</view>
</template>

<script lang="uts">
	import { getQuickLoginAnonymousPhone } from "@/uni_modules/hw-accountkit-component"
	export default {
		data() {
			return {
				timerId: null,
				// Define the parameters passed to the sign-in/sign-up page, which are used to navigate to the one-tap sign-in page.
				homeparams: {
					isGetAnonymousPhone: false
				},
				anonymousPhone: ''
			}
		},
		methods: {
			setGetAnonymousPhoneTimer() {
				console.log('setTimer.');
				// Set the wait time based on actual requirements, with 5 seconds recommended.
				const waitTime = 5000;
				this.timerId = setTimeout(() => {
					console.error('Failed to get quickLoginAnonymousPhone due to timeout.');
					// Handle the timeout to avoid prolonged waiting.
				}, waitTime);
			},
			async getAnonymousPhone(event : { detail : { isGetAnonymousPhone : boolean; }; }) {
				console.log('on_get_anonymous_phone', event.detail.isGetAnonymousPhone);
				if (event.detail.isGetAnonymousPhone) {
				    // Configure the timer for processing the anonymous phone number timeout.
					this.setGetAnonymousPhoneTimer();
					// Call the encapsulated HarmonyOS NEXT API to obtain the anonymous phone number.
					this.anonymousPhone = await getQuickLoginAnonymousPhone();
					if (this.timerId !== null) {
						console.log('Succeeded in clearing timer: ' + this.timerId);
						clearTimeout(this.timerId);
					}
					if (this.anonymousPhone) {
						console.log('Succeeded in getting AnonymousPhone.');
						uni.navigateTo({
							url: `./quickloginbutton?anonymousPhone=${this.anonymousPhone}`
						});
					} else {
						// Implement the logic to redirect to other sign-in methods yourself.
						console.log('use other login way to log in.');
					}
				} else {
					// handle exception
				}
			}
		}
	}
</script>

<style scoped>
	.homeview {
		width: 100%;
		height: 100%;
		background-color: #f1f3f5;
	}

	.homecomponent {
		width: 100%;
		height: 99%;
	}
</style>