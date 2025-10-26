/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { gamePlayer } from '@kit.GameServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { authentication } from '@kit.AccountKit';
import { util } from '@kit.ArkTS';

/**
 * API class.
 */
export class ApiUtil {
  // For details, please refer to the official documentation.
  gamePlayerId: string = '';
  teamPlayerId: string = '';
  thirdOpenId: string = '';

  // Initialize the Game Service Kit.
  public init(context: common.UIAbilityContext): void {
    hilog.info(0x0000, 'testTag', `Enter init.`);
    try {
      // After successful page loading, call the initialization API.
      gamePlayer.init(context, () => {
        hilog.info(0x0000, 'testTag', `Succeeded init.`);

        // After the initialization succeeds, register the playerChanged event.
        // When player information changes, for example, when the game account is switched, the playerChanged event callback method will be executed to notify you to clear the local cache and call the unionLogin API again.
        this.onPlayerChangedEventRegister();

        // The session mechanism is not mandatory. You can decide whether to build the mechanism.
        // If you build a local session mechanism, when the playerChanged event is detected, you need to clear the session and call the unionLogin API to display the pop-up again for multi-provider sign-in.
        // For details about listening to the playerChanged event, see the implementation of the this.onPlayerChangedEventRegister method.
        if (this.isExistValidSession()) {
          // Directly enter the game.
          return;
        }

        // Call the API for multi-provider sign-in.
        this.unionLogin(context);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to init. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // Callback method of the playerChanged event.
  private onPlayerChangedEventCallback(result: gamePlayer.PlayerChangedResult) {
    if (result.event === gamePlayer.PlayerChangedEvent.SWITCH_GAME_ACCOUNT) {
      // After the local session is cleared, call the unionLogin API again.
    }
  }

  // Register the game account switching event.
  private onPlayerChangedEventRegister(): void {
    hilog.info(0x0000, 'testTag', `Enter onPlayerChangedEventRegister.`);

    try {
      gamePlayer.on('playerChanged', this.onPlayerChangedEventCallback);
    } catch (error) {
      hilog.error(0x0000, 'testTag',
        `Failed to rigister playerChanged event. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // Multi-provider sign-in.
  public unionLogin(context: common.UIAbilityContext, showLoginDialog?: boolean): void {
    hilog.info(0x0000, 'testTag', `Enter unionLogin.`);

    let thirdAccountInfo: gamePlayer.ThirdAccountInfo = {
      'accountName': 'GameOfficialAccountName', // Official game account name.
      'accountIcon': $r("app.media.startIcon"), // Official game account icon.
    };
    let unionLoginParam: gamePlayer.UnionLoginParam = {
      showLoginDialog: showLoginDialog ?? false, // The default value is false. To switch to another account or perform other operations, set this parameter to true.
      thirdAccountInfos: [
        thirdAccountInfo  // The total size of official game account icons cannot exceed 35 KB.
      ]
    };

    try {
      gamePlayer.unionLogin(context, unionLoginParam).then((result: gamePlayer.UnionLoginResult) => {
        hilog.info(0x0000, 'testTag', `Succeeded in union login.`);
        this.gamePlayerId = result.localPlayer?.gamePlayerId ?? '';
        this.teamPlayerId = result.localPlayer?.teamPlayerId ?? '';
        let accountName = result.accountName;
        if (accountName === 'hw_account') {
          if (result.needBinding) {
            // When needBinding is set to true (the association scene), the player ID needs to be associated with the official game account.
            // Call the createAuthorizationWithHuaweiIDRequest API to create an authorization request (to obtain the mobile number).
            this.createAuthorizationAndVerifyPlayer(context);
          } else {
            // When needBinding is set to false (the transfer scene), call the createLoginWithHuaweiIDRequest API to create a sign-in request.
            this.createLoginAndVerifyPlayer(context);
          }
        } else if (accountName === 'official_account' || accountName === thirdAccountInfo.accountName) {
          // 1. Sign in to the game using the official account.
          // 2. After a successful sign-in, call the verifyLocalPlayer API to perform compliance verification.
          // 3. After the compliance verification succeeds, the game must call savePlayerRole to report the player's role information when the player creates a role.

          // After a player signs in to the game with an official game account, call the compliance verification API.
          this.thirdOpenId = '123xxxx'; // thirdOpenId indicates the ID of the official game account.
          this.verifyLocalPlayer(context);
        }
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to union login. Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to union login. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // Associate the player account.
  // thirdOpenId indicates the ID of the official game account.
  // teamPlayerId indicates the account that corresponds to the player's HUAWEI ID.
  public bindPlayer(context: common.UIAbilityContext, thirdOpenId: string, teamPlayerId: string): void {
    hilog.info(0x0000, 'testTag', `Enter bindPlayer.`);

    try {
      gamePlayer.bindPlayer(context, thirdOpenId, teamPlayerId).then(() => {
        hilog.info(0x0000, 'testTag', `Succeeded in binding player.`);
        // Save the association result persistently.
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to bind player. Code: ${error.code}, message: ${error.message}`);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to bind player. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // Compliance verification.
  public verifyLocalPlayer(context: common.UIAbilityContext): void {
    hilog.info(0x0000, 'testTag', `Enter verifyLocalPlayer.`);
    let request: gamePlayer.ThirdUserInfo = {
      thirdOpenId: this.thirdOpenId, // ID of the official game account.
      isRealName: true, // Indicates whether the player has passed identity verification. Options: true and false.
    };

    try {
      gamePlayer.verifyLocalPlayer(context, request).then(() => {
        hilog.info(0x0000, 'testTag', `Succeeded in verifying local player.`);
        // If the compliance verification succeeds, the player is allowed to enter the game.
      }).catch((error: BusinessError) => {
        hilog.error(0x0000, 'testTag', `Failed to verify local player. Code: ${error.code}, message: ${error.message}`);
        // If the compliance verification fails, the player is not allowed to enter the game.
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to verify local player. Code: ${error.code}, message: ${error.message}`);
      // If the compliance verification fails, the player is not allowed to enter the game.
    }
  }

  // Submit the player's role information.
  // The game must call savePlayerRole to report the player's role information when the player creates a role.
  public savePlayerRole(context: common.UIAbilityContext): void {
    hilog.info(0x0000, 'testTag', `Enter savePlayerRole.`);
    let request: gamePlayer.GSKPlayerRole = {
      roleId: '123', // Player's role ID. If the game does not have a role system, pass 0. Do not pass "" or null.
      roleName: 'Jason', // Player's role name. If the game does not have a role system, pass default. Do not pass "" or null.
      serverId: '456',
      serverName: 'Zhangshan',
      gamePlayerId: this.gamePlayerId, // Pass the actually obtained value of gamePlayerId.
      teamPlayerId: this.teamPlayerId,
      thirdOpenId: this.thirdOpenId
    };

    try {
      gamePlayer.savePlayerRole(context, request).then(() => {
        hilog.info(0x0000, 'testTag', `Succeeded in saving player info.`);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to save player info. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // When needBinding is set to true, the player ID needs to be associated with the official game account.
  // In this case, call createAuthorizationWithHuaweiIDRequest to create a sign-in request and set parameters to obtain an authorization code.
  private createAuthorizationAndVerifyPlayer(context: common.UIAbilityContext): void {
    hilog.info(0x0000, 'testTag', `Enter createAuthorizationAndVerifyPlayer.`);
    // Create an authorization request and set parameters.
    let authRequest = new authentication.HuaweiIDProvider().createAuthorizationWithHuaweiIDRequest();
    // To obtain the avatar, nickname, and mobile number, the following scope needs to be passed:
    authRequest.scopes = ['profile', 'phone'];
    // If server-side development is required, the following permission needs to be passed to obtain an authorization code.
    authRequest.permissions = ['serviceauthcode'];
    // Indicates whether the sign-in needs user authorization. If the value is true but the user has not signed in or given authorization, the user sign-in or authorization screen will be displayed.
    authRequest.forceAuthorization = true;
    authRequest.state = util.generateRandomUUID();

    try {
      // Execute the authorization request.
      let controller = new authentication.AuthenticationController(context);
      controller.executeRequest(authRequest, (err, data) => {
        if (err) {
          hilog.error(0x0000, 'testTag', `Failed to auth. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        let authorizationWithHuaweiIDResponse = data as authentication.AuthorizationWithHuaweiIDResponse;
        let state = authorizationWithHuaweiIDResponse.state;
        if (state != undefined && authRequest.state != state) {
          hilog.error(0x0000, 'testTag',
            `Failed to auth, state is different. State: ${authorizationWithHuaweiIDResponse.state}, authorizationCode: $(authorizationWithHuaweiIDResponse?.data?.authorizationCode)`);
          return;
        }

        hilog.info(0x0000, 'testTag', `Succeeded in authing: ${authorizationWithHuaweiIDResponse}`);
        let authorizationWithHuaweiIDCredential = authorizationWithHuaweiIDResponse.data!;
        let avatarUri = authorizationWithHuaweiIDCredential.avatarUri;
        let nickName = authorizationWithHuaweiIDCredential.nickName;
        let authorizationCode = authorizationWithHuaweiIDCredential.authorizationCode;
        // Process avatarUri, nickName, and authorizationCode and verify the player information.
        // 1. The game client uploads the player information (such as the authorization code and player ID) to your server.
        // 2. Your server uses the authorization code to call the access token obtaining API of the Huawei Account Kit server to obtain the player's access token.
        // 3. Your server uses the access token to call the user information obtaining API of the Huawei Account Kit server to obtain the authorized mobile number.
        // 4. Your server calls the player information obtaining API of the Huawei game server to obtain the server-side player ID based on the access token.
        // 5. Your server verifies the consistency of the player IDs obtained by the client and server.

        this.thirdOpenId = '123xxxx'; // thirdOpenId indicates the ID of the official game account.
        // After the game server has successfully verified the player information, perform the following operations:
        // 1. Check whether the mobile number has been registered with the official game account. If not, register the mobile number.
        // 2. Check whether teamPlayerId has been associated with the official game account. If not, associate them.
        // 3. Call the compliance verification API.
        // 4. After the compliance verification succeeds, the game must call savePlayerRole to report the player's role information when the player creates a role.
        if (!this.isBinding(this.teamPlayerId)) {
          // Associate the player ID with the official game account.
          this.bindPlayer(context, this.thirdOpenId, this.teamPlayerId);
        }
        // Perform compliance verification.
        this.verifyLocalPlayer(context);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to auth. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // When needBinding is set to false, the player ID does not need to be associated with the official game account.
  // In this case, call createLoginWithHuaweiIDRequest to create a sign-in request and set parameters to obtain an authorization code.
  private createLoginAndVerifyPlayer(context: common.UIAbilityContext): void {
    hilog.info(0x0000, 'testTag', `Enter createAuthorizationAndVerifyPlayer.`);
    // Create a sign-in request and set parameters.
    let loginRequest = new authentication.HuaweiIDProvider().createLoginWithHuaweiIDRequest();
    // Indicates whether to forcibly display the HUAWEI ID sign-in screen when a user has not signed in.
    loginRequest.forceLogin = true;
    loginRequest.state = util.generateRandomUUID();

    try {
      // Execute the sign-in request.
      let controller = new authentication.AuthenticationController(context);
      controller.executeRequest(loginRequest, (err, data) => {
        if (err) {
          hilog.error(0x0000, 'testTag', `Failed to login. Code: ${err.code}, message: ${err.message}`);
          return;
        }
        let loginWithHuaweiIDResponse = data as authentication.LoginWithHuaweiIDResponse;
        let state = loginWithHuaweiIDResponse.state;
        if (state != undefined && loginRequest.state != state) {
          hilog.error(0x0000, 'testTag',
            `Failed to login, state is different. State: ${loginWithHuaweiIDResponse.state}, authorizationCode: $(loginWithHuaweiIDResponse?.data?.authorizationCode)`);
          return;
        }

        hilog.info(0x0000, 'testTag', `Succeeded in logining.`);
        let loginWithHuaweiIDCredential = loginWithHuaweiIDResponse.data!;
        let authorizationCode = loginWithHuaweiIDCredential.authorizationCode;
        // Process the authorization code.
        // 1. The game client uploads the player information (such as the authorization code and player ID) to your server.
        // 2. Your server uses the authorization code to call the access token obtaining API of the Huawei Account Kit server to obtain the player's access token.
        // 3. Your server calls the player information obtaining API of the Huawei game server to obtain the server-side player ID based on the access token.
        // 4. Your server verifies the consistency of the player IDs obtained by the client and server.
        // 5. After a player signs in to the game with an official game account, call the compliance verification API. No account association operation is needed.
        // 6. After the compliance verification succeeds, the game must call savePlayerRole to report the player's role information when the player creates a role.
        this.thirdOpenId = ''; // thirdOpenId indicates the ID of the official game account. Here it is assigned an empty string.
        this.verifyLocalPlayer(context);
      });
    } catch (error) {
      hilog.error(0x0000, 'testTag', `Failed to login. Code: ${error.code}, message: ${error.message}`);
    }
  }

  // Check whether teamPlayerId has been associated with the official game account.
  private isBinding(teamPlayerId: string): boolean {
    // Check whether teamPlayerId has been associated with the official game account. The default value false is returned, indicating that teamPlayerId has not been associated.
    // Query your game server to check the account association status.
    return false;
  }

  // Check whether the local session mechanism exists and whether the session is within the validity period.
  private isExistValidSession(): boolean {
    return false;
  }
}
