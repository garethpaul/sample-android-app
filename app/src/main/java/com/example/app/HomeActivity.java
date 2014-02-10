package com.example.app;

import twitter4j.*;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.User;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;
import twitter4j.json.DataObjectFactory;
import twitter4j.ResponseList;

import java.util.HashMap;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.ActivityInfo;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.media.Image;
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
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.ProgressBar;
import android.widget.ListView;
import android.widget.Toast;
import android.graphics.Typeface;
import android.util.Log;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.widget.ImageView;
import android.view.Menu;
import android.view.MenuInflater;
import java.util.List;
import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.widget.ArrayAdapter;
import android.text.TextUtils;
import android.content.Context;

import com.mopub.mobileads.MoPubView;


public class HomeActivity extends Activity {

    private static String TWITTER_CONSUMER_KEY = Const.TWITTER_CONSUMER_KEY;
    private static String TWITTER_CONSUMER_SECRET = Const.TWITTER_CONSUMER_SECRET;
    private static String PREF_KEY_OAUTH_TOKEN = "";
    private static String PREF_KEY_OAUTH_SECRET = "";
    private static String PREF_KEY_TWITTER_LOGIN = "";

    // setup logging
    private static String TAG = Const.TAG;
    private static String PREFS_NAME = "TwitterProfile";
    private static String P_NAME = "MyPref";

    // Statuses
    List<Status> statuses = new ArrayList<Status>();
    final ArrayList<Tweet> tweet_holder = new ArrayList<Tweet>();

    private ImageView imageView;
    private ImageView LogOut;
    private ImageView refresh;
    private TextView loading;
    private TextView mTextView;
    private ProgressBar progress;
    private MoPubView moPubView;


