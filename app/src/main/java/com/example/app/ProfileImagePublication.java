package com.example.app;

final class ProfileImagePublication {
    private long currentRevision;

    long begin() {
        currentRevision += 1;
        return currentRevision;
    }

    void invalidate() {
        currentRevision += 1;
    }

    boolean canPublish(long revision) {
        return revision == currentRevision;
    }
}
