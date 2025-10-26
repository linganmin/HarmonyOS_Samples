/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
<template>
	<view class="userview">
		<embed class="usercomponent" tag="usercomponent" :options="userparams" @user_logout="logOut"></embed>
	</view>
</template>

<script>
	export default {
		onLoad(option) {
		    // Obtain the anonymous phone number passed from the one-tap sign-in page in a Vue lifecycle method.
			this.userparams.quickLoginAnonymousPhone = option.anonymousPhone;
			console.log('Succeeded in getting AnonymousPhone in user vue.', option.anonymousPhone);
		},
		onBackPress() {
			return true;
		},
		data() {
			return {
				// Anonymous phone number that uni-app passes to the personal information page.
				userparams: {
					quickLoginAnonymousPhone: ''
				}
			}
		},
		methods: {
			logOut(event) {
				console.log('user logout: ', event.detail.isLogOut);
				if (event.detail.isLogOut) {
				    // Upon account logout, your are required to clear the cached user data yourself.
				    this.quickLoginAnonymousPhone = '';
					uni.reLaunch({
						url: './index'
					})
				}
			}
		}
	}
</script>

<style scoped>
	.userview {
		width: 100%;
		height: 100%;
		background-color: #f1f3f5;
	}

	.usercomponent {
		width: 100%;
		height: 99%;
	}
</style>