package com.example.app;


import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.User;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.ActivityInfo;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.TextView;
import android.widget.Toast;
import android.graphics.Typeface;
import android.util.Log;
import android.app.ListActivity;
import com.mopub.mobileads.MoPubView;

import android.os.StrictMode;


public class MainActivity extends Activity {
    // Constants
    /**
     * Register your here app https://dev.twitter.com/apps/new and get your
     * consumer key and secret
     * */

    // setup logging
    private static final String TAG = Const.TAG;
    static String TWITTER_CONSUMER_KEY = Const.TWITTER_CONSUMER_KEY;
    static String TWITTER_CONSUMER_SECRET = Const.TWITTER_CONSUMER_SECRET;

    // Preference Constants

    static final String PREF_KEY_OAUTH_TOKEN = "oauth_token";
    static final String PREF_KEY_OAUTH_SECRET = "oauth_token_secret";
    static final String PREF_KEY_TWITTER_LOGIN = "boolean";
    static final String AUTH_PREFS_NAME = "MyPref";
    static final String PROFILE_PREFS_NAME = "TwitterProfile";
    static final String TWITTER_CALLBACK_URL = Const.TWITTER_CALLBACK_URL;
    static final String URL_TWITTER_OAUTH_TOKEN = "oauth_token";
    static final String URL_TWITTER_OAUTH_VERIFIER = "oauth_verifier";


    // Login button
    ImageButton btnLoginTwitter;
    // Signup button
    ImageButton btnSignUp;
    // Update status button
    Button btnUpdateStatus;
    // Logout button
    Button btnLogoutTwitter;
    // EditText for update
    EditText txtUpdate;
    // lbl update
    TextView lblUpdate;
    TextView lblUserName;

    // Progress dialog
    ProgressDialog pDialog;

    // Twitter
    private static Twitter twitter;
    private static RequestToken requestToken;

    // Shared Preferences
    private static SharedPreferences mSharedPreferences;
    // Internet Connection detector
    private ConnectionDetector cd;


    private MoPubView moPubView;
    // Alert Dialog Manager
    AlertDialogManager alert = new AlertDialogManager();

