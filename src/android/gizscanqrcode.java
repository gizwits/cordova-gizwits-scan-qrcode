package com.gizscanqrcode;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import com.gizwits.scanlibrary.zxing.activity.ScanQrcodeActivity;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class gizscanqrcode extends CordovaPlugin {
    public static final int REQUEST_CODE = 0x0ba7c0de;
	private CallbackContext callbackContext;
    private JSONArray requestArgs;
    private String [] permissions = { Manifest.permission.CAMERA };
    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("scan")) {
			//if(!hasPermisssion()) {
            //  requestPermissions(0);
            //} else {
              this.requestArgs = args;
			  this.callbackContext = callbackContext;
              this.scan(args);
           // }
            return true;
        }
        return false;
    }

	/**
     * Starts an intent to scan and decode a barcode.
     */
    public void scan(final JSONArray args) {

        final CordovaPlugin that = this;
        cordova.getThreadPool().execute(new Runnable() {
            public void run() {
                Intent intentScan = new Intent(that.cordova.getActivity().getBaseContext(), ScanQrcodeActivity.class);
                //intentScan.setAction(Intents.Scan.ACTION);
                //intentScan.addCategory(Intent.CATEGORY_DEFAULT);

                // add config as intent extras
                if (args != null && args.length() > 0) {
					
                    JSONObject obj;
                    JSONArray names;
                    String key;
                    Object value;

                    for (int i = 0; i < args.length(); i++) {

                        try {
                            obj = args.getJSONObject(i);
                        } catch (JSONException e) {
                            Log.i("CordovaLog", e.getLocalizedMessage());
                            continue;
                        }

                        names = obj.names();
                        for (int j = 0; j < names.length(); j++) {
                            try {
                                key = names.getString(j);
                                value = obj.get(key);

                                //if (value instanceof Integer) {
                                //    intentScan.putExtra(key, (Integer) value);
                                //}else if (value instanceof Float) {
                                //    intentScan.putExtra(key, (Float) value);
								//}else if (value instanceof Boolean) {
                                //    intentScan.putExtra(key, (Boolean) value);
								//}else {
									intentScan.putExtra(key, (String) value);
								//}

                            } catch (JSONException e) {
                                Log.i("CordovaLog", e.getLocalizedMessage());
                            }
                        }

                    }

                }

                // avoid calling other phonegap apps
                intentScan.setPackage(that.cordova.getActivity().getApplicationContext().getPackageName());

                that.cordova.startActivityForResult(that, intentScan, REQUEST_CODE);
            }
        });
    }

  @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
      if(callbackContext == null){
          return;
      }
        if (requestCode == REQUEST_CODE ) {
			if(intent != null){
				String code = intent.getStringExtra("SCAN_RESULT");
				if (resultCode == Activity.RESULT_OK) {
					//this.success(new PluginResult(PluginResult.Status.OK, obj), this.callback);
					this.callbackContext.success(code);
				} else {
					this.callbackContext.error(code);
				}
			}else{
				this.callbackContext.error("");
			}
        }
    }

	  /**
     * check application's permissions
     */
   public boolean hasPermisssion() {
       for(String p : permissions)
       {
           if(!PermissionHelper.hasPermission(this, p))
           {
               return false;
           }
       }
       return true;
   }

    /**
     * We override this so that we can access the permissions variable, which no longer exists in
     * the parent class, since we can't initialize it reliably in the constructor!
     *
     * @param requestCode The code to get request action
     */
   public void requestPermissions(int requestCode)
   {
       PermissionHelper.requestPermissions(this, requestCode, permissions);
   }

   /**
   * processes the result of permission request
   *
   * @param requestCode The code to get request action
   * @param permissions The collection of permissions
   * @param grantResults The result of grant
   */
  public void onRequestPermissionResult(int requestCode, String[] permissions,
                                         int[] grantResults) throws JSONException
   {
       PluginResult result;
       for (int r : grantResults) {
           if (r == PackageManager.PERMISSION_DENIED) {
               Log.d("gizscanqrcode", "Permission Denied!");
               result = new PluginResult(PluginResult.Status.ILLEGAL_ACCESS_EXCEPTION);
                if(this.callbackContext != null) {
                   this.callbackContext.sendPluginResult(result);
               }
               return;
           }
       }

       switch(requestCode)
       {
           case 0:
//               scan(this.requestArgs);
               break;
       }
   }

    /**
     * This plugin launches an external Activity when the camera is opened, so we
     * need to implement the save/restore API in case the Activity gets killed
     * by the OS while it's in the background.
     */
    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }

}
