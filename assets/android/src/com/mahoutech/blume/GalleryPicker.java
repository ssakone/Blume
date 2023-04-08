package com.mahoutech.blume;

import android.app.Activity;
import android.content.Intent;
import android.provider.MediaStore;
import android.os.Bundle;
import android.os.Environment;
import android.database.*;
import java.io.*;  
import java.util.Locale;
import java.util.Date;
import java.text.SimpleDateFormat;
import java.net.*;
import android.net.Uri;
import androidx.core.content.FileProvider;
import android.graphics.Bitmap; 
import android.os.*;
import java.io.*;
import android.graphics.ImageDecoder;
import java.nio.channels.*;


public class GalleryPicker extends Activity {
    static final int REQUEST_IMAGE_CAPTURE = 1;
    String imageFilePath;
    public String photoFileName = "photo.jpg";
    File photoFile;

    private static native void done(String path);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Intent takePictureIntent = new Intent(Intent.ACTION_PICK,
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI);

        photoFile = getPhotoFileUri(photoFileName);  


        Uri fileProvider = FileProvider.getUriForFile(this, "com.mahoutech.blume.fileprovider", photoFile);
        takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, fileProvider);  
        
        startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_IMAGE_CAPTURE && resultCode == RESULT_OK) {
            System.out.println("finish");
            Uri photoUri = data.getData();
            final String path = getPathFromURI(photoUri);
            System.out.println(photoUri);
            System.out.println(path);
            
            System.out.println(photoUri);
            done(path);
        }
        finish();
    }

    public String getPathFromURI(Uri contentUri) {
        String res = null;
        String[] proj = {MediaStore.Images.Media.DATA};
        Cursor cursor = getContentResolver().query(contentUri, proj, null, null, null);
        if (cursor.moveToFirst()) {
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA);
            res = cursor.getString(column_index);
        }
        cursor.close();
        return res;
    }

    public Bitmap loadFromUri(Uri photoUri) {
        Bitmap image = null;
        try {
            // check version of Android on device
            if(Build.VERSION.SDK_INT > 27){
                // on newer versions of Android, use the new decodeBitmap method
                ImageDecoder.Source source = ImageDecoder.createSource(this.getContentResolver(), photoUri);
                image = ImageDecoder.decodeBitmap(source);
            } else {
                // support older versions of Android by using getBitmap
                image = MediaStore.Images.Media.getBitmap(this.getContentResolver(), photoUri);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return image;
    }

    private void saveFile(Uri sourceUri, File destination){
        try {
            File source = new File(sourceUri.getPath());
            FileChannel src = new FileInputStream(source).getChannel();
            FileChannel dst = new FileOutputStream(destination).getChannel();
            dst.transferFrom(src, 0, src.size());
            src.close();
            dst.close();
        } catch (IOException ex) {
            ex.printStackTrace();
        }
    }
    public String getFileUri(String fileName) {
        File mediaStorageDir = new File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "Blume");

        if (!mediaStorageDir.exists() && !mediaStorageDir.mkdirs()){
           System.out.println("failed to create directory");
        }

        return mediaStorageDir.getPath() + File.separator + fileName;
    }

    public File getPhotoFileUri(String fileName) {
        File mediaStorageDir = new File(getExternalFilesDir(Environment.DIRECTORY_PICTURES), "Blume");

        if (!mediaStorageDir.exists() && !mediaStorageDir.mkdirs()){
           System.out.println("failed to create directory");
        }

        File file = new File(mediaStorageDir.getPath() + File.separator + fileName);
        System.out.println(mediaStorageDir.getPath() + File.separator + fileName);
        return file;
    }
}