    @TargetApi(Build.VERSION_CODES.GINGERBREAD)
    @Override
    public void onCreate(Bundle savedInstanceState) {
        Log.v(TAG,"Hello Homescreen");
        Log.v(TAG,"onCreate");

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_home);
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);

        // get mo money
        // get paid
        moPubView = (MoPubView) findViewById(R.id.adview);
        moPubView.setAdUnitId("9bfd238f7c7a41f686a8a6bece90890a");
        moPubView.loadAd();

        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        Log.v(TAG, settings.getAll().toString());
        // set username to text
        String username = settings.getString("username", "");
        Log.v(TAG, username);
        mTextView = (TextView) findViewById(R.id.name);
        mTextView.setText(username);

        // set profile pic
        String twitter_pic = settings.getString("profile_pic", "");
        imageView = (ImageView) findViewById(R.id.imageView);

        // Get tweets
        GetTweets tweet = new GetTweets();
        tweet.execute();

        // Show progress bar
        progress = (ProgressBar) findViewById(R.id.progressBar);
        progress.setVisibility(View.VISIBLE);

        GetXMLTask task = new GetXMLTask();
        task.execute(new String[] { twitter_pic});

        // Refresh Stream
        refresh = (ImageView) findViewById(R.id.refresh);
        refresh.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View arg0) {
                GetTweets tweet = new GetTweets();
                tweet.execute();
                loading = (TextView) findViewById(R.id.loading);
                loading.setVisibility(View.VISIBLE);
                moPubView = (MoPubView) findViewById(R.id.adview);
                moPubView.setAdUnitId(Const.MoPubMiniBannerId);
                moPubView.loadAd();
            }
        });



        // Logout
        LogOut = (ImageView) findViewById(R.id.logout);
        // Logout button
        LogOut.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View arg0) {
                logoutFromTwitter();
            }
        });
    }

    private void logoutFromTwitter() {
        Log.v(TAG, "LOGOUT Please");
        SharedPreferences prefs = getSharedPreferences(P_NAME, 0);
        SharedPreferences.Editor e = prefs.edit();
        e.remove(PREF_KEY_OAUTH_TOKEN);
        e.remove(PREF_KEY_OAUTH_SECRET);
        e.remove(PREF_KEY_TWITTER_LOGIN);
        e.clear();
        e.putBoolean(PREF_KEY_TWITTER_LOGIN, false);
        e.commit();
        Intent goToNextActivity = new Intent(getApplicationContext(), MainActivity.class);
        startActivity(goToNextActivity);

    }
    private class GetTweets extends AsyncTask<String, Void, Boolean>{


        @Override
        protected Boolean doInBackground(String... params) {
            try {
                Log.v(TAG,"Attempting to bring the tweets home");
                bringTweets();
            } catch (TwitterException e) {
                Log.v(TAG, "Issue bringing tweets back home");
                e.printStackTrace();
            }
            return null;
        }

        @Override
        protected void onPreExecute() {
            //HomeActivity.this.progress.setVisibility(View.VISIBLE);
        }

        public boolean bringTweets() throws TwitterException{
            // bring the tweets home..
            //
            // Begin getting the user
            // Log.v(TAG, "bring the tweets() called");
            // Setup the builder
            ConfigurationBuilder builder = new ConfigurationBuilder();
            builder.setOAuthConsumerKey(TWITTER_CONSUMER_KEY);
            builder.setOAuthConsumerSecret(TWITTER_CONSUMER_SECRET);
            builder.setJSONStoreEnabled(true);
            builder.setIncludeMyRetweetEnabled(false);
            builder.setIncludeRTsEnabled(false);
            // Access Token
            SharedPreferences prefs = getSharedPreferences(PREFS_NAME, 0);
            // Log.v(TAG, prefs.getAll().toString());
            String access_token = prefs.getString("token", "");
            // Log.v(TAG, access_token);
            // Access Token Secret
            String access_token_secret = prefs.getString("secret", "");
            //Log.v(TAG, access_token_secret);

            //
            // Try to retrieve some tweets.
            //Log.v(TAG, "Let's go and get some tweets");
            AccessToken accessToken = new AccessToken(access_token, access_token_secret);
            Twitter twitter = new TwitterFactory(builder.build()).getInstance(accessToken);
            Paging paging = new Paging().count(200);
            statuses = twitter.getHomeTimeline(paging);
            Log.v(TAG, "Got me some tweets");
            Log.v(TAG, statuses.toString());

            for (twitter4j.Status status : statuses) {
                // checkout Tweet.class / TweetAdapter for more info..
                tweet_holder.add(new Tweet(status.getText(), status.getUser().getScreenName(), status.getUser().getBiggerProfileImageURL(), status.getCreatedAt().toString()));
            }
            Log.v(TAG, tweet_holder.toString());
            return true;
        }

        @Override
        public void onPostExecute(Boolean r){
            // do something when done..
            //Log.v(TAG, "Tweets have come home now let's put them to bed");
            ProgressBar pb = (ProgressBar)findViewById(R.id.progressBar);
            HomeActivity.this.progress.setVisibility(View.INVISIBLE);
            loading = (TextView) findViewById(R.id.loading);
            loading.setVisibility(View.INVISIBLE);


            TweetAdapter adapter = new TweetAdapter(HomeActivity.this, HomeActivity.this,
                    R.layout.list, tweet_holder);
            ListView lv = (ListView) findViewById(R.id.listView);
            lv.setAdapter(adapter);
        }

    };
    private class GetXMLTask extends AsyncTask<String, Void, Bitmap> {
        @Override
        protected Bitmap doInBackground(String... urls) {
            Bitmap map = null;
            for (String url : urls) {
                map = downloadImage(url);
            }
            return map;
        }

        // Sets the Bitmap returned by doInBackground
        @Override
        protected void onPostExecute(Bitmap result) {
            imageView.setImageBitmap(result);
        }

        // Creates Bitmap from InputStream and returns it
        private Bitmap downloadImage(String url) {
            Bitmap bitmap = null;
            InputStream stream = null;
            BitmapFactory.Options bmOptions = new BitmapFactory.Options();
            bmOptions.inSampleSize = 1;

            try {
                stream = getHttpConnection(url);
                bitmap = BitmapFactory.
                        decodeStream(stream, null, bmOptions);
                stream.close();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
            //return bitmap;
            Bitmap output = Bitmap.createBitmap(bitmap.getWidth(),
                    bitmap.getHeight(), Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(output);

            final int color = 0xff424242;
            final Paint paint = new Paint();
            final Rect rect = new Rect(0, 0, bitmap.getWidth(), bitmap.getHeight());
            final RectF rectF = new RectF(rect);
            final float roundPx = 52;

            paint.setAntiAlias(true);
            canvas.drawARGB(0, 0, 0, 0);
            paint.setColor(color);
            canvas.drawRoundRect(rectF, roundPx, roundPx, paint);

            paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
            canvas.drawBitmap(bitmap, rect, rect, paint);
            return output;
        }

        private void getUser() {



        }


        // Makes HttpURLConnection and returns InputStream
        private InputStream getHttpConnection(String urlString)
                throws IOException {
            InputStream stream = null;
            URL url = new URL(urlString);
            URLConnection connection = url.openConnection();

            try {
                HttpURLConnection httpConnection = (HttpURLConnection) connection;
                httpConnection.setRequestMethod("GET");
                httpConnection.connect();

                if (httpConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {
                    stream = httpConnection.getInputStream();
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return stream;
        }

        private class StableArrayAdapter extends ArrayAdapter<String> {

            HashMap<String, Integer> mIdMap = new HashMap<String, Integer>();

            public StableArrayAdapter(Context context, int textViewResourceId,
                                      List<String> objects) {
                super(context, textViewResourceId, objects);
                for (int i = 0; i < objects.size(); ++i) {
                    mIdMap.put(objects.get(i), i);
                }
            }

            @Override
            public long getItemId(int position) {
                String item = getItem(position);
                return mIdMap.get(item);
            }

            @Override
            public boolean hasStableIds() {
                return true;
            }

        }


    }

}
