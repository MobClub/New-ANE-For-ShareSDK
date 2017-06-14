package cn.sharesdk.ane;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import android.os.Handler.Callback;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;
import cn.sharesdk.framework.Platform;
import cn.sharesdk.framework.Platform.ShareParams;
import cn.sharesdk.framework.ShareSDK;
import cn.sharesdk.onekeyshare.OnekeyShare;
import cn.sharesdk.onekeyshare.ShareContentCustomizeCallback;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.mob.MobSDK;
import com.mob.tools.utils.Hashon;
import com.mob.tools.utils.UIHandler;

public class ShareSDKUtils extends FREContext implements FREExtension, FREFunction {
	private Hashon hashon;
	private boolean disableSSO = false; 
	private boolean DEBUG = true;

	public ShareSDKUtils() {
		super();
		hashon = new Hashon();
	}
	
	public FREContext createContext(String contextType) {
		return this;
	}

	public void initialize() {
		
	}
	
	public void dispose() {
		
	}
	
	public Map<String, FREFunction> getFunctions() {
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("ShareSDKUtils", this);
		return functionMap;
	}
	
	public FREObject call(FREContext context, FREObject[] args) {
		try {
			String json = args[0] == null ? null : args[0].getAsString();
			if (json != null) {
				HashMap<String, Object> data = hashon.fromJson(json);
				if (data != null && data.containsKey("action")) {
					String action = (String) data.get("action");
					@SuppressWarnings("unchecked")
					HashMap<String, Object> params = (HashMap<String, Object>) data.get("params");
					if (DEBUG) {
						Log.d("action ==>> ", action);
						Log.d("params ==>>", new Hashon().fromHashMap(params));
					}
					String resp = null;
					if ("initSDK".equals(action)) {
						resp = initSDK(params);
					} else if ("setPlatformConfig".equals(action)) {
						resp = setPlatformConfig(params);
					} else if ("authorize".equals(action)) {
						resp = authorize(params);
					} else if ("cancelAuthorize".equals(action)) {
						resp = removeAccount(params);
					} else if ("isAuthorized".equals(action)) {
						resp = isAuthorized(params);
					} else if ("isClientValid".equals(action)) {
						resp = isClientValid(params);
					} else if ("getUserInfo".equals(action)) {
						resp = getUserInfo(params);
					} else if ("shareContent".equals(action)) {
						resp = shareContent(params);
					} else if ("multishare".equals(action)) {
						resp = multishare(params);
					} else if ("ShowPlatformList".equals(action) || "ShowShareContentEditor".equals(action)) {
						resp = onekeyShare(params);
					} else if ("toast".equals(action)) {
						resp = toast(params);
					} else if ("getFriendList".equals(action)){
						resp = getFriendList(params);
					} else if ("addFriend".equals(action)) {
						resp = followFriend(params);
					} else if ("getAuthInfo".equals(action)) {
						resp = getAuthInfo(params);
					} else if ("disableSSO".equals(action)) {
						resp = disableSSO(params);
					}
					return resp == null ? null : FREObject.newObject(resp);
				}
			}
		} catch (Throwable t) {
			t.printStackTrace();
		}
		return null;
	}
	
	// ============================ Java Actions ============================
		
	public String disableSSO(HashMap<String, Object> params){
		boolean close  = (Boolean) params.get("close");
		disableSSO = close;
		return null;
	}
	
	/**Initialize the shareSDK and
	 * Code configuration platform of information
	 * @param params
	 * @return
	 */
	private String initSDK(HashMap<String, Object> params) {
		try {
			String appkey = (String) params.get("appKey");
			boolean enableStatistics = !"false".equals(params.get("enableStatistics"));
			MobSDK.init(getActivity(), appkey);
			if(!enableStatistics){
			  ShareSDK.disableStatistics();
			}
		} catch (Throwable t) {
			t.printStackTrace();
		}
		return null;
	}
	
