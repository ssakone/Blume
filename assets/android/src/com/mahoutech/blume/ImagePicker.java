package com.mahoutech.blume;

import android.app.Activity;
import android.content.Intent;
import android.provider.MediaStore;
import android.os.Bundle;
import android.os.Environment;
import java.io.*;  
import java.util.Locale;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.net.*;
import android.net.Uri;
import androidx.core.content.FileProvider;
import android.graphics.Bitmap; 
import java.util.UUID;


public class ImagePicker extends Activity {
    static final int REQUEST_IMAGE_CAPTURE = 1;
    String imageFilePath;
    public String photoFileName = "photo.jpg";
    File photoFile;

    private static native void done(String path);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        photoFileName = UUID.randomUUID().toString() + ".jpg";
        photoFile = getPhotoFileUri(photoFileName);  


        Uri fileProvider = FileProvider.getUriForFile(this, "org.mahoutech.blume.fileprovider", photoFile);
        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, fileProvider);  
        
        startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
            System.out.println("finish");
            done(imageFilePath);
        }
        finish();
    }

    public File getPhotoFileUri(String fileName) {
        File mediaStorageDir = new File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "Blume");

        if (!mediaStorageDir.exists() && !mediaStorageDir.mkdirs()){
           System.out.println("failed to create directory");
        }

        File file = new File(mediaStorageDir.getPath() + File.separator + fileName);
        System.out.println(mediaStorageDir.getPath() + File.separator + fileName);
        imageFilePath = mediaStorageDir.getPath() + File.separator + fileName;
        return file;
    }
}
