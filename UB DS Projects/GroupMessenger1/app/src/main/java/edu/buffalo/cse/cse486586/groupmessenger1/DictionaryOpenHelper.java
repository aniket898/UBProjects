package edu.buffalo.cse.cse486586.groupmessenger1;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

/**
 * Created by aniket on 2/9/16.
 */
public class DictionaryOpenHelper extends SQLiteOpenHelper {
    private static final int DATABASE_VERSION = 1;
    public static final String DICTIONARY_TABLE_NAME = "dictionary";
    public static final String KEY_WORD = "key";
    public static final String VALUE_WORD = "value";
    private static final String DICTIONARY_TABLE_CREATE =
            "CREATE TABLE " + DICTIONARY_TABLE_NAME + " (" +
                    KEY_WORD + " TEXT, " +
                    VALUE_WORD + " TEXT);";
    private static final String DICTIONARY_TABLE_DROP =
            "DROP TABLE IF EXISTS " + DICTIONARY_TABLE_NAME;

    DictionaryOpenHelper(Context context) {
        super(context, DICTIONARY_TABLE_NAME, null, DATABASE_VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        Log.i("aniket","in oncreate DB");
        db.execSQL(DICTIONARY_TABLE_CREATE);
    }


    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        db.execSQL(DICTIONARY_TABLE_DROP);
        onCreate(db);

    }
}