	/**Initialize the shareSDK and
	 * Code configuration platform of information
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private String setPlatformConfig(HashMap<String, Object> params) {
		try {			
			final HashMap<String, Object> devInfo = (HashMap<String, Object>) params.get("config");
			UIHandler.sendEmptyMessageDelayed(1, 500, new Callback() {
				public boolean handleMessage(Message msg) {		
					for(Entry<String, Object> entry: devInfo.entrySet()){
						String p = ShareSDK.platformIdToName(Integer.parseInt(entry.getKey()));
						ShareSDK.setPlatformDevInfo(p, (HashMap<String, Object>)entry.getValue());
					}
					return true;
				}
			});			
		} catch (Throwable t) {
			t.printStackTrace();
		}
		return null;
	}
	/**
	 * To obtain authorization
	 * @param params
	 * @return
	 */
	private String authorize(HashMap<String, Object> params) {
		int reqID = (Integer) params.get("reqID");
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		platform.setPlatformActionListener(new AnePlatformActionListener(this, reqID));
		platform.SSOSetting(disableSSO);
		platform.authorize();
		return null;
	}
	/**
	 * Remove Authorization
	 * @param params
	 * @return
	 */
	private String removeAccount(HashMap<String, Object> params) {
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		platform.removeAccount(true);
		return null;
	}
	/**
	 * To judge whether a platform with authorization
	 * @param params
	 * @return
	 */
	private String isAuthorized(HashMap<String, Object> params) {
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("isAuthValid", platform.isAuthValid());
		return hashon.fromHashMap(map);
	}
	
	public String isClientValid(HashMap<String, Object> params) {
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		HashMap<String, Object> map = new HashMap<String, Object>();
		map.put("isAuthValid", platform.isClientValid());
		return hashon.fromHashMap(map);
	}
	
	/**
	 * To obtain authorization and access to information users
	 * @param params
	 * @return
	 */
	private String getUserInfo(HashMap<String, Object> params) {
		int reqID = (Integer) params.get("reqID");
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		platform.setPlatformActionListener(new AnePlatformActionListener(this, reqID));
		platform.SSOSetting(disableSSO);
		platform.showUser(null);
		return null;
	}
	/**
	 * Specify a platform for sharing, don't use onekeyshare module
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private String shareContent(HashMap<String, Object> params) {
		int reqID = (Integer) params.get("reqID");
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		AnePlatformActionListener paListener = new AnePlatformActionListener(this, reqID);
		platform.setPlatformActionListener(paListener);
		HashMap<String, Object> shareParams = (HashMap<String, Object>) params.get("shareParams");
		ShareParams sp = new ShareParams(shareParams);
		int shareType = sp.getShareType();
		if (shareType == 0) {
			shareType = 1;//ios的自动类型，改成Text
		}
		sp.setShareType(shareType);
		platform.SSOSetting(disableSSO);
		try {
			//不同平台，分享不同内容
			if (params.containsKey("customizeShareParams")) {
				final HashMap<String, Object> customizeSP = (HashMap<String, Object>) params.get("customizeShareParams");
				if (customizeSP != null && customizeSP.size() > 0) {
					String pID = String.valueOf(platformId);
					if (customizeSP.containsKey(pID)) {
						HashMap<String, Object> data = (HashMap<String, Object>) customizeSP.get(pID);
						if (data != null && data.size() > 0) {
							if (DEBUG) {
								System.out.println("share content ==>>" + new Hashon().fromHashMap(data));
							}
							for (String key : data.keySet()) {
								sp.set(key, data.get(key));
							}
						}
					}								
				}
			}				
		} catch (Throwable t) {
			paListener.onError(platform, Platform.ACTION_SHARE, t);
		}
		platform.share(sp);
		return null;
	}
	
	private String multishare(HashMap<String, Object> params) {
		int reqID = (Integer) params.get("reqID");
		@SuppressWarnings("unchecked")
		ArrayList<Integer> platforms = (ArrayList<Integer>) params.get("platforms");
		@SuppressWarnings("unchecked")
		HashMap<String, Object> shareParams = (HashMap<String, Object>) params.get("shareParams");
		ShareParams sp = new ShareParams(shareParams);
		for (Integer platformId : platforms) {
			String platformName = ShareSDK.platformIdToName(platformId.intValue());
			Platform platform = ShareSDK.getPlatform(platformName);
			platform.setPlatformActionListener(new AnePlatformActionListener(this, reqID));
			platform.SSOSetting(disableSSO);
			platform.share(sp);
		}
		return null;
	}
	/**
	 * User onekeyShare module to share.
	 * @param params
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private String onekeyShare(HashMap<String, Object> params) {
		int reqID = (Integer) params.get("reqID");
		HashMap<String, Object> map = (HashMap<String, Object>) params.get("shareParams");
		if (map != null) {
			OnekeyShare oks = new OnekeyShare();
			if (map.containsKey("title")) {
				oks.setTitle(String.valueOf(map.get("title")));
			}
			if (map.containsKey("titleUrl")) {
				oks.setTitleUrl(String.valueOf(map.get("titleUrl")));
			}
			if (map.containsKey("text")) {
				oks.setText(String.valueOf(map.get("text")));
			}
			if (map.containsKey("imagePath")) {
				oks.setImagePath(String.valueOf(map.get("imagePath")));
			}
			if (map.containsKey("imageUrl")) {
				oks.setImageUrl(String.valueOf(map.get("imageUrl")));
			}
			if (map.containsKey("comment")) {
				oks.setComment(String.valueOf(map.get("comment")));
			}
			if (map.containsKey("site")) {
				oks.setSite(String.valueOf(map.get("site")));
			}
			if (map.containsKey("url")) {
				oks.setUrl(String.valueOf(map.get("url")));
			}
			if (map.containsKey("siteUrl")) {
				oks.setSiteUrl(String.valueOf(map.get("siteUrl")));
			}
			if (map.containsKey("musicUrl")) {
				oks.setSiteUrl((String)map.get("musicUrl"));
			}
			if(disableSSO){
				oks.disableSSOWhenAuthorize();
			}
			//不同平台，分享不同内容
			if (map.containsKey("customizeShareParams")) {
				final HashMap<String, Object> customizeSP = (HashMap<String, Object>) map.get("customizeShareParams");
				if (customizeSP != null && customizeSP.size() > 0) {
					oks.setShareContentCustomizeCallback(new ShareContentCustomizeCallback() {
						public void onShare(Platform platform, ShareParams paramsToShare) {
							String platformID = String.valueOf(ShareSDK.platformNameToId(platform.getName()));
							if (customizeSP.containsKey(platformID)) {
								Hashon hashon = new Hashon();
								HashMap<String, Object> content = (HashMap<String, Object>) customizeSP.get(platformID);
								if (content != null && content.size() > 0) {
									if (DEBUG) {
										System.out.println("customizeShareParams content ==>>" + hashon.fromHashMap(content));
									}
									for (String key : content.keySet()) {
										paramsToShare.set(key, content.get(key));
									}
								}
							}
						}
					});
				}
			}
			oks.setCallback(new AnePlatformActionListener(this, reqID));
			Object platform = params.get("platform");
			if (platform != null) {
				String platformName = ShareSDK.platformIdToName((Integer)platform);
				oks.setPlatform(platformName);
			}
			oks.show(getActivity());
		}
		return null;
	}
	
	/**
	 * Show a toast
	 * @param params
	 * @return
	 */
	private String toast(HashMap<String, Object> params) {
		final String message = (String) params.get("message");
		UIHandler.sendEmptyMessage(1, new Callback() {
			public boolean handleMessage(Message msg) {
				Toast.makeText(getActivity(), message, Toast.LENGTH_SHORT).show();
				return false;
			}
		});
		return null;
	}
	
