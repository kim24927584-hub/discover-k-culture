package util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class DBConnection {

    private static final String CLASSPATH_PROPERTIES = "db.properties";
    private static final Properties PROPS = loadProperties();

    private static final String DEFAULT_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/kculture_db?serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DEFAULT_USERNAME = "root";

    static {
        try {
            Class.forName(getConfig("DB_DRIVER", "db.driver", DEFAULT_DRIVER));
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        String url = getConfig("DB_URL", "db.url", DEFAULT_URL);
        String username = getConfig("DB_USERNAME", "db.username", DEFAULT_USERNAME);
        String password = getConfig("DB_PASSWORD", "db.password", "");

        return DriverManager.getConnection(url, username, password);
    }

    private static Properties loadProperties() {
        Properties properties = new Properties();

        try (InputStream in = DBConnection.class.getClassLoader()
                .getResourceAsStream(CLASSPATH_PROPERTIES)) {

            if (in != null) {
                properties.load(in);
            }

        } catch (IOException e) {
            throw new IllegalStateException("db.properties 파일을 읽는 중 오류가 발생했습니다.", e);
        }

        return properties;
    }

    private static String getConfig(String envKey, String propertyKey, String defaultValue) {
        String value = System.getenv(envKey);
        if (hasText(value)) {
            return value.trim();
        }

        value = System.getProperty(propertyKey);
        if (hasText(value)) {
            return value.trim();
        }

        value = PROPS.getProperty(propertyKey);
        if (hasText(value)) {
            return value.trim();
        }

        return defaultValue;
    }

    private static boolean hasText(String value) {
        return value != null && !value.trim().isEmpty();
    }
}
