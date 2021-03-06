/**
* BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
*
* Copyright (c) 2008 by respective authors (see below).
*
* This program is free software; you can redistribute it and/or modify it under the
* terms of the GNU Lesser General Public License as published by the Free Software
* Foundation; either version 2.1 of the License, or (at your option) any later
* version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT ANY
* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
* PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
* 
*/
package org.bigbluebutton.util.i18n
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import mx.events.ResourceEvent;
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ResourceUtil extends EventDispatcher
	{
		private static var instance:ResourceUtil = null;
		
		private static var MSG_RESOURCE:String = 'bbbResources';
		public static var DEFAULT_LANGUAGE:String = "en_US";
		
		private var localeChain:Array = ["az_AZ", "de_DE", "el_GR", "en_US", "es_ES", "es_LA", "fr_FR", "hu_HU", "it_IT", "lt_LT", "nb_NO", "nl_NL", "pl_PL", "pt_BR", "pt_PT", "ro_RO", "ru_RU", "tr_TR", "vi_VN", "zh_CN", "zh_TW"];
		
		private var resourceManager:IResourceManager;
		
		public function ResourceUtil(enforcer:SingletonEnforcer)
		{
			if (enforcer == null) {
				throw new Error( "You Can Only Have One ResourceUtil" );
			}
			
			resourceManager = ResourceManager.getInstance();
			resourceManager.localeChain = [ExternalInterface.call("getLanguage")];
			var localeAvailable:Boolean = false;
			for (var i:Number = 0; i<localeChain.length; i++){
				if (resourceManager.localeChain[0] == localeChain[i]) localeAvailable = true;
			}
			if (!localeAvailable){
				resourceManager.localeChain = [DEFAULT_LANGUAGE];
				changeLocale([DEFAULT_LANGUAGE]);
			} else changeLocale(resourceManager.localeChain[0]);
		}
		
		public static function getInstance():ResourceUtil {
			if (instance == null) {
				instance = new ResourceUtil(new SingletonEnforcer);
			}
			return instance;
        }
        
        public function changeLocale(... chain):void{
        	
        	if(chain != null && chain.length > 0)
        	{
        		var localeURI:String = 'locale/' + chain[0] + '_resources.swf';
        		var eventDispatcher:IEventDispatcher = resourceManager.loadResourceModule(localeURI,true);
				localeChain = [chain[0]];
				eventDispatcher.addEventListener(ResourceEvent.COMPLETE, localeChangeComplete);
				eventDispatcher.addEventListener(ResourceEvent.ERROR, handleResourceNotLoaded);
        	}
        }
        
        private function localeChangeComplete(event:ResourceEvent):void{
        	resourceManager.localeChain = localeChain;
        	update();
        }
        
        /**
         * Defaults to DEFAULT_LANGUAGE when an error is thrown by the ResourceManager 
         * @param event
         */        
        private function handleResourceNotLoaded(event:ResourceEvent):void{
        	resourceManager.localeChain = [DEFAULT_LANGUAGE];
        	update();
        }
        
        public function update():void{
        	dispatchEvent(new Event(Event.CHANGE));
        }
        
        [Bindable("change")]
        public function getString(resourceName:String, parameters:Array = null, locale:String = null):String{
			return resourceManager.getString(MSG_RESOURCE, resourceName, parameters, locale);
		}
	}
}

class SingletonEnforcer{}