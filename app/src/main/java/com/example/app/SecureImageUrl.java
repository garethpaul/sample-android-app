package com.example.app;

import java.io.IOException;
import java.net.URL;

final class SecureImageUrl {
    private SecureImageUrl() {
    }

    static URL parse(String value) throws IOException {
        if (value == null) {
            throw new IOException("Image URL is unavailable.");
        }

        URL url = new URL(value);
        if (!"https".equalsIgnoreCase(url.getProtocol())) {
            throw new IOException("Image URL must use HTTPS.");
        }
        return url;
    }
}