    @TargetApi(Build.VERSION_CODES.GINGERBREAD)
    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.v(TAG,"Created application");
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);


        // get paid
        moPubView = (MoPubView) findViewById(R.id.adview);
        moPubView.setAdUnitId(Const.MoPubBannerId);
        moPubView.loadAd();


        // bad method of avoiding issues with network..
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        cd = new ConnectionDetector(getApplicationContext());

        // Check if Internet present
        if (!cd.isConnectingToInternet()) {
            // Internet Connection is not present
            alert.showAlertDialog(MainActivity.this, "Internet Connection Error",
                    "Please connect to working Internet connection", false);
            // stop executing code by return
            return;
        }

        // Check if twitter keys are set
        if(TWITTER_CONSUMER_KEY.trim().length() == 0 || TWITTER_CONSUMER_SECRET.trim().length() == 0){
            // Internet Connection is not present
            alert.showAlertDialog(MainActivity.this, "Twitter oAuth tokens", "Please set your twitter oauth tokens first!", false);
            // stop executing code by return
            return;
        }

        // All UI elements
        btnLoginTwitter = (ImageButton) findViewById(R.id.btnLoginTwitter);
        btnSignUp = (ImageButton) findViewById(R.id.btnSignUp);
        btnUpdateStatus = (Button) findViewById(R.id.btnUpdateStatus);
        btnLogoutTwitter = (Button) findViewById(R.id.btnLogoutTwitter);
        txtUpdate = (EditText) findViewById(R.id.txtUpdateStatus);
        lblUpdate = (TextView) findViewById(R.id.lblUpdate);
        lblUserName = (TextView) findViewById(R.id.lblUserName);

        SharedPreferences twttr = getSharedPreferences(PROFILE_PREFS_NAME, MODE_PRIVATE);

        // Shared Preferences
        mSharedPreferences = getApplicationContext().getSharedPreferences(AUTH_PREFS_NAME, MODE_PRIVATE);
        /**
         * Twitter login button click event will call loginToTwitter() function
         * */
        btnLoginTwitter.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View arg0) {
                Log.v(TAG,"clicked on login button");
                // Call login twitter function
                loginToTwitter();
            }
        });

        /**
         * SignUp for Twitter Button
         */

        btnSignUp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View arg0) {

                Intent intent = new Intent(Intent.ACTION_VIEW,
                        Uri.parse("https://twitter.com/signup"));
                startActivity(intent);
            }
        });

        /** This if conditions is tested once is
         * redirected from twitter page. Parse the uri to get oAuth
         * Verifier
         * */
        if (!isTwitterLoggedInAlready()) {

            Uri uri = getIntent().getData();
            if (uri != null) {
                if (!isExpectedOAuthCallback(uri, requestToken)) {
                    Log.e(TAG, "Rejected invalid Twitter callback");
                    return;
                }

                Log.v(TAG, "start verification");
                // oAuth verifier
                String verifier = uri
                        .getQueryParameter(URL_TWITTER_OAUTH_VERIFIER);
                RequestToken callbackRequestToken = requestToken;
                requestToken = null;

                try {

                    // Get the access token
                    AccessToken accessToken = twitter.getOAuthAccessToken(
                            callbackRequestToken, verifier);

                    // Getting user details from twitter
                    // For now i am getting his name only
                    long userID = accessToken.getUserId();
                    User user = twitter.showUser(userID);
                    String username = user.getName();
                    String profile_pic = user.getBiggerProfileImageURL();
                    String screen_name = user.getScreenName();


                    // Shared Preferences

                    SharedPreferences.Editor editor = twttr.edit();
                    editor.putString("username", username);
                    editor.putString("profile_pic", profile_pic);
                    editor.putString("screen_name", screen_name);
                    editor.putLong("userid", userID);
                    editor.commit();


                    Editor e = mSharedPreferences.edit();

                    // After getting access token, access token secret
                    // store them in application preferences

                    e.putString(PREF_KEY_OAUTH_TOKEN, accessToken.getToken());
                    e.putString(PREF_KEY_OAUTH_SECRET,
                            accessToken.getTokenSecret());
                    // Store login status - true
                    e.putBoolean(PREF_KEY_TWITTER_LOGIN, true);
                    e.commit(); // save changes
                    // user already logged into twitter
                    Intent goToNextActivity = new Intent(getApplicationContext(), HomeActivity.class);
                    startActivity(goToNextActivity);

                } catch (Exception e) {
                    // Check log for login errors
                    Log.e(TAG, "Twitter login failed");
                }
            }
        }

    }

    /**
     * Function to login twitter
     * */
    private void loginToTwitter() {

        // Check if already logged in
        if (!isTwitterLoggedInAlready()) {
            Log.v(TAG,"Not Logged In");
            ConfigurationBuilder builder = new ConfigurationBuilder();
            builder.setOAuthConsumerKey(TWITTER_CONSUMER_KEY);
            builder.setOAuthConsumerSecret(TWITTER_CONSUMER_SECRET);
            Configuration configuration = builder.build();

            TwitterFactory factory = new TwitterFactory(configuration);
            twitter = factory.getInstance();

            try {
                Log.v(TAG, "PROCESS REQUEST");
                requestToken = twitter
                        .getOAuthRequestToken(TWITTER_CALLBACK_URL);
                this.startActivity(new Intent(Intent.ACTION_VIEW, Uri
                        .parse(requestToken.getAuthenticationURL())));
                Log.v(TAG,"Sent start activity to parse request token");


            } catch (TwitterException e) {
                Log.v(TAG,"Issue with Login");
            }
        } else {
            // user already logged into twitter
            Intent goToNextActivity = new Intent(getApplicationContext(), HomeActivity.class);
            startActivity(goToNextActivity);
        }
    }



    /**
     * Function to logout from twitter
     * It will just clear the application shared preferences
     * */
    private void logoutFromTwitter() {
        if (!clearTwitterSession(getApplicationContext())) {
            Log.e(TAG, "Failed to clear Twitter session");
            return;
        }

        // After this take the appropriate action
        // I am showing the hiding/showing buttons again
        // You might not needed this code
        btnLogoutTwitter.setVisibility(View.GONE);
        btnUpdateStatus.setVisibility(View.GONE);
        txtUpdate.setVisibility(View.GONE);
        lblUpdate.setVisibility(View.GONE);
        lblUserName.setText("");
        lblUserName.setVisibility(View.GONE);

        btnLoginTwitter.setVisibility(View.VISIBLE);
    }

    static boolean clearTwitterSession(android.content.Context context) {
        SharedPreferences profilePreferences = context.getSharedPreferences(
                PROFILE_PREFS_NAME, MODE_PRIVATE);
        SharedPreferences authPreferences = context.getSharedPreferences(
                AUTH_PREFS_NAME, MODE_PRIVATE);

        boolean profileCleared = profilePreferences.edit().clear().commit();
        boolean authCleared = authPreferences.edit().clear().commit();
        return profileCleared && authCleared;
    }

    static boolean isExpectedOAuthCallback(Uri uri, RequestToken expectedRequestToken) {
        if (uri == null || expectedRequestToken == null) {
            return false;
        }

        Uri configuredCallback = Uri.parse(TWITTER_CALLBACK_URL);
        String callbackToken = uri.getQueryParameter(URL_TWITTER_OAUTH_TOKEN);
        String verifier = uri.getQueryParameter(URL_TWITTER_OAUTH_VERIFIER);
        String expectedToken = expectedRequestToken.getToken();

        return configuredCallback.getScheme().equals(uri.getScheme())
                && configuredCallback.getAuthority().equals(uri.getAuthority())
                && configuredCallback.getEncodedPath().equals(uri.getEncodedPath())
                && expectedToken != null
                && expectedToken.equals(callbackToken)
                && verifier != null
                && verifier.trim().length() > 0;
    }

    /**
     * Check user already logged in your application using twitter Login flag is
     * fetched from Shared Preferences
     * */
    private boolean isTwitterLoggedInAlready() {
        Log.v(TAG, "isTwitter Logged In");
        // return twitter login status from Shared Preferences
        Boolean state = mSharedPreferences.getBoolean(PREF_KEY_TWITTER_LOGIN, false);
        return state;

    }

    protected void onResume() {
        super.onResume();
    }

    protected void onDestroy() {
        moPubView.destroy();
        super.onDestroy();
    }





}
