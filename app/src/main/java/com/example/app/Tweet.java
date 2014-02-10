package com.example.app;

/**
 * Created by gjones on 2/9/14.
 */


public class Tweet {
    public String screename;
    public String tweet;
    public String screename_thumb;
    public String created;
    public Tweet(){
        super();
    }

    public Tweet(String tweet, String screename, String screename_thumb, String created) {
        super();
        this.tweet = tweet;
        this.screename = screename;
        this.screename_thumb = screename_thumb;
        this.created = created;
    }
}
