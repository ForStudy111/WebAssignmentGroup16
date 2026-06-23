package com.counseling.model;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import javax.servlet.ServletContext;

public class GoogleOAuthConfig {

    private final String clientId;
    private final String clientSecret;
    private final String redirectUri;

    private GoogleOAuthConfig(String clientId,
            String clientSecret,
            String redirectUri) {

        this.clientId = clientId;
        this.clientSecret = clientSecret;
        this.redirectUri = redirectUri;
    }

    public static GoogleOAuthConfig load(ServletContext servletContext)
            throws IOException {

        Properties properties = new Properties();

        try (InputStream input = servletContext.getResourceAsStream(
                "/WEB-INF/google-oauth.properties")) {

            if (input == null) {
                throw new IOException(
                        "google-oauth.properties was not found in WEB-INF."
                );
            }

            properties.load(input);
        }

        String clientId = properties.getProperty("client.id", "").trim();
        String clientSecret = properties.getProperty("client.secret", "").trim();
        String redirectUri = properties.getProperty("redirect.uri", "").trim();

        if (clientId.isEmpty()
                || clientSecret.isEmpty()
                || redirectUri.isEmpty()) {

            throw new IOException(
                    "Google OAuth settings are incomplete."
            );
        }

        return new GoogleOAuthConfig(
                clientId,
                clientSecret,
                redirectUri
        );
    }

    public String getClientId() {
        return clientId;
    }

    public String getClientSecret() {
        return clientSecret;
    }

    public String getRedirectUri() {
        return redirectUri;
    }
}