	/**
	 * To get the friends list.Support sina weibo and tencent weibo
	 * @param params
	 * @return
	 */
	private String getFriendList(HashMap<String, Object> params){
		int reqID = (Integer) params.get("reqID");
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		platform.setPlatformActionListener(new AnePlatformActionListener(this, reqID));
		platform.SSOSetting(disableSSO);
		platform.listFriend((Integer) params.get("count"), (Integer) params.get("page"), (String) params.get("account"));
		return null;		
	}
	/**
	 * Pay attention to friends.Support sina weibo and tencent weibo
	 * @param params
	 * @return
	 */
	private String followFriend(HashMap<String, Object> params){
		int reqID = (Integer) params.get("reqID");
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform platform = ShareSDK.getPlatform(platformName);
		platform.setPlatformActionListener(new AnePlatformActionListener(this, reqID));
		platform.SSOSetting(disableSSO);
		platform.followFriend((String) params.get("account"));
		return null;
		
	}
	/**
	 * Obtain authorization information
	 * @param params
	 * @return
	 */
	private String getAuthInfo(HashMap<String, Object> params){
		int platformId = (Integer) params.get("platform");
		String platformName = ShareSDK.platformIdToName(platformId);
		Platform plat = ShareSDK.getPlatform(platformName);
		HashMap<String, Object> map = new HashMap<String, Object>();
		if(plat.isClientValid()){
			map.put("expiresIn", plat.getDb().getExpiresIn());
			map.put("expiresTime", plat.getDb().getExpiresTime());
			map.put("token", plat.getDb().getToken());
			map.put("tokenSecret", plat.getDb().getTokenSecret());
			map.put("userGender", plat.getDb().getUserGender());
			map.put("userID", plat.getDb().getUserId());
			map.put("openID", plat.getDb().get("openid"));
			map.put("unionID", plat.getDb().get("unionid"));
			map.put("userName", plat.getDb().getUserName());
			map.put("userIcon", plat.getDb().getUserIcon());
		}						
		return hashon.fromHashMap(map);		
	}
	
}
