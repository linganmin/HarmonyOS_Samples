/*
* FAQ:ID Token的使用场景与使用方法
 */
// [Start IdToken2]
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.auth0.jwk.InvalidPublicKeyException;
import com.auth0.jwk.Jwk;
import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTDecodeException;
import com.auth0.jwt.exceptions.JWTVerificationException;
import com.auth0.jwt.exceptions.TokenExpiredException;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpEntity;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import java.nio.charset.StandardCharsets;
import java.security.GeneralSecurityException;
import java.security.Security;
import java.security.Signature;
import java.security.interfaces.RSAPublicKey;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
public class IDTokenParser {
    // 请替换为您的Client ID
    private final static String CLIENT_ID = "123456";
    private final static int MAX_PUBLIC_KEY_SIZE = 4;
    // 缓存jwt公钥信息
    private final Map<String, RSAPublicKey> keyId2PublicKey = new HashMap<>();
    /**
     * JWK JSON Web Key端点，开发者可以从该端点获取最近两天的JWK
     * 公钥在24小时内更新。确保以下ID Token在24小时内生成
     */
    private static final String CERT_URL = "https://oauth-login.cloud.huawei.com/oauth2/v3/certs";
    // ID Token的issuer
    public static final String ID_TOKEN_ISSUE = "https://accounts.huawei.com";
    public static final String ALG_RS256 = "RS256";
    public final static String ALG_PS256 = "PS256";
    public static void main(String[] args) throws Exception {
        // 由上述CLIENT_ID对应值生成的ID Token
        String idToken = "<idToken>";
        IDTokenParser idTokenParser = new IDTokenParser();
        JSONObject idTokenInfo = idTokenParser.verifyAndParse(idToken);
        // 解析获取ID Token中的数据，例：解析获取iss
        String iss = idTokenInfo.getString("iss");
    }
    /**
     * 验证并解析ID Token
     * @param idToken idToken
     * @return ID Token携带的信息
     * @throws Exception 异常
     */
    public JSONObject verifyAndParse(String idToken) throws Exception {
        try {
            DecodedJWT decoder = JWT.decode(idToken);
            if (!decoder.getIssuer().equals(ID_TOKEN_ISSUE)) {
                // issuer校验不通过，抛出异常（异常类型可自行选择）
                throw new RuntimeException("issuer no match");
            }
            if (decoder.getAudience().size() > 0) {
                if (!decoder.getAudience().get(0).equals(CLIENT_ID)) {
                    // audience校验不通过，抛出异常（异常类型可自行选择）
                    throw new RuntimeException("audience no match");
                }
            }
            // 获取ID Token签名使用的算法
            String alg = decoder.getAlgorithm();
            if (ALG_RS256.equals(alg)) {
                Algorithm algorithm = Algorithm.RSA256(getRSAPublicKeyByKid(decoder.getKeyId()), null);
                JWTVerifier verifier = JWT.require(algorithm).build();
                JSONObject jsonObject = JSONObject.parseObject(new String(Base64.decodeBase64(decoder.getPayload())));
                // 验证签名
                verifier.verify(decoder);
                jsonObject.put("alg", decoder.getAlgorithm());
                jsonObject.put("typ", decoder.getType());
                jsonObject.put("kid", decoder.getKeyId());
                return jsonObject;
            } else if (ALG_PS256.equals(alg)) {
                PS256Algorithm algorithm = new PS256Algorithm(getRSAPublicKeyByKid(decoder.getKeyId()));
                boolean verifyResult = algorithm.verify(decoder.getHeader(), decoder.getPayload(),
                    decoder.getSignature());
                if (verifyResult) {
                    JSONObject jsonObject = JSONObject.parseObject(
                        new String(Base64.decodeBase64(decoder.getPayload())));
                    jsonObject.put("alg", decoder.getAlgorithm());
                    jsonObject.put("typ", decoder.getType());
                    jsonObject.put("kid", decoder.getKeyId());
                    return jsonObject;
                }
            }
            return null;
        } catch (JWTDecodeException e) {
            // ID Token解析失败，此场景常见于ID Token格式不正确
            throw new RuntimeException("ID Token decode failed");
        } catch (TokenExpiredException e) {
            // ID Token已过期
            throw new RuntimeException("ID Token expired");
        }
    }
    /**
     * 通过kid获取公钥信息，请缓存公钥信息，示例中采用map方式进行缓存，开发者可选择其它合适的方式进行缓存
     * @param keyId  keyId
     * @return 公钥信息
     * @throws InvalidPublicKeyException 异常
     */
    private RSAPublicKey getRSAPublicKeyByKid(String keyId) throws InvalidPublicKeyException {
        if (keyId2PublicKey.get(keyId) != null) {
            return keyId2PublicKey.get(keyId);
        }
        JSONArray keys = getJwks();
        if (keys == null) {
            return null;
        }
        if (keyId2PublicKey.size() > MAX_PUBLIC_KEY_SIZE) {
            keyId2PublicKey.clear();
        }
        for (int i = 0; i < keys.size(); i++) {
            String kid = keys.getJSONObject(i).getString("kid");
            String alg = keys.getJSONObject(i).getString("alg");
            if (ALG_RS256.equals(alg) || ALG_PS256.equals(alg)) {
                keyId2PublicKey.put(kid, getRsaPublicKeyByJwk(keys.getJSONObject(i)));
            }
        }
        return keyId2PublicKey.get(keyId);
    }
    /**
     * 从https://oauth-login.cloud.huawei.com/oauth2/v3/certs获取jwt公钥信息jwk
     * 因为jwk每天都会更新，所以需要缓存jwk
     * @return JSONObject 公钥信息数组
     */
    private static JSONArray getJwks() {
        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpGet httpGet = new HttpGet(CERT_URL);
        RequestConfig requestConfig = RequestConfig.custom()
            .setConnectTimeout(5000)
            .setConnectionRequestTimeout(5000)
            .setSocketTimeout(5000)
            .build();
        httpGet.setConfig(requestConfig);
        try {
            CloseableHttpResponse response = httpClient.execute(httpGet);
            HttpEntity entity = response.getEntity();
            String result = EntityUtils.toString(entity);
            return JSONObject.parseObject(result).getJSONArray("keys");
        } catch (Exception e) {
            return null;
        } finally {
            if (null != httpClient) {
                try {
                    httpClient.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
    /**
     * 通过jwk获取公钥信息
     * @return RSAPublicKey 公钥信息
     */
    private static RSAPublicKey getRsaPublicKeyByJwk(JSONObject jwkObject) throws InvalidPublicKeyException {
        Map<String, Object> additionalAttributes = new HashMap<>();
        additionalAttributes.put("n", jwkObject.getString("n"));
        additionalAttributes.put("e", jwkObject.getString("e"));
        List<String> operations = new ArrayList<>();
        Jwk jwk = new Jwk(jwkObject.getString("kid"), jwkObject.getString("kty"), jwkObject.getString("alg"),
            jwkObject.getString("use"), operations, null, null, null, additionalAttributes);
        return (RSAPublicKey) jwk.getPublicKey();
    }
    static class PS256Algorithm {
        private final RSAPublicKey publicKey;
        public PS256Algorithm(RSAPublicKey publicKey) {
            this.publicKey = publicKey;
        }
        public boolean verify(String header, String payload, String signature) throws JWTVerificationException {
            byte[] contentBytes = (header + '.' + payload).getBytes(StandardCharsets.UTF_8);
            byte[] signatureBytes = Base64.decodeBase64(signature);
            try {
                Security.addProvider(new BouncyCastleProvider());
                Signature sign = Signature.getInstance("SHA256WithRSA/PSS");
                sign.initVerify(publicKey);
                sign.update(contentBytes);
                return sign.verify(signatureBytes);
            } catch (GeneralSecurityException e) {
                throw new JWTVerificationException("JWT verify failed");
            }
        }
    }
}
// [End IdToken2]