/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

/**
 * @file This module provides the capabilities to use FIDO2 online authentication.
 * @kit OnlineAuthenticationKit
 */

import type common from '@ohos.app.ability.common';

/**
 * This module provides the capabilities to use fido authentication.
 *
 * @namespace fido2
 * @syscap SystemCapability.Security.FIDO2
 * @atomicservice
 * @since 6.0.0(20)
 */
declare namespace fido2 {
  /**
   * Authenticator attestation response in Uint8Array format.
   *
   * @typedef AuthenticatorAttestationResponse
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticatorAttestationResponse {
    /**
     * Attestation object in Uint8Array format.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly attestationObject: Uint8Array;
    /**
     * Obtains ClientData json data in Uint8Array format.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly clientDataJson: Uint8Array;
    /**
     * Algorithm of the credential in Uint8Array format.
     *
     * @type { Algorithm }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    publicKeyAlgorithm: Algorithm;
    /**
     * PublicKey in Uint8Array format.
     *
     * @type { ?Uint8Array }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    publicKey?: Uint8Array ;
    /**
     * Authenticator data in Uint8Array format.
     *
     * @type { Uint8Array }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorData: Uint8Array ;
    /**
     * The transports of the credential record.
     *
     * @type { string[] }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    transports: string[];
  }
  /**
   * Json type representations mirroring PublicKeyCredential,
   * suitable for submission to a Relying Party server as an application/json payload.
   *
   * @typedef AuthenticatorAttestationResponseJson
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticatorAttestationResponseJson {
    /**
     * Obtains ClientData json data.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    clientDataJson: string;
    /**
     * Authenticator data, as a json string.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorData: string;
    /**
     * The definition hints as to how clients might communicate with a particular authenticator
     * in order to obtain an assertion for a specific credential.
     *
     * @type { Array<string> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    transports: Array<string>;
    /**
     * PublicKey of the credential.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    publicKey?: string;
    /**
     * Algorithm of the credential.
     *
     * @type { Algorithm }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    publicKeyAlgorithm: Algorithm;
    /**
     * Attestation object, which is cryptographically protected against tampering by the client.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    attestationObject: string;
  }
  /**
   * Results of processing client extensions requested by the Relying Party upon
   * the RP’s invocation of either create() or get().
   *
   * @typedef AuthenticationExtensionsClientOutputsJson
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticationExtensionsClientOutputsJson {

  }
  /**
   * Authenticator’s response to a client’s request for generation of a new authentication assertion given
   * the Relying Party’s challenge and OPTIONAL list of credentials it is aware of.
   *
   * @typedef AuthenticatorAssertionResponseJson
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticatorAssertionResponseJson {
    /**
     * Obtains ClientData json data.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    clientDataJson: string;
    /**
     * Authenticator data.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorData: string;
    /**
     * Signature.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    signature: string;
    /**
     * User handle returned from the authenticator.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    userHandle?: string;
  }
  /**
   * Authenticator assertion response.
   *
   * @typedef AuthenticatorAssertionResponse
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticatorAssertionResponse {
    /**
     * Authenticator data.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly authenticatorData: Uint8Array;
    /**
     * Signature.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly signature: Uint8Array;
    /**
     * UserHandle.
     *
     * @type { ?Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly userHandle?: Uint8Array;
    /**
     * Obtains ClientData json data.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly clientDataJson: Uint8Array;
  }
  /**
   * Authentication extensions.
   *
   * @typedef AuthenticationExtensionsClientOutputs
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticationExtensionsClientOutputs {

  }
  /**
   * PublicKey attestation credential.
   *
   * @typedef PublicKeyAttestationCredential
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyAttestationCredential {
    /**
     * Raw credential id.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly rawId: Uint8Array;
    /**
     * Authentication attestation response.
     *
     * @type { AuthenticatorAttestationResponse }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly response: AuthenticatorAttestationResponse;
    /**
     * Attachment of the authenticator.
     *
     * @type { ?AuthenticatorAttachment }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly authenticatorAttachment?: AuthenticatorAttachment;
    /**
     * The credential’s identifier. The requirements for the identifier are distinct for each type of credential.
     *
     * @type { string }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly id: string;
    /**
     * This attribute’s getter returns the value of the object’s interface object's slot,
     * which specifies the credential type represented by this object.
     *
     * @type { string }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly type: string;
    /**
     * The client extension results.
     *
     * @type { AuthenticationExtensionsClientOutputs }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly clientExtensionResults: AuthenticationExtensionsClientOutputs;
    /**
     * Obtain the certification result of json data.
     *
     * @type { RegistrationResponseJson }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    registrationResponseJson: RegistrationResponseJson;
  }
  /**
   * Registration response of json.
   *
   * @typedef RegistrationResponseJson
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface RegistrationResponseJson {
    /**
     * The credential’s identifier, as a json string.
     * The requirements for the identifier are distinct for each type of credential.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    id: string;
    /**
     * Raw credential id, as a json string.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    rawId: string;
    /**
     * Authentication attestation response of json.
     *
     * @type { AuthenticatorAttestationResponseJson }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    response: AuthenticatorAttestationResponseJson;
    /**
     * Attachment of the authenticator.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorAttachment?: string;
    /**
     * The json results of processing client extensions requested
     * by the Relying Party upon the RP’s invocation of either create() or get().
     *
     * @type { AuthenticationExtensionsClientOutputsJson }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    clientExtensionResults: AuthenticationExtensionsClientOutputsJson;
    /**
     * This attribute’s getter returns the value of the object’s interface object's slot,
     * which specifies the credential type represented by this object.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    type: string;
  }
  /**
   * Defines FIDO2 authentication request parameters.
   *
   * @typedef PublicKeyCredentialRequestOptions
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyCredentialRequestOptions {
    /**
     * Obtains the challenge value.
     *
     * @type { Uint8Array }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    challenge: Uint8Array;
    /**
     * Timeout.
     *
     * @type { ?number }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    timeout?: number;
    /**
     * The rp id.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    rpId?: string;
    /**
     * Allowed credentials, the default value is an empty array.
     *
     * @type { ?Array<PublicKeyCredentialDescriptor> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    allowCredentials?: Array<PublicKeyCredentialDescriptor>;
    /**
     * User verification requirement enumeration, the default value is "preferred".
     *
     * @type { ?UserVerificationRequirement }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    userVerification?: UserVerificationRequirement;
    /**
     * Hints, the default value is an empty array.
     *
     * @type { ?Array<PublicKeyCredentialHint> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    hints?: Array<PublicKeyCredentialHint>;
    /**
     * Extension lists.
     *
     * @type { ?Map<string, Object> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    extensions?: Map<string, Object>;
  }
  /**
   * PublicKey assertion credential.
   *
   * @typedef PublicKeyAssertionCredential
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyAssertionCredential {
    /**
     * Raw credential id.
     *
     * @type { Uint8Array }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly rawId: Uint8Array;
    /**
     * Authentication assertion response.
     *
     * @type { AuthenticatorAssertionResponse }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly response: AuthenticatorAssertionResponse;
    /**
     * Attachment of the authenticator.
     *
     * @type { ?AuthenticatorAttachment }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly authenticatorAttachment?: AuthenticatorAttachment;
    /**
     * The credential’s identifier. The requirements for the identifier are distinct for each type of credential.
     *
     * @type { string }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly id: string;
    /**
     * This attribute’s getter returns the value of the object’s interface object's slot,
     * which specifies the credential type represented by this object.
     *
     * @type { string }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly type: string;
    /**
     * The client extension results.
     *
     * @type { AuthenticationExtensionsClientOutputs }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    clientExtensionResults: AuthenticationExtensionsClientOutputs;
    /**
     * Authentication extensions. The json type representations of PublicKeyCredential.
     *
     * @type { AuthenticationResponseJson }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticationResponseJson: AuthenticationResponseJson;
  }
  /**
   * Authentication extensions. The json type representations of publicKeyCredential.
   *
   * @typedef AuthenticationResponseJson
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticationResponseJson {
    /**
     * The credential’s identifier, as a json string.
     * The requirements for the identifier are distinct for each type of credential.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    id: string;
    /**
     * Raw credential id, as a json string.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    rawId: string;
    /**
     * The authenticator assertion response, the structure of the json string.
     *
     * @type { AuthenticatorAssertionResponseJson }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    response: AuthenticatorAssertionResponseJson;
    /**
     * Attachment of the authenticator.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorAttachment?: string;
    /**
     * The client extension results.
     *
     * @type { AuthenticationExtensionsClientOutputsJson }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    clientExtensionResults: AuthenticationExtensionsClientOutputsJson;
    /**
     * This attribute’s getter returns the value of the object’s interface object's slot,
     * which specifies the credential type represented by this object, as a json string.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    type: string;
  }
  /**
   * Enum of the mediation requirements.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum CredentialMediationRequirement {
    /**
     * User mediation is suppressed for the given operation. If the operation can be performed without user involvement,
     * wonderful. If user involvement is necessary, then the operation will return null rather than involving the user.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SILENT = "silent",
    /**
     * If credentials can be handed over for a given operation without user mediation, they will be.
     * If user mediation is required, then the user agent will involve the user in the decision.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    OPTIONAL = "optional",
    /**
     * If credentials can be handed over for a given operation without user mediation, they will be.
     * If user mediation is required, then the user agent will involve the user in the decision.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    CONDITIONAL = "conditional",
    /**
     * The user agent will not hand over credentials without user mediation,
     * even if the prevent silent access flag is unset for an origin.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    REQUIRED = "required"
  }
  /**
   * The options of credential creation.
   *
   * @typedef CredentialCreationOptions
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface CredentialCreationOptions {
    /**
     * Mediation requirements.
     *
     * @type { ?CredentialMediationRequirement }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    mediation?: CredentialMediationRequirement;
    /**
     * The options of publicKey credential creation.
     *
     * @type { PublicKeyCredentialCreationOptions }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    publicKey: PublicKeyCredentialCreationOptions;
  }
  /**
   * The options of credential request.
   *
   * @typedef CredentialRequestOptions
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface CredentialRequestOptions {
    /**
     * Mediation requirements.
     *
     * @type { ?CredentialMediationRequirement }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    mediation?: CredentialMediationRequirement;
    /**
     * The options of publicKey credential request.
     *
     * @type { PublicKeyCredentialRequestOptions }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    publicKey: PublicKeyCredentialRequestOptions;
  }
  /**
   * Status of the tokenBinding protocol.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum TokenBindingStatus {
    /**
     * Status during normal communication.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PRESENT = "present",
    /**
     * Token binding is supported, but communication is not yet available.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SUPPORTED = "supported"
  }
  /**
   * Token binding (protocol), used by the client to communicate with the relying party.
   *
   * @typedef TokenBinding
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface TokenBinding {
    /**
     * The binding status of the client.
     *
     * @type { TokenBindingStatus }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    status: TokenBindingStatus;
    /**
     * Id.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    id: string;
  }
  /**
   * For WebAuthn Relying Parties to reference when generating credentials to specify preferences
   * for credential delivery.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum AttestationConveyancePreference {
    /**
     * none Relying parties are not interested in validator proof, default value.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    NONE = "none",
    /**
     * The indirect relying party prefers to provide a verifiable attestation statement document,
     * but allows the customer to decide how to obtain such attestation statement.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    INDIRECT = "indirect",
    /**
     * Direct Relying parties want to receive attestation claims generated by verifiers.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    DIRECT = "direct",
    /**
     * The Relying Party wants to receive an enterprise attestation,
     * which is an attestation statement that may include information which uniquely identifies the authenticator.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    ENTERPRISE = "enterprise"
  }
  /**
   * Relying parties may require user authentication (verifying whether the current user is the user)
   * for some operations, but do not require other operations.
   * Enumeration types are defined to distinguish different requirement levels.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum UserVerificationRequirement {
    /**
     * User verification is required.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    REQUIRED = "required",
    /**
     * Relying parties prioritize user validation of the operation when possible,
     * but do not fail if the response does not have the user validation flag set.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PREFERRED = "preferred",
    /**
     * Relying parties do not want to use user authentication during operations.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    DISCOURAGED = "discouraged"
  }
  /**
   * Resident key requirement enumeration
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum ResidentKeyRequirement {
    /**
     * The Relying Party prefers creating a server-side credential, but will accept a client-side discoverable credential.
     * The client and authenticator SHOULD create a server-side credential if possible.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    DISCOURAGED = "discouraged",
    /**
     * The Relying Party strongly prefers creating a client-side discoverable credential,
     * but will accept a server-side credential.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PREFERRED = "preferred",
    /**
     * The Relying Party requires a client-side discoverable credential.
     * The client MUST return an error if a client-side discoverable credential cannot be created.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    REQUIRED = "required"
  }
  /**
   * Enum for authenticator transport.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum AuthenticatorAttachment {
    /**
     * Platform authenticator, fingerprint, face, etc.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PLATFORM = "platform",
    /**
     * Cross-platform authenticator, also known as roaming authentication, includes Bluetooth, NFC, and USB.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    CROSS_PLATFORM = "cross-platform"
  }
  /**
   * This parameter is specified by the webAuthn relying party and is related to the authenticator.
   *
   * @typedef AuthenticatorSelectionCriteria
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticatorSelectionCriteria {
    /**
     * Authenticator attachment.
     *
     * @type { ?AuthenticatorAttachment }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorAttachment?: AuthenticatorAttachment;
    /**
     * Resident Key.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    residentKey?: string;
    /**
     * Is require resident Key or not, the default value is false.
     *
     * @type { ?boolean }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    requireResidentKey?: boolean;
    /**
     * User Verification, the default value is "preferred".
     *
     * @type { ?UserVerificationRequirement }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    userVerification?: UserVerificationRequirement;
  }
  /**
   * Enum for authenticator transport.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum AuthenticatorTransport {
    /**
     * USB.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    USB = "usb",
    /**
     * NFC.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    NFC = "nfc",
    /**
     * BLE.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    BLE = "ble",
    /**
     * Smart card.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SMART_CARD = "smart-card",
    /**
     * Hybrid.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    HYBRID = "hybrid",
    /**
     * Internal.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    INTERNAL = "internal"
  }
  /**
   * Parameters for registering or authenticating credentials.
   *
   * @typedef PublicKeyCredentialDescriptor
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyCredentialDescriptor {
    /**
     * Credential type.
     *
     * @type { PublicKeyCredentialType }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    type: PublicKeyCredentialType;
    /**
     * Credential id.
     *
     * @type { Uint8Array }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    id: Uint8Array;
    /**
     * Defines the authenticator access type (USB, NFC, Bluetooth).
     *
     * @type { ?Array<AuthenticatorTransport> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    transports?: Array<AuthenticatorTransport>;
  }
  /**
   * Enum for algorithm.
   *
   * @enum { number }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum Algorithm {
    /**
     * ES256.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    ES256 = -7,
    /**
     * ES384.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    ES384 = -35,
    /**
     * ES384.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    ES512 = -36,
    /**
     * RS256.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    RS256 = -257,
    /**
     * RS384.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    RS384 = -258,
    /**
     * RS512.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    RS512 = -259,
    /**
     * PS256.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PS256 = -37,
    /**
     * PS384.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PS384 = -38,
    /**
     * PS512.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PS512 = -39
  }
  /**
   * Enum for publicKey credential hint.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum PublicKeyCredentialHint {
    /**
     * Security key.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SECURITY_KEY = "security-key",
    /**
     * Client device.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    CLIENT_DEVICE = "client-device",
    /**
     * Hybrid.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    HYBRID = "hybrid"
  }
  /**
   * Enum for publicKey credential type.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum PublicKeyCredentialType {
    /**
     * Public key.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PUBLIC_KEY = "public-key"
  }
  /**
   * Additional options for creating a new authentication credential.
   *
   * @typedef PublicKeyCredentialParameters
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyCredentialParameters {
    /**
     * PublicKey credential type.
     *
     * @type { PublicKeyCredentialType }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    type: PublicKeyCredentialType;
    /**
     * Algorithm.
     *
     * @type { Algorithm }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    alg: Algorithm;
  }
  /**
   * Attribute that represents the relying party when creating a new credential.
   *
   * @typedef PublicKeyCredentialUserEntity
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyCredentialUserEntity {
    /**
     * Id.
     *
     * @type { Uint8Array }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    id: Uint8Array;
    /**
     * DisplayName.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    displayName: string;
    /**
     * Name.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    name: string;
  }
  /**
   * Attribute that represents the relying party when creating a new credential.
   *
   * @typedef PublicKeyCredentialRpEntity
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyCredentialRpEntity {
    /**
     * Id.
     *
     * @type { ?string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    id?: string;
    /**
     * Name.
     *
     * @type { string }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    name: string;
  }
  /**
   * Indicates the option for creating a new authentication credential.
   *
   * @typedef PublicKeyCredentialCreationOptions
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface PublicKeyCredentialCreationOptions {
    /**
     * The relying party attribute when creating a new credential.
     *
     * @type { PublicKeyCredentialRpEntity }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    rp: PublicKeyCredentialRpEntity;
    /**
     * User information.
     *
     * @type { PublicKeyCredentialUserEntity }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    user: PublicKeyCredentialUserEntity;
    /**
     * Challenge.
     *
     * @type { Uint8Array }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    challenge: Uint8Array;
    /**
     * The list of additional parameters for authentication credentials.
     *
     * @type { Array<PublicKeyCredentialParameters> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    pubKeyCredParams: Array<PublicKeyCredentialParameters>;
    /**
     * Timeout.
     *
     * @type { ?number }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    timeout?: number;
    /**
     * The list of additional parameters for authentication credentials, the default value is an empty array.
     *
     * @type { ?Array<PublicKeyCredentialDescriptor> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    excludeCredentials?: Array<PublicKeyCredentialDescriptor>;
    /**
     * The configuration items related to the authenticator.
     *
     * @type { ?AuthenticatorSelectionCriteria }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    authenticatorSelection?: AuthenticatorSelectionCriteria;
    /**
     * Hints, the default value is an empty array.
     *
     * @type { ?Array<PublicKeyCredentialHint> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    hints?: Array<PublicKeyCredentialHint>;
    /**
     * Credential Preferences, the default value is "none".
     *
     * @type { ?AttestationConveyancePreference }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    attestation?: AttestationConveyancePreference;
    /**
     * The Relying Party MAY use this OPTIONAL member to specify a preference regarding
     * the attestation statement format used by the authenticator, the default value is an empty array.
     *
     * @type { ?Array<string> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    attestationFormats?: Array<string>;
    /**
     * Extended parameters.
     *
     * @type { ?Map<string, Object> }
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    extensions?: Map<string, Object>;
  }
  /**
   * Enum for uvm
   *
   * @enum { number }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum Uvm {
    /**
     * Fingerprint authenticator
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    UVM_FINGERPRINT = 2,
    /**
     * PIN authenticator.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    UVM_PIN = 4,
    /**
     * 3D face authenticator.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    UVM_FACE = 16
  }
  /**
   * Enum for client capability.
   *
   * @enum { string }
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  enum ClientCapability {
    /**
     * Conditional of create.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    CONDITIONAL_CREATE = "conditionalCreate",
    /**
     * Conditional of get.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    CONDITIONAL_GET = "conditionalGet",
    /**
     * Hybrid transport.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    HYBRID_TRANSPORT = "hybridTransport",
    /**
     * Passkey platform authenticator.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    PASSKEY_PLATFORM_AUTHENTICATOR = "passkeyPlatformAuthenticator",
    /**
     * User verifying platform authenticator.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    USER_VERIFYING_PLATFORM_AUTHENTICATOR = "userVerifyingPlatformAuthenticator",
    /**
     * Related origins.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    RELATED_ORIGINS = "relatedOrigins",
    /**
     * Signal all accepted credentials.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SIGNAL_ALL_ACCEPTED_CREDENTIALS = "signalAllAcceptedCredentials",
    /**
     * Signal current user details.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SIGNAL_CURRENT_USER_DETAILS = "signalCurrentUserDetails",
    /**
     * Signal unknown credential.
     *
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    SIGNAL_UNKNOWN_CREDENTIAL = "signalUnknownCredential"
  }
  /**
   * Describes the current state of authenticators available to the application.
   *
   * @typedef AuthenticatorMetadata
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  interface AuthenticatorMetadata {
    /**
     * The authenticator aaguid.
     *
     * @type { string }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly aaguid: string;
    /**
     * The supported authenticator types.
     *
     * @type { Uvm }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly uvm: Uvm;
    /**
     * Indicates whether the authenticator is available.
     *
     * @type { boolean }
     * @readonly
     * @syscap SystemCapability.Security.FIDO2
     * @atomicservice
     * @since 6.0.0(20)
     */
    readonly isAvailable: boolean;
  }
  /**
   * When the value for a given capability is true, the feature is known to be currently supported by the client.
   *
   * @permission ohos.permission.ACCESS_FIDO2_ONLINEAUTH
   * @param { common.Context } context - The context of an ability.
   * @returns { Promise<Map<ClientCapability, boolean>> } return parameter of type Map.
   * @throws { BusinessError } 201 - Permission denied.
   * @throws { BusinessError } 1021300007 - Unknown error.
   * @throws { BusinessError } 1021300011 - Failed to connect to the service.
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  function getClientCapabilities(context: common.Context): Promise<Map<ClientCapability, boolean>>;
  /**
   * Gets the list of supported platform authenticators.
   *
   * @permission ohos.permission.ACCESS_FIDO2_ONLINEAUTH
   * @param { common.Context } context - The context of an ability.
   * @returns { Array<AuthenticatorMetadata> } return parameter of type AuthenticatorMetadata.
   * @throws { BusinessError } 201 - Permission denied.
   * @throws { BusinessError } 1021300007 - Unknown error.
   * @throws { BusinessError } 1021300011 - Failed to connect to the service.
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  function getPlatformAuthenticators(context: common.Context): Promise<Array<AuthenticatorMetadata>>;
  /**
   * Registration based on fido2.
   *
   * @permission ohos.permission.ACCESS_FIDO2_ONLINEAUTH
   * @param { common.Context } context - The context of an ability.
   * @param { CredentialCreationOptions } options - The FIDO2 registration request options.
   * @param { TokenBinding } [tokenBinding]  - The FIDO2 registration tokenBinding.
   * @returns { Promise<PublicKeyAttestationCredential> } return FIDO2 registration response.
   * @throws { BusinessError } 201 - Permission denied.
   * @throws { BusinessError } 1021300001 - The system does not support.
   * @throws { BusinessError } 1021300002 - Invalid state.
   * @throws { BusinessError } 1021300003 - System integrity check failed.
   * @throws { BusinessError } 1021300004 - User abort.
   * @throws { BusinessError } 1021300005 - Time out.
   * @throws { BusinessError } 1021300006 - Encoding error.
   * @throws { BusinessError } 1021300007 - Unknown error.
   * @throws { BusinessError } 1021300008 - The constraint condition is incorrect.
   * @throws { BusinessError } 1021300009 - Data error.
   * @throws { BusinessError } 1021300010 - User Rejects.
   * @throws { BusinessError } 1021300011 - Failed to connect to the service.
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  function register(context: common.Context, options: CredentialCreationOptions, tokenBinding?: TokenBinding): Promise<PublicKeyAttestationCredential>;
  /**
   * Authentication based on fido2.
   *
   * @permission ohos.permission.ACCESS_FIDO2_ONLINEAUTH
   * @param { common.Context } context - The context of an ability.
   * @param { CredentialRequestOptions } options - The FIDO2 credential request options.
   * @param { TokenBinding } [tokenBinding] - The FIDO2 Authentication tokenBinding.
   * @returns { Promise<PublicKeyAssertionCredential> } return FIDO2 Authentication response.
   * @throws { BusinessError } 201 - Permission denied.
   * @throws { BusinessError } 1021300002 - Invalid state.
   * @throws { BusinessError } 1021300003 - System integrity check failed.
   * @throws { BusinessError } 1021300004 - User abort.
   * @throws { BusinessError } 1021300005 - Time out.
   * @throws { BusinessError } 1021300006 - Encoding error.
   * @throws { BusinessError } 1021300007 - Unknown error.
   * @throws { BusinessError } 1021300009 - Data error.
   * @throws { BusinessError } 1021300010 - User Rejects.
   * @throws { BusinessError } 1021300011 - Failed to connect to the service.
   * @throws { BusinessError } 1021310001 - Invalid CTAP command.
   * @throws { BusinessError } 1021310002 - The command contains invalid parameters.
   * @throws { BusinessError } 1021310003 - Invalid message or attribute length.
   * @throws { BusinessError } 1021310004 - Invalid CBOR or unpredictable error.
   * @throws { BusinessError } 1021310005 - Failed to parse the CBOR.
   * @throws { BusinessError } 1021310006 - Not found valid credentials.
   * @throws { BusinessError } 1021310007 - Not allowed.
   * @throws { BusinessError } 1021310008 - User verification failed.
   * @throws { BusinessError } 1021310009 - Other error.
   * @syscap SystemCapability.Security.FIDO2
   * @atomicservice
   * @since 6.0.0(20)
   */
  function authenticate(context: common.Context, options: CredentialRequestOptions, tokenBinding?: TokenBinding): Promise<PublicKeyAssertionCredential>;
}

export default fido2;
