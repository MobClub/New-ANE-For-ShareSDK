package cn.sharesdk.ane {
	
	/** 微信分享类型 */
	public class ShareType {			
		/**
		 *  自动适配类型，视传入的参数来决定
		 */
		public static const SSDKContentTypeAuto:int = 0;
		
		/**
		 *  文本
		 */
		public static const SSDKContentTypeText:int = 1;
		
		/**
		 *  图片
		 */
		public static const SSDKContentTypeImage:int = 2;
		
		/**
		 *  网页
		 */
		public static const SSDKContentTypeWebPage:int = 4;
		
		/**
		 *  音频
		 */
		public static const SSDKContentTypeMusic:int = 5;
		
		/**
		 *  视频
		 */
		public static const SSDKContentTypeVideo:int = 6;
		
		/**
		 *  应用
		 */
		public static const SSDKContentTypeApp:int = 7;
		
		/**
		 *  附件
		 */
		public static const SSDKContentTypeFile:int = 8;
		
		/**
		 *  表情
		 */
		public static const SSDKContentTypeEmoji:int = 9;
	}
	
}