package com.example.app;

import java.util.List;

final class TimelinePublication<T> {
    private final List<T> displayedRows;
    private long currentRevision;

    TimelinePublication(List<T> displayedRows) {
        this.displayedRows = displayedRows;
    }

    long begin() {
        currentRevision += 1;
        return currentRevision;
    }

    void invalidate() {
        currentRevision += 1;
    }

    boolean publish(long revision, boolean successful, List<T> fetchedRows) {
        if (revision != currentRevision) {
            return false;
        }

        if (successful) {
            displayedRows.clear();
            displayedRows.addAll(fetchedRows);
        }
        return true;
    }
}
