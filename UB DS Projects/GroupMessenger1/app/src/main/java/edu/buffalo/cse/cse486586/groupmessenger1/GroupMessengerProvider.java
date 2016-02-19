package edu.buffalo.cse.cse486586.groupmessenger1;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;
import android.util.Log;

/**
 * GroupMessengerProvider is a key-value table. Once again, please note that we do not implement
 * full support for SQL as a usual ContentProvider does. We re-purpose ContentProvider's interface
 * to use it as a key-value table.
 * 
 * Please read:
 * 
 * http://developer.android.com/guide/topics/providers/content-providers.html
 * http://developer.android.com/reference/android/content/ContentProvider.html
 * 
 * before you start to get yourself familiarized with ContentProvider.
 * 
 * There are two methods you need to implement---insert() and query(). Others are optional and
 * will not be tested.
 * 
 * @author stevko
 *
 */
public class GroupMessengerProvider extends ContentProvider {

    private DictionaryOpenHelper mDbHelper;

    @Override
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        // You do not need to implement this.
        SQLiteDatabase db = mDbHelper.getWritableDatabase();
        db.delete(DictionaryOpenHelper.DICTIONARY_TABLE_NAME, selection, selectionArgs);
        return 0;
    }

    @Override
    public String getType(Uri uri) {
        // You do not need to implement this.
        return null;
    }

    @Override
    public Uri insert(Uri uri, ContentValues values) {
        /*
         * TODO: You need to implement this method. Note that values will have two columns (a key
         * column and a value column) and one row that contains the actual (key, value) pair to be
         * inserted.
         * 
         * For actual storage, you can use any option. If you know how to use SQL, then you can use
         * SQLite. But this is not a requirement. You can use other storage options, such as the
         * internal storage option that we used in PA1. If you want to use that option, please
         * take a look at the code for PA1.
         */
        Log.i("aniket","in insert DB");
        SQLiteDatabase db = mDbHelper.getWritableDatabase();
        Log.i("aniket","in insert DB pass2");
        Log.i("aniket","values: "+values.get("key")+" ::: "+values.get("value"));
        db.insert(DictionaryOpenHelper.DICTIONARY_TABLE_NAME,null,values);
        Log.v("insert", values.toString());
        return uri;
    }

    @Override
    public boolean onCreate() {
        // If you need to perform any one-time initialization task, please do it here.
        mDbHelper = new DictionaryOpenHelper(getContext());
        return false;
    }

    @Override
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        // You do not need to implement this.
        SQLiteDatabase db = mDbHelper.getReadableDatabase();
        int count = db.update(
                DictionaryOpenHelper.DICTIONARY_TABLE_NAME,
                values,
                selection,
                selectionArgs);
        return count;
    }

    @Override
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs,
                        String sortOrder) {
        /*
         * TODO: You need to implement this method. Note that you need to return a Cursor object
         * with the right format. If the formatting is not correct, then it is not going to work.
         *
         * If you use SQLite, whatever is returned from SQLite is a Cursor object. However, you
         * still need to be careful because the formatting might still be incorrect.
         *
         * If you use a file storage option, then it is your job to build a Cursor * object. I
         * recommend building a MatrixCursor described at:
         * http://developer.android.com/reference/android/database/MatrixCursor.html
         */
        Log.i("aniket","in query DB");
        SQLiteDatabase db = mDbHelper.getReadableDatabase();
        String[] selection2 = new String[1];
        selection2[0] = selection;
        Log.i("aniket","selection argument : "+selection2[0]);
        String[] projection2 = {
                DictionaryOpenHelper.KEY_WORD,
                DictionaryOpenHelper.VALUE_WORD
        };


        Log.i("aniket","got readable database");
        Cursor c = db.query(
                DictionaryOpenHelper.DICTIONARY_TABLE_NAME,  // The table to query
                projection2,                               // The columns to return
                "key = ?",                                // The columns for the WHERE clause
                selection2,                            // The values for the WHERE clause
                null,                                     // don't group the rows
                null,                                     // don't filter by row groups
                sortOrder                                      // The sort order
        );

        Log.i("aniket", selection);
        return c;
    }
}
