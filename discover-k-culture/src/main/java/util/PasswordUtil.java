package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * 회원 비밀번호 해시/검증 유틸리티.
 *
 * 새 비밀번호는 PBKDF2-HMAC-SHA256으로 저장하고,
 * 기존 DB에 평문으로 저장된 계정은 로그인 시 한 번만 평문 비교 후
 * MemberDAO에서 새 해시 형식으로 자동 갱신할 수 있도록 호환합니다.
 */
public final class PasswordUtil {

    private static final String PREFIX = "PBKDF2";
    private static final int ITERATIONS = 120_000;
    private static final int KEY_LENGTH_BITS = 256;
    private static final int SALT_LENGTH = 16;

    private PasswordUtil() {
    }

    public static String hash(String password) throws Exception {
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("비밀번호가 비어 있습니다.");
        }

        byte[] salt = new byte[SALT_LENGTH];
        new SecureRandom().nextBytes(salt);
        byte[] derived = derive(password.toCharArray(), salt, ITERATIONS);

        return PREFIX + "$" + ITERATIONS + "$"
                + Base64.getEncoder().encodeToString(salt) + "$"
                + Base64.getEncoder().encodeToString(derived);
    }

    public static boolean verify(String password, String stored) throws Exception {
        if (password == null || stored == null) {
            return false;
        }

        if (!isHashed(stored)) {
            return MessageDigest.isEqual(
                    password.getBytes(StandardCharsets.UTF_8),
                    stored.getBytes(StandardCharsets.UTF_8));
        }

        String[] parts = stored.split("\\$", 4);
        if (parts.length != 4) {
            return false;
        }

        int iterations;
        try {
            iterations = Integer.parseInt(parts[1]);
        } catch (NumberFormatException e) {
            return false;
        }

        byte[] salt;
        byte[] expected;
        try {
            salt = Base64.getDecoder().decode(parts[2]);
            expected = Base64.getDecoder().decode(parts[3]);
        } catch (IllegalArgumentException e) {
            return false;
        }

        byte[] actual = derive(password.toCharArray(), salt, iterations);
        return MessageDigest.isEqual(expected, actual);
    }

    public static boolean isHashed(String value) {
        return value != null && value.startsWith(PREFIX + "$");
    }

    private static byte[] derive(char[] password, byte[] salt, int iterations) throws Exception {
        PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, KEY_LENGTH_BITS);
        try {
            return SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
                    .generateSecret(spec)
                    .getEncoded();
        } finally {
            spec.clearPassword();
        }
    }
}
