package cafe.reindeer.mobisix;

import java.io.File;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.content.Context;
import android.media.MediaScannerConnection;
import android.media.MediaScannerConnection.MediaScannerConnectionClient;
import android.net.Uri;
import android.support.v4.content.ContextCompat;
import android.support.v4.app.ActivityCompat;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

import cafe.reindeer.mobisix.SingleMediaScanner;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "mobisix/perms";
  private int pcode;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
      new MethodCallHandler(){
        @Override
        public void onMethodCall(MethodCall call, Result result){
          if (call.method.equals("getPermissions")){
            int res = ContextCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.WRITE_EXTERNAL_STORAGE);
            if (res == PackageManager.PERMISSION_GRANTED){
              result.success(1);
            } else {
              getPermissions();
              result.success(pcode);
            }
          }

          if (call.method.equals("mediaScan")){
            String filepath = call.argument("filepath");
            mediaScan(filepath);
            result.success(1);
          }
        }
      });
  }

  private void getPermissions(){
    ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE}, 111);
  }

  private void mediaScan(String filepath){
    new SingleMediaScanner(this, new File(filepath));
  }

  @Override
  public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
    switch (requestCode) {
        case 111: {
            if (grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                  pcode = 1;
            } else {
              pcode = 0;
            }
            return;
        }
    }
}
}
