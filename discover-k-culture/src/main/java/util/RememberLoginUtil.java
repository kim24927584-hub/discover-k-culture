package util;

import java.nio.charset.StandardCharsets;

import java.security.MessageDigest;
import java.security.SecureRandom;

import java.util.HexFormat;


public class RememberLoginUtil {

    private static final SecureRandom RANDOM =
        new SecureRandom();


    private RememberLoginUtil() {
    }


    public static String createToken() {

        byte[] bytes =
            new byte[32];

        RANDOM.nextBytes(bytes);

        return HexFormat
            .of()
            .formatHex(bytes);
    }


    public static String sha256(
        String value
    ) {

        try {

            MessageDigest md =
                MessageDigest.getInstance(
                    "SHA-256"
                );

            byte[] hashed =
                md.digest(
                    value.getBytes(
                        StandardCharsets.UTF_8
                    )
                );

            return HexFormat
                .of()
                .formatHex(hashed);

        } catch (Exception e) {

            throw new IllegalStateException(
                e
            );
        }
    }
}
