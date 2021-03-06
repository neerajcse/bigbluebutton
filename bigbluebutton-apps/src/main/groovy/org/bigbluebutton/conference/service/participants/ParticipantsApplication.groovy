/*
 * BigBlueButton - http://www.bigbluebutton.org
 * 
 * Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.
 * 
 * BigBlueButton is free software; you can redistribute it and/or modify it under the 
 * terms of the GNU Lesser General Public License as published by the Free Software 
 * Foundation; either version 3 of the License, or (at your option) any later 
 * version. 
 * 
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along 
 * with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.
 *
 * $Id: $
 */

package org.bigbluebutton.conference.service.participants


import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.red5.logging.Red5LoggerFactory
import java.util.Mapimport org.bigbluebutton.conference.RoomsManager
import org.bigbluebutton.conference.Roomimport org.bigbluebutton.conference.Participantimport org.bigbluebutton.conference.IRoomListener
public class ParticipantsApplication {

	private static Logger log = Red5LoggerFactory.getLogger( ParticipantsApplication.class, "bigbluebutton" );	
	
	
	private static final String APP = "PARTICIPANTS";
	private RoomsManager roomsManager
	
	public boolean createRoom(String name) {
		roomsManager.addRoom(new Room(name))
		return true
	}
	
	public boolean destroyRoom(String name) {
		if (roomsManager.hasRoom(name)) {
			roomsManager.removeRoom(name)
		}
		return true
	}
	
	public boolean hasRoom(String name) {
		return roomsManager.hasRoom(name)
	}
	
	public boolean addRoomListener(String room, IRoomListener listener) {
		if (roomsManager.hasRoom(room)){
			roomsManager.addRoomListener(room, listener)
			return true
		}
		log.warn("Adding listener to a non-existant room ${room}")
		return false
	}
	
	public void setParticipantStatus(String room, Long userid, String status, Object value) {
		roomsManager.changeParticipantStatus(room, userid, status, value)
	}
	
	public Map getParticipants(String roomName) {
		log.debug("${APP}:getParticipants - ${roomName}")
		if (! roomsManager.hasRoom(roomName)) {
			log.warn("Could not find room ${roomName}")
			return null
		}

		return roomsManager.getParticipants(roomName)
	}
	
	public boolean participantLeft(String roomName, Long userid) {
		log.debug("Participant $userid leaving room $roomName")
		if (roomsManager.hasRoom(roomName)) {
			Room room = roomsManager.getRoom(roomName)
			log.debug("Removing $userid from room $roomName")
			room.removeParticipant(userid)
			return true;
		}

		return false;
	}
	
	public boolean participantJoin(String roomName, Long userid, String username, String role, String externUserID, Map status) {
		log.debug("${APP}:participant joining room ${roomName}")
		if (roomsManager.hasRoom(roomName)) {
			Participant p = new Participant(userid, username, role, externUserID, status)			
			Room room = roomsManager.getRoom(roomName)
			room.addParticipant(p)
			log.debug("${APP}:participant joined room ${roomName}")
			return true
		}
		log.debug("${APP}:participant failed to join room ${roomName}")
		return false
	}
	
	public void setRoomsManager(RoomsManager r) {
		log.debug("Setting room manager")
		roomsManager = r
	}
}
