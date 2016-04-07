package cn.sharesdk.ane {
	
	import flash.system.Capabilities;
	public class ShareContent
	{
		private var shareParams:Object = new Object();		
		private var customizeShareParams:Object = new Object();		
		
		/*iOS/Android*/
		public function setTitle(title:String):void 
		{
			shareParams["title"] = title;
		}
		
		/*iOS/Android*/
		public function setText(text:String):void 
		{
			shareParams["text"] = text;
		}
		
		/*iOS/Android*/
		public function setUrl(url:String):void 
		{
			shareParams["url"] = url;
		}
		
		/*iOS/Android - 本地图片路径*/
		public function setImagePath(imagePath:String):void 
		{			
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				shareParams["imagePath"] = imagePath;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				shareParams["imageUrl"] = imagePath;
			}
		}
		
		/*iOS/Android - 网络图片路径*/
		public function setImageUrl(imageUrl:String):void
		{
			shareParams["imageUrl"] = imageUrl;
		}
		
		/*iOS/Android - 分享类型*/
		public function setShareType(shareType:int):void 
		{
			//如果是android,改成1
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				if (shareType == 0)
				{
					shareType = 1;
				}
			}
			shareParams["shareType"] = shareType;
		}
		
		/*Android Only*/
		public function setTitleUrl(titleUrl:String):void 
		{
			shareParams["titleUrl"] = titleUrl;
		}
		
		/*iOS/Android*/
		public function setComment(comment:String):void 
		{
			shareParams["comment"] = comment;
		}
		
		/*Android Only*/
		public function setSite(site:String):void 
		{
			shareParams["site"] = site;
		}
		
		/*Android Only*/
		public function setSiteUrl(siteUrl:String):void 
		{
			shareParams["siteUrl"] = siteUrl;
		}
		
		/*Android Only*/
		public function setAddress(address:String):void 
		{
			shareParams["address"] = address;
		}
		
		/*iOS/Android*/
		public function setFilePath(filePath:String):void 
		{
			shareParams["filePath"] = filePath;
		}
		
		/*iOS/Android*/
		public function setMusicUrl(musicUrl:String):void 
		{
			shareParams["musicUrl"] = musicUrl;
		}
		
		/*iOS/Android - Sina/Tencent/Twitter/VKontakte*/
		public function setLatitude(latitude:String):void 
		{
			shareParams["latitude"] = latitude;
		}
		
		/*iOS/Android - Sina/Tencent/Twitter/VKontakte*/
		public function setLongitude(longitude:String):void 
		{
			shareParams["longitude"] = longitude;
		}
		
		/*iOS/Android - YouDaoNote*/
		public function setSource(source:String):void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				shareParams["url"] = source;//android
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				shareParams ["source"] = source;//ios
			}			
		}
		
		/*iOS/Android - YouDaoNote*/
		public function setAuthor(author:String):void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				//android
				shareParams["address"] = author;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				//ios
				shareParams ["author"] = author;
			}	
		}
		
		/*iOS/Android - Flickr*/
		public function setSafetyLevel(safetyLevel:int):void
		{
			shareParams ["safetyLevel"] = safetyLevel;
		}
		
		/*iOS/Android - Flickr*/
		public function setContentType(contentType:int):void
		{
			shareParams ["contentType"] = contentType;
		}
		
		/*iOS/Android - Flickr*/
		public function setHidden(hidden:int):void
		{
			shareParams ["hidden"] = hidden;
		}
		
		/*iOS/Android - Flickr*/
		public function setIsPublic(isPublic:Boolean):void
		{
			shareParams ["isPublic"] = isPublic;
		}
		
		/*iOS/Android - Flickr*/
		public function setIsFriend(isFriend:Boolean):void
		{
			shareParams ["isFriend"] = isFriend;
		}
		
		/*iOS/Android - Flickr*/
		public function setIsFamily(isFamily:Boolean):void
		{
			shareParams ["isFamily"] = isFamily;
		}
		
		/*iOS/Android - VKontakte*/
		public function setFriendsOnly(friendsOnly:Boolean):void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				//android
				shareParams["isFriend"] = friendsOnly;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				//IOS
				shareParams ["friendsOnly"] = friendsOnly;
			}	
		}
		
		/*iOS/Android - VKontakte*/
		public function setGroupID(groupID:String):void
		{
			shareParams ["groupID"] = groupID;
		}
		
		/*iOS/Android - WhatsApp*/
		public function setAudioPath(audioPath:String):void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				//android
				shareParams["filePath"] = audioPath;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				//ios
				shareParams ["audioPath"] = audioPath;
			}	
		}
		
		/*iOS/Android - WhatsApp*/
		public function setVideoPath(videoPath:String):void
		{
			if (Capabilities.manufacturer.indexOf("Android") != -1)
			{
				//android
				shareParams["filePath"] = videoPath;
			}
			else if (Capabilities.manufacturer.indexOf("iOS") != -1)
			{
				//ios
				shareParams ["videoPath"] = videoPath;
			}	
		}
		
		/*iOS/Android - YouDaoNote/YinXiang/Evernote*/
		public function setNotebook(notebook:String):void
		{
			shareParams ["notebook"] = notebook;
		}
		
		/*iOS/Android - Pocket/Flickr/YinXiang/Evernote*/
		public function setTags(tags:String):void
		{
			shareParams ["tags"] = tags;
		}
		
		/*iOS Only - Sina*/
		public function setObjectID(objectId:String):void 
		{
			shareParams["objectID"] = objectId;
		}
		
		/*iOS Only - Renren*/
		public function setAlbumID(albumId:String):void 
		{
			shareParams["AlbumID"] = albumId;
		}
		
		/*iOS Only - Wechat*/
		public function setEmotionPath(emotionPath:String):void
		{
			shareParams["emotionPath"] = emotionPath;
		}
		
		/*iOS Only - Wechat/Yixin*/
		public function setExtInfoPath(extInfoPath:String):void
		{
			shareParams["extInfoPath"] = extInfoPath;
		}
		
		/*iOS Only - Wechat*/ 
		public function setSourceFileExtension(sourceFileExtension:String):void
		{
			shareParams["sourceFileExtension"] = sourceFileExtension;
		}
		
		/*iOS Only - Wechat*/
		public function setSourceFilePath(sourceFilePath:String):void
		{
			shareParams["sourceFilePath"] = sourceFilePath;
		}
		
		/*iOS Only - QQ/Wechat/Yixin*/
		public function setThumbImageUrl(thumbImageUrl:String):void
		{
			shareParams["thumbImageUrl"] = thumbImageUrl;
		}
		
		/*iOS Only - Douban/LinkedIn*/
		public function setUrlDescription(urlDescription:String):void
		{
			shareParams["urlDescription"] = urlDescription;
		}
		
		/*iOS Only - WhatsApp/Instagram*/
		public function setMenuX(menuX:String):void
		{
			shareParams ["menuX"] = menuX;
		}
		
		/*iOS Only - WhatsApp/Instagram*/
		public function setMenuY(menuY:String):void
		{
			shareParams ["menuY"] = menuY;
		}
		
		/*iOS Only - LinkedIn*/
		public function setVisibility(visibility:String):void
		{
			shareParams ["visibility"] = visibility;
		}
		
		/*iOS Only - Tumblr*/
		public function setBlogName(blogName:String):void
		{
			shareParams ["blogName"] = blogName;
		}
		
		/*iOS Only - SMS/Mail*/
		public function setRecipients(recipients:String):void
		{
			shareParams ["recipients"] = recipients;
		}
		
		/*iOS Only - Mail*/
		public function setCCRecipients(ccRecipients:String):void
		{
			shareParams ["ccRecipients"] = ccRecipients;
		}
		
		/*iOS Only - Mail*/
		public function setBCCRecipients(bccRecipients:String):void
		{
			shareParams ["bccRecipients"] = bccRecipients;
		}
		
		/*iOS Only - Dropbox/Mail/SMS*/
		public function setAttachmentPath(attachmentPath:String):void
		{
			shareParams ["attachmentPath"] = attachmentPath;
		}
		
		/*iOS Only - Instapaper*/
		public function setDesc(desc:String):void
		{
			shareParams ["desc"] = desc;
		}
		
		/*iOS Only - Instapaper*/
		public function setIsPrivateFromSource(isPrivateFromSource:Boolean):void
		{
			shareParams ["isPrivateFromSource"] = isPrivateFromSource;
		}
		
		/*iOS Only - Instapaper*/
		public function setResolveFinalUrl(resolveFinalUrl:Boolean):void
		{
			shareParams ["resolveFinalUrl"] = resolveFinalUrl;
		}
		
		/*iOS Only - - Instapaper*/
		public function setFolderId(folderId:int):void
		{
			shareParams ["folderId"] = folderId;
		}
		
		/*iOS Only - Pocket*/
		public function setTweetID(tweetID:String):void
		{
			shareParams ["tweetID"] = tweetID;
		}
		
		/*iOS Only - Yixin*/
		public function setToUserID(toUserID:String):void
		{
			shareParams ["toUserID"] = toUserID;
		}
		
		/*iOS Only - Kakao*/
		public function setPermission(permission:String):void
		{
			shareParams ["permission"] = permission;
		}
		
		/*iOS Only - Kakao*/
		public function setEnableShare(enableShare:Boolean):void
		{
			shareParams ["enableShare"] = enableShare;
		}
		
		/*iOS Only - Kakao*/
		public function setImageWidth(imageWidth:String):void
		{
			shareParams ["imageWidth"] = imageWidth;
		}
		
		/*iOS Only - Kakao*/
		public function setImageHeight(imageHeight:String):void
		{
			shareParams ["imageHeight"] = imageHeight;
		}
		
		/*iOS Only - Kakao*/
		public function setAppButtonTitle(appButtonTitle:String):void
		{
			shareParams ["appButtonTitle"] = appButtonTitle;
		}
		
		/*iOS Only - Kakao*/
		public function setAndroidExecParam(androidExecParam:Object):void
		{
			shareParams ["androidExecParam"] = androidExecParam;
		}
		
		/*iOS Only - Kakao*/
		public function setAndroidMarkParam(androidMarkParam:String):void
		{
			shareParams ["androidMarkParam"] = androidMarkParam;
		}
		
		/*iOS Only - Kakao*/
		public function setIphoneExecParam(iphoneExecParam:Object):void
		{
			shareParams ["iphoneExecParam"] = iphoneExecParam;
		}
		
		/*iOS Only - Kakao*/
		public function setIphoneMarkParam(iphoneMarkParam:String):void
		{
			shareParams ["iphoneMarkParam"] = iphoneMarkParam;
		}
		
		/*iOS Only - Kakao*/
		public function setIpadExecParam(ipadExecParam:Object):void
		{
			shareParams ["ipadExecParam"] = ipadExecParam;
		}
		
		/*iOS Only - Kakao*/
		public function setIpadMarkParam(ipadMarkParam:String):void
		{
			shareParams ["ipadMarkParam"] = ipadMarkParam;
		}
		
		
		//不同平台分享不同内容
		public function setShareContentCustomize(platform:int, content:ShareContent):void 
		{
			customizeShareParams [platform] = content.getShareParams();
		}
		
		public function getShareParams():Object 
		{
			if (customizeShareParams != null) 
			{
				shareParams["customizeShareParams"] = customizeShareParams;
			}
			return shareParams;
		}
	}
	
}