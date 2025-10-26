/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
<template>
	<view class="quickloginbutton-view">
		<image class="ic_back" :class="{'disabled': isDisabled }" src="../../static/hwid_next_ic_appback.svg"
			@click="backHome" :disabled="isDisabled"></image>
		<image class="logo" src="../../static/appmarket.png"></image>
		<text class="phonetitle">{{anonymousPhone}}</text>
		<text class="bindphone" :class="{'disabled': isDisabled }">华为账号绑定号码</text>
		<embed class="quickloginbutton" tag="quickloginbutton" :options="quickloginparams"
			@quick_login_response="onQuickLoginResponse"></embed>
		<button class="otherloginbutton" @click="otherLoginWays" :disabled="isDisabled">其他方式登录</button>
		<view class="agreementgroup" :class="{'disabled': isDisabled }" :disabled="isDisabled">
			<radio class="radioset" :checked="state" @click="agreeChange" active-background-color="#CE0E2D" />
			<view class="privacyarea">
				<text class="agreetext">已阅读并同意</text>
				<text class="shopping_agreement">《购物用户协议》《购物隐私政策》</text>
				<text class="and">和</text>
				<text class="privacystatement" @click="onClickPrivacyAgreement">《华为账号用户认证协议》</text>
				<text class="end">。</text>
			</view>
		</view>

    <view class="dialogpage" v-if="showDialog">
      <view class="agreementdialog">
        <text class="dialogtitle">用户协议与隐私条款</text>
        <view class="dialog_content">
          <text class="agreetext2">已阅读并同意</text>
          <text class="shopping_agreement" style="color: #CE0E2D;">《购物用户协议》《购物隐私政策》</text>
          <text class="and2">和</text>
          <text class="privacystatement" @click="onClickPrivacyAgreement"
            style="color: #CE0E2D;">《华为账号用户认证协议》</text>
          <text class="end">。</text>
        </view>
        <view class="agreementdialogbtns">
          <button class="cancelbutton" @click="clickCancel" :disabled="isDisabled">取消</button>
          <button class="confirmbutton" @click="clickConfirm" :disabled="isDisabled">同意并登录</button>
        </view>
      </view>
    </view>

  </view>
</template>

<script>
	import {
		hasNetWork
	} from "@/uni_modules/hw-accountkit-component"
	export default {
		onLoad(option) {
			// Obtain the anonymous phone number passed from the sign-in/sign-up page in a Vue lifecycle method.
			this.anonymousPhone = option.anonymousPhone;
			console.log('Succeeded in getting AnonymousPhone in quickloginbutton vue.', option.anonymousPhone);
		},
		data() {
			return {
				isDisabled: false,
				anonymousPhone: '',
				state: false,
				showDialog: false,
				// Define the parameters passed to the one-tap sign-in page, which are used for marking relevant statuses.
				quickloginparams: {
					noNetCnt: 0,
					isUserAgree: false,
					isContinueLogin: false,
					isDisabled: false
				}
			}
		},
		onBackPress() {
			if (this.showDialog) {
				this.showDialog = false;
				return true;
			} else {
				return false;
			}
		},
		methods: {
			backHome() {
				uni.navigateBack();
			},
			onClickPrivacyAgreement(e) {
				console.log('onClickPrivacyAgreement');
				if (!hasNetWork()) {
					this.quickloginparams = {
						noNetCnt: this.quickloginparams.noNetCnt + 1
					};
					return;
				}
				uni.navigateTo({
					url: './webview'
				});
			},
			onQuickLoginResponse(event) {
				// Set to a non-clickable state.
				if (event.detail.isDisabled) {
					this.isDisabled = true;
				} else {
					this.isDisabled = false;
					this.quickloginparams.isContinueLogin = false;
				}
				if (!this.state && hasNetWork()) {
					this.showDialog = true;
					return;
				}
				if (event.detail.quickLoginResponse) {
					console.log('Succeeded in getting quickLogin response.');
					const response = event.detail.quickLoginResponse;
					const authCode = response.authorizationCode;

					// Process code.
					// After sign-in to the app is successful, process the server sign-in execution logic here.
					// ...

					// After sign-in on the server is successful, the data to be displayed on the main screen is returned.
					// ...
					uni.reLaunch({
						url: `./user?anonymousPhone=${this.anonymousPhone}`
					});
				}
			},
			agreeChange(e) {
				this.state = !this.state;
				this.quickloginparams = {
					isUserAgree: this.state,
					isContinueLogin: false,
				};
				console.log('agreement state: ' + this.state);
			},
			otherLoginWays() {
				// Implement the logic to redirect to other sign-in methods yourself.

			},
			clickCancel(e) {
				this.showDialog = false;
				this.quickloginparams = {
					isUserAgree: this.state,
					isContinueLogin: false,
				};
			},
			clickConfirm(e) {
				console.info('continuelogin execute.');
				if (!hasNetWork()) {
					this.quickloginparams = {
						noNetCnt: this.quickloginparams.noNetCnt + 1
					};
					return;
				}
				this.showDialog = false;
				this.state = true;
				this.quickloginparams = {
					isUserAgree: true,
					isContinueLogin: true
				};
			}
		}
	}
