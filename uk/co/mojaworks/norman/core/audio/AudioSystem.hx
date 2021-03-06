package uk.co.mojaworks.norman.core.audio;
import haxe.Timer;
import lime.app.Event;
import lime.Assets;
import lime.audio.AudioBuffer;
import lime.audio.AudioSource;
import motion.Actuate;
import uk.co.mojaworks.norman.core.audio.AudioInstance.AudioType;
import uk.co.mojaworks.norman.utils.LinkedList;

/**
 * ...
 * @author Simon
 */
class AudioSystem
{

	public var masterVolume( get, set ) : Float;
	public var musicVolume( get, set ) : Float;
	public var sfxVolume( get, set ) : Float;
	
	var _masterVolume : Float = 1;
	var _musicVolume : Float = 1;
	var _sfxVolume : Float = 1;
	
	var _music : AudioInstance;
	var _playingAudio : LinkedList<AudioInstance>;
	
	public function new() 
	{
		_playingAudio = new LinkedList<AudioInstance>();
	}
	
	public function playOneShotWithResourceId( id : String, volume : Float ) : Int {
		
		var instance : AudioInstance = new AudioInstance( id, volume, AudioType.SFX );
		instance.source.onComplete.add( function() {
			onSoundComplete( instance );
		});
		instance.source.play();
		_playingAudio.push( instance );
		return instance.instanceId;
		
	}
	
	public function playLoopingWithResourceId( id : String, volume : Float ) : Int {
		
		var instance : AudioInstance = new AudioInstance( id, volume, AudioType.LoopingSFX );
		instance.source.onComplete.add( function() {
			onSoundComplete( instance );
		});
		instance.source.play();
		_playingAudio.push( instance );
		return instance.instanceId;
		
	}
	
	public function playMusicWithResourceId( id : String, volume : Float, crossFadeLength : Float = 0 ) : Int {
		
		var startVolume : Float = ( crossFadeLength > 0 ) ? 0 : volume;
		var instance : AudioInstance = new AudioInstance( id, startVolume, AudioType.Music );
		
		instance.source.onComplete.add( function() {
			onSoundComplete( instance );
		});
		_playingAudio.push( instance );
		instance.source.play();
				
		if ( crossFadeLength > 0 ) {
			// Tween the volumes
			var _currentMusic : AudioInstance = _music;
					
			instance.volume = 0;
			Actuate.tween( instance, crossFadeLength, { volume: volume } );
			if ( _currentMusic != null ) {
				Actuate.tween( _music, crossFadeLength, { volume: 0 } ).onComplete( function() {
					_currentMusic.destroy();
					_playingAudio.remove( _currentMusic );
				});
			}
			
		}else {
			if ( _music != null ) {
				_music.destroy();
				_playingAudio.remove( _music );
			}
		}
		
		_music = instance;
		
		return instance.instanceId;
		
	}
	
	private function set_masterVolume( val : Float ) : Float {
		
		_masterVolume = val;
		updateSoundVolumes();
		return val;
		
	}
	
	private function set_musicVolume( val : Float ) : Float {
		
		_musicVolume = val;
		updateSoundVolumes();
		return val;
		
	}
	
	private function set_sfxVolume( val : Float ) : Float {
		
		_sfxVolume = val;
		updateSoundVolumes();
		return val;
		
	}
	
	private function get_masterVolume() : Float { return _masterVolume; };
	private function get_musicVolume() : Float { return _musicVolume; };
	private function get_sfxVolume() : Float { return _sfxVolume; };
		
	private function updateSoundVolumes() : Void 
	{
		for ( sound in _playingAudio ) 
		{
			sound.updateVolume();
		}
	}
	
	private function onSoundComplete( instance : AudioInstance ) : Void {
		
		trace("Sound complete", instance.resourceId );
		
		switch( instance.type ) {
			
			case SFX:
				instance.destroy();
				_playingAudio.remove( instance );
				
			case LoopingSFX, Music:
				instance.source.play();
				
		}
		
	}
	
	public function pauseAll() : Void {
		
		for ( sound in _playingAudio ) {
			sound.source.pause();
		}
		
	}
	
	public function resumeAll() : Void {
		
		for ( sound in _playingAudio ) {
			sound.source.play();
		}
		
	}
	
	public function stopAll() : Void {
		
		for ( sound in _playingAudio ) {
			sound.destroy();
		}
		
		_playingAudio.clear();
		
	}
	
	public function stopAllWithResourceId( resourceId : String ) : Void {
		
		for ( sound in _playingAudio ) {
			if ( sound.resourceId == resourceId ) {
				sound.destroy();
				_playingAudio.remove( sound );
			}
		}
		
	}
	
	
	/**
	 * Single instance stuff
	 */
	
	
	public function pause( id : Int ) : Void {
		
		for ( sound in _playingAudio ) {
			if ( sound.instanceId == id ) sound.source.pause();
		}
		
	}
	
	public function resume( id : Int ) : Void {
		
		for ( sound in _playingAudio ) {
			if ( sound.instanceId == id ) sound.source.play();
		}
		
	}
	
	public function stop( id : Int ) : Void {
		
		for ( sound in _playingAudio ) {
			if ( sound.instanceId == id ) {
				sound.destroy();
				_playingAudio.remove( sound );
			}
		}
	}
}