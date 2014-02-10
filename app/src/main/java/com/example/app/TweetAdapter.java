package com.example.app;

/**
 * Created by gjones on 2/9/14.
 */


import android.widget.ArrayAdapter;
import android.content.Context;
import java.util.List;
import android.view.*;
import android.widget.*;
import java.util.ArrayList;
import android.app.Activity;


public class TweetAdapter extends ArrayAdapter<Tweet>{

    Context context;
    ImageLoader imageLoader;
    int layoutResourceId;
    ArrayList<Tweet> data;

    public TweetAdapter(Activity activity, Context context, int layoutResourceId, ArrayList<Tweet> data) {
        super(context, layoutResourceId, data);
        this.layoutResourceId = layoutResourceId;
        this.context = context;
        this.data = data;
        imageLoader=new ImageLoader(activity.getApplicationContext());
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View row = convertView;
        TweetHolder holder = null;

        if(row == null)
        {
            LayoutInflater inflater = ((Activity)context).getLayoutInflater();
            row = inflater.inflate(layoutResourceId, parent, false);

            holder = new TweetHolder();
            holder.tweet = (TextView)row.findViewById(R.id.tweet);
            holder.screename = (TextView)row.findViewById(R.id.screename);
            holder.screename_thumb = (ImageView)row.findViewById(R.id.screename_thumb);
            holder.created = (TextView)row.findViewById(R.id.created);
            row.setTag(holder);
        }
        else
        {
            holder = (TweetHolder)row.getTag();
        }
        ImageView thumb_image=(ImageView)row.findViewById(R.id.screename_thumb);
        Tweet tweet = data.get(position);
        holder.tweet.setText(tweet.tweet);
        holder.screename.setText(tweet.screename);
        imageLoader.DisplayImage(tweet.screename_thumb, holder.screename_thumb);



        return row;
    }

    static class TweetHolder
    {
        TextView tweet;
        TextView screename;
        ImageView screename_thumb;
        TextView created;
    }
}