</script>

<style scoped>
	.quickloginbutton-view {
		display: flex;
		flex-direction: column;
		box-sizing: border-box;
		width: 100%;
		background-color: #f1f3f5;
		padding: 36px 16px 28px 16px;
		height: 100vh;
	}

  .phonetitle {
    display: block;
    justify-content: center;
    text-align: center;
    margin-top: 44px;
    width: 100%;
    height: 40px;
    background-color: #f1f3f5;
    font-size: 28pt;
    font-weight: bold;
  }


  .quickloginbutton {
    margin-top: 32px;
    width: 100%;
    height: 40px;
    max-width: 448px;
    align-self: center;
  }

  .otherloginbutton {
    display: block;
    margin-top: 16px;
    width: 100%;
    max-width: 448px;
    height: 40px;
    line-height: 40px;
    text-align: center;
    font-size: 12pt;
    font-weight: 500;
    border-radius: 20px;
    background-color: #e7e8ea;
    list-style: none;
    border: none;
    outline: none;
  }

	.bindphone {
		display: block;
		justify-content: center;
		text-align: center;
		margin-top: 12px;
		width: 100%;
		height: 40px;
		font-size: 10pt;
		opacity: 0.4;
	}

	.bindphone.disabled {
		opacity: 0.2;
	}

  .agreementgroup {
    display: flex;
    flex-direction: row;
    font-size: 12px;
    line-height: 14px;
    position: absolute;
    bottom: 46px;
    align-self: center;
    align-items: center;
    padding-left: 20px;
    word-break: break-all;
  }

	.agreementgroup.disabled {
		opacity: 0.2;
	}

	.agreetext {
		opacity: 0.4;
	}

	.and {
		opacity: 0.4;
	}

	.privacyarea {
		display: flex;
		flex-wrap: wrap;
	}

  .privacystatement {
    font-weight: 500;
  }

  .shopping_agreement {
    font-weight: 500;
  }

  .logo {
    width: 80px;
    height: 80px;
    margin: 40px auto;
  }

	.ic_back {
		display: block;
		margin-top: 12px;
		width: 40px;
		height: 40px;
		border-radius: 20px;
		background-color: #e7e8ea;
	}

	.ic_back.disabled {
		opacity: 0.2;
	}

  .radioset {
    background-color: #f1f3f5;
    border-radius: 20px;
    border-color: #e7e8ea;
    margin-right: 16px;
    width: 24px;
    height: 24px;
    transform: scale(0.9);
  }

	.dialogpage {
		display: flex;
		justify-content: center;
		align-items: center;
		width: 100%;
		height: 100vh;
		background-color: rgba(0, 0, 0, 0.2);
		position: absolute;
		top: 0;
		left: 0;
	}

  .agreementdialog {
    margin: 0 16px;
    width: "100%";
    max-width: 400px;
    background-color: white;
    border-radius: 32px;
  }

	.dialogtitle {
		display: block;
		text-align: center;
		font-size: 20px;
		font-weight: bold;
		margin: 15px 24px;
	}

  .dialog_content {
    display: block;
    font-size: 16px;
    margin: 0 24px;
  }

  .agreementdialogbtns {
    display: flex;
    flex-direction: row;
    height: "100%";
    width: "100%";
    align-items: center;
    margin-top: 10px;
	margin-bottom: 12px;
    padding: 0 16px;
    justify-content: space-between;
    border: none;
  }

  .cancelbutton {
    height: 40px;
    font-size: 16px;
    font-weight: 500;
    border-radius: 24px;
    width: calc(50% + 24px);
    background-color: white;
    color: black;
    margin-right: 8px;
  }

  .confirmbutton {
    height: 40px;
    font-size: 16px;
    font-weight: 500;
    border-radius: 24px;
    width: calc(50% + 24px);
    background-color: #CE0E2D;
    color: white;
    margin-left: 8px;
  }

  .cancelbutton:active {
    background-color: #F5F5F5;
  }

  .confirmbutton:active {
    background-color: #a00c24;
  }

	uni-button:after {
		border: none;
	}
</style>
