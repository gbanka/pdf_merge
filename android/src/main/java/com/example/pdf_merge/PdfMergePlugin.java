package com.example.pdf_merge;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.tom_roush.pdfbox.io.MemoryUsageSetting;
import com.tom_roush.pdfbox.multipdf.PDFMergerUtility;
import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.text.PDFTextStripper;
import com.tom_roush.pdfbox.util.PDFBoxResourceLoader;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.webkit.WebView;

/**
 * PdfMergePlugin
 */
public class PdfMergePlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;


    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "pdf_merge");
        channel.setMethodCallHandler(this);
        PDFBoxResourceLoader.init(flutterPluginBinding.getApplicationContext());
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "pdf_merge");
        channel.setMethodCallHandler(new PdfMergePlugin());
        PDFBoxResourceLoader.init(registrar.activity().getApplicationContext());

    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {


        boolean error = true;

        if (call.method.equals("PdfMerger")) {
            error = false;
            final String paths = call.argument("paths");
            String[] paths_array = paths.split(";");

            PDFMergerUtility ut = new PDFMergerUtility();

            for (String path : paths_array) {
                try {
                    ut.addSource(path);
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    Log.e("Flutter-PdfMerger", "Exception thrown while PDFMergerUtility addSource", e);
                }
            }

            String mainPath = paths_array[0] + "_main.pdf";
            final File file = new File(mainPath);


            try {
                final FileOutputStream fileOutputStream = new FileOutputStream(file);
                ut.setDestinationStream(fileOutputStream);
                ut.mergeDocuments(true);
                fileOutputStream.close();


            } catch (FileNotFoundException e) {
                e.printStackTrace();
            } catch (IOException e) {
                e.printStackTrace();
            }

            result.success(mainPath);


        }
        if (error) {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
