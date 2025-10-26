/*
 * Copyright 2024. Huawei Technologies Co., Ltd. All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 *
 */

package com.huawei.iap.server.demo;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.PublicKey;
import java.security.cert.CertPath;
import java.security.cert.CertPathValidator;
import java.security.cert.CertPathValidatorException;
import java.security.cert.Certificate;
import java.security.cert.CertificateFactory;
import java.security.cert.PKIXCertPathValidatorResult;
import java.security.cert.PKIXParameters;
import java.security.cert.PKIXRevocationChecker;
import java.security.cert.TrustAnchor;
import java.security.cert.X509Certificate;
import java.security.interfaces.ECPublicKey;
import java.util.Arrays;
import java.util.Base64;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

/**
 * JWSChecker
 *
 * @author iap
 * @since 2024-09-26
 */
public class JWSChecker {

    private static final String CA_CERT_FILE_PATH = "/path/to/cer/RootCaG2Ecdsa.cer";// TODO: Need to replace it with the actual value.

    /**
     * JWS HEADER PARAM X5C: Indicates the X.509 certificate chain. The sequence is leaf certificate, intermediate certificate, and root certificate.
     */
    private static final String HEADER_PARAM_X5C = "x5c";

    private static final int X5C_CHAIN_LENGTH = 3;

    /**
     * JWS HEADER PARAM ALG：Algorithm type. The value is always ES256.
     */
    private static final String HEADER_PARAM_ALG_ES256 = "ES256";

    private static final String LEAF_CERT_OID = "1.3.6.1.4.1.2011.2.415.1.1";

    private static final Boolean CRL_SOFT_FAIL_ENABLED = false; // TODO: Determine whether to set PKIXRevocationChecker.Option.SOFT_FAIL (ignore CRL certificate download exception) based on application Security Policy.

    /**
     * Used to verify JWS and decode the payload.
     * @param jwsStr JWS string
     * @return payload string
     * @throws Exception exception
     */
    public static String checkAndDecodeJWS(String jwsStr) throws Exception {
        if (jwsStr == null || jwsStr.isEmpty()) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception("jwsStr was null");
        }
        DecodedJWT decodedJWT = JWT.decode(jwsStr);
        if (!HEADER_PARAM_ALG_ES256.equals(decodedJWT.getAlgorithm())) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception("alg must be ES256");
        }
        String[] x5cChain = decodedJWT.getHeaderClaim(HEADER_PARAM_X5C).asArray(String.class);
        if (x5cChain == null) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception("x5c chain was null");
        }
        // Verify the x5c certificate chain and obtain the public key.
        PublicKey publicKey = verifyChainAndGetPubKey(x5cChain);

        // Use the public key to verify the signature of the jws.
        JWTVerifier jwtVerifier = JWT.require(Algorithm.ECDSA256((ECPublicKey) publicKey)).build();
        jwtVerifier.verify(decodedJWT);

        // Decode and return the payload.
        return new String(Base64.getUrlDecoder().decode(decodedJWT.getPayload()), StandardCharsets.UTF_8);
    }

    private static PublicKey verifyChainAndGetPubKey(String[] certificates) throws Exception {
        CertificateFactory certificateFactory = CertificateFactory.getInstance("X.509");
        List<Certificate> certificateList = new LinkedList<>();
        for (String certificate : certificates) {
            InputStream inputStream = new ByteArrayInputStream(Base64.getDecoder().decode(certificate));
            certificateList.add(certificateFactory.generateCertificate(inputStream));
        }
        if (certificateList.size() != X5C_CHAIN_LENGTH) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception("invalid cert chain length");
        }
        PKIXCertPathValidatorResult certPathValidatorResult;
        try {
            PKIXParameters parameters = loadRootCAAndPKIX();
            CertPathValidator validator = CertPathValidator.getInstance("PKIX");
            parameters.setRevocationEnabled(true);
            PKIXRevocationChecker revocationChecker = (PKIXRevocationChecker) validator.getRevocationChecker();
            // TODO: Determine whether to set PKIXRevocationChecker.Option.SOFT_FAIL (ignore CRL certificate download exception) based on application Security Policy.
            if (CRL_SOFT_FAIL_ENABLED) {
                revocationChecker.setOptions(new HashSet<>(
                    Arrays.asList(PKIXRevocationChecker.Option.PREFER_CRLS, PKIXRevocationChecker.Option.NO_FALLBACK,
                        PKIXRevocationChecker.Option.SOFT_FAIL)));
            } else {
                revocationChecker.setOptions(new HashSet<>(
                    Arrays.asList(PKIXRevocationChecker.Option.PREFER_CRLS, PKIXRevocationChecker.Option.NO_FALLBACK)));
            }
            parameters.addCertPathChecker(revocationChecker);
            CertPath certPath = certificateFactory.generateCertPath(certificateList.subList(0, X5C_CHAIN_LENGTH - 1));
            certPathValidatorResult = (PKIXCertPathValidatorResult) validator.validate(certPath, parameters);
        } catch (Exception e) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception(e);
        }

        Certificate iapCert = certificateList.get(0);
        if (!(iapCert instanceof X509Certificate)) {
            // TODO: Need to replace it with the actual business logic.
            throw new Exception("leaf certificate must be X509 format");
        }
        X509Certificate x509Certificate = (X509Certificate) iapCert;
        if (x509Certificate.getNonCriticalExtensionOIDs() == null ||
            !x509Certificate.getNonCriticalExtensionOIDs().contains(LEAF_CERT_OID)) {
            // TODO: Need to replace it with the actual business logic.
            throw new CertPathValidatorException("OID not found");
        }
        return certPathValidatorResult.getPublicKey();
    }

    private static PKIXParameters loadRootCAAndPKIX() throws Exception {
        PKIXParameters parameters;
        // TODO: Under Java 8, Need to close the resource in the finally block.
        try (InputStream fis = Files.newInputStream(Paths.get(CA_CERT_FILE_PATH))) {
            CertificateFactory certificateFactory = CertificateFactory.getInstance("X.509");
            Certificate trustCert = certificateFactory.generateCertificate(fis);
            if (!(trustCert instanceof X509Certificate)) {
                // TODO: Need to replace it with the actual business logic.
                throw new RuntimeException("root certificate must be X509 format");
            }
            Set<TrustAnchor> trustAnchors = new HashSet<>();
            trustAnchors.add(new TrustAnchor((X509Certificate) trustCert, null));
            parameters = new PKIXParameters(trustAnchors);
        }
        return parameters;
    }

}
