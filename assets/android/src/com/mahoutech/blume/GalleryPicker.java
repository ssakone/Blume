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
import android.app.AlertDialog;
import android.content.DialogInterface;
import java.util.UUID;



public class GalleryPicker extends Activity {
    private static final int REQUEST_IMAGE_PICK = 1;
    private static final int REQUEST_VIDEO_PICK = 2;
    private static final int REQUEST_IMAGE_CAPTURE = 3;
    private static final int REQUEST_VIDEO_CAPTURE = 4;

    String imageFilePath;
    String videoFilePath;

    public String photoFileName = "photo.jpg";
    public String videoFileName = "video.mp4";

    public File imageFile;
    public File videoFile;

    private static native void done(String path);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String[] options = {"Choose photo in gallery", "Choose video in gallery", "Capture photo", "Capture video"};

        AlertDialog.Builder builder = new AlertDialog.Builder(this);
        builder.setTitle("Choisissez une source")
            .setItems(options, new DialogInterface.OnClickListener() {
                public void onClick(DialogInterface dialog, int which) {
                    switch (which) {
                        case 0:
                            // Choose photo from gallery
                            startActivityForResult(new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI), REQUEST_IMAGE_PICK);
                            break;
                        case 1:
                            // Choose video from gallery
                            startActivityForResult(new Intent(Intent.ACTION_PICK, MediaStore.Video.Media.EXTERNAL_CONTENT_URI), REQUEST_VIDEO_PICK);
                            break;
                        case 2:
                            // Take new photo with camera
                            Intent takePictureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
                            photoFileName = UUID.randomUUID().toString() + ".jpg";
                            imageFile = getFileUri(photoFileName, Environment.DIRECTORY_PICTURES);

                            Uri fileProvider = FileProvider.getUriForFile(GalleryPicker.this, "org.mahoutech.blume.fileprovider", imageFile);
                            takePictureIntent.putExtra(MediaStore.EXTRA_OUTPUT, fileProvider);

                            startActivityForResult(takePictureIntent, REQUEST_IMAGE_CAPTURE);

                                break;
                        case 3:
                           Intent captureVideoIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
                           videoFileName = UUID.randomUUID().toString() + ".mp4";  // Create a unique name for the video file
                           videoFile = getFileUri(videoFileName, Environment.DIRECTORY_MOVIES);  // Create a new File for the video

                           Uri videoFileProvider = FileProvider.getUriForFile(GalleryPicker.this, "org.mahoutech.blume.fileprovider", videoFile);
                           captureVideoIntent.putExtra(MediaStore.EXTRA_OUTPUT, videoFileProvider);

                           startActivityForResult(captureVideoIntent, REQUEST_VIDEO_CAPTURE);
                           break;
                    }
                }
            });
        builder.show();

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            Uri uri;
            String path = "";
            if (requestCode == REQUEST_IMAGE_PICK) {
                uri = data.getData();
                path = getPathFromURI(uri);
            } else if (requestCode == REQUEST_VIDEO_PICK) {
                uri = data.getData();
                path = getPathFromVideoURI(uri);
            } else if (requestCode == REQUEST_IMAGE_CAPTURE) {
                path = imageFile.getAbsolutePath();
            } else if (requestCode == REQUEST_VIDEO_CAPTURE) {
                path = videoFile.getAbsolutePath();
            }
            System.out.println(path);
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

    public String getPathFromVideoURI(Uri contentUri) {
        String res = null;
        String[] proj = {MediaStore.Video.Media.DATA};
        Cursor cursor = getContentResolver().query(contentUri, proj, null, null, null);
        if (cursor.moveToFirst()) {
            int column_index = cursor.getColumnIndexOrThrow(MediaStore.Video.Media.DATA);
            res = cursor.getString(column_index);
        }
        cursor.close();
        return res;
    }

    public File getFileUri(String fileName, String env) {
        File mediaStorageDir = new File(getExternalFilesDir(env), "Blume");

        if (!mediaStorageDir.exists() && !mediaStorageDir.mkdirs()){
           System.out.println("failed to create directory");
        }

        File file = new File(mediaStorageDir.getPath() + File.separator + fileName);
        System.out.println(mediaStorageDir.getPath() + File.separator + fileName);
        return file;
    }
}
