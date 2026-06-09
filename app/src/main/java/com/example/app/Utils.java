package com.example.app;

import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class Utils {
    private static final String TAG = Utils.class.getSimpleName();

    public static boolean CopyStream(InputStream is, OutputStream os)
    {
        final int buffer_size=1024;
        try
        {
            byte[] bytes=new byte[buffer_size];
            for(;;)
            {
                int count=is.read(bytes, 0, buffer_size);
                if(count==-1)
                    break;
                os.write(bytes, 0, count);
            }
            return true;
        }
        catch(IOException ex)
        {
            Log.e(TAG, "Failed to copy stream", ex);
            return false;
        }
    }
}
